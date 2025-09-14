include { VEPannotWF } from "../modules/ConsensusAndAnnotation/workflow/wf_VEPannot"
include { QCPlink } from '../modules/QCPlink/QCPlink'
include { QCVariants } from '../modules/QCVariants/QCVariants'
include { MultiQCWF } from '../modules/MultiQC/workflow/wf_MultiQCWF'
include { IndexVCF } from '../modules/VariantCallingAdditional/process/IndexVCF'


workflow inputGATKvcf {
    main:
    input_gatk = Channel.fromPath("${params.inputVCF_gatk}/*.vcf.gz")

    IndexVCF(input_gatk)
    
    QCVariants(IndexVCF.out.gvcf_qc)

    QCPlink(QCVariants.out.qcVariants)

    VEPannotWF(IndexVCF.out.gvcf_qc)

    allDone = Channel.empty()
    .mix(VEPannotWF.out.doneEffectPrediction)
    .collect()
    
    MultiQCWF( allDone, Channel.fromPath("${params.outputDir}"))
}