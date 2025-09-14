include { MultiQC } from "../process/MultiQC"

workflow MultiQCWF {

    take:
    allDone
    outputDir

    main:
    MultiQC(allDone.collect(), outputDir)

    multiqc_report = MultiQC.out[0]
    multiqc_data = MultiQC.out[1]

    emit:
    multiqc_report
    multiqc_data
}
