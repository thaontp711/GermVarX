process BuildConsensusNonCombine {
    label "germvarx"

	maxForks params.lightFork
        
    tag "Consensus building ..."

    publishDir "$params.outputDir/VariantCalling/VariantsFromConsensus", mode:"copy"
    
    input:
    tuple val(sampleID), 
    path(gatk_hc_snp_indel_recalibratedVCF_gz), path(gatk_hc_snp_indel_recalibratedVCF_gz_tbi), 
    path(outFile1), path(outFile1_tbi)

    output:
    tuple val(sampleID), path("${consensus_vcf}"), path("${consensus_vcf_tbi}"), emit: consensusVariantCall
    val(sampleID), emit: doneVariantConsensus
    
    script:
    consensus_vcf = "${sampleID}_gatk_dv.vcf.gz"
    consensus_vcf_tbi = "${consensus_vcf}.tbi"
    """
    bcftools sort ${gatk_hc_snp_indel_recalibratedVCF_gz} -Oz -o sorted_${gatk_hc_snp_indel_recalibratedVCF_gz}
    bcftools sort ${outFile1} -Oz -o sorted_${outFile1}
    tabix -p vcf sorted_${gatk_hc_snp_indel_recalibratedVCF_gz}
    tabix -p vcf sorted_${outFile1}

    bcftools isec -n=2 sorted_${gatk_hc_snp_indel_recalibratedVCF_gz} sorted_${outFile1} -w2 -Oz -o ${consensus_vcf}

    tabix -p vcf ${consensus_vcf}
    """
}