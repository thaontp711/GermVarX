process CallVarDVVCF {

    label "deepvariant"

    maxForks params.heavyFork

    tag "Variant calling by DeepVariant"

    publishDir "$params.outputDir/VariantCalling/VariantsFromDV", mode: "copy"

    input:
    tuple val(sampleID), path(sortedBAM), path(sortedBAMindex)

    output:
    tuple val(sampleID), path("${outFile1}"), path("${outFile1_index}"), emit: dv_variants
    val(sampleID), emit: doneVariantCallingDV

    script:
    outFile1 = "${sampleID}.DV.vcf.gz"
	outFile1_index = "${sampleID}.DV.vcf.gz.tbi"

    """
    /opt/deepvariant/bin/run_deepvariant \
        --model_type=${params.readGroupLibrary} \
        --ref=${params.alignmentRef} \
        --regions=${params.exomeRegionsBed} \
        --reads=${sortedBAM} \
        --output_vcf=${outFile1} \
        --intermediate_results_dir ${sampleID}_deep_variant \
        --num_shards=${params.shards}
    """
}
