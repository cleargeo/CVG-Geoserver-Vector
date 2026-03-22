# CVG GeoServer Vector â€” Master Changelog

**Project:** CVG GeoServer Vector
**Standard:** `Z:\9999\Cline_Global_Rules\Change Log Requirements.md`
**(c) Clearview Geographic LLC â€” All Rights Reserved**

---

## Deployment Log

| Date | Version | ChangeID | Author | VM | Summary |
|------|---------|----------|--------|----|---------|
| 2026-03-22 | [Unreleased] | 20260322-AZ-portal-v | Alex Zelenski | VM 455 | Session 12 â€” Portal enhancements: basemap switcher, opacity slider, GetMap URL bar, WFS GetFeatureInfo JSON popup on click |
| 2026-03-22 | v1.1.0 | 20260322-AZ-v1.1.0-v | Alex Zelenski | VM 455 + VM 451 | HTTPS routing fixes; operational scripts formally tracked; cross-VM status checks; services verified live |
| 2026-03-21 | v1.0.0 | 20260321-AZ-v1.0.0-v | Alex Zelenski | VM 455 (10.10.10.204) | Initial project scaffolding â€” multi-stage Dockerfile, vectortiles/css/importer plugins, tini, container JVM, Caddy TLS, deploy script |

---

## [Unreleased] â€” Portal Enhancements â€” 2026-03-22 (Session 12)

**ChangeID:** `20260322-AZ-portal-v`
**Author:** Alex Zelenski, GISP
**Session:** 12

### Files Modified

| File | Change | Notes |
|------|--------|-------|
| `caddy/portal/index.html` | Major enhancements | Basemap switcher, opacity slider, live GetMap URL bar, WFS GetFeatureInfo JSON attribute popup on map click |

### Changes Detail

#### caddy/portal/index.html â€” Public Tool Additions
- **Basemap switcher** â€” `<select id="bmap-sel">` with CartoDB Dark (default), OpenStreetMap, ESRI Satellite, OpenTopoMap; `swBmap()` JS function swaps Leaflet tile layer without reloading the map
- **Opacity slider** â€” `<input type="range" id="osl">` with `setOp()` JS; adjusts WMS layer opacity in real time (0â€“100%); persists across layer changes
- **Live GetMap URL bar** â€” `<div id="gmap-bar">` below map; `updGMapUrl()` called on `moveend`/`zoomend`; shows full WMS GetMap URL for current view extent; one-click Copy button
- **WFS GetFeatureInfo on map click** â€” `map.on('click')` handler calls `GetFeatureInfo` with `INFO_FORMAT=application/json`; JSON response parsed; feature attributes displayed in floating popup; queried via `vector.cleargeo.tech/geoserver/wms`
- **Scale bar** â€” Leaflet `L.control.scale()` added to map; shows metric + imperial units
- **`initMap()` function** â€” wraps map initialisation; called once on page load; handles basemap layer management

### Deployment

- Deployed to VM455 via SCP: `G:\...\caddy\portal\index.html` â†’ `/opt/cvg/CVG_Geoserver_Vector/caddy/portal/index.html`
- Caddy bind-mounts `/opt/cvg/CVG_Geoserver_Vector/caddy/portal` â†’ `/srv/portal`; changes are live immediately (no container restart required)
- Verified in browser at `https://vector.cleargeo.tech`

### Post-Deploy Checklist (Session 12)

- [x] Basemap switcher renders on portal load
- [x] Opacity slider adjusts WMS/WFS layer transparency
- [x] Live GetMap URL updates on pan/zoom
- [x] GetFeatureInfo JSON popup appears on map click (when layer is loaded)
- [x] Deployed to VM455 and verified live
- [ ] Run `scripts/geoserver-init.sh` to set admin password + create `cvg` workspace
- [ ] Publish first vector layer so GetFeatureInfo can return real feature attributes

---

## v1.1.0 â€” 2026-03-22 â€” Routing Fixes + Operational Scripts

**ChangeID:** `20260322-AZ-v1.1.0-v`
**Author:** Alex Zelenski, GISP
**Session:** 11 (continued from Sessions 10/11 on 2026-03-21)

### Files Added

| File | Role | Notes |
|------|------|-------|
| `_check_status.bat` | Cross-VM status (Windows) | SSH to VM454+VM455; docker ps; internal WFS/WMS checks via docker exec; Caddy :80 |
| `_check_status.sh` | Cross-VM status (Unix) | Same checks as .bat; bash version for Linux/macOS |
| `scripts/geoserver-init.sh` | First-run init | REST API: set admin password, proxy URL, remove demo workspaces, create `cvg` workspace; sentinel file |
| `scripts/health-check.sh` | Health check | --local/--prod/--ip modes; WFS+WMS+WMTS+GWC; LAN restriction verify; TLS cert expiry; exit code 1 on failure |
| `scripts/backup.sh` | data_dir backup | `geoserver-vector-data` volume backup via ephemeral alpine; timestamped tarballs; --dest/--keep; manifest |
| `scripts/reset-password.sh` | Password reset | REST API password change; reads .env; auto-detect mode; verify old+new |

### Files Modified

| File | Change | Notes |
|------|--------|-------|
| `caddy/Caddyfile` | Major hardening | Portal landing; /health probe; WPS LAN restriction; OGC API route; trusted_proxies; cache headers; CSP; handle_errors; /status ordering fixed |
| `CHANGELOG.md` | Updated | v1.1.0 section added |
| `ROADMAP.md` | Updated | v0.3.0 marked complete; session history updated |
| `05_ChangeLogs/master_changelog.md` | Updated | This file â€” created in Session 12 (recreated after filesystem loss) |
| `05_ChangeLogs/version_manifest.yml` | Updated | Created in Session 12 (recreated after filesystem loss) |

### Infrastructure Events

```
VM 455 (vector.cleargeo.tech) â€” HTTP routing chain VERIFIED LIVE:
  fix: VM451 cvg-caddy proxy target vector â†’ http://10.10.10.204:80 (was :8080 directly)
  fix: VM451 health_uri /status removed (Host: 10.10.10.204 â†’ 308 â†’ 503 cascade)
  fix: caddy/Caddyfile handle /status moved before reverse_proxy catch-all

VM 454 (raster.cleargeo.tech) â€” Same routing fixes applied on VM451 side

Verified production endpoints:
  https://vector.cleargeo.tech/status                             â†’ "OK" 200 âœ…
  https://vector.cleargeo.tech/geoserver/ows?service=WFS&...     â†’ WFS_Capabilities 200 âœ…
  https://raster.cleargeo.tech/status                            â†’ "OK" 200 âœ…
  https://raster.cleargeo.tech/geoserver/ows?service=WMS&...     â†’ WMS_Capabilities 200 âœ…
```

### Post-Deploy Checklist (v1.1.0)

- [x] DNS A record: `vector.cleargeo.tech â†’ 131.148.52.225`
- [x] FortiGate VIP: `public:80+443 â†’ 10.10.10.204:80+443`
- [x] HTTPS routing verified end-to-end via VM451
- [x] WFS GetCapabilities returning 200
- [ ] Run `scripts/geoserver-init.sh` to set admin password + `PROXY_BASE_URL` + create `cvg` workspace
- [ ] Register FEMA NFHL shapefiles from `/mnt/cgps` as Directory of Spatial Files datastore
- [ ] Configure PostGIS datastore (if DB available)
- [ ] Verify `PROXY_BASE_URL` appears correctly in WFS GetCapabilities `OnlineResource` URLs

---

## v1.0.0 â€” 2026-03-21 â€” Initial Release

**ChangeID:** `20260321-AZ-v1.0.0-v`
**Author:** Alex Zelenski, GISP
**Session:** 6

### Files Created

| File | Role | Notes |
|------|------|-------|
| `Dockerfile` | Container build | Multi-stage: extract+runtime; tini PID1; vector libs (geos/proj/spatialindex); container JVM; plugin installer |
| `docker-compose.yml` | Dev compose | Port 8080 exposed; dev image tag; localhost CSRF/PROXY |
| `docker-compose.prod.yml` | Prod compose | mem_limit:6g; cpus:3.0; ulimits; service_healthy; GWC volume; json logs |
| `caddy/Caddyfile` | Reverse proxy | Auto-HTTPS; CORS; security headers; max_body 50mb (WFS-T); handle_errors; JSON log |
| `deploy_production.sh` | VM provisioning | VM 455 cloud-init; Docker bootstrap; CIFS mounts; rsync; build+launch |
| `.dockerignore` | Build exclusions | war.zip; docs; scripts; Caddy config; Python artifacts |
| `.gitignore` | SCM exclusions | data_dir; logs; secrets; OS files; Python artifacts |
| `plugins/README.md` | Plugin guide | Install instructions for GeoServer extension ZIPs |
| `README.md` | Documentation | Quick start; endpoints; data stores; PostGIS config; infrastructure; security |
| `CHANGELOG.md` | History | This release + Unreleased section |
| `ROADMAP.md` | Planning | v1.0.0 â†’ v2.0.0 milestones |
| `05_ChangeLogs/version_manifest.yml` | Version tracking | Per-file version + infrastructure metadata |
| `05_ChangeLogs/master_changelog.md` | Master log | This file |

### Infrastructure Summary

```
VM 455: cvg-geoserver-vector-01
  IP:    10.10.10.204 (Proxmox vmbr0, 10.10.10.0/24)
  RAM:   16 GB | vCPU: 4 | Disk: 60 GB (PE-Enclosure1 ZFS)
  URL:   https://vector.cleargeo.tech
  Stack: GeoServer 2.28.3 + Caddy 2-alpine + Watchtower
  JVM:   eclipse-temurin:17-jre-jammy | 4.2 GB heap (70% of 6 GB container limit)
  Data:  /mnt/cgps (CGPS TrueNAS, ro) + /mnt/cgdp (CGDP TrueNAS, ro)
```

### Endpoints Available After Deploy

| Endpoint | URL |
|----------|-----|
| WFS | `https://vector.cleargeo.tech/geoserver/wfs` |
| WMS | `https://vector.cleargeo.tech/geoserver/wms` |
| WMTS | `https://vector.cleargeo.tech/geoserver/gwc/service/wmts` |
| OGC API Features | `https://vector.cleargeo.tech/geoserver/ogc/features/v1` |
| REST API | `https://vector.cleargeo.tech/geoserver/rest` |
| Admin UI | `https://vector.cleargeo.tech/geoserver/web` |

### Post-Deploy Checklist

- [x] DNS A record: `vector.cleargeo.tech â†’ 131.148.52.225`
- [x] FortiGate VIP: `public:80+443 â†’ 10.10.10.204:80+443`
- [ ] Change GeoServer admin password (default: `admin/geoserver`)
- [ ] Register NAS vector datasets (FEMA NFHL, HWM GeoPackage, AOI boundaries)
- [ ] Configure PostGIS datastore (if DB available)
- [ ] Verify `PROXY_BASE_URL` in GetCapabilities response URLs