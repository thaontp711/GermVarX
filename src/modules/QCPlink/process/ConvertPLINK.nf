process ConvertPLINK {
    label "plink"

    maxForks params.heavyFork

    tag "Convert VCF to PLINK BED format for $sampleID"

    input:
    tuple val(sampleID), path(fixedtags_vcf_gz), path(fixedtags_vcf_gz_tbi)

    output:
    tuple  val(sampleID),
          path("${plink_bed}"), 
          path("${plink_bim}"), 
          path("${plink_fam}"), 
          emit: plink_bed_files

    script:
    fixedtags_vcf = "${fixedtags_vcf_gz}".replaceFirst(/.vcf.gz$/, ".vcf")
    plink_bed = "${sampleID}_initial.bed"
    plink_bim = "${sampleID}_initial.bim"
    plink_fam = "${sampleID}_initial.fam"

    """
    gunzip -c ${fixedtags_vcf_gz} > ${fixedtags_vcf}

    plink --vcf ${fixedtags_vcf} \
      --make-bed \
      --out ${sampleID}_initial \
      --vcf-half-call missing \
      --allow-extra-chr
    """
}
