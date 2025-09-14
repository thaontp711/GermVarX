include { VEPannot } from "../process/VEPannot"

workflow VEPannotWF{

    take:
        consensusVariantCall

    main:
        VEPannot(consensusVariantCall)

        doneEffectPrediction = Channel.empty()

        doneEffectPrediction =  doneEffectPrediction.mix( VEPannot.out.doneEffectPrediction)

        vep_ann_consensus = Channel.empty().mix(VEPannot.out.vep_ann_consensus)
        vep_ann_consensus_non = Channel.empty().mix(VEPannot.out.vep_ann_consensus_non)

    emit:
        vep_ann_consensus
        doneEffectPrediction
        vep_ann_consensus_non
}