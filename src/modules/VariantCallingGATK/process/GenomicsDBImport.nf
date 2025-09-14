process GenomicsDBImport {
    label "gatk"
    maxForks params.heavyFork
    tag "GenomicsDBImport ..."

    input:
    val chr
    path gvcf_list
    path gvcf_index_list

    output:
    tuple val(chr), path("${db_dir}"), emit: genomicsdb_workspace

    script:
    L_opts = "-L ${chr}"
    db_dir = "genomicsdb_${chr}"

    """
    gatk --java-options "-Xmx160G -XX:+UseParallelGC -XX:ParallelGCThreads=16" GenomicsDBImport \\
    -R ${params.alignmentRef} \\
    ${gvcf_list.collect { "-V ${it}" }.join(' \\\n        ')} \\
    ${L_opts} \\
    --genomicsdb-workspace-path ${db_dir}
    """
}
