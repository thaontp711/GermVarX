include { CallVarGATK } from "./process/CallVarGATK"
include { CallVarGATKVCF } from "./process/CallVarGATKVCF"
include {CombineGVCFs} from "./process/CombineGVCFs"
include {GenotypeGVCFs} from "./process/GenotypeGVCFs"
include { GatherVcfs } from './process/GatherVcfs'
include {GenomicsDBImport} from "./process/GenomicsDBImport"
include {GenotypeGVCFsDB} from "./process/GenotypeGVCFsDB"

workflow VariantCallingGATK {
    take:
        qualityRecalibratedBAMForGATK

    main:
        gatk_vcf = Channel.empty()

        if(params.single_sample_mode){
            CallVarGATKVCF(qualityRecalibratedBAMForGATK)
            
            gatk_vcf = gatk_vcf
            .mix(CallVarGATKVCF.out.gatk_gvcf)

        }else{
            CallVarGATK(qualityRecalibratedBAMForGATK)

            chroms = "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY".split(',')
            chr_ch = Channel.from(chroms)
            
            if(params.output_type != "GVCF"){
                genotype_vcf = Channel.empty()
            
                if(params.use_genomicsdb){
                    GenomicsDBImport(chr_ch, CallVarGATK.out.gatk_gvcf.collect(), CallVarGATK.out.gatk_gvcf_tbi.collect())

                    GenotypeGVCFsDB(GenomicsDBImport.out.genomicsdb_workspace)

                    genotype_vcf = genotype_vcf
                                .mix(GenotypeGVCFsDB.out.gatk_vcf)
                }else{
                    CombineGVCFs(chr_ch, CallVarGATK.out.gatk_gvcf.collect(), CallVarGATK.out.gatk_gvcf_tbi.collect())

                    GenotypeGVCFs(CombineGVCFs.out.gatk_vcf_combine)

                    genotype_vcf = genotype_vcf
                                .mix(GenotypeGVCFs.out.gatk_vcf)
                }

                genotype_vcf_list = genotype_vcf.map{ it[0] }.collect()
                genotype_vcf_list_tbi = genotype_vcf.map{ it[1] }.collect()

                GatherVcfs(genotype_vcf_list, genotype_vcf_list_tbi)

                gatk_vcf = gatk_vcf
                .mix(GatherVcfs.out.gatk_merge_vcf)
            }
        }
    
    emit:
        gatk_vcf
}