process MergeVCFsDV {

    label "glnexus"

    maxForks params.lightFork

    tag "GLnexus Merge for gvcfs from DeepVariant calling"

    input:
    path gvcf_list
    path gvcf_index_list

    output:
    path("${merged_vcf}"), emit: merge_vcf
    val(""), emit: domeMergeDV

    script:
    merged_vcf = "mergeVCFs_DV.glnexus.bcf"

    """
    glnexus_cli --config DeepVariantWES ${gvcf_list.join(' ')} > ${merged_vcf}
    """
}