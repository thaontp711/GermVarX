include { HardFilter } from "./process/HardFilter"

workflow ApplyHardFilterGATK{
    take:
        gatk_vcf
    
    main:
        HardFilter(gatk_vcf)

        done_filtered = Channel.empty().mix(HardFilter.out.done_filtered)
        gatk_filtered = Channel.empty().mix(HardFilter.out.gatk_filtered)
    
    emit:
        done_filtered
        gatk_filtered
}