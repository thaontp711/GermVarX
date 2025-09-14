include {ChannelSetup} from "./workflow/ChannelDefinitions"
include {QualityAssessment} from "./process/QualityAssessment"

workflow ValidationAndQC{
    main:
        ChannelSetup()

        QualityAssessment(ChannelSetup.out.allFastq_ch)

        readPairs = Channel.empty()
        .mix(ChannelSetup.out.readPairs_ch)

    emit: 
        readPairs
}