process VEPannot {

    label "vep"

	maxForks params.heavyFork 

	tag "Annotation with VEP for $sampleID"
 
	publishDir "$params.outputDir/Annotatation", mode: "copy", pattern: "*.{vcf.gz,vcf.gz.tbi,html}"
 
    input:
	
	tuple val(sampleID), path(vep_input), path(vep_input_tbi)

    output:
	path("${vep_ann_consensus}"), emit: vep_ann_consensus
	path("${vep_ann_consensus}.tbi")
	tuple val(sampleID), path("${vep_ann_consensus}"), emit: vep_ann_consensus_non
	val(sampleID), emit: doneEffectPrediction
	path("*")

    script:
	vep_ann_consensus = "${sampleID}_gatk_dv.ann.vcf.gz"
    
	"""
	vep \
	--fork 14 \
	--database \
	--assembly GRCh38 \
	--species homo_sapiens \
	--input_file ${vep_input} \
	--output_file ${vep_ann_consensus} \
	--vcf \
	--compress_output bgzip \
	--force_overwrite \
	--fasta ${params.alignmentRef} \
	--everything \
	--pick 
	
	tabix ${vep_ann_consensus}
	"""

	// """
	// vep \
	// --fork 14 \
	// --offline \
	// --cache \
	// --cache_version 114 \
	// --assembly GRCh38 \
	// --species homo_sapiens \
	// --input_file ${vep_input} \
	// --output_file ${vep_ann_consensus} \
	// --vcf \
	// --compress_output bgzip \
	// --force_overwrite \
	// --dir_cache ${params.vepCacheDir} \
	// --dir_plugins ${params.vepPluginsDir} \
	// --fasta ${params.alignmentRef} \
	// --everything \
	// --pick \
	// --plugin dbNSFP,${params.dbNSFP},SIFT_score,SIFT_pred,Polyphen2_HDIV_score,Polyphen2_HDIV_pred,MutationTaster_score,MutationTaster_pred,PROVEAN_score,PROVEAN_pred,REVEL_score \
    //           --plugin CADD,${params.caddsnvs},${params.caddIndel} \
	// --custom ${params.clinvar},ClinVar,vcf,exact,0,CLNSIG,CLNDN 
	
	// tabix ${vep_ann_consensus}
	// """
}