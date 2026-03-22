# =============================================================================
# CVG GeoServer Backload -- NAS Staging Copy Script
# Author: Alex Zelenski, GISP | Clearview Geographic LLC
# Version: 1.0.0 | 2026-03-22
#
# PURPOSE:
#   Copy P1+P2 source GDB directories from Z:\ to NAS staging area
#   (\\10.10.10.100\cgps\backload\) so the Linux VM can access them
#   for GDAL conversion and GeoServer publishing.
#
# USAGE:
#   powershell -ExecutionPolicy Bypass -File backload_stage_to_nas.ps1
#   powershell -ExecutionPolicy Bypass -File backload_stage_to_nas.ps1 -Year 2025
#   powershell -ExecutionPolicy Bypass -File backload_stage_to_nas.ps1 -Year ALL
#
# TARGET:  \\10.10.10.100\cgps\backload\{year}\{slug}\
#          (also accessible on Linux VM as /mnt/cgdp/backload/)
# =============================================================================

param(
    [string]$Year = "ALL",
    [string]$NASBackload = "\\10.10.10.100\cgps\backload",
    [string]$ZDrive = "Z:"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$COPY_LOG = Join-Path $PSScriptRoot ("backload_stage_log_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".csv")
$CountOK = 0; $CountSkip = 0; $CountErr = 0

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "  CVG Backload -- Stage GDBs to NAS" -ForegroundColor Cyan
Write-Host "  Source: Z:\  -->  Destination: $NASBackload" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

# Test NAS connectivity
if (-not (Test-Path $NASBackload)) {
    Write-Warning "NAS staging path not reachable: $NASBackload"
    Write-Warning "Ensure \\10.10.10.100\cgps is mounted or map it manually."
    Write-Warning "Trying to continue anyway -- will create local staging if NAS not available."
}

"Timestamp,Year,ProjectSlug,SourceGDB,DestPath,SizeMB,Status" | Out-File $COPY_LOG -Encoding UTF8

function Copy-GDB {
    param(
        [string]$SourceGDB,
        [string]$DestDir,
        [string]$YearVal,
        [string]$Slug
    )

    $gdbName = Split-Path $SourceGDB -Leaf
    $destGDB = Join-Path $DestDir $gdbName

    if (Test-Path $destGDB) {
        Write-Host ("  [SKIP] Already staged: " + $gdbName) -ForegroundColor DarkGray
        $script:CountSkip++
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + ",$YearVal,$Slug,$gdbName,$destGDB,,$Status" | Add-Content $COPY_LOG
        return
    }

    try {
        $null = New-Item -ItemType Directory -Path $DestDir -Force -ErrorAction SilentlyContinue
        Write-Host ("  [COPY] " + $gdbName + " --> " + $DestDir) -ForegroundColor Green
        Copy-Item -Path $SourceGDB -Destination $destGDB -Recurse -Force -ErrorAction Stop
        $sizeMB = [math]::Round((Get-ChildItem $destGDB -Recurse | Measure-Object Length -Sum).Sum / 1MB, 1)
        Write-Host ("         OK (" + $sizeMB + " MB)") -ForegroundColor White
        $script:CountOK++
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + ",$YearVal,$Slug,$gdbName,$destGDB,$sizeMB,ok" | Add-Content $COPY_LOG
    } catch {
        Write-Warning ("  [ERR ] " + $gdbName + " -- " + $_.Exception.Message)
        $script:CountErr++
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + ",$YearVal,$Slug,$gdbName,$destGDB,,error" | Add-Content $COPY_LOG
    }
}

# =============================================================================
# PRIORITY 1 -- Z:\2025
# =============================================================================
if ($Year -eq "2025" -or $Year -eq "ALL") {
    Write-Host ""
    Write-Host "--- PRIORITY 1: Z:\2025 ---" -ForegroundColor Yellow

    $p1_gdbs = @(
        # P1-A: Wetland Delineations
        @{ Src = "2025\2505 Seebeck WD\Seebeck Wetland\Seebeck Wetland.gdb"; Slug = "seebeck_wd" },
        @{ Src = "2025\2511A Barnes County Road 3 Wetland Delineation\APRX\2511A_BarnesCountyRd_WD\2511A_BarnesCountyRd_WD.gdb"; Slug = "barnes_county_rd3_wd" },
        @{ Src = "2025\2511A Barnes County Road 3 Wetland Delineation\APRX\2511A_BarnesCountyRd_WD\2511A barnes county WD Points.gdb"; Slug = "barnes_county_rd3_wd" },
        @{ Src = "2025\2515A Old New York Rd (Wilton) Wetland Deliniation\2515A Old New York Rd (Wilton) Wetland Deliniation\2515A Old New York Rd (Wilton) Wetland Deliniation.gdb"; Slug = "old_new_york_rd_wd" },
        @{ Src = "2025\2536 _ Wetland Delineation\A_Aclade Wetland Delineation\2_GIS\Aclalde_Wetland_Delineation\Acalade_Wetland_Delineation.gdb"; Slug = "aclade_wd" },

        # P1-B: City of Palatka VA
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Critical Asset Inventory.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Community and Cultural Facilities.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Education Facilities.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Emergency and Public Safety.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Government and Institutional.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Health and Human Services.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Infrastructure and Utilities.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Natural and Cultural.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\4_Baseline\Baseline_aprx\Transportation.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\5_Exposure\Palatka_VDatum\Palatka_VDatum.gdb"; Slug = "palatka_va" },
        @{ Src = "2025\2520 City of Palatka\A 380 Vulnerability Assessment\7_Data Share\25PLN18 Task 1 - Critical Asset Inventory\Critical Asset Inventory GIS Data\Critical Asset Inventory.gdb"; Slug = "palatka_va" },

        # P1-C: Marine Science Center (vector GDBs only - rasters handled separately)
        @{ Src = "2025\2517 Marine Science Center\A_Educational Display\01_Data\Artifical_Reefs\Artifical_Reef_Locations.gdb"; Slug = "marine_science_center" },
        @{ Src = "2025\2517 Marine Science Center\A_Educational Display\01_Data\Bathymetry\GEBCO_contours\GEBCO_contours_NCEI.gdb"; Slug = "marine_science_center" },
        @{ Src = "2025\2517 Marine Science Center\A_Educational Display\02_GIS\Display\Display.gdb"; Slug = "marine_science_center" },
        @{ Src = "2025\2517 Marine Science Center\A_Educational Display\02_GIS\Clip to shoreline.gdb"; Slug = "marine_science_center" },

        # P1-D: Due Diligence
        @{ Src = "2025\2507 Seagate Due Diligence\2507 Seagate\2507 Seagate.gdb"; Slug = "seagate_dd" },
        @{ Src = "2025\2516A Vargas Due Diligence\2516A Vargas Due Diligence\2516A Vargas Due Diligence.gdb"; Slug = "vargas_dd" },
        @{ Src = "2025\2539 JMcVey\Volusia_SFH_Woodshop_Env_Stewardship_DD\Due Diligence Mapping.gdb"; Slug = "jmcvey_dd" },

        # P1-E: Other 2025
        @{ Src = "2025\2540 ACastaneda_CJR Concrete Inc\A_BiologicalReview_Deland\SubjectParcel.gdb"; Slug = "cjr_concrete" }
    )

    foreach ($entry in $p1_gdbs) {
        $src = Join-Path $ZDrive $entry.Src
        if (Test-Path $src) {
            $destDir = Join-Path $NASBackload ("2025\" + $entry.Slug)
            Copy-GDB -SourceGDB $src -DestDir $destDir -YearVal "2025" -Slug $entry.Slug
        } else {
            Write-Warning ("  [MISS] Not found: " + $src)
        }
    }
}

# =============================================================================
# PRIORITY 2A -- Z:\2024
# =============================================================================
if ($Year -eq "2024" -or $Year -eq "ALL") {
    Write-Host ""
    Write-Host "--- PRIORITY 2A: Z:\2024 ---" -ForegroundColor Yellow

    $p2a_gdbs = @(
        @{ Src = "2024\2401 GFelix\Aprx\CG2401 Statistical Tree Survey\CG2401 Statistical Tree Survey.gdb"; Slug = "gfelix_tree_survey" },
        @{ Src = "2024\2402 RLanda\Aprx\CG2402 Wetland Delineation\CG2402 Wetland Delineation.gdb"; Slug = "rlanda_wd" },
        @{ Src = "2024\2402 RLanda\Aprx\CG2402 Wetland Delineation\OHWL.gdb"; Slug = "rlanda_wd" },
        @{ Src = "2024\2413 CMurphy\Aprx\DeLand Tree Survey and Wetland Delineation\DeLand Tree Survey and Wetland Delineation.gdb"; Slug = "cmurphy_deland" }
    )

    foreach ($entry in $p2a_gdbs) {
        $src = Join-Path $ZDrive $entry.Src
        if (Test-Path $src) {
            $destDir = Join-Path $NASBackload ("2024\" + $entry.Slug)
            Copy-GDB -SourceGDB $src -DestDir $destDir -YearVal "2024" -Slug $entry.Slug
        } else {
            Write-Warning ("  [MISS] Not found: " + $src)
        }
    }
}

# =============================================================================
# PRIORITY 2B -- Z:\2023 (key deliverable GDBs only, not all 136)
# =============================================================================
if ($Year -eq "2023" -or $Year -eq "ALL") {
    Write-Host ""
    Write-Host "--- PRIORITY 2B: Z:\2023 (key GDBs) ---" -ForegroundColor Yellow

    $p2b_gdbs = @(
        # Wetland delineations
        @{ Src = "2023\2308 SWoolley\Tomahawk Trail Wetland Delineation\Tomahawk Trail Wetland Delineation.gdb"; Slug = "tomahawk_trail_wd" },
        @{ Src = "2023\2310 CHaas\A_Damascus Rd WD\Damascus Rd Wetland Delineation.gdb"; Slug = "damascus_rd_wd" },
        @{ Src = "2023\2313 BBlissett\Project Maps\2313 Wetland and Wildlife Survey\2313 Wetland and Wildlife Survey.gdb"; Slug = "blissett_wd" },
        @{ Src = "2023\2314 DHague\Wetland Delineation Aprx\2314 Wetland Delineation\2314 Wetland Delineation.gdb"; Slug = "dhague_wd" },
        @{ Src = "2023\2316 VFlaherty\Wetland Aprx\1869 Linville Road\1869 Linville Road.gdb"; Slug = "linville_rd_wd" },
        @{ Src = "2023\2322 GMorello\Wetland APRX\Shell Harbor Rd\Shell Harbor Rd.gdb"; Slug = "shell_harbor_wd" },
        @{ Src = "2023\2324 CBlack\Wetland APRX\Blossom Rd\Blossom Rd.gdb"; Slug = "blossom_rd_wd" },
        @{ Src = "2023\2327 RJones\Wetland APRX\6th Ave\6th Ave.gdb"; Slug = "6th_ave_wd" },
        @{ Src = "2023\2329 WGuzman\A Quail Nest Barndominium\Aprx\CG2329 Wetland Delineation\CG2329 Wetland Delineation.gdb"; Slug = "quail_nest_wd" },
        @{ Src = "2023\2331 MWest\East Crystal View\East Crystal View.gdb"; Slug = "crystal_view_wd" },
        @{ Src = "2023\2334 DDeen\Aprx\CG2334 DDeen\CG2334 DDeen.gdb"; Slug = "ddeen_wd" },

        # Arcadis Fort Lauderdale VA -- final deliverables only
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\9_DataShares\Fort Lauderdale_Baseline Critical Asset Inventory.gdb"; Slug = "arcadis_ftl_va" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\9_DataShares\Fort Lauderdale_Exposure.gdb"; Slug = "arcadis_ftl_va" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\9_DataShares\Fort Lauderdale_Sensitivity Analyis.gdb"; Slug = "arcadis_ftl_va" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\9_DataShares\FTL_RoadwayAnalysisData.gdb"; Slug = "arcadis_ftl_va" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\4_Baseline Layout\0_Baseline APRX\380 FtLauderdale Critical Com Em.gdb"; Slug = "arcadis_ftl_va" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\4_Baseline Layout\0_Baseline APRX\380 FtLauderdale Critical Infrastructure.gdb"; Slug = "arcadis_ftl_va" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\4_Baseline Layout\0_Baseline APRX\380 FtLauderdale Natural and Cultural.gdb"; Slug = "arcadis_ftl_va" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\4_Baseline Layout\0_Baseline APRX\380 FtLauderdale Transportation.gdb"; Slug = "arcadis_ftl_va" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\5_Flood Projection\2_SLR Projections\SLR+Exceedance1\SLR_NIH 2040.gdb"; Slug = "arcadis_ftl_slr" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\5_Flood Projection\2_SLR Projections\SLR+Exceedance1\SLR_NIH 2070.gdb"; Slug = "arcadis_ftl_slr" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\5_Flood Projection\2_SLR Projections\SLR+Exceedance1\SLR_NIH 2100.gdb"; Slug = "arcadis_ftl_slr" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\5_Flood Projection\2_SLR Projections\SLR+Exceedance1\SLR_NIL 2040.gdb"; Slug = "arcadis_ftl_slr" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\5_Flood Projection\2_SLR Projections\SLR+Exceedance1\SLR_NIL 2070.gdb"; Slug = "arcadis_ftl_slr" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\5_Flood Projection\2_SLR Projections\SLR+Exceedance1\SLR_NIL 2100.gdb"; Slug = "arcadis_ftl_slr" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\5_Flood Projection\Fort Lauderdale Surge\Fort Lauderdale Surge.gdb"; Slug = "arcadis_ftl_surge" },
        @{ Src = "2023\2311 Arcadis\A_Fort Lauderdale\5_Flood Projection\Depth Grid Processing\FTL_DepthGrids.gdb"; Slug = "arcadis_ftl_surge" },

        # Other 2023
        @{ Src = "2023\2303 DTorres\2301 East Retta Environmental Assessment\2301 East Retta Environmental Assessment.gdb"; Slug = "east_retta_env" },
        @{ Src = "2023\2304 JBurkhardt\CG2304 Opsrey Circle\CG2304 Opsrey Circle.gdb"; Slug = "osprey_circle" },
        @{ Src = "2023\2306 SMcIntosh\1808 9th Ave Tree Replianting\1808 9th Ave Tree Replianting.gdb"; Slug = "tree_9th_ave" }
    )

    foreach ($entry in $p2b_gdbs) {
        $src = Join-Path $ZDrive $entry.Src
        if (Test-Path $src) {
            $destDir = Join-Path $NASBackload ("2023\" + $entry.Slug)
            Copy-GDB -SourceGDB $src -DestDir $destDir -YearVal "2023" -Slug $entry.Slug
        } else {
            Write-Warning ("  [MISS] Not found: " + $src)
        }
    }
}

# =============================================================================
# Summary
# =============================================================================
Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ("  STAGING COMPLETE") -ForegroundColor Green
Write-Host ("  Copied: " + $CountOK + "  |  Skipped: " + $CountSkip + "  |  Errors: " + $CountErr) -ForegroundColor White
Write-Host ("  Log: " + $COPY_LOG) -ForegroundColor White
Write-Host ""
Write-Host "  NEXT: On Linux VM (10.10.10.200):" -ForegroundColor Yellow
Write-Host "    bash backload_gpkg_convert.sh 2025 /mnt/cgdp/backload/2025 /mnt/cgdp/backload/2025" -ForegroundColor White
Write-Host "    bash backload_gpkg_convert.sh 2024 /mnt/cgdp/backload/2024 /mnt/cgdp/backload/2024" -ForegroundColor White
Write-Host "    bash backload_gpkg_convert.sh 2023 /mnt/cgdp/backload/2023 /mnt/cgdp/backload/2023" -ForegroundColor White
Write-Host "=====================================================================" -ForegroundColor Cyan
