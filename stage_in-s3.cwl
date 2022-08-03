#!/usr/bin/env cwltool

cwlVersion: v1.1
class: CommandLineTool
$namespaces:
  cwltool: http://commonwl.org/cwltool#
hints:
  "cwltool:Secrets":
    secrets:
      - aws_access_key_id
      - aws_secret_access_key
  DockerRequirement:
    dockerPull: 'pymonger/stage_in:0.0.1'
baseCommand:
  - /home/jovyan/stage_in/stage_in.py
  - s3
requirements:
  ShellCommandRequirement: {}
  NetworkAccess:
    networkAccess: true
  InitialWorkDirRequirement:
    listing:
      - entryname: .aws/credentials
        entry: |
          [default]
          output = json
          region = us-west-2
          aws_access_key_id = $(inputs.aws_access_key_id)
          aws_secret_access_key = $(inputs.aws_secret_access_key)

inputs:
  aws_access_key_id: string
  aws_secret_access_key: string 
  url:
    type: string
    inputBinding:
      position: 1
      shellQuote: false
      valueFrom: |
        "$(self)"
  unsigned:
    type: boolean
    inputBinding:
      position: 2
      prefix: -u

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
