<!--
  © Clearview Geographic LLC -- All Rights Reserved | Est. 2018
  CVG GeoServer Vector — BACKLOAD PRIORITY PLAN
  Author: Alex Zelenski, GISP | azelenski@clearviewgeographic.com
  Revised: 2026-03-22 v2.0 — Full portfolio scope (ALL geospatial data)
-->

# ⚠️ TOP PRIORITY — CVG GeoServer Vector: Full Portfolio Backload Campaign

> **Status:** 🔴 **CRITICAL — #1 ACTIVE INITIATIVE ON BOTH GEOSERVERS**
> **Author:** Alex Zelenski, GISP
> **Revised:** 2026-03-22 v2.0
> **Applies To:** CVG GeoServer Vector (`vector.cleargeo.tech`) — see sister doc for `raster.cleargeo.tech`

---

## 🚨 SCOPE NOTICE — ALL GEOSPATIAL DATA, NOT JUST SLR/STORM SURGE

> **This campaign covers 100% of geospatial vector data across ALL CVG project types from 2018–2026.**
>
> CVG's portfolio spans far beyond sea level rise and storm surge analysis. Every project that produced
> a vector output — regardless of client, discipline, or data type — must be inventoried, classified,
> processed, and published to `vector.cleargeo.tech`. This includes (but is not limited to):
>
> - 🌊 Coastal risk, SLR extents, surge boundaries ← **these are just one slice**
> - 🌿 Wetland delineation polygons, flags, transects ← **core CVG product**
> - 🌲 Tree survey point data, canopy polygons, transect lines ← **core CVG product**
> - 🦎 Habitat evaluation polygons, wildlife corridor lines
> - 🏘️ Property/parcel lines, AOI boundaries, due diligence study areas
> - 🏙️ Municipal/county GIS features: zoning, parcels, roads, infrastructure
> - 💧 Watershed/basin polygons, drainage networks, stormwater features
> - 🔥 Fire risk zones, WUI boundaries, fuel model polygons
> - 🌊 FEMA DFIRM flood zone polygons, BFE lines, LOMA/LOMC data
> - 🧭 GPS field survey points, benchmark monuments, field observation points
> - 📍 High-water marks, tide gauge points, storm damage survey points
> - 🛩️ AOI/project boundary polygons for any drone/aerial survey
> - 🌿 Native plant species occurrence points, invasive species location points
> - 🏗️ Site plan support layers, construction impact areas
> - 🗺️ Any vector feature produced for any CVG client project, 2018–2026
>
> **If it is a vector and it lives in `Z:\{year}\{project}\` — it belongs in this backload.**
> **Primary source: ArcGIS File Geodatabases (`.gdb`) in every project's `Aprx\` folder.**

---

## 🎯 Mission Statement

**The #1 priority for both GeoServer platforms is to systematically backload, categorize, and organize ALL previously collected project-specific geospatial vector data stored in the Z:\ project archive directories spanning 2018–2026.**

This initiative precedes all other GeoServer development work (WFS-T, SLD styling, wizard integration, API endpoints, etc.). No new project data should be published until the backload inventory and publishing pipeline is operational and validated.

---

## 📂 Source Directories — Z:\ Project Archive (Priority Order)

The Z:\ drive (CGPS volume) contains ALL historical CVG project data organized by year and sequential project number. Archive structure:

```
Z:\{YEAR}\{YY##}_{ClientName}\
        ├── Aprx\{ProjectName}\
        │   └── {ProjectName}.gdb\   ← PRIMARY VECTOR SOURCE (ArcGIS File GDB)
        ├── {ProjectName}.gpkg       ← GeoPackage (if exported)
        ├── Wetland Flags\           ← GPS points from field work
        ├── Maps for Avenza\         ← Field map exports
        └── Report\                  ← Final deliverable reports
```

> **Key insight from Z:\ exploration:** Most CVG projects store all vector data inside
> **ArcGIS File Geodatabases (`.gdb`)** within the `Aprx\` sub-folder. These GDBs are
> the primary extraction target. Secondary exports (`.gpkg`, `.shp`) may also exist.

### Priority Loading Order

| Priority | Directory | Content Summary | Status |
|----------|-----------|-----------------|--------|
| 🔴 **P1 — CRITICAL** | `Z:\2026` | Current year — 2601 CRJ Concrete, 2602 Sacramento | 🔴 Not loaded |
| 🔴 **P1 — CRITICAL** | `Z:\2025` | 2501–2540: Fire Risk, WDs, Due Diligence, Marine Science, PPBERP, CRS Consulting + more (40 projects) | 🔴 Not loaded |
| 🟠 **P2 — HIGH** | `Z:\2024` | 2401–2413: Tree Surveys, Municipal, Due Diligence (13 projects) | 🔴 Not loaded |
| 🟠 **P2 — HIGH** | `Z:\2023` | 2301–2335: Wetland Delineations, FDOT, Coastal, Municipal, Planning (35 projects) | 🔴 Not loaded |
| 🟡 **P3 — MEDIUM** | `Z:\2022` | 2201–2272: City of Deland, Ponce Inlet, UGA, NGA, Team Volusia, Coastal, Parks + (70+ projects) | 🔴 Not loaded |
| 🟡 **P3 — MEDIUM** | `Z:\2021` | 2102–2134: Audubon, Riverside Conservancy, Seminole County, Climate Reality, WRA Engineering + (33 projects) | 🔴 Not loaded |
| 🟢 **P4 — STANDARD** | `Z:\2020` | 2001–2044: Edgewater Env., Coastal Risk, Volusia Water Alliance, SJRWMD, UCF, Ocean Habitats + (44 projects) | 🔴 Not loaded |
| 🟢 **P4 — STANDARD** | `Z:\2019` | 1901–1937: Monroe County, Volusia County, FBSLRVA, Contour Engineering, Zev Cohen + (37 projects) | 🔴 Not loaded |
| 🔵 **P5 — ARCHIVE** | `Z:\2018` | 1801–1841: Founding year — Martin County, Nassau County, Mitigation Banking Group + (23 projects) | 🔴 Not loaded |

> **Load most recent → oldest:** 2026 → 2025 → 2024 → … → 2018
> Most relevant, active client data becomes available immediately.

---

## 🗂️ CVG Project Type Taxonomy — Vector Data

The following project types are confirmed in the Z:\ archive. Each type maps to specific vector feature classes:

### Tier A — Environmental / Ecological (Core CVG Work)

| Project Type | Expected Vector Data | GeoServer Type Code |
|--------------|---------------------|---------------------|
| **Wetland Delineation** | Wetland polygons, upland/wetland line, GPS flag points, transect lines, WRAP/UMAM data points | `wetland` |
| **Tree / Canopy Survey** | Tree point data (species, DBH, condition), canopy polygons, transect lines, sample plots | `treesurvey` |
| **Habitat Evaluation** | Habitat type polygons, condition assessment points, WRAP/UMAM units | `habitat` |
| **Wildlife Corridor** | Corridor polygons, movement paths, habitat patch polygons, crossing points | `wildlife` |
| **Aquatic / Water Quality** | Water body polygons, monitoring station points, sample transects | `aquatic` |
| **Fire Risk Assessment** | WUI zone polygons, fuel model polygons, risk zone boundaries | `fire` |
| **Native Landscape/Restoration** | Native plant occurrence points, invasive species points, restoration zone polygons | `vegetation` |
| **Mitigation Banking** | Bank service area polygons, mitigation site boundaries, credit ledger areas | `mitigation` |

### Tier B — Coastal / Flood / Climate

| Project Type | Expected Vector Data | GeoServer Type Code |
|--------------|---------------------|---------------------|
| **Coastal Risk / SLR** | SLR scenario extent polygons, depth contour lines, inundation boundary | `slr` |
| **Storm Surge / Flood** | Surge extent polygons, HWM points, flood depth zone polygons | `surge` |
| **FEMA / Floodplain** | DFIRM flood zone polygons, BFE lines, SFHA boundaries, LOMA areas | `flood` |
| **Coastal Resilience / PPBERP** | Vulnerability zone polygons, exposure index points, adaptation area boundaries | `vuln` |
| **CRS Consulting** | CRS activity area polygons, NFIP compliance zones, drainage study areas | `crs` |

### Tier C — Property / Development / Municipal

| Project Type | Expected Vector Data | GeoServer Type Code |
|--------------|---------------------|---------------------|
| **Due Diligence / Property** | Parcel lines, property boundary polygon, AOI, encumbrance polygons | `duediligence` |
| **City / County Municipal** | Zoning polygons, parcel overlay, infrastructure lines, annexation areas | `municipal` |
| **Rezoning / Planning** | Proposed zoning polygons, study area boundary, adjacent zoning | `planning` |
| **HOA / Community** | Community boundary, common area polygons, covenant areas | `hoa` |
| **Stormwater / Engineering** | Drainage catchment polygons, conveyance lines, retention area boundaries | `stormwater` |
| **GPS Field Survey** | Survey point collection, control points, field observation points | `gpssurvey` |

### Tier D — Reference / Support

| Project Type | Expected Vector Data | GeoServer Type Code |
|--------------|---------------------|---------------------|
| **Avenza Field Mapping** | Track lines, waypoints, field markup polygons from field trips | `avenza` |
| **Drone Survey AOI** | Flight area polygon, GCP points, nadir/oblique footprint | `droneaoi` |
| **GIS Consulting / Support** | Miscellaneous analysis layers, query results, data delivery packages | `support` |
| **Reference / Basemap** | County boundary, city limits, road network, parcel reference | `reference` |

---

## 🏷️ GeoServer Vector Naming Convention

All published vector layers must follow this naming scheme **from day one — no exceptions:**

```
Workspace:  cvg
Layer Name: cvg:{typeCode}_{projectSlug}_{year}[_{descriptor}]

Where:
  typeCode    = from CVG Project Type Taxonomy above (wetland, treesurvey, surge, municipal, etc.)
  projectSlug = derived from Z:\ folder name, lowercased, spaces/hyphens→underscores,
                strip project number prefix
                e.g.: "2505 Seebeck WD"              → seebeck_wd
                      "2401 GFelix"                   → gfelix
                      "2307 FDOT"                     → fdot
                      "2505 Seebeck WD"               → seebeck_wd
                      "2501 Holden Nash - Fire Risk"   → holden_nash
                      "2102 WestVolusiaAudubon"        → west_volusia_audubon
                      "2122 The Riverside Conservancy" → riverside_conservancy
                      "1932 FBSLRVA"                  → fbslrva
                      "2201 City of Deland"           → city_deland
  year        = 4-digit project year
  descriptor  = optional sub-layer (polygons, points, lines, flags, transects, cat3, 2ft, etc.)
```

### Layer Naming Examples (Real CVG Projects)

```
# Wetland Delineation layers:
cvg:wetland_seebeck_wd_2025_polygons       ← 2505 Seebeck — wetland jurisdiction polygons
cvg:wetland_seebeck_wd_2025_flags          ← 2505 Seebeck — GPS flag point locations
cvg:wetland_seebeck_wd_2025_transects      ← 2505 Seebeck — survey transect lines
cvg:wetland_jwalden_2025                   ← 2503 J.Walden wetland boundary
cvg:wetland_kola_road_2025                 ← 2535 Kola Road NSB wetland

# Tree / Canopy Survey layers:
cvg:treesurvey_gfelix_2024_points          ← 2401 GFelix — individual tree GPS points
cvg:treesurvey_gfelix_2024_canopy          ← 2401 GFelix — canopy drip-line polygons
cvg:treesurvey_osmin_2024_points           ← 2408 Osmin — tree point survey

# Habitat / Wildlife layers:
cvg:habitat_west_volusia_audubon_2021      ← 2102 West Volusia Audubon habitat map
cvg:wildlife_riverside_conservancy_2021    ← 2122 Riverside Conservancy corridor
cvg:habitat_wcorridor_volusia_2025         ← Volusia Wildlife Corridor (multi-year)

# Fire Risk:
cvg:fire_holden_nash_2025_zones            ← 2501 Holden Nash Fire Risk zones
cvg:fire_holden_nash_2025_wui              ← 2501 Holden Nash WUI boundary

# Coastal / SLR / Surge:
cvg:slr_fbslrva_2019                       ← 1932 FBSLRVA SLR scenario boundary
cvg:flood_martin_county_2018               ← 1836 Martin County FEMA flood zones
cvg:surge_captains_clean_water_2023        ← 2305 Captains for Clean Water surge extents
cvg:crs_city_palatka_2025                  ← 2520 City of Palatka CRS consulting
cvg:vuln_ppberp_2025                       ← 2524 PPBERP Vulnerability Assessment

# Municipal / Property:
cvg:municipal_city_deland_2022             ← 2201 City of Deland municipal features
cvg:municipal_fdot_2023                    ← 2307 FDOT project features
cvg:planning_walker_rezoning_2025          ← 2523 Walker 10 Acre Rezoning
cvg:duediligence_seagate_2025              ← 2507 Seagate Due Diligence AOI
cvg:duediligence_vargas_2025               ← 2516A Vargas Due Diligence
cvg:municipal_treasure_coast_rpc_2023      ← 2325 Treasure Coast RPC
cvg:municipal_city_sacramento_2026         ← 2602 City of Sacramento CA
cvg:municipal_ponce_inlet_2022             ← 2207 Ponce Inlet FL

# Water / Ecology:
cvg:aquatic_ocean_habitats_2020            ← 2019 Ocean Habitats
cvg:stormwater_sjrwmd_2020                 ← 2016 SJRWMD drainage features
cvg:mitigation_fl_mitigation_2020          ← 2024 FL Mitigation banking areas
cvg:aquatic_marine_science_2025            ← 2517 Marine Science Center
```

---

## 🗂️ Backload Workflow — Phase by Phase

### Phase 1 — Inventory (Run FIRST for Every Year)

**Use the PowerShell inventory script** (required since Z:\ is Windows/SMB):

```powershell
# Run from any workstation with Z:\ mapped:
# Usage: .\scripts\backload_inventory.ps1 -Year 2026

# Produces two CSV files:
#   backload_inventory_{YEAR}_vectors.csv    ← .shp, .gpkg, .geojson, .kml, .gdb dirs
#   backload_inventory_{YEAR}_gdbs.csv       ← ALL .gdb directories (primary source)

powershell -ExecutionPolicy Bypass -File "G:\07_APPLICATIONS_TOOLS\CVG_Geoserver_Vector\scripts\backload_inventory.ps1" -Year 2026
```

**Vector file types to capture:**

```
Primary source (extract from):   .gdb  (ArcGIS File Geodatabase — contains feature classes)
Direct-publish formats:          .gpkg  .geojson  .json
Convert-first formats:           .shp   .kml  .kmz  .gdb feature classes → GPKG
Point/tabular data:              .csv   (with lat/lon or x/y fields)
```

> **CRITICAL:** Most CVG vector data lives **inside `.gdb` directories** under each project's
> `Aprx\` subfolder. The inventory MUST enumerate all `.gdb` directories and flag them for
> feature class extraction. This is NOT just about loose `.shp` files.

**Inventory Completion Checklist:**
- [ ] `Z:\2026` — inventory complete (GDBs + loose vectors cataloged)
- [ ] `Z:\2025` — inventory complete
- [ ] `Z:\2024` — inventory complete
- [ ] `Z:\2023` — inventory complete
- [ ] `Z:\2022` — inventory complete
- [ ] `Z:\2021` — inventory complete
- [ ] `Z:\2020` — inventory complete
- [ ] `Z:\2019` — inventory complete
- [ ] `Z:\2018` — inventory complete

---

### Phase 2 — Categorization (Classify Each Dataset)

After inventory CSV is generated, classify each feature class / file:

| Field | Values |
|-------|--------|
| **Project Year** | 2018–2026 |
| **Project Number** | YYNN format (e.g., `2505`, `2401`) |
| **Project Slug** | Derived from folder name (lowercased, no special chars) |
| **Client/Project Name** | Full client/project name |
| **CVG Type Code** | From taxonomy table (wetland, treesurvey, surge, municipal, etc.) |
| **Source Format** | `.gdb_fc`, `.gpkg`, `.shp`, `.geojson`, `.kml`, `.csv` |
| **Source Path** | Full Z:\ path including GDB name and feature class name |
| **Geometry Type** | `Point`, `MultiPoint`, `LineString`, `Polygon`, `MultiPolygon` |
| **CRS (EPSG)** | Verify with `ogrinfo -al -so`; note if NAD83 / FL State Plane |
| **GPKG Ready?** | `yes` (already .gpkg) · `no — needs conversion` |
| **Publish Priority** | `high` (recent/active client) · `medium` · `archive` (2018–2020) |
| **Descriptor** | Sub-layer name (`polygons`, `points`, `flags`, `lines`, etc.) |

---

### Phase 3 — Processing (Convert to GeoPackage)

All vector data must be converted to **GeoPackage (GPKG)** and reprojected to **EPSG:4326** before publishing:

```bash
# ── GDB Feature Class → GPKG (most common CVG source) ──
ogr2ogr \
  -f GPKG \
  -t_srs EPSG:4326 \
  -nln "wetland_seebeck_wd_2025_polygons" \
  "/mnt/cgdp/backload/2025/seebeck_wd/wetland_seebeck_wd_2025_polygons.gpkg" \
  "Z:/2025/2505 Seebeck WD/Seebeck Wetland/Seebeck Wetland.gdb" \
  "WetlandPolygons"

# ── SHP → GPKG ──
ogr2ogr -f GPKG -t_srs EPSG:4326 \
  "/mnt/cgdp/backload/{year}/{slug}/{layername}.gpkg" \
  "Z:/{year}/{project}/{file}.shp"

# ── KML/KMZ → GPKG ──
ogr2ogr -f GPKG -t_srs EPSG:4326 \
  "/mnt/cgdp/backload/{year}/{slug}/{layername}.gpkg" \
  "Z:/{year}/{project}/{file}.kml"

# ── GeoJSON → GPKG ──
ogr2ogr -f GPKG -t_srs EPSG:4326 \
  "/mnt/cgdp/backload/{year}/{slug}/{layername}.gpkg" \
  "Z:/{year}/{project}/{file}.geojson"

# ── CSV with coordinates → GPKG ──
ogr2ogr -f GPKG -t_srs EPSG:4326 \
  -oo X_POSSIBLE_NAMES=Longitude,lon,x \
  -oo Y_POSSIBLE_NAMES=Latitude,lat,y \
  "/mnt/cgdp/backload/{year}/{slug}/{layername}.gpkg" \
  "Z:/{year}/{project}/{file}.csv"

# ── List feature classes inside a GDB ──
ogrinfo -al -so "Z:/2025/2505 Seebeck WD/Seebeck Wetland/Seebeck Wetland.gdb"

# ── Verify GPKG output ──
ogrinfo -al -so "/mnt/cgdp/backload/2025/seebeck_wd/wetland_seebeck_wd_2025_polygons.gpkg"
```

**Processing Checklist (per feature class / file):**
- [ ] Feature classes listed via `ogrinfo -al -so` (for GDB sources)
- [ ] Geometry type identified (Point / Line / Polygon)
- [ ] CRS verified; reproject to EPSG:4326 applied (`-t_srs EPSG:4326`)
- [ ] Converted to GPKG with proper layer name (`-nln {layername}`)
- [ ] Output verified: feature count, bbox, geometry type confirmed
- [ ] Saved to `/mnt/cgdp/backload/{year}/{projectSlug}/`
- [ ] Entry logged in `backload_vector_processing_log.csv`

---

### Phase 4 — Publishing (GeoServer REST API)

```bash
VS_BASE="https://vector.cleargeo.tech/geoserver/rest"
WS="cvg"
PW=$GEOSERVER_ADMIN_PASSWORD

# ── Step 1: Create GeoPackage DataStore ──
curl -u admin:$PW -X POST \
  -H "Content-Type: application/json" \
  -d "{
    \"dataStore\": {
      \"name\": \"wetland_seebeck_wd_2025\",
      \"type\": \"GeoPackage\",
      \"connectionParameters\": {
        \"entry\": [
          {\"@key\": \"database\", \"\$\": \"file:///mnt/cgdp/backload/2025/seebeck_wd/wetland_seebeck_wd_2025_polygons.gpkg\"},
          {\"@key\": \"dbtype\", \"\$\": \"geopkg\"}
        ]
      }
    }
  }" \
  "$VS_BASE/workspaces/$WS/datastores"

# ── Step 2: Publish FeatureType (layer) from DataStore ──
curl -u admin:$PW -X POST \
  -H "Content-Type: application/json" \
  -d "{\"featureType\": {
    \"name\": \"wetland_seebeck_wd_2025_polygons\",
    \"title\": \"Seebeck Wetland Delineation 2025 — Jurisdiction Polygons\",
    \"abstract\": \"Wetland jurisdiction polygons for Seebeck property wetland delineation (CVG 2505, 2025). Source: ArcGIS GDB. CRS: EPSG:4326.\"
  }}" \
  "$VS_BASE/workspaces/$WS/datastores/wetland_seebeck_wd_2025/featuretypes"

# ── Step 3: Smoke test via WFS GetFeature ──
curl "https://vector.cleargeo.tech/geoserver/wfs?service=WFS&version=2.0.0\
&request=GetFeature&typeNames=cvg:wetland_seebeck_wd_2025_polygons\
&count=5&outputFormat=application/json"
```

---

### Phase 5 — Organization (GeoServer Layer Groups)

All published layers must be organized into GeoServer layer groups by year AND CVG project type:

```
cvg (workspace)
├── BL_2026_All                 ← all 2026 backloaded vectors
│   ├── BL_2026_Wetlands        ← wetland delineation layers
│   ├── BL_2026_TreeSurveys     ← tree/canopy survey layers
│   ├── BL_2026_Habitat         ← habitat / wildlife layers
│   ├── BL_2026_Coastal         ← coastal/flood/SLR layers
│   ├── BL_2026_Municipal       ← city/county/property layers
│   └── BL_2026_FireRisk        ← fire risk layers
├── BL_2025_All
├── BL_2024_All
│   ...
└── BL_2018_All
```

---

## 📊 Master Vector Backload Register

> Update this table as each layer is processed and published. Export to `backload_vector_register.csv`.

| # | Year | Proj# | Project Name | Source (.gdb / .shp etc.) | Feature Class | Type Code | Geom | GPKG? | Published? | Layer Name | Notes |
|---|------|-------|-------------|--------------------------|---------------|-----------|------|-------|------------|------------|-------|
| 1 | 2026 | 2601 | CRJ Concrete | — | — | — | — | ❌ | ❌ | — | Inventory pending |
| 2 | 2026 | 2602 | City of Sacramento CA | — | — | municipal | — | ❌ | ❌ | — | GIS support — inventory pending |
| 3 | 2025 | 2501 | Holden Nash / Fire Risk | — | — | fire | Polygon | ❌ | ❌ | — | Inventory pending |
| 4 | 2025 | 2503 | J.Walden | — | — | wetland | Polygon | ❌ | ❌ | — | WD report found; GDB expected |
| 5 | 2025 | 2505 | Seebeck WD | `Seebeck Wetland.gdb` | WetlandPolygons | wetland | Polygon | ❌ | ❌ | cvg:wetland_seebeck_wd_2025_polygons | GDB confirmed at Z:\2025\2505\ |
| 6 | 2025 | 2505 | Seebeck WD | `Seebeck Wetland.gdb` | FlagPoints | wetland | Point | ❌ | ❌ | cvg:wetland_seebeck_wd_2025_flags | GPS flag points |
| 7 | 2025 | 2507 | Seagate Due Diligence | — | — | duediligence | Polygon | ❌ | ❌ | — | Inventory pending |
| 8 | 2025 | 2511A | Barnes County Rd 3 WD | — | — | wetland | Polygon | ❌ | ❌ | — | Inventory pending |
| 9 | 2025 | 2515A | Old New York Rd WD | — | — | wetland | Polygon | ❌ | ❌ | — | Inventory pending |
| 10 | 2025 | 2516A | Vargas Due Diligence | — | — | duediligence | Polygon | ❌ | ❌ | — | Inventory pending |
| 11 | 2025 | 2517 | Marine Science Center | — | — | aquatic | — | ❌ | ❌ | — | Inventory pending |
| 12 | 2025 | 2520 | City of Palatka | — | — | crs/municipal | Polygon | ❌ | ❌ | — | CRS consulting |
| 13 | 2025 | 2523 | Walker 10 Acre Rezoning | — | — | planning | Polygon | ❌ | ❌ | — | Inventory pending |
| 14 | 2025 | 2524 | PPBERP Vuln. Assessment | — | — | vuln | Polygon | ❌ | ❌ | — | Inventory pending |
| 15 | 2024 | 2401 | G.Felix Tree Survey | `CG2401.gdb` | TreePoints | treesurvey | Point | ❌ | ❌ | cvg:treesurvey_gfelix_2024_points | GDB confirmed |
| 16 | 2024 | 2408 | Osmin Tree Survey | — | — | treesurvey | Point | ❌ | ❌ | — | Inventory pending |
| 17 | 2024 | 2405 | RescAlert | — | — | — | — | ❌ | ❌ | — | Inventory pending |
| 18 | 2023 | 2301 | Evolving Landscapes | — | — | habitat | Polygon | ❌ | ❌ | — | Inventory pending |
| 19 | 2023 | 2305 | Captains for Clean Water | — | — | surge/coastal | Polygon | ❌ | ❌ | — | Inventory pending |
| 20 | 2023 | 2307 | FDOT | — | — | municipal | — | ❌ | ❌ | — | Inventory pending |
| 21 | 2023 | 2325 | Treasure Coast RPC | — | — | municipal | Polygon | ❌ | ❌ | — | Inventory pending |
| 22 | 2022 | 2201 | City of Deland | — | — | municipal | Polygon | ❌ | ❌ | — | Inventory pending |
| 23 | 2022 | 2206 | JWilson WD | — | — | wetland | Polygon | ❌ | ❌ | — | Inventory pending |
| 24 | 2022 | 2207 | Ponce Inlet FL | — | — | municipal/coastal | Polygon | ❌ | ❌ | — | Inventory pending |
| 25 | 2022 | 2217 | National Geospatial Agency | — | — | — | — | ❌ | ❌ | — | Inventory pending |
| 26 | 2022 | 2244 | Drones on Demand | — | — | droneaoi | Polygon | ❌ | ❌ | — | AOI + GCP points expected |
| 27 | 2021 | 2102 | West Volusia Audubon | — | — | habitat | Polygon | ❌ | ❌ | — | Habitat mapping expected |
| 28 | 2021 | 2119 | Seminole County | — | — | municipal | Polygon | ❌ | ❌ | — | Inventory pending |
| 29 | 2021 | 2122 | Riverside Conservancy | — | — | wildlife | Polygon | ❌ | ❌ | — | Corridor polygons expected |
| 30 | 2021 | 2126 | Climate Reality Project | — | — | — | — | ❌ | ❌ | — | Inventory pending |
| 31 | 2020 | 2001 | Edgewater Env. Alliance | — | — | habitat | Polygon | ❌ | ❌ | — | Inventory pending |
| 32 | 2020 | 2003 | Coastal Risk Consultants | — | — | coastal | Polygon | ❌ | ❌ | — | Inventory pending |
| 33 | 2020 | 2016 | SJRWMD | — | — | stormwater | Polygon | ❌ | ❌ | — | Inventory pending |
| 34 | 2020 | 2019 | Ocean Habitats | — | — | aquatic | Polygon | ❌ | ❌ | — | Inventory pending |
| 35 | 2020 | 2024 | FL Mitigation | — | — | mitigation | Polygon | ❌ | ❌ | — | Mitigation banking areas |
| 36 | 2020 | 2037 | Native Florida Landscapes | — | — | vegetation | Polygon | ❌ | ❌ | — | Inventory pending |
| 37 | 2019 | 1912 | Zev Cohen & Associates | — | — | — | — | ❌ | ❌ | — | Engineering/planning firm |
| 38 | 2019 | 1926 | Volusia County | — | — | municipal | Polygon | ❌ | ❌ | — | Inventory pending |
| 39 | 2019 | 1930 | Contour Engineering | — | — | stormwater | — | ❌ | ❌ | — | Inventory pending |
| 40 | 2019 | 1932 | FBSLRVA | — | — | slr | Polygon | ❌ | ❌ | — | SLR extents expected |
| 41 | 2019 | 1935 | Monroe County | — | — | flood/municipal | Polygon | ❌ | ❌ | — | Inventory pending |
| 42 | 2018 | 1803 | Mitigation Banking Group | — | — | mitigation | Polygon | ❌ | ❌ | — | Founding year |
| 43 | 2018 | 1836 | Martin County | — | — | municipal/flood | Polygon | ❌ | ❌ | — | Inventory pending |
| 44 | 2018 | 1840 | Nassau County | — | — | municipal | Polygon | ❌ | ❌ | — | Inventory pending |
| … | … | … | … | … | … | … | … | … | … | … | … |

---

## 🔧 Scripts Required

| Script | Purpose | Location | Status |
|--------|---------|----------|--------|
| `backload_inventory.ps1` | PowerShell: walk Z:\ year → enumerate GDBs + vector files → CSV | `scripts/` | ✅ Created |
| `backload_gpkg_convert.sh` | Bash: batch GDB/SHP/KML → GPKG via ogr2ogr | `scripts/` | ✅ Created |
| `backload_publish_vector.sh` | Bash: REST API register datastore + publish featuretype | `scripts/` | ⬜ TODO |
| `backload_verify_vector.sh` | Bash: WFS GetFeature smoke test per layer | `scripts/` | ⬜ TODO |
| `backload_layer_group.sh` | Bash: create GeoServer layer groups per year+type | `scripts/` | ⬜ TODO |

---

## ⚡ Immediate Start Sequence

> **Begin here — right now — before any other GeoServer work:**

```
STEP 1 ─── Run inventory script for Z:\2026
           powershell -File scripts/backload_inventory.ps1 -Year 2026
           → Produces: backload_inventory_2026_vectors.csv
                       backload_inventory_2026_gdbs.csv

STEP 2 ─── For each GDB found: list feature classes
           ogrinfo -al -so "Z:\2026\{project}\Aprx\{proj}.gdb"
           → Identify geometry type, CRS, feature count

STEP 3 ─── Classify each feature class
           Assign: TypeCode, LayerName (cvg:type_slug_year_descriptor), PublishPriority

STEP 4 ─── Copy raw source to NAS staging area
           \\10.10.10.100\cgps\backload\2026\{projectSlug}\

STEP 5 ─── Convert to GPKG via ogr2ogr
           bash scripts/backload_gpkg_convert.sh 2026
           → Output: /mnt/cgdp/backload/2026/{slug}/{layername}.gpkg

STEP 6 ─── Verify CVG workspace exists in vector GeoServer
           curl -u admin:$PW https://vector.cleargeo.tech/geoserver/rest/workspaces/cvg

STEP 7 ─── Publish first batch (2026 + 2025 wetland + tree survey layers)
           bash scripts/backload_publish_vector.sh 2026

STEP 8 ─── Repeat for 2025 → 2024 → 2023 → ... → 2018
```

---

## 📋 Priority Summary Card

```
╔══════════════════════════════════════════════════════════════════════╗
║  CVG GEOSERVER VECTOR — FULL PORTFOLIO BACKLOAD PRIORITY            ║
║  ────────────────────────────────────────────────────────────────    ║
║                                                                       ║
║  ⚠  SCOPE: ALL CVG GEOSPATIAL VECTOR DATA — NOT JUST SLR/SURGE ⚠   ║
║     Wetland Delineations · Tree Surveys · Habitat · Wildlife ·       ║
║     Fire Risk · Municipal · CRS · Due Diligence · + MORE             ║
║                                                                       ║
║  PRIMARY SOURCE: ArcGIS .gdb FILES in each project's Aprx\ folder   ║
║  SECONDARY:      .gpkg · .shp · .geojson · .kml files               ║
║                                                                       ║
║  🔴 P1 — CRITICAL:  Z:\2026  →  Load NOW (current year)             ║
║  🔴 P1 — CRITICAL:  Z:\2025  →  Load NOW (40 projects, many WDs)    ║
║  🟠 P2 — HIGH:      Z:\2024  →  Load NEXT (13 projects)             ║
║  🟠 P2 — HIGH:      Z:\2023  →  Load NEXT (35 projects)             ║
║  🟡 P3 — MEDIUM:    Z:\2022  →  After P2 (70+ projects)             ║
║  🟡 P3 — MEDIUM:    Z:\2021  →  After P2 (33 projects)              ║
║  🟢 P4 — STANDARD:  Z:\2020  →  Batch with 2019 (44 projects)       ║
║  🟢 P4 — STANDARD:  Z:\2019  →  Batch with 2020 (37 projects)       ║
║  🔵 P5 — ARCHIVE:   Z:\2018  →  Last (founding year, 23 projects)   ║
║                                                                       ║
║  DATA FLOW:  Z:\ .gdb/.shp  →  NAS Staging  →  GPKG  →  GeoServer  ║
║  ENDPOINT:   https://vector.cleargeo.tech/geoserver/wfs             ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

## Related Documents

| Document | Location |
|----------|----------|
| Raster Backload Plan | `CVG_Geoserver_Raster/BACKLOAD_PRIORITY.md` |
| Vector GeoServer Roadmap | `ROADMAP.md` |
| GeoServer Init Script | `scripts/geoserver-init.sh` |
| Inventory Script (PowerShell) | `scripts/backload_inventory.ps1` |
| GPKG Conversion Script | `scripts/backload_gpkg_convert.sh` |
| Changelog | `05_ChangeLogs/master_changelog.md` |
| Z:\ Master Plan | `Z:\CVG_MASTER_ACTION_PLAN.md` |

---

*CVG GeoServer Vector Backload Priority v2.0 — Revised 2026-03-22*
*Scope expanded from coastal-only to FULL CVG portfolio (all geospatial vector data, 2018–2026)*
*Primary source confirmed: ArcGIS File Geodatabases (.gdb) in Z:\ project Aprx\ folders*
*© Clearview Geographic, LLC — Proprietary — CVG-ADF*
