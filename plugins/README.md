# CVG GeoServer Vector — Plugin Installation

**(c) Clearview Geographic LLC — All Rights Reserved**

Place GeoServer 2.28.3 extension ZIP files in this directory before running `docker compose build`.
The Dockerfile will automatically extract all `*.zip` files into `WEB-INF/lib` at build time.

---

## How It Works

```dockerfile
# From Dockerfile (Stage 1 — extract):
COPY plugins/ /build/plugins/

RUN for ZIP in /build/plugins/*.zip; do
        unzip -q -o "$ZIP" -d "$WEBINF"
    done
```

If a plugin ZIP is not present here, the Dockerfile attempts to download it from SourceForge.
Currently auto-downloaded: `vectortiles`, `css`, `importer`.

---

## Recommended Plugins for Vector Service

Download from: `https://sourceforge.net/projects/geoserver/files/GeoServer/2.28.3/extensions/`

| Plugin ZIP | Purpose | Priority |
|-----------|---------|----------|
| `geoserver-2.28.3-vectortiles-plugin.zip` | OGC Vector Tiles (MapboxGL MVT, GeoJSON tiles, TopoJSON) — auto-downloaded | **HIGH** |
| `geoserver-2.28.3-css-plugin.zip` | CSS/YSLD cartographic styling — auto-downloaded | HIGH |
| `geoserver-2.28.3-importer-plugin.zip` | Web-based bulk shapefile/GeoPackage importer — auto-downloaded | HIGH |
| `geoserver-2.28.3-mbstyle-plugin.zip` | Mapbox GL style support for vector tile rendering | MEDIUM |
| `geoserver-2.28.3-wps-plugin.zip` | OGC Web Processing Service (buffer, dissolve, intersection) | MEDIUM |
| `geoserver-2.28.3-ogr-wfs-plugin.zip` | OGR/GDAL WFS datastore: GPX, KML, GML, FlatGeobuf | LOW |
| `geoserver-2.28.3-geofence-plugin.zip` | Per-layer security rules (row-level & attribute filtering) | LOW |

---

## Vector Tiles Notes

The `vectortiles` plugin (auto-downloaded from SourceForge if not supplied) enables:
- `application/vnd.mapbox-vector-tile` (MVT/PBF) output format from WMS
- GeoJSON tiles and TopoJSON tiles
- Works with MapboxGL JS, MapLibre, Deck.gl, and QGIS Vector Tile layers

After installing, add the tileset format to each published WMS layer via:
`GeoServer admin → Tile Caching → Layer → Vector Tiles → Enable`

---

## PostGIS Notes

PostGIS datastore is built into GeoServer core — **no plugin needed**.
Configure via GeoServer admin UI:
```
Stores → Add new Store → PostGIS
  Host:     <pgdb hostname or IP>
  Port:     5432
  Database: cvg_spatial
  Schema:   public
  User:     geoserver_ro    ← read-only service account
  Password: <from secrets>
```

---

## Naming Convention

Plugin ZIPs must match the pattern:
```
geoserver-2.28.3-<name>-plugin.zip
```

---

## Build & Verify

```bash
# Place ZIP(s) in this directory, then rebuild:
docker compose build --no-cache

# Verify plugin loaded:
docker exec geoserver-vector-dev \
    ls /opt/geoserver/webapps/geoserver/WEB-INF/lib/ | grep gs-vectortiles

# Check GeoServer web UI:
#   http://localhost:8080/geoserver/web/
#   → Server → About & Status → Modules
```

---

*This directory is excluded from Docker build context (via `.dockerignore`) except for `*.zip` files.*
