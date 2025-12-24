process QCVariantsProcess {
    label "germvarx"

    maxForks params.heavyFork

    tag "QC Variants ..."

    publishDir "$params.outputDir/VariantCalling/VariantsFromQCVariants", mode:"copy"

    input:
    tuple val(sampleID), path(vcf), path(vcf_tbi)

    output:
    tuple val(sampleID), path("${qcvariants_vcf}"), path("${qcvariants_vcf_tbi}"), emit: qcvariants

    script:
    OUTPUT_PREFIX = "${sampleID}_variantConsensus_highConf"
    qcvariants_vcf = "${sampleID}_qcfiltered.vcf.gz"
    qcvariants_vcf_tbi = "${qcvariants_vcf}.tbi"
    
    """
    bcftools norm -f ${params.alignmentRef} -Oz -o ${OUTPUT_PREFIX}.normf.vcf.gz ${vcf} 
    bcftools view -e 'ALT="*"' -m2 -M2 -Oz -o ${OUTPUT_PREFIX}.PASS.vcf.gz ${OUTPUT_PREFIX}.normf.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.vcf.gz

    bcftools view --include 'QUAL>=${params.QUAL}' ${OUTPUT_PREFIX}.PASS.vcf.gz | \
    bcftools filter -e 'FMT/DP < ${params.DP} | FMT/GQ < ${params.GQ}' \
    -S . -Oz -o ${OUTPUT_PREFIX}.PASS.filtered.vcf.gz

    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.vcf.gz

    python ${params.py_ABfilter} ${OUTPUT_PREFIX}.PASS.filtered.vcf.gz \
    ${OUTPUT_PREFIX}.PASS.filtered.AB.vcf.gz \
    ${params.ABlower} ${params.ABupper}
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.vcf.gz

    bcftools +fill-tags ${OUTPUT_PREFIX}.PASS.filtered.AB.vcf.gz -- -t AC,AN,AF | \
    bcftools view -Oz -o ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.vcf.gz

    bcftools view -r \$(echo chr{1..22} chrX chrY| tr ' ' ',') \
    ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.vcf.gz -Oz -o \
    ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags23.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags23.vcf.gz

    bcftools annotate --set-id '%CHROM\\:%POS\\:%REF\\:%ALT' \
    ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags23.vcf.gz -Oz -o ${qcvariants_vcf}
    bcftools index -t ${qcvariants_vcf}
    """
}