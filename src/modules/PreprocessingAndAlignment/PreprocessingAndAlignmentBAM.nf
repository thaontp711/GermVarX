include { ReadPreProcessing } from './process/ReadPreProcessing'
include { QualityAssessmentPost } from './process/QualityAssessmentPost'
include { MarkDuplicates } from './process/MarkDuplicates'
include { SortAndIndexDeDup } from './process/SortAndIndexDeDup'
include { RecalQualScores } from "./process/RecalQualScores"

workflow PreprocessingAndAlignmentBAM {
    take:
        ch_BAM

    main:

        MarkDuplicates(ch_BAM)

        SortAndIndexDeDup(MarkDuplicates.out.noDupBAM)

        RecalQualScores(SortAndIndexDeDup.out.sortedAndIndexedBAM)

        sortedAndIndexedBAMforDV = Channel.empty()
        .mix(SortAndIndexDeDup.out.sortedAndIndexedBAMforDV)

        qualityRecalibratedBAMForGATK = Channel.empty()
        .mix(RecalQualScores.out.qualityRecalibratedBAMForGATK)

        qualityRecalibratedBAMForMosdepth = Channel.empty()
        .mix(RecalQualScores.out.qualityRecalibratedBAM)

        donePreprocessingAndAlignment = Channel.empty()
        .mix(RecalQualScores.out.doneQualityScoreRecalibration)

    emit:
        sortedAndIndexedBAMforDV
        qualityRecalibratedBAMForGATK
        qualityRecalibratedBAMForMosdepth
        donePreprocessingAndAlignment
}