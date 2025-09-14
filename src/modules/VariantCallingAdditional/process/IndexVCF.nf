process IndexVCF {

    label "germvarx"

	maxForks params.lightFork
        
    tag "Indexing gvcfs from DV calling"
    
    input:
    path(gvcf)

    output:
    path("${gvcf}"), emit: gvcf
    path("${gvcf_tbi}"), emit: gvcf_tbi
    tuple val(sanpleID), path("${gvcf}"), path("${gvcf_tbi}"), emit: gvcf_qc
    val(""), emit: domeMergeDV
    
    script:
    sanpleID = gvcf.getBaseName().tokenize('_')[0]
    gvcf_tbi = gvcf + ".tbi"

    """
    tabix -p vcf ${gvcf}
    """
}