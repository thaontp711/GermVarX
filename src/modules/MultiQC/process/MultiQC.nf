process MultiQC {

    label "germvarx"

	maxForks params.lightFork
        
    tag "Generating MultiQC Report"

	publishDir "${params.outputDir}/MultiQC_Report", mode:"copy"

	input:
	val allVals
	path(outDir)

	output:
	path("multiqc_report.html")
	path("multiqc_data")

	script:
	"""
	multiqc "${outDir}"
	"""
}