include { PreprocessingAndAlignmentBAM } from '../modules/PreprocessingAndAlignment/PreprocessingAndAlignmentBAM'
include { CoverageAnalysis } from '../modules/CoverageAnalysis/CoverageAnalysis'
include { VariantCallingGATK } from '../modules/VariantCallingGATK/VariantCallingGATK'
include { ApplyHardFilterGATK } from '../modules/RecalibrationFilteringGATK/ApplyHardFilterGATK'
include { RecalibrationFilteringGATK } from '../modules/RecalibrationFilteringGATK/RecalibrationFilteringGATK'
include { VariantCallingAdditional } from '../modules/VariantCallingAdditional/VariantCallingAdditional'
include { BuildConsensusWF } from "../modules/ConsensusAndAnnotation/workflow/wf_BuildConsensus"
include { VEPannotWF } from "../modules/ConsensusAndAnnotation/workflow/wf_VEPannot"
include { MultiQCWF } from '../modules/MultiQC/workflow/wf_MultiQCWF'
include { ConsensusAndAnnotation } from '../modules/ConsensusAndAnnotation/ConsensusAndAnnotation'
include { QCVariants } from '../modules/QCVariants/QCVariants'
include { QCPlink } from '../modules/QCPlink/QCPlink'


workflow inputBAM {
    main:
    
    ch_bam = Channel
    .fromPath("${params.inputBAM}/*.bam")
    .map { file ->
        def id = file.getBaseName().tokenize('_')[0]
        return [id, file]
    }


    PreprocessingAndAlignmentBAM(ch_bam)

    CoverageAnalysis(PreprocessingAndAlignmentBAM.out.qualityRecalibratedBAMForMosdepth)

    VariantCallingGATK(PreprocessingAndAlignmentBAM.out.qualityRecalibratedBAMForGATK)

    VariantCallingAdditional(
        PreprocessingAndAlignmentBAM.out.sortedAndIndexedBAMforDV
        )
    
    if(params.output_type != "GVCF"){
        gatk_filter = Channel.empty()
        done_gatk_filter = Channel.empty()
        if(params.single_sample_mode || params.hard_filter){
            ApplyHardFilterGATK(VariantCallingGATK.out.gatk_vcf)
            gatk_filter = gatk_filter.mix(ApplyHardFilterGATK.out.gatk_filtered)
            done_gatk_filter = done_gatk_filter.mix(ApplyHardFilterGATK.out.done_filtered)
        } 
        else {
            RecalibrationFilteringGATK(VariantCallingGATK.out.gatk_vcf)
            gatk_filter = gatk_filter.mix(RecalibrationFilteringGATK.out.gatk_recalibratedIndels)
            done_gatk_filter = done_gatk_filter.mix(RecalibrationFilteringGATK.out.doneRecalibrationFilteringGATK)
        }

        BuildConsensusWF(VariantCallingAdditional.out.dv_variants, gatk_filter)

        if(params.single_sample_mode){
            VEPannotWF(BuildConsensusWF.out.consensusVariantCall)
            
            allDone = Channel.empty()
            .mix(done_gatk_filter)
            .mix(VariantCallingAdditional.out.doneVariantCallingAdditional)
            .mix(VEPannotWF.out.doneEffectPrediction)
            
            MultiQCWF( allDone, Channel.fromPath("${params.outputDir}"))
        }else{
            VEPannotWF(BuildConsensusWF.out.consensusVariantCall)

            QCVariants(BuildConsensusWF.out.consensusVariantCall)

            QCPlink(QCVariants.out.qcVariants)

            allDone = Channel.empty()
            .mix(done_gatk_filter)
            .mix(VariantCallingAdditional.out.doneVariantCallingAdditional)
            .mix(VEPannotWF.out.doneEffectPrediction)
            .collect()
            
            MultiQCWF( allDone, Channel.fromPath("${params.outputDir}"))
        }
    }
}