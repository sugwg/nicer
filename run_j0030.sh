#!/bin/bash

set -x
echo "Hello, world" 
. /opt/conda/etc/profile.d/conda.sh
conda activate xpsi

python /srv/projects/nicer/run_j0030.py
