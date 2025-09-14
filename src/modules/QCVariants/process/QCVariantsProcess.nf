process QCVariantsProcess {
    label "germvarx"

    maxForks params.heavyFork

    tag "QC Variants from consensus vcf file"

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
    bcftools view --include 'QUAL>=20' ${vcf} | \
    bcftools filter -e 'FMT/DP < 10 | FMT/GQ < 20' \
    -S . -Oz -o ${OUTPUT_PREFIX}.PASS.filtered.vcf.gz

    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.vcf.gz

    python ${params.py_ABfilter} ${OUTPUT_PREFIX}.PASS.filtered.vcf.gz ${OUTPUT_PREFIX}.PASS.filtered.AB.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.vcf.gz

    bcftools +fill-tags ${OUTPUT_PREFIX}.PASS.filtered.AB.vcf.gz -- -t AC,AN,AF | bcftools view -Oz -o ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.vcf.gz

    bcftools norm -f ${params.alignmentRef} -Oz -o ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.vcf.gz ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.vcf.gz

    bcftools annotate --set-id +'%CHROM\\:%POS\\:%REF\\:%FIRST_ALT' ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.vcf.gz -Oz -o ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id.vcf.gz

    bcftools view ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id.vcf.gz -r \$(echo chr{1..22} chrX chrY| tr ' ' ',') -Oz -o ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id23.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id23.vcf.gz

    # extract bialleic variants only
    bcftools view -m2 -M2 ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id23.vcf.gz -Oz -o ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id23.biallelic.vcf.gz
    bcftools index -t ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id23.biallelic.vcf.gz

    bcftools view ${OUTPUT_PREFIX}.PASS.filtered.AB.fixedtags.normf.id23.biallelic.vcf.gz | \
    awk '
    /^#/ { print; next }
    {
        key = \$1 FS \$2 FS \$4 FS \$5
        if (!qual[key] || \$6 > qual[key]) {
        qual[key] = \$6
        line[key] = \$0
        }
    }
    END {
        for (k in line) print line[k]
    }
    ' | bcftools sort -Oz -o ${qcvariants_vcf}

    bcftools index -t ${qcvariants_vcf}
    """
}