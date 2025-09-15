# GermVarX
An Automated Workflow for Germline Variant Calling from Whole-Exome Sequencing Cohort Studies

GermVarX is distributed as a Nextflow pipeline with Docker container support.
To set up the environment:
a)	Install Docker
Follow the installation instructions for your platform:
https://docs.docker.com/engine/install/.
b)	Install Nextflow
GermVarX requires Nextflow (version ≥ 24).
Installation instructions: https://www.nextflow.io/docs/latest/getstarted.html.
________________________________________
2. Download the GermVarX Pipeline
Clone the source code from the official GitHub repository:
git clone <GermVarX_repository_link>
cd GermVarX
________________________________________
3. Set Up Docker Images
Pull the required pre-built images and build the GermVarX custom image:
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
________________________________________

4. Run the Pipeline
After parameter configuration, run the pipeline from the GermVarX directory (where nextflow.config is located):
nextflow run src/main.nf -profile docker <INPUT> [OPTIONS]
To run from another directory:
nextflow run /path/to/project/src/main.nf \
  -c /path/to/project/nextflow.config \
  -profile docker <INPUT> [OPTIONS]

INPUT Options
•	FASTQ input
nextflow run src/main.nf -profile docker --inputDir <path/to/folder_fastq_files>
•	BAM input
nextflow run src/main.nf -profile docker --inputBAM <path/to/folder_BAM_files>
•	GVCF input (GATK)
nextflow run src/main.nf -profile docker --inputGVCF_gatk <path/to/folder_GATK_GVCF_files >
•	GVCF input (DeepVariant)
nextflow run src/main.nf -profile docker --inputGVCF_dv <path/to/folder_DeepVariant_GVCF_files >
•	VCF input (GATK)
nextflow run src/main.nf -profile docker --inputVCF_gatk <path/to/folder_GATK_VCF_files >
•	VCF input (DeepVariant)
nextflow run src/main.nf -profile docker --inputVCF_dv <path/to/folder_DeepVariant_VCF_files>

________________________________________

