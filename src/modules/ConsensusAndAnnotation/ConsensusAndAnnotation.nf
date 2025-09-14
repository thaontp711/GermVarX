include { BuildConsensusWF } from "./workflow/wf_BuildConsensus"
include { VEPannotWF } from "./workflow/wf_VEPannot"

workflow ConsensusAndAnnotation {
    take:
        gatk_recalibratedIndels
        dv_variants
    
    main:
        BuildConsensusWF(
            gatk_recalibratedIndels,
            dv_variants
        )

        VEPannotWF(
        BuildConsensusWF.out.consensusVariantCall
        )

        doneConsensusAndAnnotation = Channel.empty()
        .mix(VEPannotWF.out.doneEffectPrediction)

    emit:
        doneConsensusAndAnnotation
    
}