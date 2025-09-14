process CallVarGATKVCF {

    label "gatk"

    maxForks params.lightFork

    tag "Variant calling using GATK HaplotypeCaller"

    publishDir "${params.outputDir}/VariantCalling/VariantsFromGATK", mode: "copy"

    input:
    tuple val(sampleID), path(BQSRbam)

    output:
    tuple val(sampleID), path("${gatk_hc_gvcf}"), path("${gatk_hc_gvcf_tbi}"), emit: gatk_gvcf
    val(sampleID), emit: doneVariantCallingGATK

    script:
    gatk_hc_gvcf = "${BQSRbam}".replaceFirst(/_Quality_Score_Recalibrated.bam$/, "_haplotypeCaller.vcf.gz")
    gatk_hc_gvcf_tbi = "${BQSRbam}".replaceFirst(/_Quality_Score_Recalibrated.bam$/, "_haplotypeCaller.vcf.gz.tbi")

    """
    grep -E "^chr([0-9]{1,2}|1[0-9]|2[0-2]|X|Y)[[:space:]]" ${params.exomeRegionsBed} > human_autosomes_XY.bed

    gatk --java-options "-Xmx16g" HaplotypeCaller \\
        -R ${params.alignmentRef} \\
        -I ${BQSRbam} \\
        -L human_autosomes_XY.bed \\
        -stand-call-conf 30.0 \\
        -O ${gatk_hc_gvcf} \\
        --native-pair-hmm-threads ${params.threads_haplotypeCaller}
    """
}
