import pysam
import sys

# Usage:
# python script.py input.vcf output.vcf [min_AB] [max_AB]

if len(sys.argv) < 3:
    print("Usage: python script.py <input.vcf> <output.vcf> [min_AB] [max_AB]")
    sys.exit(1)

# Required arguments
infile = sys.argv[1]
outfile = sys.argv[2]

# Optional AB parameters (default to 0.2 and 0.8)
if len(sys.argv) >= 5:
    min_ab = float(sys.argv[3])
    max_ab = float(sys.argv[4])
else:
    min_ab = 0.2
    max_ab = 0.8

vcf_in = pysam.VariantFile(infile, "r")
vcf_out = pysam.VariantFile(outfile, "w", header=vcf_in.header)

def mark_missing(record):
    for sample in record.samples:
        gt = record.samples[sample].get("GT", None)
        ad = record.samples[sample].get("AD", None)

        # Only process heterozygous (0/1)
        if gt == (0, 1) and ad and len(ad) >= 2:
            ref_reads, alt_reads = ad[:2]
            total_reads = ref_reads + alt_reads

            # No depth → mark as missing
            if total_reads == 0:
                record.samples[sample]["GT"] = (None, None)
                continue

            # Allele balance
            ab = ref_reads / total_reads

            # AB filter
            if ab < min_ab or ab > max_ab:
                record.samples[sample]["GT"] = (None, None)

    return record

# Process VCF
for record in vcf_in:
    vcf_out.write(mark_missing(record))

vcf_in.close()
vcf_out.close()

print(f"Processing complete. Using AB range [{min_ab}, {max_ab}].")
