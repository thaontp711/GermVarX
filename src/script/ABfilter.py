import pysam
import sys

infile = sys.argv[1]
outfile = sys.argv[2]

min_ab = float(sys.argv[3])
max_ab = float(sys.argv[4])

vcf_in = pysam.VariantFile(infile, "r")
vcf_out = pysam.VariantFile(outfile, "w", header=vcf_in.header)

def mark_missing(record):
    for sample_name, sample in record.samples.items():
      gt = sample.get("GT")
      ad = sample.get("AD")

      if gt not in [(0, 1), (1, 0)]:
        continue

      if ad is None or len(ad) < 2:
        sample["GT"] = (None, None)
        continue

      ref_reads, alt_reads = ad[0], ad[1]

      if ref_reads is None or alt_reads is None:
        sample["GT"] = (None, None)
        continue

      total_reads = ref_reads + alt_reads

      # Zero depth
      if total_reads == 0:
            sample["GT"] = (None, None)
            continue

      # Correct allele balance definition
      ab = alt_reads / total_reads

      if ab < min_ab or ab > max_ab:
            sample["GT"] = (None, None)

    return record

for record in vcf_in:
    vcf_out.write(mark_missing(record))

vcf_in.close()
vcf_out.close()

print(
    "Done: heterozygous genotypes with AB <", min_ab, ">", max_ab, ", missing AD, or zero depth marked as ./."
)
