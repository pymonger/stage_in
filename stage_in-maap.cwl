#!/usr/bin/env cwltool

cwlVersion: v1.1
class: CommandLineTool
$namespaces:
  cwltool: http://commonwl.org/cwltool#
hints:
  "cwltool:Secrets":
    secrets:
      - user_token
      - application_token
  DockerRequirement:
    dockerPull: 'pymonger/stage_in:0.0.1'
baseCommand:
  - /home/jovyan/stage_in/stage_in.py
  - maap
requirements:
  ShellCommandRequirement: {}
  NetworkAccess:
    networkAccess: true
  InitialWorkDirRequirement:
    listing:
      - entryname: maap.cfg
        entry: |
          [request]
          page_size = 20
          content_type = application/echo10+xml
          
          [service]
          maap_host =
          maap_token =
          tiler_endpoint =
          
          [maap_endpoint]
          search_granule_url = cmr/granules
          search_collection_url = cmr/collections
          algorithm_register = mas/algorithm
          algorithm_build = dps/algorithm/build
          mas_algo = mas/algorithm
          dps_job = dps/job
          wmts = wmts
          member = members/self
          member_dps_token = members/dps/userImpersonationToken
          requester_pays = members/self/awsAccess/requesterPaysBucket
          edc_credentials = members/self/awsAccess/edcCredentials/{endpoint_uri}
          s3_signed_url = members/self/presignedUrlS3/{bucket}/{key}
          query_endpoint = query/
          
          [aws]
          aws_access_key_id = ""
          aws_secret_access_key = ""
          user_upload_bucket = maap-landing-zone-gccops
          user_upload_directory = user-added/uploaded_objects
          
          [search]
          indexed_attributes = [
               "site_name,Site Name,string",
               "data_format,Data Format,string",
               "track_number,Track Number,float",
               "polarization,Polarization,string",
               "dataset_status,Dataset Status,string",
               "geolocated,Geolocated,boolean",
               "spat_res,Spatial Resolution,float",
               "samp_freq,Sampling Frequency,float",
               "acq_mode,Acquisition Mode,string",
               "band_ctr_freq,Band Center Frequency,float",
               "freq_band_name,Frequency Band Name,string",
               "swath_width,Swath Width,float",
               "field_view,Field of View,float",
               "laser_foot_diam,Laser Footprint Diameter,float",
               "pass_number,Pass Number,int",
               "revisit_time,Revisit Time,float",
               "flt_number,Flight Number,int",
               "number_plots,Number of Plots,int",
               "plot_area,Plot Area,float",
               "subplot_size,Subplot Size,float",
               "tree_ht_meas_status,Tree Height Measurement Status,boolean",
               "br_ht_meas_status,Breast Height Measurement Status,boolean",
               "br_ht,Breast Height,float",
               "beam,Beam,int",
               "intensity_status,intensity Status,boolean",
               "ret_dens,Return Density,float",
               "ret_per_pulse,Returns Per Pulse,string",
               "min_diam_meas,Minimum Diameter Measured,float",
               "allometric_model_appl,Allometric Model Applied,string",
               "stem_mapped_status,Stem Mapped Status,boolean",
               "br_ht_modeled_status,Breast Height Modeled Status,boolean",
               "flt_alt,Flight Altitude,float",
               "gnd_elev,Ground Elevation,float",
               "hdg,Heading,float",
               "swath_slant_rg_st_ang,Swath Slant Range Start Angle,float",
               "azm_rg_px_spacing,Azimuth Range Pixel Spacing,float",
               "slant_rg_px_spacing,Slant Range Pixel Spacing,float",
               "acq_type,Acquisition Type,string",
               "orbit_dir,Orbit Direction,string",
               "modis_pft,MODIS PFT,string",
               "wwf_ecorgn,WWF Ecoregion,string",
               "band_ctr_wavelength,Band Center Wavelength,float",
               "swath_slant_rg_end_ang,Swath Slant Range End Angle,float"
               ]

inputs:
  collection_concept_id:
    type: string
    inputBinding:
      position: 1
      shellQuote: false
      valueFrom: |
        "$(self)"
  readable_granule_name:
    type: string
    inputBinding:
      position: 2
      shellQuote: false
      valueFrom: |
        "$(self)"
  maap_host:
    type: string
    inputBinding:
      position: 3
      shellQuote: false
      prefix: '--maap_host'
      valueFrom: |
        "$(self)"
  #user_token:
  #  type: string
  #  inputBinding:
  #    position: 4
  #    shellQuote: false
  #    prefix: '--user_token'
  #    valueFrom: |
  #      "$(self)"
  #application_token:
  #  type: string
  #  inputBinding:
  #    position: 5
  #    shellQuote: false
  #    prefix: '--application_token'
  #    valueFrom: |
  #      "$(self)"

outputs:
  inputs_dir:
    type: Directory
    outputBinding:
      glob: 'inputs'
#  stdout_file:
#    type: stdout
#  stderr_file:
#    type: stderr
#stdout: stage_in-stdout.txt
#stderr: stage_in-stderr.txt
