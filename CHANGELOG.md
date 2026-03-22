# CVG GeoServer Vector — Changelog

All notable changes to this project will be documented in this file.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) | CVG Standard: `Z:\9999\Cline_Global_Rules\Change Log Requirements.md`

---

## [Unreleased]

### Added (portal improvements — 2026-03-22)

#### caddy/portal/index.html — Major public-facing tool additions
- **Leaflet interactive map** (`vector-map`) — live WMS layer preview centred on US East/Gulf Coast; click feature to query attributes via WMS GetFeatureInfo (JSON); real-time lat/lon display; scale bar
- **Basemap switcher** — OpenStreetMap, CartoDB Dark, ESRI Satellite, OpenTopoMap
- **Opacity slider** — adjustable WMS layer transparency in real time
- **Auto layer browser** — JavaScript fetches WFS GetCapabilities on load, parses `<FeatureType>` nodes, renders cards with per-layer buttons: **WMS Map** (preview), **GeoJSON** (direct 100-feature download link), **OGC API** (collections items link), **Schema** (triggers DescribeFeatureType)
- **Layer filter** — instant-search across feature type name and title
- **WFS GetFeature Query Builder** — form fields: typeNames, max features, output format (GeoJSON/GML/CSV/Shapefile), CRS, CQL filter expression, optional spatial BBox; "Use Map View" syncs bbox; generates full GetFeature URL plus curl/Python snippets; **Preview on Map** button renders GeoJSON result as green Leaflet layer with automatic zoom-to-fit
- **DescribeFeatureType schema inspector** — enter any feature type name; fetches WFS JSON schema; renders attribute table (field name, type, nillable); auto-linked from layer cards; direct XML link
- **Feature attribute panel** — below map; displays all properties of clicked feature in key/value table
- **OGC API Features** quick access — curated curl/Python/Leaflet examples with live "Browse Collections" links
- **Copy-to-clipboard buttons** on all endpoint `<code>` blocks and `<pre>` code snippets
- **"Try in Browser"** links on WFS, WMS, OGC API endpoint cards
- **Public access notice** banner and `meta description` / `robots: index,follow`

---

## [1.1.0] — 2026-03-22

### ChangeID: `20260322-AZ-v1.1.0`

**HTTPS routing fixes verified, operational scripts formally tracked, and cross-VM status script added.**

### Added

#### Root scripts — Cross-VM convenience tools
- **`_check_status.bat`** + **`_check_status.sh`** — SSH-based status check for both VM 454 (Raster) and VM 455 (Vector); checks Docker container status + internal WFS/WMS/Web UI health via `docker exec` curl; Caddy :80 check

#### scripts/ — Operational scripts formally tracked (present since v1.0.0, now version-manifest registered)
- **`scripts/geoserver-init.sh`** — First-run init via REST API; sets admin password, proxy URL, removes demo workspaces, creates `cvg` workspace; idempotent sentinel
- **`scripts/health-check.sh`** — Comprehensive health check (`--local`, `--prod`, `--ip` modes); containers, portal, WFS + WMS + WMTS + GWC; REST LAN restriction; TLS cert expiry; exit code 1 on failure
- **`scripts/backup.sh`** — `geoserver-vector-data` volume backup; timestamped tarballs; `--dest`, `--keep` flags; integrity verify; manifest; cron example for VM 455
- **`scripts/reset-password.sh`** — Admin password reset via REST API; reads `.env`; auto-detect local/prod; verifies old + new password

### Fixed

#### HTTPS Routing — Full End-to-End Production Verification (Sessions 10/11 — 2026-03-21)
- **VM451 proxy target corrected**: `cvg-caddy` was forwarding `vector.cleargeo.tech` directly to `cvg-geoserver-vector:8080`, bypassing `caddy-gsv` entirely — corrected to `http://10.10.10.204:80`
- **VM451 `health_uri` removed**: `health_uri /status` probes sent `Host: 10.10.10.204`, causing `caddy-gsv` to return 308 redirect → Caddy marked upstream unhealthy → cascading 503s; removed
- **`handle /status` placement**: moved before bare `reverse_proxy` catch-all in both HTTP and HTTPS blocks; Caddy catch-all behaviour requires ordered routing

### Verified (Production — 2026-03-21)

| Endpoint | Result |
|---|---|
| `curl https://vector.cleargeo.tech/status` | `"OK"` HTTP 200 |
| `curl https://vector.cleargeo.tech/geoserver/ows?service=WFS&...GetCapabilities` | WFS_Capabilities XML HTTP 200 (CVG feature types) |
| `curl https://raster.cleargeo.tech/status` | `"OK"` HTTP 200 |
| `curl https://raster.cleargeo.tech/geoserver/ows?service=WMS&...GetCapabilities` | WMS_Capabilities XML HTTP 200 |

### Infrastructure (unchanged from v1.0.0)

| Item | Value |
|------|-------|
| VM | 455 — `cvg-geoserver-vector-01` @ 10.10.10.204 |
| Public URL | https://vector.cleargeo.tech |
| GeoServer | 2.28.3 (standalone Jetty) |
| Java | 17 JRE (`eclipse-temurin:17-jre-jammy`) |
| JVM heap | 4.2 GB (70% of 6 GB mem_limit) |

---

## [1.0.0] — 2026-03-21

### ChangeID: `20260321-AZ-v1.0.0`

**Initial release — production-ready GeoServer 2.28.3 vector feature service with full Docker infrastructure.**

### Added

#### Dockerfile
- Multi-stage build: `extract` (unzip + plugins) → `runtime` (clean JRE)
  - Stage 1: minimal `curl`, `unzip`, `wget` — no apt packages in runtime layer
- **Plugin installation system** — `plugins/` directory; ZIPs installed at build time
  - Pre-supplied ZIPs: `plugins/*.zip` → `WEB-INF/lib`
  - Fallback: downloads `vectortiles`, `css`, `importer` from SourceForge
  - Vector plugin recommendations documented: vectortiles, mbstyle, css, importer, wps, ogr-wfs
- **`tini` as PID 1** — `ENTRYPOINT ["/usr/bin/tini", "--"]` — clean SIGTERM to JVM on `docker stop`
- **Container-aware JVM tuning:**
  - `UseContainerSupport` — respects Docker `mem_limit`
  - `MaxRAMPercentage=70.0` — 70% of container memory (4.2 GB at 6 GB limit)
  - `InitialRAMPercentage=20.0` — lean startup
  - `MaxGCPauseMillis=100` — tighter pause target for WFS GetFeature latency
  - `ExplicitGCInvokesConcurrent` — concurrent GC invocation
  - `java.security.egd=file:/dev/./urandom` — fast entropy in container
- **`PROXY_BASE_URL`** env var — correct WFS/WMS GetCapabilities public URLs through Caddy
- **`GEOSERVER_CSRF_WHITELIST=vector.cleargeo.tech`** — CSRF protection for proxied admin UI
- **`GEOWEBCACHE_CACHE_DIR`** env pointing to separate `/opt/geowebcache_data` volume
- WFS GetCapabilities healthcheck (`GET /geoserver/ows?service=wfs&version=2.0.0&request=GetCapabilities`)
- No GDAL overhead — vector stack uses `libgeos-dev`, `libproj-dev`, `libspatialindex-dev` only
- Non-root `geoserver` user (UID 1001)
- OCI labels: maintainer, title, description, vendor, version, licenses

#### docker-compose.prod.yml
- Hard resource limits: `mem_limit: 6g`, `memswap_limit: 6g`, `cpus: "3.0"`
- `ulimits.nofile: 32768` — WFS streaming opens many FDs for large feature datasets
- `stop_grace_period: 45s` — allows in-flight WFS requests to complete
- `depends_on: condition: service_healthy` — Caddy waits for healthy GeoServer
- Separate `geoserver-gwc` named volume for GeoWebCache tile store
- `/var/log/geoserver` bind mount (host-side log retention)
- JSON logging with `max-size: 100m`, `max-file: 5`
- Named networks: `cvg-gsv-web` + `cvg-gsv-internal`
- Caddy: `mem_limit: 256m`; Watchtower: `mem_limit: 64m`
- Dual routing comments: dedicated VM455 or via VM451 Caddy

#### docker-compose.yml (dev)
- Uses `cvg/geoserver-vector:dev` image tag (separate from prod `latest`)
- `PROXY_BASE_URL=http://localhost:8080/geoserver`
- `GEOSERVER_CSRF_WHITELIST=localhost`
- Separate dev named volumes: `geoserver-vector-data-dev`, `geoserver-vector-gwc-dev`

#### caddy/Caddyfile
- Auto-HTTPS via Let's Encrypt
- Reverse proxy to `geoserver-vector:8080`
- 300s read/write timeouts for large WFS GetFeature responses
- Security headers (X-Frame-Options, HSTS, X-Content-Type-Options, Referrer-Policy)
- CORS for GIS clients (QGIS, ArcGIS, Leaflet, OpenLayers)
- Structured JSON access log, 14-day rotation
- gzip + zstd compression
- `limits { max_body 50mb }` for WFS GetFeature/Transaction requests
- *(TODO v1.0.0)* `handle_errors` block with 502/503/504 maintenance HTML — not yet added; tracked in ROADMAP v1.0.0

#### deploy_production.sh
- Creates VM 455 on Proxmox via PVE REST API + cloud-init (Ubuntu 22.04)
  - 16 GB RAM, 4 vCPU, 60 GB disk (PE-Enclosure1 ZFS pool)
- VM bootstrap: Docker CE, cifs-utils, directory layout
- TrueNAS CGPS + CGDP CIFS mounts + fstab persistence
- rsync project files + docker compose build + launch + 90s wait
- Health checks

#### Project files
- `.dockerignore`, `.gitignore`
- `plugins/` — plugin ZIP staging directory with README
- `README.md` — endpoints, data stores, PostGIS config, infrastructure, security
- `CHANGELOG.md` — this file
- `ROADMAP.md` — versioned roadmap v1.0.0 → v2.0.0
- `05_ChangeLogs/version_manifest.yml` + `05_ChangeLogs/master_changelog.md`

### Infrastructure

| Item | Value |
|------|-------|
| VM | 455 — `cvg-geoserver-vector-01` @ 10.10.10.204 |
| Public URL | https://vector.cleargeo.tech |
| GeoServer | 2.28.3 (standalone Jetty) |
| Java | 17 JRE (`eclipse-temurin:17-jre-jammy`) |
| Caddy | 2-alpine |
| Docker Compose | v2 (plugin) |
| JVM heap | 4.2 GB (70% of 6 GB mem_limit) |

---

[Unreleased]: https://git.cvg.internal/clearview-geographic/cvg-geoserver-vector/compare/v1.1.0...HEAD
[1.1.0]: https://git.cvg.internal/clearview-geographic/cvg-geoserver-vector/compare/v1.0.0...v1.1.0
[1.0.0]: https://git.cvg.internal/clearview-geographic/cvg-geoserver-vector/releases/tag/v1.0.0
