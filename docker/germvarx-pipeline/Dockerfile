FROM ubuntu:22.04

LABEL \
  author="Nguyen Thi Phuong Thao" \
  description="An Automated Workflow for Joint Germline Variant Exploration in Whole-Exome Sequencing Cohorts" \
  maintainer="<thaontp@ioit.ac.vn>"

ENV DEBIAN_FRONTEND=noninteractive

ENV C_INCLUDE_PATH=/usr/local/include
ENV LIBRARY_PATH=/usr/local/lib
ENV LD_LIBRARY_PATH=/usr/local/lib

ENV fastp_version=0.23.1
ENV bwa_mem2_version=2.2.1
ENV bedtools_version=2.30.0
ENV fastqc_version=0.11.9
ENV samtools_version=1.15.1
ENV bcftools_version=1.15.1
ENV htslib_version=1.15.1

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        default-jre \
        python3 python3-dev python3-pip \
        build-essential gcc g++ make autoconf \
        git bzip2 unzip zip wget curl \
        zlib1g-dev libcurl4-openssl-dev pkg-config \
        libbz2-dev liblzma-dev libncurses5-dev libncursesw5-dev \
        parallel && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip install --no-cache-dir pysam pandas cutadapt multiqc && \
    mkdir /tools && cd /tools && \
    ##htslib
    wget https://github.com/samtools/htslib/releases/download/${htslib_version}/htslib-${htslib_version}.tar.bz2 && \
    tar -xvjf htslib-${htslib_version}.tar.bz2 && \
    cd htslib-${htslib_version} && ./configure && make && make install && cd .. \
    ## samtools
    && wget https://github.com/samtools/samtools/releases/download/${samtools_version}/samtools-${samtools_version}.tar.bz2 \
    && tar -xvjf samtools-${samtools_version}.tar.bz2 \
    && cd samtools-${samtools_version} && ./configure && make && make install && cd .. \
    ## bcftools
    && wget https://github.com/samtools/bcftools/releases/download/${bcftools_version}/bcftools-${bcftools_version}.tar.bz2 \
    && tar -xvjf bcftools-${bcftools_version}.tar.bz2 \
    && cd bcftools-${bcftools_version} && ./configure && make && make install && cd .. \
    ## bedtools
    && wget https://github.com/arq5x/bedtools2/releases/download/v${bedtools_version}/bedtools-${bedtools_version}.tar.gz \
    && tar -zxvf bedtools-${bedtools_version}.tar.gz \
    && cd bedtools2 && make && make install && cd .. \
    ## fastqc
    && wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${fastqc_version}.zip \
    && unzip fastqc_v${fastqc_version}.zip \
    && cd FastQC && chmod 755 fastqc \
    && ln -s /tools/FastQC/fastqc /usr/local/bin/fastqc \
    ## fastp
    && wget http://opengene.org/fastp/fastp.${fastp_version} && \
    mv fastp.${fastp_version} fastp && chmod a+x fastp && mv fastp /usr/local/bin/ && \
    ## BWA-MEM2
    wget https://github.com/bwa-mem2/bwa-mem2/releases/download/v${bwa_mem2_version}/bwa-mem2-${bwa_mem2_version}_x64-linux.tar.bz2 && \
    tar jxf bwa-mem2-${bwa_mem2_version}_x64-linux.tar.bz2 && \
    mv bwa-mem2-${bwa_mem2_version}_x64-linux/bwa-mem2* /usr/local/bin/ && \
    ## mosdepth
    mkdir /mosdepth && cd /mosdepth && \
    wget https://github.com/brentp/mosdepth/releases/download/v0.3.3/mosdepth && \
    chmod +x mosdepth && \
    mkdir scripts && cd scripts && \
    wget https://raw.githubusercontent.com/brentp/mosdepth/master/scripts/plot-dist.py && \
    chmod +x plot-dist.py && \
    mv /mosdepth/mosdepth /usr/local/bin/ && \
    mv /mosdepth/scripts/plot-dist.py /usr/local/bin/ &&\
    ## Clean up
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

