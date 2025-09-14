import pysam
import sys

# Open input and output VCF files
infile = sys.argv[1]
outfile = sys.argv[2]
vcf_in = pysam.VariantFile(infile, "r")
vcf_out = pysam.VariantFile(outfile, "w", header=vcf_in.header)

# Define function to mark heterozygous genotypes with extreme AB as missing
def mark_missing(record):
    for sample in record.samples:
        gt = record.samples[sample].get("GT", None)
        ad = record.samples[sample].get("AD", None)
        
        # Only process heterozygous (0/1) genotypes
        if gt == (0, 1) and ad and len(ad) >= 2:
            ref_reads, alt_reads = ad[:2]
            total_reads = ref_reads + alt_reads

            # Special case: No depth (total_reads == 0), mark as missing immediately
            if total_reads == 0:
                record.samples[sample]["GT"] = (None, None)
                continue

            # Compute allele balance (AB)
            ab = ref_reads / total_reads  
            
            # Mark as missing if AB is outside the range (AB < 0.2 or AB > 0.8)
            if ab < 0.2 or ab > 0.8:
                record.samples[sample]["GT"] = (None, None)

    return record

# Process each variant
for record in vcf_in:
    updated_record = mark_missing(record)
    vcf_out.write(updated_record)

# Close files
vcf_in.close()
vcf_out.close()

print("Processing complete. Variants with AB > 0.8, AB < 0.2, or AD=0,0 are marked as missing (./.).")