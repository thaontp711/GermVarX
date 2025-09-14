include { ReadPreProcessing } from './process/ReadPreProcessing'
include { QualityAssessmentPost } from './process/QualityAssessmentPost'
include { AlignToGenome } from './process/AlignToGenome'
include { MarkDuplicates } from './process/MarkDuplicates'
include { SortAndIndexDeDup } from './process/SortAndIndexDeDup'
include { RecalQualScores } from "./process/RecalQualScores"

workflow PreprocessingAndAlignment {
    take:
        readPairs

    main:
        sortedAndIndexedBAMforDV = Channel.empty()
        qualityRecalibratedBAMForGATK = Channel.empty()
        qualityRecalibratedBAMForMosdepth = Channel.empty()
        donePreprocessingAndAlignment = Channel.empty()
        
        ReadPreProcessing(readPairs)

        QualityAssessmentPost(ReadPreProcessing.out.processedReads)
        
        AlignToGenome(ReadPreProcessing.out.processedReads)

        if(params.output_type != "BAM"){

            MarkDuplicates(AlignToGenome.out.bwaAlignment)

            SortAndIndexDeDup(MarkDuplicates.out.noDupBAM)

            RecalQualScores(SortAndIndexDeDup.out.sortedAndIndexedBAM)

            sortedAndIndexedBAMforDV = sortedAndIndexedBAMforDV
            .mix(SortAndIndexDeDup.out.sortedAndIndexedBAMforDV)

            qualityRecalibratedBAMForGATK = qualityRecalibratedBAMForGATK
            .mix(RecalQualScores.out.qualityRecalibratedBAMForGATK)

            qualityRecalibratedBAMForMosdepth = qualityRecalibratedBAMForMosdepth
            .mix(RecalQualScores.out.qualityRecalibratedBAM)

            donePreprocessingAndAlignment = donePreprocessingAndAlignment
            .mix(RecalQualScores.out.doneQualityScoreRecalibration)
        }

    emit:
        sortedAndIndexedBAMforDV
        qualityRecalibratedBAMForGATK
        qualityRecalibratedBAMForMosdepth
        donePreprocessingAndAlignment
}