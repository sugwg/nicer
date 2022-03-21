# nicer
Files for NICER reproducibility project.

This repository is intended to streamline the use of XPSI (https://xpsi-group.github.io/xpsi/index.html) via a Docker container.

## Instructions to run the j0030 analysis code as a job on sugwg-condor

1. Clone this repository using `git clone https://github.com/sugwg/nicer.git ~/<nicer_path>` where `<nicer_path>` is where you want to clone the repository. 

2. Change the working directory `cd ~/<nicer_path>`, replacing `<nicer_path>` with where you cloned the repository.

3. If you want to build the docker container using the `Dockerfile`:
   1. Use the command `id` to check if you are in the docker group on `sugwg-condor`.  
   2. Use the command `docker build --no-cache --tag chaitanyaafle/nicer:<tag> -f Dockerfile .` to build the container, where one needs to specify a unique tag replacing `<tag>` and the container identifier `chaitanyaafle/nicer` can be changed to anything in OSG's docker_images.txt here https://github.com/opensciencegrid/cvmfs-singularity-sync/blob/master/docker_images.txt.
   3. Push the new container to Docker Hub using `docker push chaitanyaafle/nicer:<tag>`. After waiting ~a day, this docker image should sync with CVMFS and a singularity container built from the image should become available for use. 

4. Once the container is synced, you can use it to submit the analysis jobs. For example, to submit jobs using the build `chaitanyaafle/nicer:8d3b23d`, which is already synced successfully in CVMFS, verify that the correct container identifier and tag are present in the arguments: `/cvmfs/singularity.opensciencegrid.org/chaitanyaafle/nicer:8d3b23d` in the submitfile `submit.sub`. 
   NOTE: The docker image `chaitanyaafle/nicer:8d3b23d` is the latest one that works, and can be used to submit `PSR j0030+0451` analysis jobs.

5. Output directory and logs
   1. Make a directory to store the output of the analysis:`mkdir <output_directory>`.
   2. Make a directory to store the logs of the job: `mkdir <log_directory>`.

6. Changes to be made in the submitfile `submit.sub`:
   1. On lines 3, 4, 6, 7, 8, and 18 replace `<home_dir>` with the path to your home directory, and `<nicer_path>` to where you cloned the repository.  
   2. To use an already-synced container, e.g. `chaitanyaafle/nicer:8d3b23d`, verify that the correct container identifier and tag are present in the arguments on line 4: `/cvmfs/singularity.opensciencegrid.org/chaitanyaafle/nicer:8d3b23d`.
   3. On line 10, give the appropriate argument for the number of machines to be used, eg. `machine_count = 2`.
   4. On line 11, give the appropriate argument for number of nodes per machine to be used, eg. `request_cpus = 40`.
   5. Replace `<log_directory>` with the correct path on lines 6, 7, and 8.

7. Changes to be made in the python script `run_j0030.py`:
   1. Replace `<nicer_path>` to its appropriate value in `/srv/<nicer_path>/`... on lines 19, 23, 24, 25, 28, 30, 114, and 154.
   2. In `runtime_params`, the value of the key `'outputfiles_basename'` (line 154) should be `/srv/<nicer_path>/<output_directory>/run1_nlive1000_eff0.3_noCONST_noMM_noIS_tol-1`, with the appropriate replacements for `<nicer_path>` and `<output_directory>`.

8. Changes to be made in the executable `run_j0030.sh`, assuming `nicer/` was cloned to `~/<nicer_path>`:
      1. Replace `<nicer_path>` to its appropriate value in `/srv/<nicer_path>/run_j0030.py`... on line 8

9. Provide the correct path to `sshd.sh` in line 92 in `openmpiscript`, replacing `<home_dir>/<nicer_path>` to its correct value.

10. Submit the condor job: `condor_submit submit.sub`


