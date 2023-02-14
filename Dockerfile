################## BASE IMAGE ######################
FROM --platform=linux/amd64 ubuntu:20.04 as base

################## METADATA ######################
LABEL base_image="Ubuntu:20.04"
LABEL version="1.0.0"
LABEL software="FastQ Screen"
LABEL software.version="0.15.2"
LABEL about.summary="FastQ Screen allows you to screen a library of sequences in FastQ format against a set of sequence databases so you can see if the composition of the library matches with what you expect."
LABEL about.home="https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/"
LABEL about.documentation="https://stevenwingett.github.io/FastQ-Screen/"
LABEL about.license_file="https://github.com/StevenWingett/FastQ-Screen/blob/v0.15.2/license.txt"
LABEL about.license="GNU GPL v3"

################## MAINTAINER ######################
MAINTAINER Matthew Galbraith <matthew.galbraith@cuanschutz.edu>

################## INSTALLATION ######################
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES tar wget unzip ca-certificates
# add wget if downloading  directly

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# # Get and extract FastQ Screen
# COPY v0.15.2.tar.gz /
# RUN tar -xzvf v0.15.2.tar.gz

# Download and extract FastQ Screen
RUN wget https://github.com/StevenWingett/FastQ-Screen/archive/refs/tags/v0.15.2.tar.gz && \
	tar -xzvf v0.15.2.tar.gz

# Download and extract Bowtie2
RUN wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.5.1/bowtie2-2.5.1-linux-x86_64.zip && \
	unzip bowtie2-2.5.1-linux-x86_64.zip


################## 2ND STAGE ######################
FROM --platform=linux/amd64 ubuntu:20.04
# ARG ENV_NAME="fastq_screen"
# ARG FASTQC_VERSION="0.15.2"
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES libfindbin-libs-perl wget
# may need to add libgd-perl and RUN perl -MCPAN -e 'install GD::Graph' to get png graphs

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=base /FastQ-Screen-0.15.2/* /usr/local/bin
COPY --from=base /bowtie2-2.5.1-linux-x86_64/* /usr/local/bin
