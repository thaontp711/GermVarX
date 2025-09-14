include { VEPannotWF } from "../modules/ConsensusAndAnnotation/workflow/wf_VEPannot"
include { QCPlink } from '../modules/QCPlink/QCPlink'
include { MultiQCWF } from '../modules/MultiQC/workflow/wf_MultiQCWF'
include { QCVariants } from '../modules/QCVariants/QCVariants'
include { IndexVCF } from '../modules/VariantCallingAdditional/process/IndexVCF'


workflow inputDVvcf {
    main:
    input_dv = Channel.fromPath("${params.inputVCF_dv}/*.vcf.gz")

    IndexVCF(input_dv)
    
    QCVariants(IndexVCF.out.gvcf_qc)

    QCPlink(QCVariants.out.qcVariants)

    VEPannotWF(IndexVCF.out.gvcf_qc)

    allDone = Channel.empty()
    .mix(VEPannotWF.out.doneEffectPrediction)
    .collect()
    
    MultiQCWF( allDone, Channel.fromPath("${params.outputDir}"))
}