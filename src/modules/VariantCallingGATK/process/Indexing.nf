process Indexing {
    label "gatk"
    maxForks params.heavyFork
    tag "Indexing for gatk_gvcf files"

    input:
    tuple val(sampleID), path (gvcf)

    output:
    path("${gvcf}"), emit: gvcf
    path("${gvcf_tbi}"), emit: gvcf_tbi

    script:
    gvcf_tbi = gvcf + ".tbi"


    """
    gatk IndexFeatureFile -I ${gvcf}
    """
}