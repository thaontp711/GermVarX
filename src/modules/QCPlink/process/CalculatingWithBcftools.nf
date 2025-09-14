process CalculatingWithBcftools {
    label "germvarx"

    maxForks params.heavyFork

    tag "Calculating sample statistics with bcftools"

    input:
    tuple val(sampleID), path(fixedtags_vcf_gz), path(fixedtags_vcf_gz_tbi)

    output:
        path("${bcftools_stats}"), emit: bcftools_stats

    script:
    fixedtags_vcf = "${fixedtags_vcf_gz}".replaceFirst(/.vcf.gz$/, ".vcf")
    bcftools_stats = "${sampleID}_bcftools_stats.txt"

    """
    gunzip -c ${fixedtags_vcf_gz} > ${fixedtags_vcf}

    bcftools stats -s - ${fixedtags_vcf} > ${bcftools_stats}
    """

}