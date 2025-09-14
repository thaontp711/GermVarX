include { QCVariantsProcess } from './process/QCVariantsProcess'

workflow QCVariants {
    take:
        consensusVariantCall
    
    main:
        
        QCVariantsProcess(consensusVariantCall)
        qcVariants = Channel.empty().mix(QCVariantsProcess.out.qcvariants)
    
    emit:
        qcVariants
}