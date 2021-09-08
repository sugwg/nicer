# nicer
Files for NICER reproducibility project

This repository contains a dockerfile for a Docker image that runs an XPSI tutorial jupyter notebook, as well as that jupyter notebook.

## Instructions:  
1. Clone this repository to an empty folder on your local machine  
2. Follow the instructions from here https://github.com/ThomasEdwardRiley/xpsi_workshop to download the NICER RMF, and put this file in `v0.7.5/model_data/`. Make sure the name of the file is `‘nicer_v1.01_rmf_matrix.txt’`
3. `cd` to `/nicer/docker` and run `docker build --tag xpsi .` . This takes ~15min to build on my laptop
4. `cd` back to `/nicer` and run `docker run -it -p 8888:8888 xpsi`
5. Then run `jupyter notebook --ip 0.0.0.0 --port 8888 --no-browser --allow-root` and copy+paste the notebook link into a browser
6. In the Jupyter notebook, click ‘Run all cells’. This takes ~15min on my laptop, and will generate output in both the jupyter notebook and the command line
