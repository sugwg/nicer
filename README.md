# nicer
Files for NICER reproducibility project.

This repository is intended to streamline the use of XPSI (https://xpsi-group.github.io/xpsi/index.html) via a Docker container.

## Running the j0030 code as a job on sugwg-condor

1. Clone this repository: `git clone https://github.com/sugwg/nicer.git ~/<nicer_path>` where `<nicer_path>` is where you want to clone the repository. 
2. `cd ~/<nicer_path>`
3. Build the docker container, giving it an appropriate tag to have it synced with CVMFS: `docker build --tag chaitanyaafle/nicer:<tag> -f Dockerfile .` where one needs to specify a unique tag replacing `<tag>` and the container identifier `chaitanyaafle/nicer` can be changed to anything in OSG's docker_images.txt here https://github.com/opensciencegrid/cvmfs-singularity-sync/blob/master/docker_images.txt.
4. Push the new container to Docker Hub: `docker push chaitanyaafle/nicer:<tag>`
5.After waiting ~a day, this docker image should sync with CVMFS and a singularity container built from the image should become available for use. 
6. Changes to be made in the submitfile `submit.sub`:
    1. To use an already-synced container, e.g. `chaitanyaafle/nicer:f96934c`,  open the submitfile `submit.sub` and on line 2, verify that the correct container identifier and tag are present in the arguments: `/cvmfs/singularity.opensciencegrid.org/chaitanyaafle/nicer:f96934c`.
    2. On line 2, change `/home/chaitanya.afle:/srv` to `/home/<dir>:/srv` where `<dir>` is your home directory on `sugwg-condor`
    3. On line 2, change to `/srv/<nicer_path>/nicer/run_j0030.sh`
    4. Verify the name of the `<output_directory>` on lines 4, 5, and 6.
7. Changes to be made in the python script `run_j0030.py`:
    1. Replace `<nicer_path>` to its appropriate value in `/srv/<nicer_path>/nicer/`... on lines 18, 22, 23, 24, 27, 29, and 112
    2. In `runtime_params`, the value of the key `'outputfiles_basename'` should be `/srv/<nicer_path>/<output_directory>/`.
8. Changes to be made in the executable `run_j0030.sh`, assuming `nicer/` was cloned to `~/<path>`:
    1. Replace `<nicer_path>` to its appropriate value in `/srv/<nicer_path>/nicer/`... on line 5

8. Submit the condor job: `condor_submit submit.sub`


## To change the number of threads with the job will run
Make the following changes:

1. In `submit.sub`: on line 8, `change request_cpus = 40` to `request_cpus = <N>`, where `<N>` is your preferred number of threads.

2. In `run_j0030.sh`: on line 5, change `mpiexec -n 40` to `mpiexec -n <N>`, where `<N>` is your preferred number of threads.

