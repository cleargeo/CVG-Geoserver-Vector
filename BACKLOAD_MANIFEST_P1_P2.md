<!--
  CVG GeoServer Vector -- Backload Publishing Manifest
  Priority 1 (Z:\2025) and Priority 2 (Z:\2023, Z:\2024)
  Generated: 2026-03-22 from live Z:\ inventory scan
  Author: Alex Zelenski, GISP | Clearview Geographic LLC
-->

# CVG GeoServer Vector -- Backload Manifest: P1 & P2

> **Endpoint:** https://vector.cleargeo.tech/geoserver  
> **Workspace:** `cvg`  
> **Status:** Phase 1 complete (inventory). Phase 2 in progress (categorization).  
> **NOTE:** Z:\2026 is empty (projects 2601/2602 are in-progress stubs -- nothing to publish yet)

---

## PRIORITY 1 -- Z:\2025 (47 GDBs, 95 SHPs, 74 JSONs)

### P1-A: Wetland Delineations (Publish First -- Core CVG Product)

| # | Source GDB | Project | Type | Slug | Proposed Layer Name(s) | Status |
|---|-----------|---------|------|------|----------------------|--------|
| 1 | `Z:\2025\2505 Seebeck WD\Seebeck Wetland\Seebeck Wetland.gdb` | 2505 Seebeck WD | wetland | `seebeck_wd` | `cvg:wetland_seebeck_wd_2025_polygons`<br>`cvg:wetland_seebeck_wd_2025_flags` | [ ] Stage [ ] Convert [ ] Publish |
| 2 | `Z:\2025\2511A Barnes County Road 3 Wetland Delineation\APRX\2511A_BarnesCountyRd_WD\2511A_BarnesCountyRd_WD.gdb` | 2511A Barnes Co. Rd 3 WD | wetland | `barnes_county_rd3_wd` | `cvg:wetland_barnes_county_rd3_2025_polygons`<br>`cvg:wetland_barnes_county_rd3_2025_points` | [ ] Stage [ ] Convert [ ] Publish |
| 3 | `Z:\2025\2511A Barnes County Road 3 Wetland Delineation\APRX\2511A_BarnesCountyRd_WD\2511A barnes county WD Points.gdb` | 2511A (GPS Points) | wetland | `barnes_county_rd3_wd` | `cvg:wetland_barnes_county_rd3_2025_gps` | [ ] Stage [ ] Convert [ ] Publish |
| 4 | `Z:\2025\2515A Old New York Rd (Wilton) Wetland Deliniation\2515A Old New York Rd (Wilton) Wetland Deliniation\2515A Old New York Rd (Wilton) Wetland Deliniation.gdb` | 2515A Old New York Rd WD | wetland | `old_new_york_rd_wd` | `cvg:wetland_old_new_york_rd_2025_polygons` | [ ] Stage [ ] Convert [ ] Publish |
| 5 | `Z:\2025\2536 _ Wetland Delineation\A_Aclade Wetland Delineation\2_GIS\Aclalde_Wetland_Delineation\Acalade_Wetland_Delineation.gdb` | 2536 Aclade WD | wetland | `aclade_wd` | `cvg:wetland_aclade_2025_polygons` | [ ] Stage [ ] Convert [ ] Publish |

### P1-B: City of Palatka -- 380 Vulnerability Assessment (High Value -- Multiple GDBs)

*Project 2520: Full climate vulnerability assessment with categorized critical asset GDBs*

| # | Source GDB | Layer Type | Slug | Proposed Layer Name | Status |
|---|-----------|-----------|------|---------------------|--------|
| 6 | `...\4_Baseline\Critical Asset Inventory.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_critical_assets_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 7 | `...\4_Baseline\Community and Cultural Facilities.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_community_cultural_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 8 | `...\4_Baseline\Education Facilities.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_education_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 9 | `...\4_Baseline\Emergency and Public Safety.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_emergency_safety_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 10 | `...\4_Baseline\Government and Institutional.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_government_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 11 | `...\4_Baseline\Health and Human Services.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_health_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 12 | `...\4_Baseline\Infrastructure and Utilities.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_infrastructure_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 13 | `...\4_Baseline\Natural and Cultural.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_natural_cultural_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 14 | `...\4_Baseline\Baseline_aprx\Transportation.gdb` | vuln/municipal | `palatka_va` | `cvg:vuln_palatka_transportation_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 15 | `...\5_Exposure\Palatka_VDatum\Palatka_VDatum.gdb` | flood/vuln | `palatka_va` | `cvg:vuln_palatka_vdatum_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 16 | `...\7_Data Share\...\Critical Asset Inventory.gdb` | vuln | `palatka_va` | `cvg:vuln_palatka_ca_deliverable_2025` | [ ] Stage [ ] Convert [ ] Publish |

### P1-C: Marine Science Center (2517 -- Aquatic/Bathymetric Data)

*1,487 MrSID rasters + vector GDBs -- both raster and vector GeoServer layers*

| # | Source | Type | Proposed Layer Name | Notes |
|---|--------|------|---------------------|-------|
| 17 | `...\Artifical_Reef_Locations.gdb` | aquatic | `cvg:aquatic_marine_science_reefs_2025` | Artificial reef point locations |
| 18 | `...\GEBCO_contours_NCEI.gdb` | aquatic | `cvg:aquatic_marine_science_bathymetry_2025` | GEBCO bathymetric contours |
| 19 | `...\Display.gdb` | aquatic | `cvg:aquatic_marine_science_display_2025` | Display/reference layers |
| 20 | `...\Clip to shoreline.gdb` | aquatic/coastal | `cvg:aquatic_marine_science_shoreline_2025` | Shoreline clip boundary |
| 21 | 1,487 .sid raster files | aquatic/raster | `cvg:ortho_marine_science_imagery_2025_*` | --> RASTER GeoServer, COG convert |

### P1-D: Due Diligence Projects

| # | Source GDB | Project | Type | Proposed Layer Name | Status |
|---|-----------|---------|------|---------------------|--------|
| 22 | `Z:\2025\2507 Seagate Due Diligence\2507 Seagate\2507 Seagate.gdb` | 2507 Seagate DD | duediligence | `cvg:duediligence_seagate_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 23 | `Z:\2025\2516A Vargas Due Diligence\2516A Vargas Due Diligence\2516A Vargas Due Diligence.gdb` | 2516A Vargas DD | duediligence | `cvg:duediligence_vargas_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 24 | `Z:\2025\2539 JMcVey\Volusia_SFH_Woodshop_Env_Stewardship_DD\Due Diligence Mapping.gdb` | 2539 JMcVey DD | duediligence | `cvg:duediligence_jmcvey_2025` | [ ] Stage [ ] Convert [ ] Publish |

### P1-E: Other 2025 Projects

| # | Source | Project | Type | Proposed Layer Name | Status |
|---|--------|---------|------|---------------------|--------|
| 25 | `Z:\2025\2540 ACastaneda_CJR Concrete Inc\A_BiologicalReview_Deland\SubjectParcel.gdb` | 2540 CJR Concrete | duediligence | `cvg:duediligence_cjr_concrete_2025` | [ ] Stage [ ] Convert [ ] Publish |
| 26 | `Z:\2025\2N02LF~7\2518AFarmton\2518AFarmton.gdb` | 2518A Farmton | habitat | `cvg:habitat_farmton_2025` | [ ] Stage [ ] Convert [ ] Publish |

### P1-F: Florida CLC Reference Raster (Shared by Multiple Projects)

*CLC_v3_8_Raster.gdb appears in 2507, 2511A, 2515A, 2516A -- publish ONCE as shared reference*

| # | Source | Type | Proposed Layer Name | Notes |
|---|--------|------|---------------------|-------|
| 27 | `...\CLC_v3_8_Raster.gdb` | reference/raster | `cvg:ref_clc_v38_florida_2025` | Florida Coop Land Cover v3.8 -- raster, goes to RASTER GeoServer |

---

## PRIORITY 2A -- Z:\2024 (4 GDBs confirmed)

| # | Source GDB | Project | Type | Proposed Layer Name(s) | Status |
|---|-----------|---------|------|----------------------|--------|
| 28 | `Z:\2024\2401 GFelix\Aprx\CG2401 Statistical Tree Survey\CG2401 Statistical Tree Survey.gdb` | 2401 GFelix Tree Survey | treesurvey | `cvg:treesurvey_gfelix_2024_points`<br>`cvg:treesurvey_gfelix_2024_plots` | [ ] Stage [ ] Convert [ ] Publish |
| 29 | `Z:\2024\2402 RLanda\Aprx\CG2402 Wetland Delineation\CG2402 Wetland Delineation.gdb` | 2402 RLanda WD | wetland | `cvg:wetland_rlanda_2024_polygons`<br>`cvg:wetland_rlanda_2024_flags` | [ ] Stage [ ] Convert [ ] Publish |
| 30 | `Z:\2024\2402 RLanda\Aprx\CG2402 Wetland Delineation\OHWL.gdb` | 2402 RLanda OHWL | wetland | `cvg:wetland_rlanda_2024_ohwl` | [ ] Stage [ ] Convert [ ] Publish |
| 31 | `Z:\2024\2413 CMurphy\Aprx\DeLand Tree Survey and Wetland Delineation\DeLand Tree Survey and Wetland Delineation.gdb` | 2413 CMurphy | treesurvey + wetland | `cvg:treesurvey_cmurphy_deland_2024`<br>`cvg:wetland_cmurphy_deland_2024` | [ ] Stage [ ] Convert [ ] Publish |

---

## PRIORITY 2B -- Z:\2023: Arcadis Fort Lauderdale VA (136 GDBs, 307 SHPs)

### Arcadis Fort Lauderdale (2311) -- Climate Vulnerability Assessment

*Published in coordinated layer groups: BL_2023_FtLauderdale_*

| # | GDB | Type | Layer Name | Notes |
|---|-----|------|-----------|-------|
| 32 | `4_Baseline/.../380 FtLauderdale Critical Com Em.gdb` | vuln | `cvg:vuln_ftl_critical_community_em_2023` | Critical community/emergency |
| 33 | `4_Baseline/.../380 FtLauderdale Critical Infrastructure.gdb` | vuln | `cvg:vuln_ftl_critical_infrastructure_2023` | Roads, utilities, infrastructure |
| 34 | `4_Baseline/.../380 FtLauderdale Natural and Cultural.gdb` | vuln | `cvg:vuln_ftl_natural_cultural_2023` | Natural resources, cultural assets |
| 35 | `4_Baseline/.../380 FtLauderdale Transportation.gdb` | vuln | `cvg:vuln_ftl_transportation_2023` | Transportation network |
| 36 | `4_Baseline/.../FtLauderdale Elevation.gdb` | dem | `cvg:dem_ftl_elevation_2023` | Elevation/DEM --> RASTER GeoServer also |
| 37 | `4_Baseline/.../FtLauderdale Risk Assessment.gdb` | vuln | `cvg:vuln_ftl_risk_assessment_2023` | Risk scoring polygons |
| 38 | `4_Baseline/.../FtLauderdale Social Vulnerability.gdb` | vuln | `cvg:vuln_ftl_social_vulnerability_2023` | SVI/social vulnerability |
| 39 | `5_Flood Projection/.../Ft Lauderdale SLR.gdb` | slr | `cvg:slr_ftl_main_2023` | SLR projection extents |
| 40 | `5_Flood Projection/.../Storm Surge.gdb` | surge | `cvg:surge_ftl_2023` | Storm surge extents |
| 41 | `5_Flood Projection/.../Sea Level Rise.gdb` | slr | `cvg:slr_ftl_scenarios_2023` | Multi-scenario SLR |
| 42 | `5_Flood Projection/.../Rainfall.gdb` | flood | `cvg:flood_ftl_rainfall_2023` | Rainfall flood projections |
| 43 | `5_Flood Projection/.../Depth Grid Processing/FTL_DepthGrids.gdb` | surge/flood | `cvg:surge_ftl_depth_grids_2023` | Depth grid vector outputs |
| 44 | `5_Flood Projection/.../Tidal Flood Days/Tidal Flood Days.gdb` | flood | `cvg:flood_ftl_tidal_days_2023` | Tidal flooding frequency |
| 45 | `5_Flood Projection/.../SLR_NIH 2040.gdb` | slr | `cvg:slr_ftl_nih_2040_2023` | SLR scenario NIH 2040 |
| 46 | `5_Flood Projection/.../SLR_NIH 2070.gdb` | slr | `cvg:slr_ftl_nih_2070_2023` | SLR scenario NIH 2070 |
| 47 | `5_Flood Projection/.../SLR_NIH 2100.gdb` | slr | `cvg:slr_ftl_nih_2100_2023` | SLR scenario NIH 2100 |
| 48 | `5_Flood Projection/.../SLR_NIL 2040.gdb` | slr | `cvg:slr_ftl_nil_2040_2023` | SLR scenario NIL 2040 |
| 49 | `5_Flood Projection/.../SLR_NIL 2070.gdb` | slr | `cvg:slr_ftl_nil_2070_2023` | SLR scenario NIL 2070 |
| 50 | `5_Flood Projection/.../SLR_NIL 2100.gdb` | slr | `cvg:slr_ftl_nil_2100_2023` | SLR scenario NIL 2100 |
| 51 | `6_Analysis/.../FLT_CriticalAssetInventory.gdb` | vuln | `cvg:vuln_ftl_ca_inventory_2023` | Critical asset inventory |
| 52 | `6_Analysis/.../Fort Lauderdale Sensitivity Analysis.gdb` | vuln | `cvg:vuln_ftl_sensitivity_2023` | Sensitivity analysis results |
| 53 | `9_DataShares/Fort Lauderdale_Baseline Critical Asset Inventory.gdb` | vuln | `cvg:vuln_ftl_ca_baseline_deliverable_2023` | Final deliverable |
| 54 | `9_DataShares/Fort Lauderdale_Exposure.gdb` | vuln | `cvg:vuln_ftl_exposure_deliverable_2023` | Flood exposure analysis |
| 55 | `9_DataShares/FTL_RoadwayAnalysisData.gdb` | vuln | `cvg:vuln_ftl_roadway_2023` | Roadway vulnerability |
| 56 | `Roadway_Final/Roadway_VulnerabilityClassifications.gdb` | vuln | `cvg:vuln_ftl_roadway_vuln_class_2023` | Roadway vuln. classification |

### 2023 Wetland Delineations

| # | Source GDB | Project | Proposed Layer Name | Status |
|---|-----------|---------|---------------------|--------|
| 57 | `2308 SWoolley/Tomahawk Trail Wetland Delineation.gdb` | 2308 Tomahawk Trail WD | `cvg:wetland_tomahawk_trail_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 58 | `2310 CHaas/Damascus Rd Wetland Delineation.gdb` | 2310 Damascus Rd WD | `cvg:wetland_damascus_rd_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 59 | `2313 BBlissett/2313 Wetland and Wildlife Survey.gdb` | 2313 Wetland+Wildlife | `cvg:wetland_blissett_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 60 | `2314 DHague/2314 Wetland Delineation.gdb` | 2314 DHague WD | `cvg:wetland_dhague_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 61 | `2316 VFlaherty/1869 Linville Road.gdb` | 2316 Linville Rd WD | `cvg:wetland_linville_rd_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 62 | `2322 GMorello/Shell Harbor Rd.gdb` | 2322 Shell Harbor WD | `cvg:wetland_shell_harbor_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 63 | `2324 CBlack/Blossom Rd.gdb` | 2324 Blossom Rd WD | `cvg:wetland_blossom_rd_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 64 | `2327 RJones/6th Ave.gdb` | 2327 6th Ave WD | `cvg:wetland_6th_ave_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 65 | `2329 WGuzman/CG2329 Wetland Delineation.gdb` | 2329 Quail Nest WD | `cvg:wetland_quail_nest_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 66 | `2331 MWest/East Crystal View.gdb` | 2331 Crystal View WD | `cvg:wetland_crystal_view_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 67 | `2334 DDeen/CG2334 DDeen.gdb` | 2334 DDeen | `cvg:wetland_ddeen_2023` | [ ] Stage [ ] Convert [ ] Publish |

### 2023 Other Projects

| # | Source GDB | Project | Type | Proposed Layer Name | Status |
|---|-----------|---------|------|---------------------|--------|
| 68 | `2303 DTorres/2301 East Retta Environmental Assessment.gdb` | 2303 East Retta | habitat | `cvg:habitat_east_retta_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 69 | `2304 JBurkhardt/CG2304 Osprey Circle.gdb` | 2304 Osprey Circle | duediligence | `cvg:duediligence_osprey_circle_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 70 | `2306 SMcIntosh/1808 9th Ave Tree Replanting.gdb` | 2306 Tree Replanting | treesurvey | `cvg:treesurvey_9th_ave_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 71 | `2308 SWoolley/FL_geodatabase_wetlands.gdb` | 2308 FL NWI | reference | `cvg:ref_fl_nwi_wetlands_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 72 | `2312 CFernandez/CLC_v3_5.gdb` | 2312 Mitigation Banking | mitigation | `cvg:ref_clc_v35_mitbanks_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 73 | `2312 CFernandez/Lot and land.gdb` | 2312 Lot+Land | mitigation | `cvg:mitigation_lot_land_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 74 | `2316 VFlaherty/Avenza Tracks.gdb` | 2316 Field Tracks | gpssurvey | `cvg:avenza_vflaherty_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 75 | `2320 ARuppel/2016 N Grandview Ave.gdb` | 2320 ARuppel | duediligence | `cvg:duediligence_grandview_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 76 | `2329 WGuzman/DEMS/MyProject65.gdb` | 2329 DEM Work | dem | `cvg:dem_quail_nest_2023` | [ ] Stage [ ] Convert [ ] Publish |
| 77 | `2311 Arcadis/FL_geodatabase_wetlands.gdb` (NWI) | reference | reference | `cvg:ref_fl_nwi_2023` | Duplicate of #71 -- share one layer |
| 78 | `2311 Arcadis/.../FloridaFireOccurrenceDatabase.gdb` | fire | reference | `cvg:ref_fl_fire_history_2023` | FWC Fire history 1994-2020 |

---

## Layer Counts Summary

| Year | Priority | GDBs | Proposed Layers | Status |
|------|----------|------|-----------------|--------|
| Z:\2026 | P1 | 0 | 0 (empty) | N/A -- check back |
| Z:\2025 | P1 | 47 | ~27 unique layers | [ ] Not started |
| Z:\2024 | P2 | 4 | 7 layers | [ ] Not started |
| Z:\2023 (Arcadis) | P2 | ~100 | ~25 Arcadis layers | [ ] Not started |
| Z:\2023 (other) | P2 | ~36 | ~18 WD/other | [ ] Not started |
| **TOTAL P1+P2** | | **187** | **~77 layers** | **[ ] Not started** |

---

## Next Actions Required

### On Windows Workstation (doing now):
1. [x] Complete P1+P2 inventory -- 47 + 4 + 136 GDBs cataloged
2. [ ] Run `backload_stage_to_nas.ps1` to copy P1+P2 source GDBs to NAS staging
3. [ ] Verify GeoServer endpoints are reachable and workspace `cvg` exists

### On Linux VM (10.10.10.200) or VM with GDAL:
4. [ ] Run `backload_gpkg_convert.sh 2025` -- convert all P1 GDB feature classes to GPKG
5. [ ] Run `backload_gpkg_convert.sh 2024` -- convert P2a GDB feature classes
6. [ ] Run `backload_gpkg_convert.sh 2023` -- convert P2b GDB feature classes
7. [ ] Run `backload_cog_convert.sh 2025` -- convert .sid rasters to COG (Marine Science Center)
8. [ ] Run `backload_publish_vector.sh 2025` -- publish P1 layers via REST API
9. [ ] Run `backload_publish_vector.sh 2023` -- publish P2b layers via REST API

---

*Manifest v1.0 | 2026-03-22 | Generated from live Z:\ scan*  
*CVG -- Clearview Geographic LLC -- Proprietary*
