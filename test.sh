#!/bin/bash
set -ex

rm -rf inputs
./stage_in.py maap C1200110748-NASA_MAAP SC:ABLVIS1B.001:129488185
./stage_in.py http https://data.ornldaac.earthdata.nasa.gov/protected/gedi/GEDI_L4A_AGB_Density_V2_1/data/GEDI04_A_2019107224731_O01958_01_T02638_02_002_02_V002.h5
./stage_in.py s3 s3://copernicus-dem-30m/Copernicus_DSM_COG_10_N21_00_W159_00_DEM/Copernicus_DSM_COG_10_N21_00_W159_00_DEM.tif -u
