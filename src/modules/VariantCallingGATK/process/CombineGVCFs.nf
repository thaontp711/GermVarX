process CombineGVCFs {
    label "gatk"
    maxForks params.heavyFork
    tag "CombineGVCFs ..."
    

    input:
    val chr
    path gvcf_list
    path gvcf_index_list

    output:
    tuple val(sampleID), path("${genotype_vcf}"), path("${genotype_vcf_tbi}"), emit: gatk_vcf_combine

    script:
    sampleID = "${chr}"
    genotype_vcf = "combine_${chr}_BWA_Alignment_haplotypeCaller.g.vcf.gz"
    genotype_vcf_tbi = genotype_vcf + ".tbi"

    L_opts = "-L ${chr}"

    """
    gatk --java-options "-Xmx160G -XX:+UseParallelGC -XX:ParallelGCThreads=16" CombineGVCFs \\
    -R ${params.alignmentRef} \\
    ${gvcf_list.collect { "-V ${it}" }.join(' \\\n        ')} \\
    ${L_opts} \\
    -O ${genotype_vcf}

    gatk IndexFeatureFile -I ${genotype_vcf}
    """
}