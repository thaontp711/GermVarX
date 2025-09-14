process MOSDEPTH_QC {

    label "germvarx"
    maxForks params.heavyFork
    tag "Analysing Coverage with mosdepth"

    publishDir "$params.outputDir/Coverage_summaries", mode: 'copy', pattern: "*.txt"

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    val(sample_id), emit: doneMosdepthCoverageAnalysis
    path("*")

    script:
    """
    mosdepth --threads 1 \
             -n --fast-mode --by ${params.exomeRegionsBed} \
             --thresholds 10,20,30 \
             ${sample_id} \
             ${bam}
    """
}