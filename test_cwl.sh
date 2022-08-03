#!/bin/bash
set -ex

rm -rf inputs
cwltool --no-match-user --no-read-only stage_in-maap.cwl stage_in-maap-inputs.yml 
cwltool --no-match-user --no-read-only stage_in-http.cwl stage_in-http-inputs.yml 
cwltool --no-match-user --no-read-only stage_in-s3.cwl stage_in-s3-inputs.yml 
