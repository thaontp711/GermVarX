# GermVarX
**An Automated Workflow for Germline Variant Calling from Whole-Exome Sequencing Cohort Studies**

GermVarX is distributed as a **Nextflow pipeline** with **Docker container support**.

---

## 1. Environment Setup

### Install Docker
Follow the installation instructions for your platform:  
👉 [Docker Installation Guide](https://docs.docker.com/engine/install/)

### Install Nextflow
GermVarX requires **Nextflow (version ≥ 24)**.  
👉 [Nextflow Installation Guide](https://www.nextflow.io/docs/latest/getstarted.html)

---

## 2. Download the GermVarX Pipeline and Test Datasets

Clone the source code from the official GitHub repository:

```bash
git clone https://github.com/thaontp711/GermVarX.git
cd GermVarX
```
Create a directory for the test data and download paired-end WES FASTQ files for two samples along with the corresponding target BED file:

```mkdir -p testdata/fastq testdata/bed
cd testdata/fastq

# Sample 1: NA12891
wget https://storage.googleapis.com/brain-genomics-public/research/sequencing/fastq/novaseq/wes_agilent/50x/NA12891.novaseq.wes_agilent.50x.R1.fastq.gz
wget https://storage.googleapis.com/brain-genomics-public/research/sequencing/fastq/novaseq/wes_agilent/50x/NA12891.novaseq.wes_agilent.50x.R2.fastq.gz

# Sample 2: NA12892
wget https://storage.googleapis.com/brain-genomics-public/research/sequencing/fastq/novaseq/wes_agilent/50x/NA12892.novaseq.wes_agilent.50x.R1.fastq.gz
wget https://storage.googleapis.com/brain-genomics-public/research/sequencing/fastq/novaseq/wes_agilent/50x/NA12892.novaseq.wes_agilent.50x.R2.fastq.gz

cd ../bed
wget https://storage.googleapis.com/brain-genomics-public/research/sequencing/grch38/bed/agilent.targets.grch38.bed
```

---

## 3. Set Up Docker Images

Pull the required pre-built images and build the GermVarX custom image:

```bash
# PLINK 1.9
docker pull quay.io/biocontainers/plink:1.90b6.21--h516909a_0

# GATK 4.2.6.1
docker pull broadinstitute/gatk:4.2.6.1

# DeepVariant 1.6.1
docker pull google/deepvariant:1.6.1

# VEP 114.1
docker pull ensemblorg/ensembl-vep:release_114.1

# GLnexus 1.4.1
docker pull quay.io/biocontainers/glnexus:1.4.1--h17e8430_5

# GermVarX pipeline (custom image)
docker build -t germvarx-pipeline:0.1 ./docker/germvarx-pipeline
```

---

## 4. Configure Parameters

Configure input parameters and execution settings in the configuration files provided within the `configuration` directory.

---

## 5. Run the Pipeline

After parameter configuration, run the pipeline from the **GermVarX directory** (where `nextflow.config` is located):

```bash
nextflow run src/main.nf -profile docker <INPUT> [OPTIONS]
```

To run from another directory:

```bash
nextflow run /path/to/project/src/main.nf \
  -c /path/to/project/nextflow.config \
  -profile docker <INPUT> [OPTIONS]
```

---

## 5. INPUT Options

### FASTQ input
```bash
nextflow run src/main.nf -profile docker --inputDir <path/to/folder_fastq_files>
```

### BAM input
```bash
nextflow run src/main.nf -profile docker --inputBAM <path/to/folder_BAM_files>
```

### GVCF input (GATK)
```bash
nextflow run src/main.nf -profile docker --inputGVCF_gatk <path/to/folder_GATK_GVCF_files>
```

### GVCF input (DeepVariant)
```bash
nextflow run src/main.nf -profile docker --inputGVCF_dv <path/to/folder_DeepVariant_GVCF_files>
```

### VCF input (GATK)
```bash
nextflow run src/main.nf -profile docker --inputVCF_gatk <path/to/folder_GATK_VCF_files>
```

### VCF input (DeepVariant)
```bash
nextflow run src/main.nf -profile docker --inputVCF_dv <path/to/folder_DeepVariant_VCF_files>
```
