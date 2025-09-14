process GenotypeGVCFs{

    label "gatk"

    maxForks params.heavyFork

    tag "GenotypeGVCFs ..."


    input:
    tuple val(sampleID), path(gatk_hc_gvcf), path(gatk_hc_gvcf_tbi)

    output:
    tuple path("${genotype_vcf}"), path("${genotype_vcf_tbi}"), emit: gatk_vcf

    script:
    genotype_vcf = "combine_${sampleID}_BWA_Alignment_haplotypeCaller.vcf.gz"
    genotype_vcf_tbi = genotype_vcf + ".tbi"

    """
    gatk --java-options "-Xmx120G -XX:+UseParallelGC -XX:ParallelGCThreads=16" GenotypeGVCFs \\
        -R ${params.alignmentRef} \\
        -V ${gatk_hc_gvcf} \\
        -O ${genotype_vcf} \\

    gatk IndexFeatureFile -I ${genotype_vcf}
    """
}