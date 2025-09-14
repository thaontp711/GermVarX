process HardFilter{
    label "gatk"

    maxForks params.heavyFork

    tag "Applying GATK hard filters ..."

    publishDir "${params.outputDir}/VariantCalling/VariantsFromGATK", mode: "copy"

    input:
    tuple val(sampleID), path(genotype_vcf), path(genotype_vcf_tbi)

    output:
    tuple val(sampleID), path("${gatk_filtered_vcf}"), path("${gatk_filtered_vcf_tbi}"), emit: gatk_filtered
    val(''), emit: done_filtered

    script:
    gatk_filtered_vcf = "${sampleID}_hardfilter_snp_indel.vcf.gz"
    gatk_filtered_vcf_tbi = gatk_filtered_vcf + ".tbi"

    """
    gatk --java-options "-Xmx8g" SelectVariants \
        -V ${genotype_vcf} -select-type SNP -select-type MIXED \
        -O ${sampleID}.HC.snps.vcf.gz

    gatk --java-options "-Xmx8g" VariantFiltration \
        -V ${sampleID}.HC.snps.vcf.gz -filter "QD < ${params.snpINFO_QD}" --filter-name "QD${params.snpINFO_QD}" \
        -filter "QUAL < ${params.snpQUAL}" --filter-name "QUAL${params.snpQUAL}" \
        -filter "SOR > ${params.snpINFO_SOR}" --filter-name "SOR${params.snpINFO_SOR}" \
        -filter "FS > ${params.snpINFO_FS}" --filter-name "FS${params.snpINFO_FS}" \
        -filter "MQ < ${params.snpINFO_MQ}" --filter-name "MQ${params.snpINFO_MQ}" \
        -filter "MQRankSum < ${params.snpINFO_MQRankSum}" --filter-name "MQRankSum${params.snpINFO_MQRankSum}" \
        -filter "ReadPosRankSum < ${params.snpINFO_ReadPosRankSum}" --filter-name "ReadPosRankSum${params.snpINFO_ReadPosRankSum}" \
        -O ${sampleID}.HC.snps.flt.vcf.gz
        
    gatk --java-options "-Xmx8g" SelectVariants \
        -V ${genotype_vcf} -select-type INDEL -select-type MIXED \
        -O ${sampleID}.HC.indels.vcf.gz

    gatk --java-options "-Xmx8g" VariantFiltration \
        -V ${sampleID}.HC.indels.vcf.gz -filter "QD < ${params.indelINFO_QD}" --filter-name "QD${params.indelINFO_QD}" \
        -filter "QUAL < ${params.indelQUAL}" --filter-name "QUAL${params.indelQUAL}" \
        -filter "FS > ${params.indelINFO_FS}" --filter-name "FS${params.indelINFO_FS}" \
        -filter "ReadPosRankSum < ${params.indelINFO_ReadPosRankSum}" --filter-name "ReadPosRankSum${params.indelINFO_ReadPosRankSum}" \
        -O ${sampleID}.HC.indels.flt2.vcf.gz
        
    gatk --java-options "-Xmx8g" MergeVcfs \
        -I ${sampleID}.HC.snps.flt.vcf.gz \
        -I ${sampleID}.HC.indels.flt2.vcf.gz \
        -O ${gatk_filtered_vcf}

    gatk IndexFeatureFile -I ${gatk_filtered_vcf}
    """
}