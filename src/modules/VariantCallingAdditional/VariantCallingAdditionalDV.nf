include { CallVarDV } from "./process/CallVarDV"
include { CompressAndIndexVCF } from './process/CompressAndIndexVCF'
include { MergeVCFsDV } from './process/MergeVCFsDV'
include { IndexVCF } from './process/IndexVCF'

workflow VariantCallingAdditionalDV {
    take:
        gvcf_dv
    main:

        IndexVCF(gvcf_dv)

        MergeVCFsDV(IndexVCF.out.gvcf.collect(), IndexVCF.out.gvcf_tbi.collect())

        CompressAndIndexVCF(MergeVCFsDV.out.merge_vcf)

        dv_variants = Channel.empty()
        .mix(CompressAndIndexVCF.out.merge_vcf_dv)

        doneVariantCallingAdditional = Channel.empty()
        mix(CompressAndIndexVCF.out.domeMergeDV)
        
    emit:
        dv_variants
        doneVariantCallingAdditional
}