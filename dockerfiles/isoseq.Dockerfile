FROM continuumio/miniconda3:latest

### UPDATING CONDA ------------------------- ###

RUN conda update -y conda

### INSTALLING PIPELINE PACKAGES ----------- ###

# Adding bioconda to the list of channels
RUN conda config --add channels bioconda

# Adding conda-forge to the list of channels
RUN conda config --add channels conda-forge

# Installing mamba
RUN conda install -y mamba

# Installing software
RUN mamba install -y \
    isoseq3=4.0.0 \
    lima=2.9.0 \
    numpy \
    pandas \
    pbccs=6.4.0 \
    pbmm2=1.13.1 \
    pbpigeon=1.2.0 \
    pysam=0.22.0 \
    samtools=1.18 && \
    conda clean -afty

### SETTING WORKING ENVIRONMENT ------------ ###

# Set workdir to /home/
WORKDIR /home/

# Launch bash automatically
CMD ["/bin/bash"]
