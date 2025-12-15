process Calculate {
    label "plink"

    maxForks params.heavyFork

    tag "Filter variants with call rate and Calculate sample-level statistics"

    publishDir "${params.outputDir}/${sampleID}_qcPlink",
    pattern: "*_variant_filtered.{bed,bim,fam}",
    mode: "copy"

    publishDir "${params.outputDir}/${sampleID}_qcPlink",
    pattern: "*relatedness.genome",
    mode: "copy"

    input:
        tuple val(sampleID),
            path(plink_bed), 
            path(plink_bim), 
            path(plink_fam)

    output:
        tuple path("${missing_imiss}"), path("${heterozygosity}"), path("${sex_check}"), path("${relatedness}"), emit: plink_variants
        path("*_variant_filtered.*")

    script:
        sex_check = "${sampleID}_sex_check.sexcheck"
        relatedness =  "${sampleID}_relatedness.genome"
        heterozygosity =  "${sampleID}_heterozygosity.het"
        missing_imiss =  "${sampleID}_sample_missing.imiss"

        """
        plink --bfile ${sampleID}_initial \
            --geno ${params.VarCallRate} \
            --make-bed \
            --out ${sampleID}_variant_filtered

        echo -e "23 10001 2781479 1\\n23 155701383 156030895 2" > par_regions.txt

        plink --bfile ${sampleID}_variant_filtered \
            --exclude range par_regions.txt \
            --make-bed --out ${sampleID}_variant_filtered_nonPAR

        plink --bfile ${sampleID}_variant_filtered_nonPAR \
            --check-sex \
            --out ${sampleID}_sex_check

        plink --bfile ${sampleID}_variant_filtered \
            --indep-pairwise 50 5 0.2 \
            --out ${sampleID}_indepSNP
        
        plink --bfile ${sampleID}_variant_filtered \
            --extract ${sampleID}_indepSNP.prune.in \
            --genome \
            --out ${sampleID}_relatedness

        plink --bfile ${sampleID}_variant_filtered \
            --het \
            --out ${sampleID}_heterozygosity
        
        plink --bfile ${sampleID}_variant_filtered \
            --missing \
            --out ${sampleID}_sample_missing
        """
}
