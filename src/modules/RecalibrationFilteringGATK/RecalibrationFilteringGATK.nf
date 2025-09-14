include {VQSRProcess} from './process/VQSRProcess'


workflow RecalibrationFilteringGATK {
    take:
        gatk_vcf

    main:
        gatk_recalibratedIndels = Channel.empty()
        doneRecalibrationFilteringGATK = Channel.empty()
        
        VQSRProcess(gatk_vcf)

        gatk_recalibratedIndels = gatk_recalibratedIndels
        .mix(VQSRProcess.out.gatk_recalibratedVCF)

        doneRecalibrationFilteringGATK = doneRecalibrationFilteringGATK
        .mix(VQSRProcess.out.doneVariantRecalibration)
    emit:
        gatk_recalibratedIndels
        doneRecalibrationFilteringGATK
    
}