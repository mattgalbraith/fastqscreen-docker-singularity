[![Docker Image CI](https://github.com/mattgalbraith/fastqscreen-docker-singularity/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mattgalbraith/samtools-fastqscreen-singularity/actions/workflows/docker-image.yml)
# fastqscreen-docker-singularity
## Build Docker container for FastQ Screen software and (optionally) convert to Apptainer/Singularity.  
FastQ Screen allows you to screen a library of sequences in FastQ format against a set of sequence databases so you can see if the composition of the library matches with what you expect.  
  
#### Requirements:
Perl
Bowtie, Bowtie2 (default) or BWA
wget (optional but required for --get_genomes)
gzip (optional)
SAMtools (optional)
GD::Graph (optional)
Bismark (bisulfite mapping only)
References genome indices (up to 32) 
fastq_screen.conf file with reference info (will keep outside container and pass with --conf)
Test Dataset (optional)
  
## Build docker container:  

Not using Conda to keep image size small.  
### 1. For FastQC installation instructions:  
https://stevenwingett.github.io/FastQ-Screen/  
See also:
https://github.com/StevenWingett/FastQ-Screen  


### 2. Build the Docker Image

#### To build image from the command line:  
``` bash
# Assumes current working directory is the top-level fastqc-docker-singularity directory
docker build -t fastqscreen:0.15.2 . # tag should match software version
```
* Can do this on [Google shell](https://shell.cloud.google.com)

#### To test this tool from the command line:

``` bash
docker run --rm -it fastqscreen:0.15.2 fastqc --help
```

#### (Optional) Download pre-built Bowtie2 indices of commonly used genomes downloaded directly from the Babraham Bioinformatics website
Alternatively, build genome indices for aligner(s) of choice from FASTA files according to aligner instructions and add to fastq_screen.conf file
``` bash
docker run -it --rm -v ${PWD}:/data -w /data fastq_screen:test fastq_screen --get_genomes --outdir /data/References
```

#### Set up fastq_screen.conf file  


#### Run with test data  
``` bash
wget https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/fastq_screen_test_dataset.tar.gz && tar -xzvf fastq_screen_test_dataset.tar.gz

REFERENCES_DIR=/path/to/references

docker run -it --rm -v ${PWD}:/data -w /data -v ${REFERENCES_DIR}:/references fastq_screen:test fastq_screen FASTQ
# -v ${PWD}:/data mounts current working dir as /data in container
# -w /data sets working dir in container
# -v ${REFERENCES_DIR}:/references mounts REFERENCES_DIR as /references in container

# SUCCESSFUL TEST RESULT: 
```

## Optional: Conversion of Docker image to Singularity  

### 3. Build a Docker image to run Singularity  
(skip if this image is already on your system)  
https://github.com/mattgalbraith/singularity-docker

### 4. Save Docker image as tar and convert to sif (using singularity run from Docker container)  
``` bash
docker images
docker save <Image_ID> -o fastqscreen-docker.tar && gzip fastqscreen-docker.tar # = IMAGE_ID of fastqc image
docker run -v "$PWD":/data --rm -it singularity bash -c "singularity build /data/fastqscreen.sif docker-archive:///data/fastqscreen-docker.tar.gz"
```
NB: On Apple M1/M2 machines ensure Singularity image is built with x86_64 architecture or sif may get built with arm64  

Next, transfer the fastqscreen.sif file to the system on which you want to run FastQC from the Singularity container  

### 5. Test singularity container on (HPC) system with Singularity/Apptainer available  
``` bash
# set up path to the FastQ Screen Singularity container
FASTQ_SCREEN_SIF=path/to/fastqscreen.sif

# Test that FastQ Screen can run from Singularity container
singularity run $FASTQ_SCREEN_SIF fastq_screen --help # depending on system/version, singularity may be called apptainer
```