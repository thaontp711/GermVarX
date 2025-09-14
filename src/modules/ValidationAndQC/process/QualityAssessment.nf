process QualityAssessment {

    label "germvarx"

    maxForks params.lightFork

    tag "FASTQC on input samples"

    publishDir "$params.outputDir/FASTQC"

    input:
    path(fastq)

    output:
    path("*_fastqc.zip")
    path("*_fastqc.html")
    val("DoneInitialFastQC"), emit: doneFastQC 

    script:
    """
    fastqc -q -o . ${fastq}
    """
}
