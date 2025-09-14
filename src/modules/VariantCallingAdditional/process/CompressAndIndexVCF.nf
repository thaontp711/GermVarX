process CompressAndIndexVCF {

    label "germvarx"

	maxForks params.lightFork
        
    tag "Compressing And Indexing VCF for DV"

    publishDir "$params.outputDir/VariantCalling/VariantsFromDV", mode: "copy"
    
    input:
    path gvcf

    output:
    tuple val(sampleID), path("${merge_vcf}"), path("${merge_vcf_tbi}"), emit: merge_vcf_dv
    val(""), emit: domeMergeDV
    
    script:
    sampleID = "dv"
    merge_vcf = "dv_glnexus.vcf.gz"
    merge_vcf_tbi = merge_vcf + ".tbi"

    """
    bcftools view -O z -o ${merge_vcf} ${gvcf}
    tabix -p vcf ${merge_vcf}
    """
}