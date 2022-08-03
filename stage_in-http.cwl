#!/usr/bin/env cwltool

cwlVersion: v1.1
class: CommandLineTool
$namespaces:
  cwltool: http://commonwl.org/cwltool#
hints:
  "cwltool:Secrets":
    secrets:
      - urs_username
      - urs_password
  DockerRequirement:
    dockerPull: 'pymonger/stage_in:0.0.1'
baseCommand:
  - /home/jovyan/stage_in/stage_in.py
  - http
requirements:
  ShellCommandRequirement: {}
  NetworkAccess:
    networkAccess: true
  InitialWorkDirRequirement:
    listing:
      - entryname: .netrc
        entry: |
          machine urs.earthdata.nasa.gov login $(inputs.urs_username) password $(inputs.urs_password)
          macdef init

          machine uat.urs.earthdata.nasa.gov login $(inputs.urs_username) password $(inputs.urs_password)
          macdef init
 
inputs:
  url:
    type: string
    inputBinding:
      position: 1
      shellQuote: false
      valueFrom: |
        "$(self)"

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
