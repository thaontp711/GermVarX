process SortAndIndexDeDup {

    label "germvarx"

    maxForks params.lightFork
    
    tag "Sorting and Indexing BAMs"

    input:
    tuple val(sampleID), path(bamForSorting)

    output:
    tuple val(sampleID), path("${sortedBAM}"), emit: sortedAndIndexedBAM // BAI files are used automatically by RecalQualScores which outputs an updated BAI for the BQSR bam
    tuple val(sampleID), path("${sortedBAM}"), path("${sortedBAMindex}"), emit: sortedAndIndexedBAMforDV // BQSR isn't necessary for DV and can obscure novel variant detection
    val(sampleID), emit: doneSortAndIndex

    script:
    sortedBAM = "${bamForSorting}".replaceFirst(/_duplicates_marked.bam$/, "_sorted.bam")
    sortedBAMindex = "${bamForSorting}".replaceFirst(/_duplicates_marked.bam$/, "_sorted.bam.bai")
    """
    samtools sort -@${params.noThreads} -o $sortedBAM ${bamForSorting}
    samtools index $sortedBAM
    """
}