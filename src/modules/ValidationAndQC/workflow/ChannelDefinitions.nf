// workflows/channel_definitions.nf
workflow ChannelSetup {
    main:
    allFastq_ch = Channel.fromPath(params.allFastq)
    readPairs_ch = Channel.fromFilePairs(params.reads, flat: true)
    runDir_ch = Channel.from("$workflow.launchDir")

    emit:
    allFastq_ch
    readPairs_ch
    runDir_ch
}