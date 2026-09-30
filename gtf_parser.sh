#-----------------------------

# ALWAYS LOOK AT A FILE BEFORE YOU WRITE COMMANDS FOR IT

ls -lh Mus_musculus.GRCm38.75_chr1.gtf
wc -l Mus_musculus.GRCm38.75_chr1.gtf
grep "^#" Mus_musculus.GRCm38.75_chr1.gtf
head -2 Mus_musculus.GRCm38.75_chr1.gtf

## result:
## about 26 MB, 81231 lines, 5 of them header lines starting with #

#-----------------------------

# What kinds of line are in the file? That is column 3.
# grep -v "^#" drops the header lines (-v inverts the match)
# cut -f3 takes the third TAB separated column (tab is cut's default)
# sort groups identical values, uniq -c counts each group
# sort -nr puts the largest count first (-n numeric, -r reverse)
# NOTE: uniq only collapses ADJACENT identical lines, which is why sort
# always has to come before it

grep -v "^#" Mus_musculus.GRCm38.75_chr1.gtf | cut -f3 | sort | uniq -c | sort -nr

## result:
##   36128 exon
##   25901 CDS
##    7588 UTR
##    4993 transcript
##    2299 stop_codon
##    2290 start_codon
##    2027 gene
##
## 2027 genes but 81226 data lines - one gene is spread over many lines,
## one per transcript, exon, CDS and codon. This is the single most
## important thing to understand about the file.

#-----------------------------

# We do NOT commit the data file - it is public and one command re-creates it
# What belongs in the repository is the command, not the data

echo "*.gtf" > .gitignore
echo "curl -O https://raw.githubusercontent.com/vsbuffalo/bds-files/master/chapter-07-unix-data-tools/Mus_musculus.GRCm38.75_chr1.gtf.gz" > get_data.sh
echo "gzip -d Mus_musculus.GRCm38.75_chr1.gtf.gz" >> get_data.sh

# Track the changes and commit

git add .gitignore get_data.sh
git commit -m "Added download script and ignored the annotation file"
git push

# git status should NOT list the .gtf file - the .gitignore is working

git status

#-----------------------------

# To keep the commands short below, put the file name in a variable

gtf=Mus_musculus.GRCm38.75_chr1.gtf


#=============================================================================
# QUESTION 1 - WHAT IS ACTUALLY ANNOTATED ON THIS CHROMOSOME?
#=============================================================================

# a. How many genes are annotated?

# A gene is a line whose THIRD column is exactly "gene"
# -F"\t" tells awk that columns are separated by tabs
# This matters here: the 9th column contains spaces, so without -F"\t"
# awk would split that column into pieces (see Question 4)

grep -v "^#" $gtf | awk -F"\t" '$3=="gene"' | wc -l

## result:
## 2027

#-----------------------------

# b. Break the genes down by biotype

# grep  drops the header lines
# awk   keeps only the gene lines
# sed   replaces the whole line with just the biotype value
# sort | uniq -c | sort -nr  counts and ranks
#
# How the sed works:
#   .*                  match anything before
#   gene_biotype "      the literal text we are looking for
#   \([^"]*\)           CAPTURE everything that is not a quote  <- this is \1
#   ".*                 the closing quote and anything after
#   /\1/                replace the whole line with what was captured
# Parentheses have to be escaped as \( \) to act as grouping in basic sed.
# This is the same capture-group idea used on FASTA headers, applied to a
# longer string.

grep -v "^#" $gtf \
 | awk -F"\t" '$3=="gene"' \
 | sed 's/.*gene_biotype "\([^"]*\)".*/\1/' \
 | sort | uniq -c | sort -nr

## result:
##    1240 protein_coding
##     221 pseudogene
##     118 miRNA
##     105 snRNA
##      99 snoRNA
##      89 lincRNA
##      73 antisense
##      31 misc_RNA
##      23 rRNA
##      20 processed_transcript
##       5 sense_intronic
##       2 polymorphic_pseudogene
##       1 sense_overlapping
##
## The counts add up to 2027, which is the check that nothing was lost.

#-----------------------------
