include { fullPipeline } from './pipeline/fullPipeline'
include { inputBAM } from './pipeline/inputBAM'
include { inputGATKgvcf } from './pipeline/inputGATKgvcf'
include { inputDVgvcf } from './pipeline/inputDVgvcf'
include { inputGATKvcf } from './pipeline/inputGATKvcf'
include { inputDVvcf } from './pipeline/inputDVvcf'

workflow {
    validateParams()
    if(params.inputBAM != ""){
        logBanner("BAM", params.inputBAM)
        inputBAM()
    }
    else if(params.inputGVCF_gatk != ""){
        logBanner("GVCF (GATK)", params.inputGVCF_gatk)
        inputGATKgvcf()
    }
    else if(params.inputGVCF_dv != ""){
        logBanner("GVCF (Deepvariant)", params.inputGVCF_dv)
        inputDVgvcf()
    }
    else if(params.inputVCF_gatk != ""){
        logBanner("VCF (GATK)", params.inputVCF_gatk)
        inputGATKvcf()
    }
    else if(params.inputVCF_dv != ""){
        logBanner("VCF (Deepvariant)", params.inputVCF_dv)
        inputDVvcf()
    }
    else{
        logBanner("FASTQ", params.inputDir)
        fullPipeline()
    }
}

def logBanner(inputType, inputPath) {
    def outputType = "Full Pipeline"
    if (params.output_type != ""){
        outputType = "${params.output_type}"
    }
    println """
        =================================================
        |       G E R M V A R X  -  P I P E L I N E      |
        =================================================

        Source data             : ${inputPath}
        Input type              : ${inputType}
        Output type             : ${outputType}
        Library type            : ${params.readGroupLibrary}
        Sequencing platform     : ${params.readGroupPlatform}
        Genome reference        : ${params.alignmentRef}
        Target capture BED file : ${params.exomeRegionsBed}
        Output directory        : ${params.outputDir}
        Filter                  : ${params.hard_filter ? "Hard Filter" : "GATK VQSR"}
        Mode                    : ${params.single_sample_mode ? "Single Mode" : "Joint Genotyping Mode"}
        Joint genotyping by     : ${params.use_genomicsdb ? "GenomicsDBImport" : "CombineGVCFs"}

        =================================================
        >               E X E C U T I N G               <
        =================================================
    """.stripIndent()
}

def validateParams(){

    def inputs = [
        params.inputDir,
        params.inputBAM,
        params.inputGVCF_gatk,
        params.inputGVCF_dv,
        params.inputVCF_gatk,
        params.inputVCF_dv
    ]

    def nonEmptyInputs = inputs.findAll { it?.trim() }
    if (nonEmptyInputs.size() < 1) {
        log.error "No input data specified.\n" +
                "Please provide exactly ONE type of input data.\n" +
                "See README.txt for details."
        System.exit(1)
    }
    else if (nonEmptyInputs.size() > 1) {
        log.error "Multiple types of input data specified.\n" +
                "Please provide only ONE type of input data.\n" +
                "You have provided: ${nonEmptyInputs}" +
                "See README.txt for details."
        System.exit(1)
    }

    if(params.output_type != "" && params.output_type != "BAM" && params.output_type != "GVCF") {
        log.error "Invalid value for --outputType: ${params.outputType}\n" +
        "Allowed values are:\n" +
        "    BAM   - stop after BAM file generation\n" +
        "    GVCF  - stop after GVCF file generation\n" +
        "Please correct and re-run the pipeline."
        System.exit(1)
    }
}