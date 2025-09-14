process GatherVcfs{
    label "gatk"

    maxForks params.heavyFork

    tag "GatherVcfs for all file chr_vcf"

    publishDir "${params.outputDir}/VariantCalling/VariantsFromGATK"

    input:
    path(gatk_vcf)
    path(gatk_vcf_tbi)

    output:
    tuple val(sampleID), path("${gatk_filtered_vcf}"), path("${gatk_filtered_vcf_tbi}"), emit: gatk_merge_vcf
    val("done"), emit: done_gatk_merge_vcf

    script:
    sampleID = "gatk"
    gatk_filtered_vcf = "${sampleID}_haplotypeCaller.vcf.gz"
    gatk_filtered_vcf_tbi = "${gatk_filtered_vcf}.tbi"

    chrom_order = [
    "chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", "chr8", "chr9", "chr10",
    "chr11", "chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18", "chr19",
    "chr20", "chr21", "chr22", "chrX", "chrY"
    ]

    inputList = gatk_vcf
    .sort { f ->
        def chr = f.name.replaceFirst(/^combine_/, "").replaceFirst(/_BWA.*/, "")
        chrom_order.indexOf(chr)
    }
    .collect { "-I ${it}" }
    .join(' \\\n  ')

    """
    gatk GatherVcfs \\
    ${inputList} \\
    -O ${gatk_filtered_vcf}

    gatk IndexFeatureFile -I ${gatk_filtered_vcf}
    """
}
