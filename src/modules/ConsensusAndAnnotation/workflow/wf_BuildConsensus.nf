include { BuildConsensus } from "../process/BuildConsensus"
include { BuildConsensusNonCombine } from "../process/BuildConsensusNonCombine"

workflow BuildConsensusWF{

    take:
        gatk_recalibratedIndels
        dv_variants

    main:
        consensusVariantCall = Channel.empty()
        doneVariantConsensus = Channel.empty()

        if(params.single_sample_mode){
            BuildConsensusNonCombine(gatk_recalibratedIndels.join(dv_variants))

            consensusVariantCall = consensusVariantCall.mix( BuildConsensusNonCombine.out.consensusVariantCall)
            doneVariantConsensus =  doneVariantConsensus.mix( BuildConsensusNonCombine.out.doneVariantConsensus)
        }else{
            input = gatk_recalibratedIndels
            .combine(dv_variants)
            .map { rec -> tuple("consensus", rec[1], rec[2], rec[4], rec[5]) }

            BuildConsensus(input)

            consensusVariantCall = consensusVariantCall.mix( BuildConsensus.out.consensusVariantCall)
            doneVariantConsensus =  doneVariantConsensus.mix( BuildConsensus.out.doneVariantConsensus)
        }

    emit:
        consensusVariantCall
        doneVariantConsensus
}