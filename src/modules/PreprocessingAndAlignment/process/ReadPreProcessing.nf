process ReadPreProcessing {

    label "germvarx"

    maxForks params.lightFork

    tag "Trimming adapters ..."

    publishDir "$params.outputDir/Preprocessing/Trimmed_fastq", mode: "copy"

    input:
        tuple val(sampleID), path(sampleFastq1), path(sampleFastq2)

    output:
        tuple val(sampleID), path("${outputFQ1}"), path("${outputFQ2}"), emit: processedReads
        val(sampleID), emit: doneReadPreProcessing


    script:
        outputFQ1 = "${sampleID}_R1_trimmed.fastq.gz"
        outputFQ2 = "${sampleID}_R2_trimmed.fastq.gz"

        
        """
        fastp -w ${params.noThreads} -i ${sampleFastq1} -I ${sampleFastq2} -o $outputFQ1 -O $outputFQ2 -q 15 -l 20
        """
}