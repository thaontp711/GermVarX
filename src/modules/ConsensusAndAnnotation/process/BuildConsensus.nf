process BuildConsensus {

    label "germvarx"

	maxForks params.lightFork
        
    tag "Consensus building ..."

    publishDir "$params.outputDir/VariantCalling/VariantsFromConsensus", mode:"copy"
    
    input:
    tuple val(sampleID), path(gatk_hc_snp_indel_recalibratedVCF_gz), path(gatk_hc_snp_indel_recalibratedVCF_gz_tbi), path(outFile1), path(outFile1_tbi)

    output:
    tuple val(ID), path("${consensus_vcf}"), path("${consensus_vcf_tbi}"), emit: consensusVariantCall
    val(sampleID), emit: doneVariantConsensus
    
    script:
    ID = "Consensus"
    consensus_vcf = "Consensus_gatk_dv.vcf.gz"
    consensus_vcf_tbi = "${consensus_vcf}.tbi"
    """
    bcftools isec -n=2 ${gatk_hc_snp_indel_recalibratedVCF_gz} ${outFile1} -w1 -Oz -o ${consensus_vcf}

    bcftools index -t ${consensus_vcf}
    """
}