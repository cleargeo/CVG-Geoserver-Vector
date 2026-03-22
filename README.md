# CVG GeoServer Vector

<!-- version: v1.0.0 | change_id: 20260321-AZ-v1.0.0 -->
[![Version](https://img.shields.io/badge/version-v1.0.0-blue)](CHANGELOG.md)
[![GeoServer](https://img.shields.io/badge/GeoServer-2.28.3-green)](https://geoserver.org)
[![Java](https://img.shields.io/badge/Java-17_JRE-orange)](https://adoptium.net)
[![License](https://img.shields.io/badge/license-Proprietary-red)](LICENSE)

**(c) Clearview Geographic LLC — All Rights Reserved | Est. 2018**
*Author: Alex Zelenski, GISP | azelenski@clearviewgeographic.com*

---

## Overview

CVG GeoServer Vector is a containerized [GeoServer 2.28.3](https://geoserver.org) instance tuned for **vector feature services**. It powers CVG's WFS/WMS endpoints for Shapefiles, GeoPackages, GeoJSON, and PostGIS feature classes — including flood zone boundaries, infrastructure layers, watershed delineations, and jurisdictional datasets.

**Production URL:** `https://vector.cleargeo.tech`
**Host VM:** `cvg-geoserver-vector-01` (VMID 455) — `10.10.10.204`

---

## Services Provided

| Service | Endpoint | Description |
|---------|----------|-------------|
| WFS | `/geoserver/wfs` | GetFeature, DescribeFeatureType, Transactions |
| WMS | `/geoserver/wms` | Vector-rendered GetMap tiles, GetFeatureInfo |
| WFS-T | `/geoserver/wfs` | Transactional WFS (update/insert/delete) |
| OGC API Features | `/geoserver/ogc/features` | OGC API — Features (GeoServer 2.26+) |
| REST API | `/geoserver/rest` | Layer management (admin only) |
| Web UI | `/geoserver/web` | Admin console |

---

## Quick Start — Local Development

### Prerequisites
- Docker Desktop (with WSL2 backend on Windows)
- `geoserver-2.28.3-bin.zip` present in this directory

### Run locally

```bash
# Build and start (GeoServer on http://localhost:8080)
docker compose up -d --build

# Watch startup logs (~90 seconds first boot)
docker logs -f geoserver-vector-dev

# Verify health
curl http://localhost:8080/geoserver/web/

# Default credentials (DEV ONLY — change before any real use)
# URL:      http://localhost:8080/geoserver/web/
# Username: admin
# Password: geoserver
```

### Stop

```bash
docker compose down
```

---

## Production Deployment

Production uses VM 455 on the CVG-QUEEN-11-PROXMOX cluster. The full deployment (VM creation → Docker → Caddy TLS) is automated:

```bash
# From DFORGE-100 Git Bash
cd "G:/07_APPLICATIONS_TOOLS/CVG_Geoserver_Vector"
bash deploy_production.sh
```

**What the deploy script does:**

| Step | Action |
|------|--------|
| 0 | Pre-flight: SSH key + file checks |
| 1 | Create VM 455 on Proxmox (Ubuntu 22.04, cloud-init) |
| 2 | Wait for SSH availability |
| 3 | Bootstrap: Docker CE, cifs-utils, directory layout |
| 4 | Mount TrueNAS CGPS + CGDP shares |
| 5 | rsync project files → VM |
| 6 | `docker compose -f docker-compose.prod.yml up -d --build` |
| 7 | Health check + summary |

### Required manual steps post-deploy

1. **DNS A record** — add to hive0 BIND9 or Cloudflare:
   ```
   vector   IN A   131.148.52.225
   ```

2. **FortiGate VIP** — forward public `131.148.52.225:80+443` → VM `10.10.10.204:80+443`

3. **Change admin password** — immediately after first successful boot:
   `https://vector.cleargeo.tech/geoserver/web/` → Security → Users/Groups → admin → Edit

4. **Configure CSRF whitelist** — set `GEOSERVER_CSRF_WHITELIST=vector.cleargeo.tech` in `docker-compose.prod.yml`

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GEOSERVER_DATA_DIR` | `/opt/geoserver/data_dir` | GeoServer data directory (persisted volume) |
| `GEOSERVER_LOG_LOCATION` | `/var/log/geoserver/geoserver.log` | Log file path |
| `GEOSERVER_CSRF_WHITELIST` | *(unset)* | Comma-separated allowed origins for web UI |
| `GEOSERVER_LOG_PROFILE` | `DEFAULT_LOGGING.properties` | Log verbosity profile |
| `JAVA_OPTS` | See Dockerfile | JVM heap + GC settings |

### JVM Tuning (Vector-Optimized)

```
-Xms1g -Xmx4g          # 4 GB heap — sufficient for WFS feature streaming
-XX:+UseG1GC            # Low-pause GC for concurrent WFS requests
-XX:MaxGCPauseMillis=200
-Djava.awt.headless=true
```

Adjust `JAVA_OPTS` in `docker-compose.prod.yml` to match VM 455's 16 GB RAM.

### Data Mounts

| Mount | Host Path | Access | Purpose |
|-------|-----------|--------|---------|
| `geoserver-data` | Docker volume | rw | GeoServer data directory (workspaces, stores, styles) |
| `/mnt/cgps` | `//10.10.10.100/cgps` | ro | TrueNAS CGPS — source vector datasets (Shapefiles, GPKG) |
| `/mnt/cgdp` | `//10.10.10.100/cgdp` | ro | TrueNAS CGDP — processed feature outputs |

---

## Vector Data Stores

Typical data stores to configure after deployment:

### Shapefile Store
For individual feature classes:
- **Store type:** Shapefile
- **File path:** `file:///mnt/cgps/vectors/{project}/{layer}.shp`

### GeoPackage Store
For multi-layer SQLite-based datasets:
- **Store type:** GeoPackage
- **Database:** `file:///mnt/cgps/geopackages/{project}.gpkg`

### PostGIS Store
For live database-backed feature services (connects to CVG PostGIS server):
- **Store type:** PostGIS
- **Host:** pgdb.cvg.internal (or 10.10.10.x)
- **Database:** `cvg_spatial`
- **User:** `geoserver_ro` (read-only service account)

---

## Docker Image Details

| Property | Value |
|----------|-------|
| Base image | `eclipse-temurin:17-jre-jammy` |
| GeoServer | 2.28.3 (standalone Jetty) |
| User | `geoserver` (UID 1001, non-root) |
| Exposed port | `8080` |
| Health check | `GET /geoserver/web/` every 30s, 120s start period |
| Image size | ~600 MB (no GDAL — vector-only stack) |

---

## Infrastructure

| Component | Detail |
|-----------|--------|
| Proxmox host | CVG-QUEEN-11-PROXMOX (10.10.10.56) |
| VM ID | 455 — `cvg-geoserver-vector-01` |
| VM IP | 10.10.10.204 |
| VM RAM | 16 GB |
| VM vCPUs | 4 |
| VM Disk | 60 GB (PE-Enclosure1 ZFS pool) |
| Public IP | 131.148.52.225 (FortiGate NAT) |
| TLS | Caddy + Let's Encrypt auto-HTTPS |
| Network | TCP/80+443 → FortiGate VIP → VM 455 |

---

## Security Notes

- GeoServer runs as `geoserver` user (UID 1001) — not root
- WFS-T (transactional) requires authenticated role — configure in Security → Authentication
- REST API endpoint should be restricted to internal network only
- Change default `admin/geoserver` password immediately
- TrueNAS shares mounted read-only (`ro`) in container
- Caddy enforces HTTPS with HSTS (1-year max-age)
- PostGIS connections should use a **read-only** service account

---

## Related Projects

| Project | Description |
|---------|-------------|
| `CVG_Geoserver_Raster` | Sister raster WMS/WCS service (VM 454, raster.cleargeo.tech) |
| `CVG_GeoServ_Processor` | Python pipeline: processes outputs → publishes to GeoServer |
| `CVG_Storm Surge Wizard` | Generates flood zone boundary vectors consumed by this service |
| `CVG_SLR Wizard` | Generates SLR inundation boundary vectors consumed by this service |
| `CVG_Rainfall Wizard` | Generates rainfall runoff boundary vectors consumed by this service |

---

*© Clearview Geographic LLC — Proprietary — All Rights Reserved*
