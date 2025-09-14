process GenotypeGVCFsDB {

    label "gatk"
    maxForks params.heavyFork
    tag "GenotypeGVCFs ..."

    input:
    tuple val(chr), path(genomicsdb_workspace)

    output:
    tuple path("${genotype_vcf}"), path("${genotype_vcf_tbi}"), emit: gatk_vcf

    script:
    genotype_vcf = "combine_${chr}_BWA_Alignment_haplotypeCaller.vcf.gz"
    genotype_vcf_tbi = genotype_vcf + ".tbi"

    """
    gatk --java-options "-Xmx100G -XX:+UseParallelGC -XX:ParallelGCThreads=16" GenotypeGVCFs \\
        -R ${params.alignmentRef} \\
        -V gendb://${genomicsdb_workspace} \\
        -O ${genotype_vcf}

    gatk IndexFeatureFile -I ${genotype_vcf}
    """
}
