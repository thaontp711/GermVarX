include { ConvertPLINK } from './process/ConvertPLINK'
include { Calculate } from './process/Calculate'
include { CalculatingWithBcftools } from './process/CalculatingWithBcftools'
include { ConsolidateSampleQC } from './process/ConsolidateSampleQC'

workflow QCPlink {
    take:
        qcVariants_plink
    
    main:
        ConvertPLINK(qcVariants_plink)

        CalculatingWithBcftools(qcVariants_plink)

        Calculate(ConvertPLINK.out.plink_bed_files)

        ConsolidateSampleQC(
            qcVariants_plink.map{ it[0] },
            Calculate.out.plink_variants,
            CalculatingWithBcftools.out.bcftools_stats
        )
    
}