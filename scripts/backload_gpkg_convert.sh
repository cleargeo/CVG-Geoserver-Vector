#!/usr/bin/env bash
# =============================================================================
# CVG GeoServer Vector — Backload GPKG Conversion Script
# Author: Alex Zelenski, GISP | Clearview Geographic LLC
# Version: 1.0.0 | 2026-03-22
#
# PURPOSE:
#   Batch-convert ALL vector data for a given project year from raw format
#   (ArcGIS GDB, SHP, KML, GeoJSON, CSV) to GeoPackage (GPKG) for publishing
#   to vector.cleargeo.tech.
#
#   Handles ALL CVG vector types — wetland delineations, tree surveys,
#   habitat, municipal, coastal, floodplain, property, due diligence, etc.
#   NOT limited to SLR or storm surge data.
#
# REQUIREMENTS:
#   - GDAL/OGR >= 3.1 (ogr2ogr, ogrinfo)
#   - GDAL FileGDB driver (for reading ArcGIS GDBs)
#   - Read access to Z:\ (or NAS staging copy)
#   - Write access to /mnt/cgdp/backload/
#
# USAGE:
#   bash backload_gpkg_convert.sh <YEAR> [INPUT_DIR] [OUTPUT_DIR]
#
# EXAMPLES:
#   bash backload_gpkg_convert.sh 2026
#   bash backload_gpkg_convert.sh 2025 /mnt/cgps/backload/2025 /mnt/cgdp/backload/2025
#
# GDB CONVERSION NOTE:
#   ArcGIS File Geodatabases (.gdb) contain MULTIPLE feature classes.
#   This script uses a manifest CSV produced by the PowerShell inventory
#   script to know WHICH feature classes to extract from each GDB.
#   If no manifest exists, it lists all feature classes via ogrinfo and
#   converts them all.
# =============================================================================

set -euo pipefail

YEAR="${1:?Usage: $0 <YEAR> [INPUT_DIR] [OUTPUT_DIR]}"
INPUT_BASE="${2:-/mnt/cgps/backload/${YEAR}}"
OUTPUT_BASE="${3:-/mnt/cgdp/backload/${YEAR}}"
LOG_FILE="backload_gpkg_convert_${YEAR}_$(date +%Y%m%d_%H%M%S).log"
PROCESSING_LOG="backload_vector_processing_log.csv"
TARGET_CRS="EPSG:4326"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; ORANGE='\033[0;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; WHITE='\033[1;37m'; NC='\033[0m'

log()         { echo -e "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
log_success() { log "${GREEN}✓${NC} $*"; }
log_warn()    { log "${ORANGE}⚠${NC} $*"; }
log_error()   { log "${RED}✗${NC} $*"; }
log_section() { log "${CYAN}══ $* ══${NC}"; }

# CSV log header
if [ ! -f "$PROCESSING_LOG" ]; then
    echo "Timestamp,Year,ProjectSlug,SourceFile,FeatureClass,GeomType,SourceCRS,FeatCount,OutputGPKG,Status,Notes" \
         > "$PROCESSING_LOG"
fi

COUNT_TOTAL=0; COUNT_OK=0; COUNT_SKIP=0; COUNT_ERROR=0

log_section "CVG Backload GPKG Converter — Year $YEAR"
log "Source:  $INPUT_BASE"
log "Output:  $OUTPUT_BASE"
log ""

for dep in ogr2ogr ogrinfo; do
    if ! command -v "$dep" &>/dev/null; then
        log_error "Missing: $dep — install GDAL/OGR"
        exit 1
    fi
done
log_success "OGR $(ogr2ogr --version | head -1) — OK"

if [ ! -d "$INPUT_BASE" ]; then
    log_error "Input directory not found: $INPUT_BASE"
    exit 1
fi
mkdir -p "$OUTPUT_BASE"

# ── Helper: derive project slug from path ─────────────────────────────────────
get_slug() {
    local PATH_STR="$1"
    # Remove leading year/number prefix, lowercase, replace spaces with _
    echo "$PATH_STR" | \
        sed "s|.*/[0-9]\{4\}/||" | \
        cut -d'/' -f1 | \
        sed 's/^[0-9]*[_ -]*//' | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9]/_/g' | \
        sed 's/__*/_/g' | \
        sed 's/^_//;s/_$//'
}

# ── Helper: convert a single source to GPKG ───────────────────────────────────
convert_to_gpkg() {
    local INPUT="$1"
    local LAYER_NAME="$2"   # target layer name in GPKG (also filename)
    local PROJECT_SLUG="$3"
    local FEATURE_CLASS="${4:-}"   # for GDB extraction

    local OUT_DIR="${OUTPUT_BASE}/${PROJECT_SLUG}"
    local OUT_FILE="${OUT_DIR}/${LAYER_NAME}.gpkg"

    COUNT_TOTAL=$((COUNT_TOTAL + 1))

    log ""
    log_section "$LAYER_NAME"
    log "  Source:    $INPUT"
    [ -n "$FEATURE_CLASS" ] && log "  FC:        $FEATURE_CLASS"
    log "  Output:    $OUT_FILE"

    if [ -f "$OUT_FILE" ]; then
        log_warn "  Already exists — skipping"
        COUNT_SKIP=$((COUNT_SKIP + 1))
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$YEAR,$PROJECT_SLUG,$INPUT,$FEATURE_CLASS,,,,$OUT_FILE,skipped,already_exists" >> "$PROCESSING_LOG"
        return 0
    fi

    mkdir -p "$OUT_DIR"

    # Build ogr2ogr args
    local OGR_ARGS=(-f GPKG -t_srs "$TARGET_CRS" -nln "$LAYER_NAME" -overwrite)

    # Geometry validity repair
    OGR_ARGS+=(-makevalid)

    # Re-encode attributes to UTF-8
    OGR_ARGS+=(-lco ENCODING=UTF-8)

    # Feature class arg (GDB only)
    local FC_ARG=""
    [ -n "$FEATURE_CLASS" ] && FC_ARG="$FEATURE_CLASS"

    if ogr2ogr "${OGR_ARGS[@]}" "$OUT_FILE" "$INPUT" $FC_ARG >> "$LOG_FILE" 2>&1; then

        # Verify output
        local FEAT_COUNT; FEAT_COUNT=$(ogrinfo -al -so "$OUT_FILE" "$LAYER_NAME" 2>/dev/null | \
            grep "Feature Count" | awk '{print $NF}' || echo "unknown")
        local GEOM_TYPE; GEOM_TYPE=$(ogrinfo -al -so "$OUT_FILE" "$LAYER_NAME" 2>/dev/null | \
            grep "Geometry:" | awk '{print $NF}' || echo "unknown")

        if [ "$FEAT_COUNT" != "0" ] && [ "$FEAT_COUNT" != "unknown" ]; then
            log_success "  OK — $FEAT_COUNT features ($GEOM_TYPE)"
            COUNT_OK=$((COUNT_OK + 1))
            echo "$(date '+%Y-%m-%d %H:%M:%S'),$YEAR,$PROJECT_SLUG,$(basename "$INPUT"),$FEATURE_CLASS,$GEOM_TYPE,$TARGET_CRS,$FEAT_COUNT,$OUT_FILE,ok," >> "$PROCESSING_LOG"
        else
            log_warn "  Converted but 0 or unknown feature count — verify manually"
            echo "$(date '+%Y-%m-%d %H:%M:%S'),$YEAR,$PROJECT_SLUG,$(basename "$INPUT"),$FEATURE_CLASS,$GEOM_TYPE,$TARGET_CRS,$FEAT_COUNT,$OUT_FILE,warn_empty," >> "$PROCESSING_LOG"
        fi
    else
        log_error "  ogr2ogr FAILED — see $LOG_FILE"
        COUNT_ERROR=$((COUNT_ERROR + 1))
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$YEAR,$PROJECT_SLUG,$(basename "$INPUT"),$FEATURE_CLASS,,,,$OUT_FILE,error," >> "$PROCESSING_LOG"
    fi
}

# ── Process GDB directories ───────────────────────────────────────────────────

log_section "Processing ArcGIS GDB directories (primary CVG source)"

while IFS= read -r -d '' GDB_DIR; do
    PROJECT_SLUG=$(get_slug "$GDB_DIR")
    GDB_NAME=$(basename "$GDB_DIR" .gdb)

    log ""
    log "GDB: $GDB_DIR"
    log "  Slug: $PROJECT_SLUG"

    # List all feature classes in this GDB
    FC_LIST=$(ogrinfo -ro -al -so "$GDB_DIR" 2>/dev/null | \
        grep "^[0-9]*: " | \
        grep -v "^1: " | \
        awk '{print $2}' | \
        grep -v "^$" || true)

    # Fallback: try layer listing
    if [ -z "$FC_LIST" ]; then
        FC_LIST=$(ogrinfo -ro "$GDB_DIR" 2>/dev/null | \
            grep -E "^[0-9]+:" | sed 's/^[0-9]*: //;s/ (.*//' || true)
    fi

    if [ -z "$FC_LIST" ]; then
        log_warn "  Could not list feature classes — may need FileGDB driver or check GDB integrity"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$YEAR,$PROJECT_SLUG,$(basename "$GDB_DIR"),,,,,$GDB_DIR,error_no_fc_list,install FileGDB driver" >> "$PROCESSING_LOG"
        continue
    fi

    while IFS= read -r FC; do
        [ -z "$FC" ] && continue

        # Skip system/internal tables
        echo "$FC" | grep -qiE "^GDB_|^a0000|^File_" && continue

        # Build layer name: typeCode derived from GDB+FC name heuristic
        LAYER_NAME="${PROJECT_SLUG}_${FC,,}"
        LAYER_NAME=$(echo "$LAYER_NAME" | sed 's/[^a-z0-9_]/_/g' | sed 's/__*/_/g')

        convert_to_gpkg "$GDB_DIR" "$LAYER_NAME" "$PROJECT_SLUG" "$FC"
    done <<< "$FC_LIST"

done < <(find "$INPUT_BASE" -type d -name "*.gdb" -print0)

# ── Process standalone vector files ───────────────────────────────────────────

log_section "Processing standalone vector files (.shp, .gpkg, .geojson, .kml, .kmz)"

for EXT in shp geojson json kml kmz gpx; do
    while IFS= read -r -d '' VEC_FILE; do
        PROJECT_SLUG=$(get_slug "$VEC_FILE")
        FILE_BASE=$(basename "$VEC_FILE")
        FILE_NOEXT="${FILE_BASE%.*}"
        LAYER_NAME="${PROJECT_SLUG}_${FILE_NOEXT,,}"
        LAYER_NAME=$(echo "$LAYER_NAME" | sed 's/[^a-z0-9_]/_/g' | sed 's/__*/_/g')

        convert_to_gpkg "$VEC_FILE" "$LAYER_NAME" "$PROJECT_SLUG" ""
    done < <(find "$INPUT_BASE" -type f -iname "*.${EXT}" -print0)
done

# ── Process CSV with lat/lon ──────────────────────────────────────────────────

log_section "Processing CSV point files"

while IFS= read -r -d '' CSV_FILE; do
    # Only process if header contains lat/lon indicators
    HEADER=$(head -1 "$CSV_FILE" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if echo "$HEADER" | grep -qE "lat|lon|longitude|latitude|x,|,y,|northing|easting"; then
        PROJECT_SLUG=$(get_slug "$CSV_FILE")
        FILE_BASE=$(basename "$CSV_FILE" .csv)
        LAYER_NAME="${PROJECT_SLUG}_${FILE_BASE,,}"
        LAYER_NAME=$(echo "$LAYER_NAME" | sed 's/[^a-z0-9_]/_/g' | sed 's/__*/_/g')
        OUT_DIR="${OUTPUT_BASE}/${PROJECT_SLUG}"
        OUT_FILE="${OUT_DIR}/${LAYER_NAME}.gpkg"
        mkdir -p "$OUT_DIR"

        log ""
        log "CSV → GPKG: $(basename "$CSV_FILE")"
        if ogr2ogr -f GPKG -t_srs "$TARGET_CRS" \
            -oo X_POSSIBLE_NAMES=Longitude,lon,long,x,Easting \
            -oo Y_POSSIBLE_NAMES=Latitude,lat,y,Northing \
            -oo KEEP_GEOM_COLUMNS=NO \
            "$OUT_FILE" "$CSV_FILE" >> "$LOG_FILE" 2>&1; then
            log_success "  OK"
            COUNT_OK=$((COUNT_OK + 1))
        else
            log_warn "  Could not auto-detect coordinates — skipping. Review manually."
        fi
    fi
done < <(find "$INPUT_BASE" -type f -iname "*.csv" -print0)

# ── Final Summary ─────────────────────────────────────────────────────────────

log ""
log_section "GPKG CONVERSION COMPLETE — Z:\\$YEAR"
log "  Total:    $COUNT_TOTAL"
log_success "  Success:  $COUNT_OK"
log_warn    "  Skipped:  $COUNT_SKIP"
log_error   "  Errors:   $COUNT_ERROR"
log ""
log "  Processing log: $PROCESSING_LOG"
log "  Detailed log:   $LOG_FILE"
log ""
if [ "$COUNT_ERROR" -gt 0 ]; then
    log_warn "  Check errors — FileGDB driver may be needed for some GDBs."
    log_warn "  Install: GDAL with FileGDB support, or use OpenFileGDB driver."
fi
log_success "  ✓ Ready for Phase 4: backload_publish_vector.sh $YEAR"
log ""
