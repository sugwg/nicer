FROM continuumio/miniconda3

SHELL ["/bin/bash","-c"]

RUN apt-get update && \
    apt-get install -y \
    unzip \
    wget \
    make \
    cmake \
    build-essential \
    git \
    ssh \
    vim \
    libblas3 \
    libblas-dev \
    liblapack3 \
    liblapack-dev \
    libatlas3-base \
    libatlas-base-dev \
    gfortran \
    gsl-bin \
    libgsl-dev \
    curl \
    libsm6 \
    libxext6 \
    libgl1-mesa-glx

RUN pip install GetDist==0.3.1 \
    nestcheck==0.2.0 \
    fgivenx

RUN conda install -y \
    scipy \
    matplotlib

# Conda env creation, and tell shell to start conda on opening (may not need the last bit)
RUN curl -L https://raw.githubusercontent.com/ThomasEdwardRiley/xpsi/v0.7.5/environment.yml > /tmp/environment.yml && \
    conda env create -f /tmp/environment.yml; exit 0 && \
    conda init && \
    echo 'conda activate xpsi' >> ~/.bashrc

# Jupyter stuff
SHELL [ "conda", "run", "-n", "xpsi", "/bin/bash", "-c"]
RUN python -m ipykernel install --name xpsi --display-name "XPSI Notebook"

# Manually installing the correct OpenMPI version
RUN wget https://download.open-mpi.org/release/open-mpi/v1.6/openmpi-1.6.5.tar.gz && \
    tar -xvf openmpi-1.6.5.tar.gz && \
    cd openmpi-1.6.5/ && \
    ./configure && \
    make all && \
    make install && \
    echo "export PATH=\$PATH:\$HOME/opt/openmpi/bin" >> $HOME/.bashrc && \
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$HOME/opt/openmpi/lib" >> $HOME/.bashrc && \
    ls
# The last line, ls, is necessary for this RUN block to complete through line 57. Not sure why

# Install MultiNest
RUN ldconfig && \
    git clone https://github.com/farhanferoz/MultiNest.git /opt/multinest-a2b1b5feb5 && \
    cd /opt/multinest-a2b1b5feb5 && \
    git checkout a2b1b5feb5 && \
    cd /opt/multinest-a2b1b5feb5/MultiNest_v3.11_CMake/multinest/ && \
    mkdir build && \
    cd build && \
    CC=gcc FC=mpif90 CXX=g++ cmake -DCMAKE_{C,CXX}_FLAGS="-O3 -march=native -funroll-loops" -DCMAKE_Fortran_FLAGS="-O3 -march=native -funroll-loops" .. && \
    make
ENV LD_LIBRARY_PATH=/opt/multinest-a2b1b5feb5/MultiNest_v3.11_CMake/multinest/lib:$LD_LIBRARY_PATH

#Install mpi4py
COPY mpi4py-3.0.0.tar.gz .
RUN tar -zxf mpi4py-3.0.0.tar.gz && \
    cd mpi4py-3.0.0 && \
    python setup.py build && \
    python setup.py install && \
    mpiexec -n 2 python -m mpi4py.bench helloworld > mpi4py_test.txt

# Install PyMultiNest
RUN git clone https://github.com/JohannesBuchner/PyMultiNest.git && \
    cd PyMultiNest/ && \
    python setup.py install

# Make xpsi user, switch to that user's directory
RUN useradd xpsi -m
WORKDIR /home/xpsi

# Clone and install xpsi
RUN git clone https://github.com/ThomasEdwardRiley/xpsi.git && \
    cd /home/xpsi/xpsi && \
    git checkout v0.1 && \
    CC=/usr/bin/gcc python setup.py install
  
# Copy necessary files, giving file ownership to xpsi user
COPY --chown=xpsi \
    tutorial/data/new_synthetic_expected_hreadable.dat \
    tutorial/data/new_synthetic_realisation.dat \
    tutorial/data/new_synthetic_realisation_hreadable.dat \
    tutorial/data/synthetic_expected_hreadable.dat \
    tutorial/data/synthetic_realisation.dat \
    tutorial/data/synthetic_realisation_hreadable.dat \
    tutorial/data/

COPY --chown=xpsi \
    tutorial/model_data/nicer_v1.01_arf.txt \
    tutorial/model_data/nicer_v1.01_rmf_energyintervals.txt \
    tutorial/model_data/nicer_v1.01_rmf_energymap.txt \
    tutorial/model_data/nicer_v1.01_rmf_matrix.txt \
    tutorial/model_data/

COPY --chown=xpsi \
    tutorial/run/run.txt \
    tutorial/run/rundead-birth.txt \
    tutorial/run/runev.dat \
    tutorial/run/runlive.points \
    tutorial/run/runphys_live-birth.txt \
    tutorial/run/runphys_live.points \
    tutorial/run/runpost_equal_weights.dat \
    tutorial/run/runresume.dat \
    tutorial/run/runstats.dat \
    tutorial/run/runsummary.txt \
    tutorial/run/

COPY --chown=xpsi tutorial/modeling_0.7.5.ipynb tutorial/

COPY --chown=xpsi \
    A_NICER_VIEW_OF_PSR_J0030p0451/ST_PST/CustomData.py \
    A_NICER_VIEW_OF_PSR_J0030p0451/ST_PST/CustomInstrument.py \
    A_NICER_VIEW_OF_PSR_J0030p0451/ST_PST/CustomInterstellar.py \
    A_NICER_VIEW_OF_PSR_J0030p0451/ST_PST/CustomPhotosphere.py \
    A_NICER_VIEW_OF_PSR_J0030p0451/ST_PST/CustomPrior.py \
    A_NICER_VIEW_OF_PSR_J0030p0451/ST_PST/CustomPulse.py \
    A_NICER_VIEW_OF_PSR_J0030p0451/ST_PST/CustomSpacetime.py \
    A_NICER_VIEW_OF_PSR_J0030p0451/ST_PST/main_run1.py \
    j0030/

COPY --chown=xpsi \
    A_NICER_VIEW_OF_PSR_J0030p0451/data/NICER_J0030_PaulRay_fixed_evt_25to299__preprocessed.txt \
    j0030/data/

COPY --chown=xpsi \
    A_NICER_VIEW_OF_PSR_J0030p0451/model_data/crab_ratio_SA80_d49.txt \
    A_NICER_VIEW_OF_PSR_J0030p0451/model_data/interstellar_phot_frac.txt \
    A_NICER_VIEW_OF_PSR_J0030p0451/model_data/ni_xrcall_onaxis_v1.02_arf.txt \
    A_NICER_VIEW_OF_PSR_J0030p0451/model_data/nicer_upd_d49_matrix.txt \
    A_NICER_VIEW_OF_PSR_J0030p0451/model_data/nicer_upd_energy_bounds.txt \
    A_NICER_VIEW_OF_PSR_J0030p0451/model_data/nsx_H_v171019.out \
    A_NICER_VIEW_OF_PSR_J0030p0451/model_data/README_v171019.txt \
    j0030/model_data/

RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/xpsi/.bashrc && echo "conda activate xpsi" >> /home/xpsi/.bashrc
RUN mkdir /var/lib/condor
USER xpsi
