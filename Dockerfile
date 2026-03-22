# =============================================================================
# (c) Clearview Geographic LLC -- All Rights Reserved | Est. 2018
# CVG GeoServer Vector — Docker Image
# Author: Alex Zelenski, GISP | azelenski@clearviewgeographic.com
# GeoServer 2.28.3 — Vector-optimized (WFS, WMS, PostGIS, Shapefile, GeoPackage)
# =============================================================================
# Build stages:
#   stage 1 (extract)  — unzips GeoServer binary + installs plugins
#   stage 2 (runtime)  — clean JRE image, copies extracted GeoServer
# This keeps the final image free of apt build-deps and zip artifacts.
# =============================================================================

# ── Stage 1: Extract GeoServer + install plugins ──────────────────────────────
FROM eclipse-temurin:17-jre-jammy AS extract

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy and extract the GeoServer standalone binary (embedded Jetty).
# NOTE: geoserver-2.28.3-bin.zip extracts FLAT (no top-level subdirectory).
#       Extract directly into the target directory using -d to avoid mv failure.
COPY geoserver-2.28.3-bin.zip ./
RUN mkdir -p geoserver \
    && unzip -q geoserver-2.28.3-bin.zip -d geoserver \
    && rm geoserver-2.28.3-bin.zip

# ── Plugin installation ───────────────────────────────────────────────────────
# Place any pre-downloaded plugin ZIPs in plugins/ directory before building.
# Required naming: geoserver-2.28.3-<name>-plugin.zip
# Recommended for vector service:
#   geoserver-2.28.3-vectortiles-plugin.zip  — OGC Vector Tiles (MapboxGL, GeoJSON)
#   geoserver-2.28.3-mbstyle-plugin.zip      — Mapbox GL style support
#   geoserver-2.28.3-css-plugin.zip          — CSS/YSLD cartographic styling
#   geoserver-2.28.3-importer-plugin.zip     — Web-based bulk data importer
#   geoserver-2.28.3-wps-plugin.zip          — OGC Web Processing Service
#   geoserver-2.28.3-ogr-wfs-plugin.zip      — OGR/GDAL WFS datastore (GPX, KML, etc.)
#
# If plugins/ directory has ZIPs they are installed here.
# Otherwise, key plugins are downloaded from SourceForge.
# =============================================================================
COPY plugins/ /build/plugins/

RUN set -e; \
    WEBINF="/build/geoserver/webapps/geoserver/WEB-INF/lib"; \
    \
    # Install any pre-supplied plugin ZIPs first
    for ZIP in /build/plugins/*.zip; do \
        [ -f "$ZIP" ] || continue; \
        echo "[plugins] Installing $(basename $ZIP)..."; \
        unzip -q -o "$ZIP" -d "$WEBINF"; \
    done; \
    \
    # Download fallback plugins if not already supplied
    # Vector plugin set:
    #   vectortiles  — OGC Vector Tiles: MapboxVectorTile (PBF), GeoJSON tiles via WMS
    #   css          — CSS cartographic styling (compact alternative to SLD)
    #   importer     — Web-based bulk data importer UI (Shapefile, CSV, GeoJSON)
    #   control-flow — Request rate limiting and concurrency control
    #   wps          — OGC Web Processing Service (vector ops: buffer, clip, dissolve, union)
    #   ysld         — YSLD compact styling language (human-readable SLD alternative)
    GS_VER="2.28.3"; \
    SF_BASE="https://sourceforge.net/projects/geoserver/files/GeoServer/${GS_VER}/extensions"; \
    for PLUGIN in vectortiles css importer control-flow wps ysld; do \
        PLUGIN_SAFE=$(echo "${PLUGIN}" | tr '-' '_'); \
        if ! ls ${WEBINF}/gs-${PLUGIN}-*.jar ${WEBINF}/gs-${PLUGIN_SAFE}-*.jar 2>/dev/null | grep -q .; then \
            echo "[plugins] Downloading ${PLUGIN} plugin..."; \
            ZIP="geoserver-${GS_VER}-${PLUGIN}-plugin.zip"; \
            wget -q --retry-connrefused --tries=3 --timeout=90 \
                 -O "/tmp/${ZIP}" \
                 "${SF_BASE}/${ZIP}/download" 2>/dev/null \
            && unzip -q -o "/tmp/${ZIP}" -d "$WEBINF" \
            && rm -f "/tmp/${ZIP}" \
            || echo "[plugins] WARNING: Could not download ${PLUGIN} — skipping"; \
        else \
            echo "[plugins] ${PLUGIN} already present — skipping download"; \
        fi; \
    done; \
    echo "[plugins] Plugin installation complete"

# ── Stage 2: Runtime image ────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-jammy AS runtime

LABEL maintainer="Alex Zelenski, GISP <azelenski@clearviewgeographic.com>"
LABEL org.opencontainers.image.title="CVG GeoServer Vector"
LABEL org.opencontainers.image.description="GeoServer 2.28.3 — Vector feature services (WFS, WMS, PostGIS, Shapefiles, GeoPackage, Vector Tiles)"
LABEL org.opencontainers.image.vendor="Clearview Geographic LLC"
LABEL org.opencontainers.image.version="2.28.3"
LABEL org.opencontainers.image.licenses="Proprietary"

# Runtime deps:
#   libgeos-dev / libproj-dev     — geometry + projection for WFS spatial ops
#   libspatialindex-dev           — R-Tree indexing for fast shapefile queries
#   tini                          — lightweight init (PID 1) for proper SIGTERM
#   fontconfig                    — WMS vector map label rendering
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        libgeos-dev \
        libproj-dev \
        libspatialindex-dev \
        ca-certificates \
        fontconfig \
        tini \
    && rm -rf /var/lib/apt/lists/*

# Copy extracted GeoServer from build stage
COPY --from=extract /build/geoserver /opt/geoserver

RUN chmod +x /opt/geoserver/bin/*.sh \
    && find /opt/geoserver -name "*.sh" -exec chmod +x {} +

# ── Environment ───────────────────────────────────────────────────────────────
ENV GEOSERVER_HOME=/opt/geoserver
ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir
ENV GEOWEBCACHE_CACHE_DIR=/opt/geowebcache_data
ENV GEOSERVER_LOG_LOCATION=/var/log/geoserver/geoserver.log

# Public URL — set at runtime via docker-compose env to match your domain.
# Ensures WFS/WMS GetCapabilities responses contain the correct public URLs.
ENV PROXY_BASE_URL=https://vector.cleargeo.tech/geoserver

# CSRF whitelist — whitelist the public domain so Caddy-proxied admin UI works
ENV GEOSERVER_CSRF_WHITELIST=vector.cleargeo.tech

# Vector-optimized JVM settings:
#   UseContainerSupport          — respect Docker --memory limits for heap sizing
#   MaxRAMPercentage=70.0        — 70% of container memory (lower than raster;
#                                   WFS feature streaming is less memory-hungry)
#   InitialRAMPercentage=20.0    — start lean, grow on demand
#   XX:+UseG1GC                  — low-pause GC for concurrent WFS requests
#   MaxGCPauseMillis=100         — tighter pause target for WFS GetFeature latency
#   -Djava.security.egd          — faster entropy source
#   forceXY=true                 — ensure consistent x,y axis order for WFS clients
# Vector-optimized JVM — performance additions vs. baseline:
#   ParallelRefProcEnabled      — parallelise reference processing = shorter GC pauses
#   UseStringDeduplication      — deduplicate GML/GeoJSON attribute name strings (high gain
#                                  for WFS with many features sharing the same field names)
#   G1HeapRegionSize=4m         — smaller regions suit many small WFS feature objects
#   shapefile.dbf.useMmap=true  — memory-mapped shapefile DBF reads (avoids copy overhead)
#   maxFormContentSize=20MB     — Jetty ceiling for WFS-T Transaction POST bodies
ENV JAVA_OPTS="-server \
    -XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=70.0 \
    -XX:InitialRAMPercentage=20.0 \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=100 \
    -XX:G1HeapRegionSize=4m \
    -XX:+ParallelRefProcEnabled \
    -XX:+UseStringDeduplication \
    -XX:+ExplicitGCInvokesConcurrent \
    -Djava.awt.headless=true \
    -Djava.security.egd=file:/dev/./urandom \
    -Dfile.encoding=UTF-8 \
    -Djavax.servlet.request.encoding=UTF-8 \
    -Djavax.servlet.response.encoding=UTF-8 \
    -DALLOW_ENV_PARAMETRIZATION=true \
    -Dorg.geoserver.htmlui.timeout=60 \
    -Dorg.geotools.shapefile.dbf.useMmap=true \
    -Dorg.eclipse.jetty.server.Request.maxFormContentSize=20971520 \
    -Dorg.geotools.referencing.forceXY=true \
    -XX:+AlwaysPreTouch \
    -XX:+PerfDisableSharedMem \
    -Dlog4j2.formatMsgNoLookups=true \
    -Dnetworkaddress.cache.ttl=60 \
    -Dorg.geotools.jdbc.DBCPStatements=true"

# Create log dirs, GWC cache dir, and non-root service user
RUN useradd -m -u 1001 -s /bin/bash geoserver \
    && mkdir -p /var/log/geoserver /opt/geowebcache_data \
    && chown -R geoserver:geoserver /opt/geoserver /var/log/geoserver /opt/geowebcache_data

USER geoserver

# Volumes:
#   data_dir           — GeoServer workspaces, stores, styles, layer config (MUST persist)
#   geowebcache_data   — GeoWebCache tile cache (optional external volume)
VOLUME ["/opt/geoserver/data_dir", "/opt/geowebcache_data"]

EXPOSE 8080

# GeoServer takes 60–120s to start on first run (data_dir init + plugin scan).
# Use /geoserver/ows (no params) — returns a tiny dispatcher page in <100ms.
# Avoids fetching the large WFS GetCapabilities XML (~200KB) on every 30s probe.
# docker-compose.prod.yml overrides this at runtime with the same lightweight probe.
HEALTHCHECK --interval=30s --timeout=15s --start-period=120s --retries=5 \
    CMD curl -fsS -o /dev/null "http://localhost:8080/geoserver/ows" || exit 1

# tini as PID 1 ensures GeoServer's JVM receives SIGTERM cleanly on docker stop
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/opt/geoserver/bin/startup.sh"]
