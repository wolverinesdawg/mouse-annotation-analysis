grep -v "^#" $gtf | awk -F"\t" '$3=="gene"' | wc -l
grep -v "^#" $gtf \
 | awk -F"\t" '$3=="gene"' \
 | sed 's/.*gene_biotype "\([^"]*\)".*/\1/' \
 | sort | uniq -c | sort -nr

