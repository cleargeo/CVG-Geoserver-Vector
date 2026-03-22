#!/usr/bin/env bash
# =============================================================================
# CVG GeoServer Vector -- Backload Publish Script (P1 + P2)
# Author: Alex Zelenski, GISP | Clearview Geographic LLC
# Version: 1.0.0 | 2026-03-22
#
# PURPOSE:
#   Create GeoServer workspace, datastores, and featuretypes for all
#   P1 (2025) and P2 (2024, 2023) backload layers via GeoServer REST API.
#   Layers are sourced from GPKG files on NAS staging area.
#
# REQUIREMENTS:
#   - GeoServer running and REST API accessible
#   - GPKG files staged at /mnt/cgdp/backload/{year}/{slug}/*.gpkg
#   - GEOSERVER_ADMIN_PASSWORD set in environment or passed as arg
#
# USAGE:
#   bash backload_publish_vector.sh <YEAR> [GS_BASE_URL]
#   GEOSERVER_ADMIN_PASSWORD=secret bash backload_publish_vector.sh 2025
#   bash backload_publish_vector.sh ALL https://vector.cleargeo.tech/geoserver
#
# INTERNAL ACCESS (before DNS cutover):
#   bash backload_publish_vector.sh 2025 http://10.10.10.200:8080/geoserver
# =============================================================================

set -euo pipefail

YEAR="${1:-ALL}"
GS_BASE="${2:-https://vector.cleargeo.tech/geoserver}"
PW="${GEOSERVER_ADMIN_PASSWORD:-admin}"
WS="cvg"
BACKLOAD_BASE="${BACKLOAD_BASE:-/mnt/cgdp/backload}"
LOG_FILE="backload_publish_${YEAR}_$(date +%Y%m%d_%H%M%S).log"
PUBLISH_REGISTER="backload_publish_register.csv"

RED='\033[0;31m'; ORANGE='\033[0;33m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
log()         { echo -e "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
log_ok()      { log "${GREEN}OK${NC} $*"; }
log_warn()    { log "${ORANGE}WARN${NC} $*"; }
log_err()     { log "${RED}ERR${NC} $*"; }
log_section() { log "${CYAN}=== $* ===${NC}"; }

[ ! -f "$PUBLISH_REGISTER" ] && echo "Timestamp,Year,Slug,LayerName,DataStore,GPKG,Status,HTTP" > "$PUBLISH_REGISTER"

# =============================================================================
# Step 0: Verify GeoServer connectivity and ensure workspace exists
# =============================================================================
log_section "Checking GeoServer connectivity"
log "Endpoint: $GS_BASE"

HTTP=$(curl -sk -u "admin:$PW" -o /dev/null -w "%{http_code}" "$GS_BASE/rest/about/version.json" 2>/dev/null || echo "000")
if [ "$HTTP" = "200" ] || [ "$HTTP" = "401" ]; then
    log_ok "GeoServer reachable (HTTP $HTTP)"
else
    log_err "GeoServer NOT reachable at $GS_BASE (HTTP $HTTP)"
    log_err "Try: export GEOSERVER_ADMIN_PASSWORD=<password>"
    log_err "Or use internal URL: http://10.10.10.200:8080/geoserver"
    exit 1
fi

# Verify auth works
HTTP=$(curl -sk -u "admin:$PW" -o /dev/null -w "%{http_code}" "$GS_BASE/rest/workspaces.json" 2>/dev/null || echo "000")
if [ "$HTTP" != "200" ]; then
    log_err "Auth failed (HTTP $HTTP). Check GEOSERVER_ADMIN_PASSWORD."
    exit 1
fi
log_ok "Auth OK"

# Ensure 'cvg' workspace exists
WS_CHECK=$(curl -sk -u "admin:$PW" -o /dev/null -w "%{http_code}" "$GS_BASE/rest/workspaces/$WS.json" 2>/dev/null || echo "000")
if [ "$WS_CHECK" = "404" ]; then
    log "Creating workspace: $WS"
    HTTP=$(curl -sk -u "admin:$PW" -X POST -H "Content-Type: application/json" \
        -d "{\"workspace\":{\"name\":\"$WS\"}}" \
        -o /dev/null -w "%{http_code}" "$GS_BASE/rest/workspaces" 2>/dev/null || echo "000")
    if [ "$HTTP" = "201" ]; then
        log_ok "Workspace '$WS' created"
    else
        log_warn "Workspace creation returned HTTP $HTTP (may already exist)"
    fi
else
    log_ok "Workspace '$WS' already exists"
fi

# =============================================================================
# Helper: publish one GPKG layer
# publish_layer SLUG GPKG_PATH LAYER_NAME TITLE YEAR
# =============================================================================
publish_layer() {
    local SLUG="$1"
    local GPKG_PATH="$2"
    local LAYER_NAME="$3"
    local TITLE="$4"
    local LAYER_YEAR="$5"
    local DS_NAME="${SLUG}_${LAYER_NAME}"

    log ""
    log_section "$LAYER_NAME"
    log "  GPKG: $GPKG_PATH"

    if [ ! -f "$GPKG_PATH" ]; then
        log_warn "  GPKG not found -- skip (run backload_gpkg_convert.sh first): $GPKG_PATH"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$LAYER_YEAR,$SLUG,$LAYER_NAME,$DS_NAME,$(basename "$GPKG_PATH"),skipped_no_gpkg,0" >> "$PUBLISH_REGISTER"
        return 0
    fi

    # 1. Check if datastore already exists
    local DS_CHECK
    DS_CHECK=$(curl -sk -u "admin:$PW" -o /dev/null -w "%{http_code}" \
        "$GS_BASE/rest/workspaces/$WS/datastores/$DS_NAME.json" 2>/dev/null || echo "000")

    if [ "$DS_CHECK" = "200" ]; then
        log_warn "  DataStore already exists: $DS_NAME -- skipping"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$LAYER_YEAR,$SLUG,$LAYER_NAME,$DS_NAME,$(basename "$GPKG_PATH"),skipped_exists,200" >> "$PUBLISH_REGISTER"
        return 0
    fi

    # 2. Create datastore
    local DS_JSON
    DS_JSON=$(cat <<EOF
{
  "dataStore": {
    "name": "$DS_NAME",
    "type": "GeoPackage",
    "enabled": true,
    "connectionParameters": {
      "entry": [
        {"@key": "database", "\$": "file://$GPKG_PATH"},
        {"@key": "dbtype", "\$": "geopkg"}
      ]
    }
  }
}
EOF
)
    local HTTP_DS
    HTTP_DS=$(curl -sk -u "admin:$PW" -X POST -H "Content-Type: application/json" \
        -d "$DS_JSON" -o /dev/null -w "%{http_code}" \
        "$GS_BASE/rest/workspaces/$WS/datastores" 2>/dev/null || echo "000")

    if [ "$HTTP_DS" != "201" ]; then
        log_err "  DataStore creation failed (HTTP $HTTP_DS): $DS_NAME"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$LAYER_YEAR,$SLUG,$LAYER_NAME,$DS_NAME,$(basename "$GPKG_PATH"),error_ds,$HTTP_DS" >> "$PUBLISH_REGISTER"
        return 1
    fi
    log_ok "  DataStore created: $DS_NAME"

    # 3. Publish featuretype
    local FT_JSON
    FT_JSON=$(cat <<EOF
{
  "featureType": {
    "name": "$LAYER_NAME",
    "nativeName": "$LAYER_NAME",
    "title": "$TITLE",
    "srs": "EPSG:4326",
    "enabled": true
  }
}
EOF
)
    local HTTP_FT
    HTTP_FT=$(curl -sk -u "admin:$PW" -X POST -H "Content-Type: application/json" \
        -d "$FT_JSON" -o /dev/null -w "%{http_code}" \
        "$GS_BASE/rest/workspaces/$WS/datastores/$DS_NAME/featuretypes" 2>/dev/null || echo "000")

    if [ "$HTTP_FT" = "201" ]; then
        log_ok "  Layer published: cvg:$LAYER_NAME"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$LAYER_YEAR,$SLUG,$LAYER_NAME,$DS_NAME,$(basename "$GPKG_PATH"),published,$HTTP_FT" >> "$PUBLISH_REGISTER"
    else
        log_err "  FeatureType publish failed (HTTP $HTTP_FT): $LAYER_NAME"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$LAYER_YEAR,$SLUG,$LAYER_NAME,$DS_NAME,$(basename "$GPKG_PATH"),error_ft,$HTTP_FT" >> "$PUBLISH_REGISTER"
        return 1
    fi
}

# =============================================================================
# PRIORITY 1 -- Z:\2025
# =============================================================================
publish_p1() {
    log_section "PRIORITY 1 -- 2025 Layers"

    # P1-A: Wetland Delineations
    log "--- P1-A: Wetland Delineations ---"
    publish_layer "seebeck_wd"          "$BACKLOAD_BASE/2025/seebeck_wd/wetland_seebeck_wd_2025_polygons.gpkg"        "wetland_seebeck_wd_2025_polygons"         "Seebeck Wetland Delineation 2025 -- Polygons"                   "2025"
    publish_layer "seebeck_wd"          "$BACKLOAD_BASE/2025/seebeck_wd/wetland_seebeck_wd_2025_flags.gpkg"           "wetland_seebeck_wd_2025_flags"            "Seebeck Wetland Delineation 2025 -- GPS Flag Points"            "2025"
    publish_layer "barnes_county_rd3_wd" "$BACKLOAD_BASE/2025/barnes_county_rd3_wd/wetland_barnes_county_rd3_2025_polygons.gpkg" "wetland_barnes_county_rd3_2025_polygons" "Barnes County Rd 3 WD 2025 -- Polygons"                    "2025"
    publish_layer "barnes_county_rd3_wd" "$BACKLOAD_BASE/2025/barnes_county_rd3_wd/wetland_barnes_county_rd3_2025_gps.gpkg"     "wetland_barnes_county_rd3_2025_gps"      "Barnes County Rd 3 WD 2025 -- GPS Points"                  "2025"
    publish_layer "old_new_york_rd_wd"  "$BACKLOAD_BASE/2025/old_new_york_rd_wd/wetland_old_new_york_rd_2025_polygons.gpkg"    "wetland_old_new_york_rd_2025_polygons"    "Old New York Rd Wetland Delineation 2025"                       "2025"
    publish_layer "aclade_wd"           "$BACKLOAD_BASE/2025/aclade_wd/wetland_aclade_2025_polygons.gpkg"              "wetland_aclade_2025_polygons"             "Aclade Wetland Delineation 2025"                                "2025"

    # P1-B: City of Palatka VA
    log "--- P1-B: City of Palatka -- 380 Vulnerability Assessment ---"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_critical_assets_2025.gpkg"       "vuln_palatka_critical_assets_2025"       "Palatka 380 VA - Critical Asset Inventory"                     "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_community_cultural_2025.gpkg"    "vuln_palatka_community_cultural_2025"    "Palatka 380 VA - Community and Cultural Facilities"            "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_education_2025.gpkg"             "vuln_palatka_education_2025"             "Palatka 380 VA - Education Facilities"                         "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_emergency_safety_2025.gpkg"      "vuln_palatka_emergency_safety_2025"      "Palatka 380 VA - Emergency and Public Safety"                  "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_government_2025.gpkg"            "vuln_palatka_government_2025"            "Palatka 380 VA - Government and Institutional"                 "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_health_2025.gpkg"                "vuln_palatka_health_2025"                "Palatka 380 VA - Health and Human Services"                    "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_infrastructure_2025.gpkg"        "vuln_palatka_infrastructure_2025"        "Palatka 380 VA - Infrastructure and Utilities"                 "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_natural_cultural_2025.gpkg"      "vuln_palatka_natural_cultural_2025"      "Palatka 380 VA - Natural and Cultural Resources"               "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_transportation_2025.gpkg"        "vuln_palatka_transportation_2025"        "Palatka 380 VA - Transportation Network"                       "2025"
    publish_layer "palatka_va" "$BACKLOAD_BASE/2025/palatka_va/vuln_palatka_vdatum_2025.gpkg"                "vuln_palatka_vdatum_2025"                "Palatka 380 VA - VDatum Flood Exposure"                        "2025"

    # P1-C: Marine Science Center
    log "--- P1-C: Marine Science Center ---"
    publish_layer "marine_science_center" "$BACKLOAD_BASE/2025/marine_science_center/aquatic_marine_science_reefs_2025.gpkg"       "aquatic_marine_science_reefs_2025"       "Marine Science Center - Artificial Reef Locations 2025"        "2025"
    publish_layer "marine_science_center" "$BACKLOAD_BASE/2025/marine_science_center/aquatic_marine_science_bathymetry_2025.gpkg"  "aquatic_marine_science_bathymetry_2025"  "Marine Science Center - GEBCO Bathymetric Contours 2025"       "2025"
    publish_layer "marine_science_center" "$BACKLOAD_BASE/2025/marine_science_center/aquatic_marine_science_shoreline_2025.gpkg"   "aquatic_marine_science_shoreline_2025"   "Marine Science Center - Shoreline Reference 2025"              "2025"

    # P1-D: Due Diligence
    log "--- P1-D: Due Diligence ---"
    publish_layer "seagate_dd"  "$BACKLOAD_BASE/2025/seagate_dd/duediligence_seagate_2025.gpkg"      "duediligence_seagate_2025"   "Seagate Due Diligence 2025"            "2025"
    publish_layer "vargas_dd"   "$BACKLOAD_BASE/2025/vargas_dd/duediligence_vargas_2025.gpkg"        "duediligence_vargas_2025"    "Vargas Due Diligence 2025"             "2025"
    publish_layer "jmcvey_dd"   "$BACKLOAD_BASE/2025/jmcvey_dd/duediligence_jmcvey_2025.gpkg"       "duediligence_jmcvey_2025"    "JMcVey Environmental DD 2025"          "2025"
    publish_layer "cjr_concrete" "$BACKLOAD_BASE/2025/cjr_concrete/duediligence_cjr_concrete_2025.gpkg" "duediligence_cjr_concrete_2025" "CJR Concrete Biological Review 2025" "2025"
}

# =============================================================================
# PRIORITY 2A -- Z:\2024
# =============================================================================
publish_p2a() {
    log_section "PRIORITY 2A -- 2024 Layers"
    publish_layer "gfelix_tree_survey" "$BACKLOAD_BASE/2024/gfelix_tree_survey/treesurvey_gfelix_2024_points.gpkg"  "treesurvey_gfelix_2024_points"  "GFelix Statistical Tree Survey 2024 -- Tree Points"  "2024"
    publish_layer "gfelix_tree_survey" "$BACKLOAD_BASE/2024/gfelix_tree_survey/treesurvey_gfelix_2024_plots.gpkg"   "treesurvey_gfelix_2024_plots"   "GFelix Statistical Tree Survey 2024 -- Sample Plots" "2024"
    publish_layer "rlanda_wd"          "$BACKLOAD_BASE/2024/rlanda_wd/wetland_rlanda_2024_polygons.gpkg"            "wetland_rlanda_2024_polygons"   "RLanda Wetland Delineation 2024 -- Polygons"         "2024"
    publish_layer "rlanda_wd"          "$BACKLOAD_BASE/2024/rlanda_wd/wetland_rlanda_2024_flags.gpkg"               "wetland_rlanda_2024_flags"      "RLanda Wetland Delineation 2024 -- GPS Flags"        "2024"
    publish_layer "rlanda_wd"          "$BACKLOAD_BASE/2024/rlanda_wd/wetland_rlanda_2024_ohwl.gpkg"                "wetland_rlanda_2024_ohwl"       "RLanda WD 2024 -- Ordinary High Water Line"          "2024"
    publish_layer "cmurphy_deland"     "$BACKLOAD_BASE/2024/cmurphy_deland/treesurvey_cmurphy_deland_2024.gpkg"     "treesurvey_cmurphy_deland_2024" "CMurphy DeLand Tree Survey 2024"                     "2024"
    publish_layer "cmurphy_deland"     "$BACKLOAD_BASE/2024/cmurphy_deland/wetland_cmurphy_deland_2024.gpkg"        "wetland_cmurphy_deland_2024"    "CMurphy DeLand Wetland Delineation 2024"             "2024"
}

# =============================================================================
# PRIORITY 2B -- Z:\2023
# =============================================================================
publish_p2b() {
    log_section "PRIORITY 2B -- 2023 Layers"

    # Wetland Delineations
    log "--- Wetland Delineations ---"
    publish_layer "tomahawk_trail_wd" "$BACKLOAD_BASE/2023/tomahawk_trail_wd/wetland_tomahawk_trail_2023.gpkg"   "wetland_tomahawk_trail_2023"   "Tomahawk Trail Wetland Delineation 2023"        "2023"
    publish_layer "damascus_rd_wd"    "$BACKLOAD_BASE/2023/damascus_rd_wd/wetland_damascus_rd_2023.gpkg"         "wetland_damascus_rd_2023"      "Damascus Rd Wetland Delineation 2023"           "2023"
    publish_layer "blissett_wd"       "$BACKLOAD_BASE/2023/blissett_wd/wetland_blissett_2023.gpkg"               "wetland_blissett_2023"         "BBlissett Wetland and Wildlife Survey 2023"     "2023"
    publish_layer "dhague_wd"         "$BACKLOAD_BASE/2023/dhague_wd/wetland_dhague_2023.gpkg"                   "wetland_dhague_2023"           "DHague Wetland Delineation 2023"                "2023"
    publish_layer "linville_rd_wd"    "$BACKLOAD_BASE/2023/linville_rd_wd/wetland_linville_rd_2023.gpkg"         "wetland_linville_rd_2023"      "1869 Linville Rd Wetland Delineation 2023"      "2023"
    publish_layer "shell_harbor_wd"   "$BACKLOAD_BASE/2023/shell_harbor_wd/wetland_shell_harbor_2023.gpkg"       "wetland_shell_harbor_2023"     "Shell Harbor Rd Wetland Delineation 2023"       "2023"
    publish_layer "blossom_rd_wd"     "$BACKLOAD_BASE/2023/blossom_rd_wd/wetland_blossom_rd_2023.gpkg"           "wetland_blossom_rd_2023"       "Blossom Rd Wetland Delineation 2023"            "2023"
    publish_layer "6th_ave_wd"        "$BACKLOAD_BASE/2023/6th_ave_wd/wetland_6th_ave_2023.gpkg"                 "wetland_6th_ave_2023"          "6th Ave Wetland Delineation 2023"               "2023"
    publish_layer "quail_nest_wd"     "$BACKLOAD_BASE/2023/quail_nest_wd/wetland_quail_nest_2023.gpkg"           "wetland_quail_nest_2023"       "Quail Nest Barndominium Wetland Delineation 2023" "2023"
    publish_layer "crystal_view_wd"   "$BACKLOAD_BASE/2023/crystal_view_wd/wetland_crystal_view_2023.gpkg"       "wetland_crystal_view_2023"     "East Crystal View Wetland Delineation 2023"     "2023"
    publish_layer "ddeen_wd"          "$BACKLOAD_BASE/2023/ddeen_wd/wetland_ddeen_2023.gpkg"                     "wetland_ddeen_2023"            "DDeen Wetland Delineation 2023"                 "2023"

    # Arcadis Fort Lauderdale VA
    log "--- Arcadis Fort Lauderdale VA ---"
    publish_layer "arcadis_ftl_va"    "$BACKLOAD_BASE/2023/arcadis_ftl_va/vuln_ftl_ca_baseline_deliverable_2023.gpkg" "vuln_ftl_ca_baseline_deliverable_2023" "Ft Lauderdale VA - Baseline Critical Assets 2023"  "2023"
    publish_layer "arcadis_ftl_va"    "$BACKLOAD_BASE/2023/arcadis_ftl_va/vuln_ftl_exposure_deliverable_2023.gpkg"    "vuln_ftl_exposure_deliverable_2023"    "Ft Lauderdale VA - Flood Exposure 2023"            "2023"
    publish_layer "arcadis_ftl_va"    "$BACKLOAD_BASE/2023/arcadis_ftl_va/vuln_ftl_sensitivity_2023.gpkg"             "vuln_ftl_sensitivity_2023"             "Ft Lauderdale VA - Sensitivity Analysis 2023"      "2023"
    publish_layer "arcadis_ftl_va"    "$BACKLOAD_BASE/2023/arcadis_ftl_va/vuln_ftl_roadway_2023.gpkg"                 "vuln_ftl_roadway_2023"                 "Ft Lauderdale VA - Roadway Vulnerability 2023"     "2023"
    publish_layer "arcadis_ftl_va"    "$BACKLOAD_BASE/2023/arcadis_ftl_va/vuln_ftl_critical_community_em_2023.gpkg"   "vuln_ftl_critical_community_em_2023"   "Ft Lauderdale VA - Critical Community/Emergency"   "2023"
    publish_layer "arcadis_ftl_va"    "$BACKLOAD_BASE/2023/arcadis_ftl_va/vuln_ftl_critical_infrastructure_2023.gpkg" "vuln_ftl_critical_infrastructure_2023" "Ft Lauderdale VA - Critical Infrastructure"        "2023"
    publish_layer "arcadis_ftl_va"    "$BACKLOAD_BASE/2023/arcadis_ftl_va/vuln_ftl_natural_cultural_2023.gpkg"        "vuln_ftl_natural_cultural_2023"        "Ft Lauderdale VA - Natural and Cultural Resources" "2023"
    publish_layer "arcadis_ftl_va"    "$BACKLOAD_BASE/2023/arcadis_ftl_va/vuln_ftl_transportation_2023.gpkg"          "vuln_ftl_transportation_2023"          "Ft Lauderdale VA - Transportation Network"         "2023"
    publish_layer "arcadis_ftl_slr"   "$BACKLOAD_BASE/2023/arcadis_ftl_slr/slr_ftl_nih_2040_2023.gpkg"               "slr_ftl_nih_2040_2023"                 "Ft Lauderdale SLR - NIH Scenario 2040"             "2023"
    publish_layer "arcadis_ftl_slr"   "$BACKLOAD_BASE/2023/arcadis_ftl_slr/slr_ftl_nih_2070_2023.gpkg"               "slr_ftl_nih_2070_2023"                 "Ft Lauderdale SLR - NIH Scenario 2070"             "2023"
    publish_layer "arcadis_ftl_slr"   "$BACKLOAD_BASE/2023/arcadis_ftl_slr/slr_ftl_nih_2100_2023.gpkg"               "slr_ftl_nih_2100_2023"                 "Ft Lauderdale SLR - NIH Scenario 2100"             "2023"
    publish_layer "arcadis_ftl_slr"   "$BACKLOAD_BASE/2023/arcadis_ftl_slr/slr_ftl_nil_2040_2023.gpkg"               "slr_ftl_nil_2040_2023"                 "Ft Lauderdale SLR - NIL Scenario 2040"             "2023"
    publish_layer "arcadis_ftl_slr"   "$BACKLOAD_BASE/2023/arcadis_ftl_slr/slr_ftl_nil_2070_2023.gpkg"               "slr_ftl_nil_2070_2023"                 "Ft Lauderdale SLR - NIL Scenario 2070"             "2023"
    publish_layer "arcadis_ftl_slr"   "$BACKLOAD_BASE/2023/arcadis_ftl_slr/slr_ftl_nil_2100_2023.gpkg"               "slr_ftl_nil_2100_2023"                 "Ft Lauderdale SLR - NIL Scenario 2100"             "2023"
    publish_layer "arcadis_ftl_surge" "$BACKLOAD_BASE/2023/arcadis_ftl_surge/surge_ftl_2023.gpkg"                    "surge_ftl_2023"                        "Ft Lauderdale Storm Surge Extents 2023"            "2023"
    publish_layer "arcadis_ftl_surge" "$BACKLOAD_BASE/2023/arcadis_ftl_surge/surge_ftl_depth_grids_2023.gpkg"        "surge_ftl_depth_grids_2023"            "Ft Lauderdale Surge Depth Grids 2023"              "2023"

    # Other 2023
    log "--- Other 2023 ---"
    publish_layer "east_retta_env"    "$BACKLOAD_BASE/2023/east_retta_env/habitat_east_retta_2023.gpkg"          "habitat_east_retta_2023"       "East Retta Environmental Assessment 2023"       "2023"
    publish_layer "osprey_circle"     "$BACKLOAD_BASE/2023/osprey_circle/duediligence_osprey_circle_2023.gpkg"   "duediligence_osprey_circle_2023" "Osprey Circle Due Diligence 2023"              "2023"
    publish_layer "tree_9th_ave"      "$BACKLOAD_BASE/2023/tree_9th_ave/treesurvey_9th_ave_2023.gpkg"           "treesurvey_9th_ave_2023"       "1808 9th Ave Tree Replanting 2023"              "2023"
}

# =============================================================================
# Layer Group Creation (organize by year+type in GeoServer)
# =============================================================================
create_layer_groups() {
    local YEAR_VAL="$1"
    log_section "Creating Layer Groups for $YEAR_VAL"

    local GROUP_NAME="BL_${YEAR_VAL}_All"
    HTTP=$(curl -sk -u "admin:$PW" -X POST -H "Content-Type: application/json" \
        -d "{\"layerGroup\":{\"name\":\"$GROUP_NAME\",\"workspace\":{\"name\":\"$WS\"},\"mode\":\"NAMED\",\"title\":\"CVG Backload $YEAR_VAL -- All Layers\"}}" \
        -o /dev/null -w "%{http_code}" "$GS_BASE/rest/workspaces/$WS/layergroups" 2>/dev/null || echo "000")
    [ "$HTTP" = "201" ] && log_ok "Layer group created: $GROUP_NAME" || log_warn "Layer group $GROUP_NAME: HTTP $HTTP"
}

# =============================================================================
# Main dispatch
# =============================================================================
case "$YEAR" in
    "2025") publish_p1; create_layer_groups 2025 ;;
    "2024") publish_p2a; create_layer_groups 2024 ;;
    "2023") publish_p2b; create_layer_groups 2023 ;;
    "ALL")  publish_p1; publish_p2a; publish_p2b
            create_layer_groups 2025; create_layer_groups 2024; create_layer_groups 2023 ;;
    *) echo "Usage: $0 <2025|2024|2023|ALL> [GS_BASE_URL]"; exit 1 ;;
esac

log ""
log_section "PUBLISH COMPLETE"
log "Register: $PUBLISH_REGISTER"
log "Log:      $LOG_FILE"
log ""
log "Verify layers via WFS:"
log "  curl '$GS_BASE/wfs?service=WFS&version=2.0.0&request=GetCapabilities' | grep 'cvg:'"
log ""
log "NOTE: If GeoServer is not yet DNS-accessible externally, use internal URL:"
log "  GEOSERVER_ADMIN_PASSWORD=admin bash $0 ALL http://10.10.10.200:8080/geoserver"
