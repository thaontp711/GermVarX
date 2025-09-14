process ConsolidateSampleQC {

    label "Python"

    tag "Python script for filtering"

    publishDir "${params.outputDir}/${sampleID}_qcPlink", mode: "copy"

    input:
    val(sampleID)
    tuple path(sample_missing_file), path(heterozygosity_file), path(sex_check_file), path(relatedness_file)          
    path(bcftools_stats_file)       

    output:
    path("${sampleID}_sample_qc_detailed.csv")
    path("${sampleID}_QC_summary.txt")

    script:
    """
    cat > qc_filter.py << 'EOF'
import pandas as pd
import numpy as np
import os

# Read files
sample_missing = pd.read_csv("${sample_missing_file}", delim_whitespace=True)
sample_missing.columns = ["FID", "IID", "MISS_PHENO", "N_MISS", "N_GENO", "F_MISS"]

het_data = pd.read_csv("${heterozygosity_file}", delim_whitespace=True)
sex_check = pd.read_csv("${sex_check_file}", delim_whitespace=True)

# Relatedness
if os.path.exists("${relatedness_file}"):
    relatedness = pd.read_csv("${relatedness_file}", delim_whitespace=True)
else:
    relatedness = pd.DataFrame()

# bcftools stats parse
sample_stats = []
if os.path.exists("${bcftools_stats_file}"):
    with open("${bcftools_stats_file}") as f:
        for line in f:
            if line.startswith("PSC"):
                parts = line.strip().split("\t")
                if len(parts) >= 10:
                    iid = parts[2]
                    n_transitions = float(parts[6])
                    n_transversions = float(parts[7])
                    n_indels = float(parts[8])
                    n_hets = float(parts[5])
                    n_hom = float(parts[3]) + float(parts[4])
                    n_snps = n_transitions + n_transversions
                    ti_tv = n_transitions / n_transversions if n_transversions > 0 else np.nan
                    het_hom = n_hets / n_hom if n_hom > 0 else np.nan
                    indel_snp = n_indels / n_snps if n_snps > 0 else np.nan
                    sample_stats.append([iid, ti_tv, het_hom, indel_snp])

sample_stats_df = pd.DataFrame(sample_stats, columns=["IID", "Ti_Tv", "Het_Hom", "Indel_SNP"])

# Merge all
merged = sample_missing.merge(sex_check[["IID", "F"]], on="IID", how="left", suffixes=("", "_sex"))
merged.rename(columns={"F": "F_sex"}, inplace=True)

# Handle heterozygosity column names
if "O(HOM)" in het_data.columns:
    het_data = het_data.rename(columns={"O(HOM)": "O_HOM", "E(HOM)": "E_HOM", "N(NM)": "N_NM", "F": "F_het"})
elif "O.HOM." in het_data.columns:
    het_data = het_data.rename(columns={"O.HOM.": "O_HOM", "E.HOM.": "E_HOM", "N.NM.": "N_NM", "F": "F_het"})
else:
    het_data["O_HOM"] = np.nan
    het_data["E_HOM"] = np.nan
    het_data["N_NM"] = np.nan
    het_data["F_het"] = np.nan

merged = merged.merge(het_data[["IID", "O_HOM", "E_HOM", "N_NM", "F_het"]], on="IID", how="left")
merged = merged.merge(sample_stats_df, on="IID", how="left")

# Calculate HET_RATE
merged["HET_RATE"] = np.where(
    (merged["N_NM"].notna()) & (merged["O_HOM"].notna()) & (merged["N_NM"] > 0),
    (merged["N_NM"] - merged["O_HOM"]) / merged["N_NM"],
    np.nan
)

# Save
merged.to_csv("${sampleID}_sample_qc_detailed.csv", index=False)
EOF

python3 qc_filter.py

# Generate summary report
echo "Generating summary report..."
cat > ${sampleID}_QC_summary.txt << EOF
VCF Quality Control Summary Report
==================================

Filtering and statistics steps applied:
1. Variant call rate filter: >90% (geno 0.1)
2. Transition/transversion ratio outliers
3. Heterozygous/homozygous ratio outliers
4. Insertion/deletion ratio outliers
5. Ambiguous sex samples
6. Related samples

Files generated:
- ${params.outputDir}/${sampleID}_qcPlink/variant_filtered.bed/.bim/.fam: Filtered dataset
- ${params.outputDir}/${sampleID}_qcPlink/relatedness.genome: Relatedness data
- ${params.outputDir}/${sampleID}_qcPlink/sample_qc_detailed.csv: Detailed sample QC metrics

EOF
    """
}
