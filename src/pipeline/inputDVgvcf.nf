include { VariantCallingAdditionalDV } from '../modules/VariantCallingAdditional/VariantCallingAdditionalDV'
include { VEPannotWF } from "../modules/ConsensusAndAnnotation/workflow/wf_VEPannot"
include { MultiQCWF } from '../modules/MultiQC/workflow/wf_MultiQCWF'
include { QCVariants } from '../modules/QCVariants/QCVariants'
include { QCPlink } from '../modules/QCPlink/QCPlink'


workflow inputDVgvcf {
    main:
    
    ch_gvcf = Channel
    .fromPath("${params.inputGVCF_dv}/*.g.vcf.gz")

    VariantCallingAdditionalDV(
        ch_gvcf
        )

    QCVariants(VariantCallingAdditionalDV.out.dv_variants)

    QCPlink(QCVariants.out.qcVariants)
    
    VEPannotWF(VariantCallingAdditionalDV.out.dv_variants)

    allDone = Channel.empty()
    .mix(VariantCallingAdditionalDV.out.doneVariantCallingAdditional)
    .mix(VEPannotWF.out.doneEffectPrediction)
    .collect()
    
    MultiQCWF( allDone, Channel.fromPath("${params.outputDir}"))
}
