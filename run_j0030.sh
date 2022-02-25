#!/bin/bash
echo "Hello, world"
. /opt/conda/etc/profile.d/conda.sh
conda activate xpsi
mpiexec -n 480 python /srv/projects/nicer/run_j0030.py
