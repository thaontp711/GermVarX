process MarkDuplicates {

    label "gatk"

    maxForks params.heavyFork

    tag "Marking Duplicates ..."

    publishDir "$params.outputDir/Preprocessing/MarkDuplicate"

    input:
    tuple val(sampleID), path(alignedBam)

    output:
    tuple val(sampleID), path("${markedDuplicatesBAM}"), emit: noDupBAM
    path("${duplicateSummary}")
    val(sampleID), emit: doneDuplicateRemoval

    script:
    markedDuplicatesBAM = "${alignedBam}".replaceFirst(/.bam$/, "_duplicates_marked.bam")
    duplicateSummary = "${sampleID}_marked_dup_metrics.txt"

    """
    gatk MarkDuplicates --INPUT ${alignedBam} --OUTPUT $markedDuplicatesBAM --METRICS_FILE $duplicateSummary --VALIDATION_STRINGENCY SILENT
    """
}