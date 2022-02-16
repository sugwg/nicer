#!/bin/bash
echo "Hello, world"
. /opt/conda/etc/profile.d/conda.sh
conda activate xpsi
mpiexec -n 40 python /srv/projects/nicer/j0030_run_test.py
