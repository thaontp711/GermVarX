include { MOSDEPTH_QC } from "./process/Mosdepth_QC"

workflow CoverageAnalysis {
    take:
        qualityRecalibratedBAMForMosdepth

    main:
        MOSDEPTH_QC(qualityRecalibratedBAMForMosdepth)

        doneMosdepthCoverageAnalysis = Channel.empty()
        .mix(MOSDEPTH_QC.out.doneMosdepthCoverageAnalysis)

    emit:
        doneMosdepthCoverageAnalysis
}