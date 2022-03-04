FROM continuumio/miniconda3:4.10.3

RUN apt-get update && \
    apt-get install -y \
    unzip \
    make \
    cmake \
    build-essential \
    git \
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

RUN curl https://download.open-mpi.org/release/open-mpi/v1.10/openmpi-1.10.6.tar.gz > /tmp/openmpi-1.10.6.tar.gz
RUN tar -zxvf /tmp/openmpi-1.10.6.tar.gz
RUN rm -f /tmp/openmpi-1.10.6.tar.gz
RUN cd openmpi-1.10.6 && ./configure
RUN cd openmpi-1.10.6 && make all
RUN cd openmpi-1.10.6 && make install
RUN rm -rf openmpi-1.10.6
RUN ldconfig -v

RUN curl -L https://raw.githubusercontent.com/ThomasEdwardRiley/xpsi/v0.7.5/environment.yml > /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml; exit 0
RUN rm -f /tmp/environment.yml

SHELL [ "conda", "run", "-n", "xpsi", "/bin/bash", "-c"]
RUN conda list
RUN conda init
RUN echo 'conda activate xpsi' >> ~/.bashrc

RUN mv /opt/conda/envs/xpsi/compiler_compat/ld /opt/conda/envs/xpsi/compiler_compat/ld.conda
RUN curl -L https://github.com/mpi4py/mpi4py/releases/download/3.0.0/mpi4py-3.0.0.tar.gz > /tmp/mpi4py-3.0.0.tar.gz
RUN tar -zxvf /tmp/mpi4py-3.0.0.tar.gz
RUN rm -f /tmp/mpi4py-3.0.0.tar.gz
COPY mpi.cfg mpi4py-3.0.0/mpi.cfg
RUN cd mpi4py-3.0.0 && python setup.py build
RUN cd mpi4py-3.0.0 && python setup.py install
RUN rm -rf mpi4py-3.0.0

RUN pip install GetDist==0.3.1 \
   nestcheck==0.2.0 \
   fgivenx


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

# You need to run the following otherwise everything gets installed properly but when you import xpsi in ipython shell, it gives error
RUN apt-get --assume-yes install libxi6 libgconf-2-4
 
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
RUN mkdir -p /.singularity.d/env
COPY .singularity.d/env/00-xpsi.sh /.singularity.d/env/00-xpsi.sh
USER xpsi
