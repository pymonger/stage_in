# stage_in
Example CWL documents exercising stage-in from various sources.

## Building the container image
```
pip install jupyter-repo2docker
git clone https://github.com/pymonger/stage_in.git
cd stage_in
repo2docker --user-id 1000 --user-name jovyan \
  --target-repo-dir /home/jovyan/stage_in \
  --no-run --image-name pymonger/stage_in:latest .
```

## Running cwltool

### Prerequisites

1. Clone repo:
   ```
   cd /tmp
   git clone https://github.com/pymonger/stage_in.git
   cd stage_in
   ```
1. Create virtualenv:
   ```
   virtualenv env
   source env/bin/activate
   ```
1. Install `cwltool`:
   ```
   pip install cwltool
   ```
