#!/bin/bash -v
conda activate xpsi
jupyter notebook --ip 0.0.0.0 --port 8888 --no-browser --allow-root
