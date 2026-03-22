<!--
  © Clearview Geographic LLC -- All Rights Reserved | Est. 2018
  CVG GeoServer Vector — ROADMAP
  Author: Alex Zelenski, GISP | azelenski@clearviewgeographic.com
-->

# CVG GeoServer Vector — Development Roadmap

> Version: v1.1.0 | Author: Alex Zelenski, GISP
> Last updated: 2026-03-22 (Session 12 — Portal enhancements live; v0.3.0 complete)
> Production URL: **https://vector.cleargeo.tech** | VM 455 · 10.10.10.204 · 131.148.52.225

---

---

## 🔴 TOP PRIORITY — Backload Campaign (Z:\ 2018–2026)

> **This is the #1 active priority for both GeoServer platforms.**
> All previously collected project-specific data in the Z:\ archive directories must be inventoried, categorized, processed to GeoPackage, and published before any new wizard-generated data is onboarded.
> **Full plan → [`BACKLOAD_PRIORITY.md`](BACKLOAD_PRIORITY.md)**

| Priority | Directory | Status |
|----------|-----------|--------|
| 🔴 P1 — CRITICAL | `Z:\2026` · `Z:\2025` | 🔴 Inventory pending |
| 🟠 P2 — HIGH | `Z:\2024` · `Z:\2023` | 🔴 Inventory pending |
| 🟡 P3 — MEDIUM | `Z:\2022` · `Z:\2021` | 🔴 Inventory pending |
| 🟢 P4 — STANDARD | `Z:\2020` · `Z:\2019` | 🔴 Inventory pending |
| 🔵 P5 — ARCHIVE | `Z:\2018` | 🔴 Inventory pending |

**Immediate backload actions:**
1. **[ ] Run `scripts/backload_inventory.sh 2026`** → generate vector file list for `Z:\2026`
2. **[ ] Classify data types** → `surge_extent` / `slr_extent` / `basin` / `hwm` / `aoi` / `boundary` / `fema`
3. **[ ] Copy source files to NAS** → `//10.10.10.100/cgps/backload/2026/{project}/`
4. **[ ] GPKG-convert all vectors** → `ogr2ogr -f GPKG -t_srs EPSG:4326`
5. **[ ] Run `geoserver-init.sh`** → creates `cvg` workspace (prerequisite for all publishing)
6. **[ ] Publish via REST API** → see `BACKLOAD_PRIORITY.md` Phase 4 for curl commands
7. **[ ] Repeat for 2025 → 2024 → … → 2018**

---

## ⚡ Next Steps — Immediate Actions (v0.4.0 Prerequisites)

> These must be done **directly on VM 455** before any data can be served via WFS/WMS.

1. **`bash scripts/geoserver-init.sh --prod`** — sets admin password, configures `PROXY_BASE_URL`, removes demo workspaces, creates `cvg` workspace
2. **Add `GEOSERVER_ADMIN_PASSWORD` to `.env`** on VM 455 → `/opt/cvg/CVG_Geoserver_Vector/.env`
3. **Verify `PROXY_BASE_URL`** in WFS GetCapabilities: `curl -s "https://vector.cleargeo.tech/geoserver/ows?service=WFS&version=2.0.0&request=GetCapabilities" | grep -i OnlineResource`
4. **Mount-verify CIFS**: `docker exec geoserver-vector ogrinfo /mnt/cgps/ --formats` — confirm CGPS/CGDP readable
5. **Configure PostGIS datastore** (if DB available): GeoServer web UI → Stores → New → PostGIS

---

## Current Live Status

| Endpoint | URL | Status |
|----------|-----|--------|
| Portal | https://vector.cleargeo.tech | ✅ Live — branded landing page |
| WFS | https://vector.cleargeo.tech/geoserver/wfs | ✅ Live — GetCapabilities verified |
| WMS | https://vector.cleargeo.tech/geoserver/wms | ✅ Live |
| WMTS | https://vector.cleargeo.tech/geoserver/gwc/service/wmts | ✅ Live |
| OGC API | https://vector.cleargeo.tech/geoserver/ogc/features/v1 | ✅ Route active |
| Admin UI | https://vector.cleargeo.tech/geoserver/web | 🔒 LAN-only (10.10.10.0/24) |
| REST API | https://vector.cleargeo.tech/geoserver/rest | 🔒 LAN-only |
| Status | https://vector.cleargeo.tech/status | ✅ Returns "OK" |

> ⚠️ No CVG layers published yet — `cvg` workspace created but empty. See Next Steps above.

---

## Platform Summary

| Component | Detail |
|---|---|
| GeoServer | 2.28.3 (standalone Jetty, eclipse-temurin:17-jre-jammy) |
| Vector libraries | libgeos, libproj, libspatialindex (APT, Jammy) |
| JVM heap | Container-aware: `MaxRAMPercentage=70.0` (approx 4.2 GB at 6 GB `mem_limit`) |
| GC | G1GC, `MaxGCPauseMillis=100` (tighter for WFS latency), `ExplicitGCInvokesConcurrent` |
| PID 1 | `tini` — clean SIGTERM delivery to JVM on `docker stop` |
| Reverse proxy | Caddy 2-alpine (TLS via Let's Encrypt HTTP-01, HTTP/3 UDP, admin UI LAN-only) |
| Updates | Watchtower (daily pull, `WATCHTOWER_POLL_INTERVAL=86400`) |
| NAS mounts | `/mnt/cgps` (CGPS share, read-only) · `/mnt/cgdp` (processed data, read-only) |
| Networks | `cvg-gsv-web` (bridge, public) · `cvg-gsv-internal` (bridge, internal) |
| DNS | `vector.cleargeo.tech -> 131.148.52.225` |

---

## CVG Platform Integration Map

```
                  +----------------------------+
                  |   TrueNAS NAS              |
                  |   /mnt/cgps  (raw vectors) |
                  |   /mnt/cgdp  (processed)   |
                  +----------+-----------------+
                             | :ro bind mounts
        +--------------------v------------------------------------------+
        |  VM 455  cvg-geoserver-vector-01  10.10.10.204                |
        |  +------------------+   +------------------------------+       |
        |  |  geoserver-vector|   |  caddy-gsv (TLS termination) |       |
        |  |  :8080 (Jetty)   |<--|  :80, :443, :443/udp (H3)   |       |
        |  +------------------+   +------------------------------+       |
        +------------------------------------------------------------------+
                             |
        WFS / WMS vector endpoints consumed by:
         +-- SSW   flood extent polygons + HWM point features
         +-- SLR   SLR scenario shoreline/boundary vectors
         +-- Rainfall  drainage basins, catchments, SSURGO HSG boundaries
         +-- Public  portal layer browser, GetFeatureInfo, OGC API Features
```

---

## [DONE] v0.1.0 — Infrastructure Scaffolding (2026-03-21)

- [x] `Dockerfile`: multi-stage build (`extract` -> `runtime`) — clean JRE image
- [x] `plugins/` staging directory — auto-installs `vectortiles`, `css`, `importer`; fallback SourceForge downloads
- [x] `tini` as PID 1 — `ENTRYPOINT ["/usr/bin/tini", "--"]` — clean SIGTERM to JVM
- [x] Container-aware JVM: `UseContainerSupport`, `MaxRAMPercentage=70.0`, `InitialRAMPercentage=20.0`, `MaxGCPauseMillis=100`
- [x] `java.security.egd=file:/dev/./urandom` — fast entropy
- [x] Vector-only stack: `libgeos-dev`, `libproj-dev`, `libspatialindex-dev` — no GDAL overhead
- [x] `PROXY_BASE_URL=https://vector.cleargeo.tech/geoserver` — correct GetCapabilities URLs
- [x] `GEOSERVER_CSRF_WHITELIST=vector.cleargeo.tech` — admin UI CSRF protection
- [x] `GEOWEBCACHE_CACHE_DIR=/opt/geowebcache_data` — separate named volume
- [x] WFS GetCapabilities healthcheck (`?service=wfs&version=2.0.0&request=GetCapabilities`)
- [x] Non-root `geoserver` user (UID 1001)
- [x] `docker-compose.yml`: local dev stack (`:8080` exposed, dev image tag, localhost CSRF/PROXY)
- [x] `docker-compose.prod.yml`: `mem_limit: 6g`, `cpus: "3.0"`, `ulimits.nofile: 32768`, `stop_grace_period: 45s`
- [x] `docker-compose.prod.yml`: `depends_on: service_healthy`; separate `geoserver-gwc` volume; JSON logs; named networks
- [x] `deploy_production.sh`: `--redeploy`, `--no-cache`, `--target vm451` flags
- [x] `.dockerignore`, `plugins/README.md`, `README.md`, `CHANGELOG.md`, `.gitignore`
- [x] `05_ChangeLogs/version_manifest.yml` + `05_ChangeLogs/master_changelog.md`
- [x] `scripts/geoserver-init.sh`, `scripts/health-check.sh`, `scripts/backup.sh`, `scripts/reset-password.sh`

## [DONE] v0.2.0 — Caddyfile Complete (2026-03-21)

- [x] `caddy/Caddyfile` for `vector.cleargeo.tech -> geoserver-vector:8080`
- [x] Admin UI (`/geoserver/web/*`) restricted to LAN `10.10.10.0/24` — 403 for public requests
- [x] `flush_interval -1` — WFS GeoJSON/GML feature responses streamed immediately (no buffering)
- [x] `response_header_timeout 60s` (WFS PostGIS query) + `read/write_timeout 300s` (large result sets)
- [x] `limits { max_body 50mb }` for WFS-T POST + large GetFeature filter XML
- [x] Security headers: HSTS 1-year, X-Frame-Options SAMEORIGIN, `-X-Powered-By`
- [x] CORS: OPTIONS preflight + `Access-Control-Allow-Origin *` + `Access-Control-Max-Age: 86400`
- [x] WFS GetCapabilities health check endpoint for upstream monitoring
- [x] Structured JSON access log `/var/log/caddy/geoserver-vector-access.log` (100 MiB roll, 14 days)
- [x] gzip + zstd compression (GML/GeoJSON compress 60-80%)

## [DONE] v0.3.0 — First Live Service on VM 455 + Portal (2026-03-21/22)

- [x] Run `bash deploy_production.sh` from DFORGE-100 to provision VM 455
- [x] DNS A record: `vector IN A 131.148.52.225` in CT104 BIND9
- [x] FortiGate VIP: `131.148.52.231:80+443 -> VM451:80+443 -> 10.10.10.204:80+443`
- [x] `https://vector.cleargeo.tech/status` returns 200 — verified live (Sessions 10/11)
- [x] `https://vector.cleargeo.tech/geoserver/ows?service=WFS` returns WFS_Capabilities — verified
- [x] HTTPS routing via VM451 fully operational (3-fix chain: proxy target, status ordering, health_uri)
- [x] `_check_status.bat` + `_check_status.sh` added for cross-VM health monitoring
- [x] Caddy hardened: portal landing, `/health` probe, WPS LAN restriction, cache-control headers, CSP, handle_errors
- [x] `caddy/portal/index.html` live — branded service portal; auto WFS layer browser; QGIS/Python/curl code examples; OGC API cards
- [x] **Portal enhancements (Session 12):** basemap switcher (CartoDB/OSM/ESRI Satellite/OpenTopo), opacity slider, live GetMap URL bar, WFS GetFeatureInfo JSON popup on click

---

## [TODO] v0.4.0 — First Data: Admin Init + NAS / PostGIS Datastores

> **Prerequisites** (complete before other v0.4.0 tasks):
> - [ ] Run `scripts/geoserver-init.sh --prod` on VM 455 (SSH: `ubuntu@10.10.10.204`)
> - [ ] Add `GEOSERVER_ADMIN_PASSWORD` to `/opt/cvg/CVG_Geoserver_Vector/.env`
> - [ ] Verify `PROXY_BASE_URL` in WFS GetCapabilities `OnlineResource` URLs

**NAS Vector Datasets:**
- [ ] CIFS mount verify: `docker exec geoserver-vector ogrinfo /mnt/cgps/ --formats`
- [ ] Create GeoServer workspace `cvg` (done by init.sh) + verify via REST: `curl -u admin:$PW https://vector.cleargeo.tech/geoserver/rest/workspaces`
- [ ] Register `/mnt/cgps/fema/` NFHL shapefiles as Directory of Spatial Files datastore → `cvg:fema_nfhl`
- [ ] Register NOAA HWM (High Water Mark) point GeoPackage → `cvg:hwm_points`
- [ ] Register AOI boundaries GeoPackage → `cvg:aoi_boundaries`
- [ ] Test `GetFeature`: `curl "https://vector.cleargeo.tech/geoserver/wfs?service=WFS&version=2.0.0&request=GetFeature&typeNames=cvg:fema_nfhl&count=5&outputFormat=application/json"`

**PostGIS Datastore (if DB live):**
- [ ] Add PostGIS datastore: GeoServer UI → Stores → New → PostGIS → `jdbc:postgresql://10.10.10.XXX:5432/cvg_spatial`
- [ ] Use read-only account `geoserver_ro` (create on DB host first)
- [ ] Publish first PostGIS layer; verify `DescribeFeatureType`

**Layer Quality:**
- [ ] Set default `maxFeatures: 5000` in GeoServer global settings (prevent runaway GetFeature)
- [ ] Configure bounding box CRS for each published layer (EPSG:4326 + EPSG:3857)
- [ ] Verify OGC API Features endpoint: `https://vector.cleargeo.tech/geoserver/ogc/features/v1/collections`

---

## [TODO] v0.5.0 — SSW Vector Integration (Flood Extent + HWM)

**SSW Processing Pipeline:**
- [ ] Add export step: flood-extent polygon → GeoPackage → `/mnt/cgdp/ssw/{project}/{scenario}/extent.gpkg`
- [ ] Layer naming convention: `cvg:ssw_{project}_{scenario}_extent` (e.g. `cvg:ssw_hca2024_cat3_extent`)
- [ ] GeoServer auto-registration: `SSW web_api.py GET /api/layers/vector` returns WFS GetCapabilities URL
- [ ] Auto-publish via REST API after each SSW run: `PUT /geoserver/rest/workspaces/cvg/datastores/...`

**SSW CVG Dash Integration:**
- [ ] WFS layer rendered in Dash map alongside Raster WMS depth grid
- [ ] `GetFeatureInfo` popup: flood zone + DFIRM BFE at clicked point (vector + raster combined)
- [ ] DFIRM BFE/flood-zone overlay: `cvg:fema_dfirm_{county}` as WMS vector layer
- [ ] HWM points: `cvg:ssw_{project}_hwm` — published per-run, shows observed high-water marks

---

## [TODO] v0.6.0 — SLR + Rainfall Vector Integration

- [ ] SLR: per-scenario per-year shoreline/inundation-extent polygon → GeoPackage → `cvg:slr_{project}_{year}_{scenario}_extent`
- [ ] WMS TIME dimension support for SLR extent animation (year slider in Dash)
- [ ] Rainfall: SSURGO HSG polygon boundaries → `cvg:ssurgo_hsg_{state}` (static, pre-loaded)
- [ ] Drainage basins per project → `cvg:basin_{project}` (published post-processing)
- [ ] Unified layer registry: `GET /api/platform/layers` — all WFS/WMS-vector + Raster WMS layers
- [ ] CQL filter pass-through: Dash queries WFS with `CQL_FILTER=project='{project_id}'`

---

## [TODO] v0.7.0 — WFS-T (Transactional) + Editing Workflows

- [ ] Enable WFS-T on `cvg-gsv-internal` network only; Caddy blocks `wfs-t`/`Transaction` from public
- [ ] SSW QA workflow: CVG field staff update HWM point attributes via WFS-T from QGIS
- [ ] QGIS WFS-T connection guide: `https://vector.cleargeo.tech/geoserver/wfs` + credentials
- [ ] Row-level security: each project's features editable only by assigned username (`geoserver:role` filter)
- [ ] Audit log: GeoServer transaction log → Loki

---

## [TODO] v1.0.0 — Production Hardening

- [ ] REST API layer auto-registration script runs on each SSW/SLR/Rainfall deploy (`CVG_GeoServ_Processor`)
- [ ] Watchtower Discord/email webhook on image update
- [ ] Log shipping: `geoserver.log` + Caddy access log → Loki on CT104
- [ ] Rate limiting in Caddy: `rate_limit {remote_ip} 200r/m` for WFS GetFeature
- [ ] `maxFeatures: 5000` GeoServer global default; `maxFeatures: 50000` per-layer override for bulk exports
- [ ] OGC security: `Transaction` locked to `cvg-gsv-internal`; `GetMap`/`GetFeature` public read-only
- [ ] Automated `scripts/health-check.sh` via Proxmox scheduled task (cron on VM 455 + alert if exit≠0)
- [ ] GeoServer data_dir backup cron: `scripts/backup.sh --dest /mnt/cgdp/backups/geoserver-vector --keep 14`
- [ ] `handle_errors` maintenance page in Caddyfile already implemented ✅

---

## Integration Matrix (Cross-Wizard)

| Wizard | Data Type | GeoServer Service | Layer Pattern | Status |
|--------|-----------|-------------------|---------------|--------|
| Storm Surge | Flood extent polygon | WFS + WMS | `cvg:ssw_{project}_{scenario}_extent` | TODO v0.5.0 |
| Storm Surge | HWM point features | WFS | `cvg:ssw_{project}_hwm` | TODO v0.5.0 |
| Storm Surge | FEMA DFIRM BFE/zones | WMS | `cvg:fema_dfirm_{county}` | TODO v0.4.0 |
| SLR | Shoreline/inundation boundary | WFS + WMS | `cvg:slr_{project}_{year}_{scenario}_extent` | TODO v0.6.0 |
| Rainfall | SSURGO HSG polygons | WFS | `cvg:ssurgo_hsg_{state}` | TODO v0.6.0 |
| Rainfall | Drainage basin/catchment | WFS | `cvg:basin_{project}` | TODO v0.6.0 |
| All | AOI boundary polygon | WFS | `cvg:aoi_{project}` | TODO v0.5.0 |

---

## Infrastructure Register

| Resource | Value |
|---|---|
| VM | 455 (`cvg-geoserver-vector-01`) |
| Internal IP | 10.10.10.204 |
| Public IP | 131.148.52.225 |
| Hostname | vector.cleargeo.tech |
| Container | `geoserver-vector` |
| Proxy container | `caddy-gsv` |
| GeoServer version | 2.28.3 |
| Java runtime | eclipse-temurin:17-jre-jammy |
| JVM heap | approx 4.2 GB (70% of 6 GB `mem_limit`) |
| NAS mounts | /mnt/cgps (ro), /mnt/cgdp (ro) |
| Watchtower | daily poll (`watchtower-gsv`) |
| SSH | `ssh -i ~/.ssh/cvg_neuron_proxmox ubuntu@10.10.10.204` |

---

## Session History

| Session | Date | Focus | Outcome |
|---|---|---|---|
| Session 12 | 2026-03-22 | Portal enhancements | Basemap switcher (CartoDB/OSM/ESRI Satellite/OpenTopo), opacity slider, live GetMap URL bar, WFS GetFeatureInfo JSON popup; deployed live to VM455 |
| Session 11 | 2026-03-22 | HTTPS routing verification + status scripts | Routing verified live; _check_status scripts added; operational scripts registered; Caddyfile hardened; v0.3.0 complete |
| Session 10/11 | 2026-03-21 | HTTPS routing fix | VM451 proxy target corrected; health_uri removed; handle /status ordering fixed; both vector+raster services live |
| Session 7 | 2026-03-21 | Docker hardening + Caddyfile + deploy script | Multi-stage Dockerfile; vectortiles/css/importer plugins; tini; container JVM; Caddyfile (LAN restriction, flush, limits); --redeploy/--target flags |

---

*CVG GeoServer Vector v1.1.0 — Updated 2026-03-22 (Session 12)*
*© Clearview Geographic, LLC — Proprietary — CVG-ADF*
