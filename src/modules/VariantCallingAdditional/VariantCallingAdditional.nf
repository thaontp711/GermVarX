include { CallVarDV } from "./process/CallVarDV"
include { CallVarDVVCF } from "./process/CallVarDVVCF"
include { MergeVCFsDV } from './process/MergeVCFsDV'
include { CompressAndIndexVCF } from './process/CompressAndIndexVCF'

workflow VariantCallingAdditional {
    take:
        sortedAndIndexedBAMforDV

    main:
        dv_variants = Channel.empty()
        doneVariantCallingAdditional = Channel.empty()

        if(params.single_sample_mode){
            CallVarDVVCF(sortedAndIndexedBAMforDV)

            dv_variants = dv_variants
            .mix(CallVarDVVCF.out.dv_variants)

            doneVariantCallingAdditional = doneVariantCallingAdditional
            .mix(CallVarDVVCF.out.doneVariantCallingDV)
        }
        else{
            CallVarDV(sortedAndIndexedBAMforDV)

            if(params.output_type != "GVCF"){
                MergeVCFsDV(CallVarDV.out.dv_variants_gvcf.collect(), CallVarDV.out.dv_variants_gvcf_tbi.collect())

                CompressAndIndexVCF(MergeVCFsDV.out.merge_vcf)

                dv_variants = dv_variants
                .mix(CompressAndIndexVCF.out.merge_vcf_dv)

                doneVariantCallingAdditional = doneVariantCallingAdditional
                .mix(CompressAndIndexVCF.out.domeMergeDV)
            }
        }
        
    emit:
        dv_variants
        doneVariantCallingAdditional
}