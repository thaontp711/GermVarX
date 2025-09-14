process RecalQualScores {

        label "gatk"

        maxForks params.heavyFork
        
        tag "Recalibrating Quality Scores"

        publishDir "$params.outputDir/Preprocessing/BaseRecalibrated"

        input:
        tuple val(sampleID), path(bamForQSR)

        output:
        tuple val(sampleID), path("${BQSRbam}") , emit: qualityRecalibratedBAMForGATK
        tuple val(sampleID), path("${BQSRbam}"), path("${BQSRbai}"), emit: qualityRecalibratedBAM
        path("${QSRsummary}")
        val(sampleID), emit: doneQualityScoreRecalibration

        script:
        QSRsummary = "${sampleID}_Quality_Score_Recalibration.table"
        BQSRbam = "${bamForQSR}".replaceFirst(/_sorted.bam$/, "_Quality_Score_Recalibrated.bam")
        BQSRbai = "${bamForQSR}".replaceFirst(/_sorted.bam$/, "_Quality_Score_Recalibrated.bai")

        """
        gatk BaseRecalibrator -R ${params.alignmentRef} -I ${bamForQSR} --known-sites ${params.dbSNPRef} --known-sites ${params.millsRef} --known-sites ${params.knownIndels} -O $QSRsummary -L ${params.exomeRegionsBed}
        gatk ApplyBQSR -R ${params.alignmentRef} -I ${bamForQSR} --bqsr-recal-file $QSRsummary -O $BQSRbam -L ${params.exomeRegionsBed}
        """
}


