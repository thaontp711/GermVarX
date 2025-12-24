process VQSRProcess {

    label "gatk"
    maxForks params.heavyFork
    tag "Variant recalibration & filtering (GATK VQSR) ..."
    publishDir "${params.outputDir}/VariantCalling/VariantsFromGATK", mode: "copy"

    input:
    tuple val(sampleID), path(genotype_vcf), path(genotype_vcf_tbi)

    output:
    tuple val(sampleID), 
          path("${gatk_snp_indel_pass_vcf}"), 
          path("${gatk_snp_indel_pass_vcf_idx}"), 
          emit: gatk_recalibratedVCF

    val(sampleID), emit: doneVariantRecalibration

    script:
    // snp
    gatk_snp_recal = "${sampleID}_haplotypeCaller_recalibrate_SNP.recal"
    tranches_file = "${sampleID}_recalibrate_SNP.tranches"
    rscript_file  = "${sampleID}_recalibrate_SNP_plots.R"

    // indel
    gatk_indel_recal = "${sampleID}_haplotypeCaller_recalibrate_INDEL.recal"
    tranches_file_indels = "${sampleID}_recalibrate_SNP_INDELs.tranches"
    rscript_file_indels = "${sampleID}_recalibrate_SNP_INDELs.plots.R"

    gatk_snp_recalibratedVCF = "${sampleID}_recal_snp.vcf.gz"

    gatk_snp_indel_recalibratedVCF = "${sampleID}_snp_indel.vcf.gz"
    gatk_snp_indel_recalibratedVCF_idx = "${gatk_snp_indel_recalibratedVCF}.tbi"

    gatk_snp_indel_pass_vcf = "${sampleID}_snp_indel_pass.vcf.gz"
    gatk_snp_indel_pass_vcf_idx = "${gatk_snp_indel_pass_vcf}.tbi"

    """   

    # snps
    gatk VariantRecalibrator \\
        -R ${params.alignmentRef} \\
        -V ${genotype_vcf} \\
        --resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${params.hapmapRef} \\
        --resource:omni,known=false,training=true,truth=true,prior=12.0 ${params.omniRef} \\
        --resource:1000G,known=false,training=true,truth=false,prior=10.0 ${params.Ref1kG} \\
        --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${params.dbSNPRef} \\
        -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \\
        -mode SNP --max-gaussians 4 -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 95.0 -tranche 90.0 \\
        -O ${gatk_snp_recal} \\
        --tranches-file ${tranches_file} \\
        --rscript-file ${rscript_file}

    # indels
    gatk VariantRecalibrator \\
        -R ${params.alignmentRef} \\
        -V ${genotype_vcf} \\
        --max-gaussians 4 \\
        --resource:mills,known=false,training=true,truth=true,prior=12 ${params.millsRef} \\
        --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${params.dbSNPRef} \\
        -an QD -an FS -an SOR -an MQRankSum -an ReadPosRankSum \\
        -mode INDEL  -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \\
        -O ${gatk_indel_recal} \\
        --tranches-file ${tranches_file_indels} \\
        --rscript-file ${rscript_file_indels}
    
    # apply recalibration to snps
    gatk ApplyVQSR \\
        -R ${params.alignmentRef} \\
        -V ${genotype_vcf} \\
        -O ${gatk_snp_recalibratedVCF} \\
        --truth-sensitivity-filter-level 99.0 \
        --recal-file ${gatk_snp_recal} \\
        --tranches-file ${tranches_file} \\
        -mode SNP
    
    # apply recalibration to indels
    gatk ApplyVQSR \\
        -R ${params.alignmentRef} \\
        -V ${gatk_snp_recalibratedVCF} \\
        -O ${gatk_snp_indel_recalibratedVCF} \\
        --truth-sensitivity-filter-level 99.0 \\
        --recal-file ${gatk_indel_recal} \\
        --tranches-file ${tranches_file_indels} \\
        -mode INDEL 

    gatk SelectVariants \
        -R ${params.alignmentRef} \
        -V ${gatk_snp_indel_recalibratedVCF} \
        --exclude-filtered \
        -O ${gatk_snp_indel_pass_vcf}
    """
}