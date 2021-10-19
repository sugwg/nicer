# nicer
Files for NICER reproducibility project

This repository is intended to streamline the use of XPSI via a Docker container.

## Running the XPSI tutorial notebook:  
1. Clone this repository to your local machine:
    `git clone https://github.com/sugwg/nicer.git`
2. `cd` to `</path/to>/nicer` and build the docker container:
    `docker build --tag xpsi -f miniconda_base .`
3. Run the docker container:
    `docker run -it -p 8888:8888 xpsi`
4. Copy and paste the http link into a browser, replace the parentheses and their contents with just `127.0.0.1` so that the beginning of the url now reads `http://127.0.0.1:8888/?token=...`, and press enter
5. Click on the `modeling_0.7.5.ipynb` file to open the Jupyter notebook
6. From the header menu in the Jupyter notebook, click 'Cell' and then ‘Run All’. As the notebook runs, it will generate output both within the notebook and in the command line


## Running the J0030 analysis single-threaded
1. Clone this repository to your local machine:
    `git clone https://github.com/sugwg/nicer.git`
2. `cd` to `</path/to>/nicer` and checkout the 'j0030' branch:
    `git checkout j0030`
3. Build the docker container:
    `docker build --tag xpsi -f miniconda_base .`
4. Run the docker container:
    `docker run -it -p 8888:8888 xpsi`
5. Press 'ctrl+C', type 'y' and press enter when prompted to kill the notebook kernel
6. `cd` to `j0030/` and run `mpiexec -n 1 python main_run1.py`