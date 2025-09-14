process CallVarGATK {

    label "gatk"

    maxForks params.lightFork

    tag "Variant calling using GATK HaplotypeCaller"

    publishDir "${params.outputDir}/VariantCalling/VariantsFromGATK/gvcf", mode: "copy"

    input:
    tuple val(sampleID), path(BQSRbam)

    output:
    path("${gatk_hc_gvcf}"), emit: gatk_gvcf
    path("${gatk_hc_gvcf_tbi}"), emit: gatk_gvcf_tbi
    val(sampleID), emit: doneVariantCallingGATK

    script:
    gatk_hc_gvcf = "${BQSRbam}".replaceFirst(/_Quality_Score_Recalibrated.bam$/, "_haplotypeCaller.g.vcf.gz")
    gatk_hc_gvcf_tbi = "${BQSRbam}".replaceFirst(/_Quality_Score_Recalibrated.bam$/, "_haplotypeCaller.g.vcf.gz.tbi")

    """
    grep -E "^chr([0-9]{1,2}|1[0-9]|2[0-2]|X|Y)[[:space:]]" ${params.exomeRegionsBed} > human_autosomes_XY.bed

    gatk --java-options "-Xmx16g" HaplotypeCaller \\
        -R ${params.alignmentRef} \\
        -I ${BQSRbam} \\
        -L human_autosomes_XY.bed \\
        -O ${gatk_hc_gvcf} \\
        --native-pair-hmm-threads ${params.threads_haplotypeCaller} \\
        -ERC GVCF
    """
}
