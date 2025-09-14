include { RecalibrationFilteringGATK } from '../modules/RecalibrationFilteringGATK/RecalibrationFilteringGATK'
include { ApplyHardFilterGATK } from '../modules/RecalibrationFilteringGATK/ApplyHardFilterGATK'
include { VEPannotWF } from "../modules/ConsensusAndAnnotation/workflow/wf_VEPannot"
include { MultiQCWF } from '../modules/MultiQC/workflow/wf_MultiQCWF'
include { QCVariants } from '../modules/QCVariants/QCVariants'
include { QCPlink } from '../modules/QCPlink/QCPlink'
include { JointGenotyping } from '../modules/VariantCallingGATK/JointGenotyping'


workflow inputGATKgvcf {
    main:
    
    ch_gvcf = Channel
    .fromPath("${params.inputGVCF_gatk}/*.g.vcf.gz")
    .map { file ->
        def id = file.getBaseName().tokenize('_')[0]
        return [id, file]
    }

    JointGenotyping(ch_gvcf)

    gatk_filter = Channel.empty()
    done_gatk_filter = Channel.empty()
    if(params.single_sample_mode || params.hard_filter){
        ApplyHardFilterGATK(JointGenotyping.out.merge_vcf)
        gatk_filter = gatk_filter.mix(ApplyHardFilterGATK.out.gatk_filtered)
        done_gatk_filter = done_gatk_filter.mix(ApplyHardFilterGATK.out.done_filtered)
    } 
    else {
        RecalibrationFilteringGATK(JointGenotyping.out.merge_vcf)
        gatk_filter = gatk_filter.mix(RecalibrationFilteringGATK.out.gatk_recalibratedIndels)
        done_gatk_filter = done_gatk_filter.mix(RecalibrationFilteringGATK.out.doneRecalibrationFilteringGATK)
    }


    QCVariants(gatk_filter)

    QCPlink(QCVariants.out.qcVariants)

    VEPannotWF(gatk_filter)

    allDone = Channel.empty()
    .mix(done_gatk_filter)
    .mix(VEPannotWF.out.doneEffectPrediction)
    .collect()
    
    MultiQCWF( allDone, Channel.fromPath("${params.outputDir}"))
}