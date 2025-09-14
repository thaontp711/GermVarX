process QualityAssessmentPost {

    label "germvarx"

    maxForks params.lightFork

    tag "FASTQC after trimming"

    publishDir "$params.outputDir/FASTQC"

    input:
    tuple val(sampleID), path(fastq1), path(fastq2)

    output:
    path("*_fastqc.zip")
    path("*_fastqc.html")
    val(sampleID), emit: donePostPreProcessFastQC

    script:
    """
    fastqc -q -o . ${fastq1}
    fastqc -q -o . ${fastq2}
    """
}
