process AlignToGenome {
    label "germvarx"
    maxForks params.heavyFork

    tag "BWA-MEM2 Alignment ..."
    publishDir "$params.outputDir/Preprocessing/BWA-MEM2_Alignment", mode: "copy"

    input:
    tuple val(sampleID), path(fastq1), path(fastq2)

    output:
    tuple val(sampleID), path("${sampleID}_BWA_Alignment.bam"), emit: bwaAlignment
    val(sampleID), emit: doneGenomeAlignment

    script:
    def outBam = "${sampleID}_BWA_Alignment.bam"

    // Get lane ID from FASTQ file
    def puField = (m = fastq1.name =~ /_L(\d{3})_/).find() ? "PU${sampleID}_L${m[0][1]}" : "${sampleID}.unit1"

    // Read group fields
    def rgid  = sampleID
    def rglb  = params.readGroupLibrary ?: "WES"
    def rgpl  = params.readGroupPlatform ?: "ILLUMINA"
    def rgpu  = params.readGroupUnit     ?: puField
    def rgsm  = sampleID
    def rgstr = "@RG\\tID:${rgid}\\tLB:${rglb}\\tPL:${rgpl}\\tPU:${rgpu}\\tSM:${rgsm}"

    """
    set -o pipefail

    bwa-mem2 mem -v 1 -t ${params.noThreads} \
        -R "${rgstr}" \
        ${params.alignmentRef} \
        ${fastq1} ${fastq2} | \
    samtools sort -@${params.noThreads} \
        -o ${outBam}
    """
}