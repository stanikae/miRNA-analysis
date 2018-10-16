#!/bin/bash

##########
## NOTES ##
# 1. This script will call scripts for miRNA anlysis
###########
#date and time of running script
declare -x tym=$(date +"%H.%M%P")
declare -x today=$(date +"%d.%m.%Y")
# scripts directory (only useful before adding scripts to path)
scriptsDir=$(pwd)
#directory for bowtie index files etc
declare -x wdir=

echo $tym
echo $today
#############################################################
#input files
# path to input fq files directory
declare -x indir=
#directory for bowtie index files etc
declare -x wdir=
#path to bowtie index files
declare -x bwtIndex=$wdir/bowtie1_index
#fastqc adapter and contaminat list files
declare -x contaminants=$criptsDir/contaminant_list_edt.txt
declare -x adapters=$scriptsDir/adapter_list_edt.txt
#annotations input file for ShortStacks
declare -x annotations=$scriptsDir/hsa_shortStack.tab
#genome file
declare -x genome=$bwtIndex/hsa_genom.fa
##############################################################
#directories to be created
#parent output directory
declare -x outdir=$scriptsDir/miRNA_${today}_analysis
#analysis report file
declare -x report=$outdir/"miRNA_analysis_report.${today}.txt"
# path to cleaned reads output directory
declare -x cleanReads=$outdir/clean_reads
#path to ShortStacks output 
declare -x shortStack_out=$outdir/shortStacks
#path to final read count files
declare -x countOut=$shortStack_out/counts_final
#create directories
mkdir -p $shortStack_out
mkdir -p $countOut

## combine hsa rRNA sequences from different sources
#cat $wdir/gencode.v25.rRNA_transcripts.fasta \
#arb-silva.de_2017-06-01_id437133_tax_silva.fasta \
#arb-silva.de_2017-06-01_id437134_tax_silva.fasta gencode.v26.tRNAs.fasta > $wdir/human_rRNA.fa

# final rRNA plus other small RNA fasta file
#cat $wdir/hsa_sncRNA.fa $wdir/human_rRNA.fa > $wdir/hsa_sncRNA_rvsd.fa

#bowtie_build_patched human_rRNA.fa rRNA_hsa
# database of human small ncRNA ==> http://lisanwanglab.org/DASHR/smdb.php#tabHome
#bowtie hsa_sncRNA_rvsd.fa RNA_hsa
#bowtie --seedlen=23 --un output_file.fastq rRNA_hsa your_trimmed_file.fastq > /dev/null

## 29 May 2018: Can't locate bowtie_patched
## building index using bowtie
#bowtie-build hsa_sncRNA_rvsd.fa RNA_hsa



## STEP 1: quality control of reads ##
#fastq check before QC
bash $scriptsDir/miRNA_fastqc_reports_29May18.sh

#fastq quality control, incl adapter removal, read trimming n removal of trailing N's
cd $wdir
bash $scriptsDir/miRNA_fastq_qualityControl_29May18.sh

date #print date to stdout
echo -e "Sequencing reads quality control completed\t$tym"

#cd $wdir
#Remove rRNA reads
#bash $scriptsDir/

## STEP 2: map miRNA reads to the genome using shortstacks tool
cd $bwtIndex
#hsa_mirbase=stem_loop_seq_edt.fa
#mature=mature_seq_edt.fa
#cat mature_seq.fa stem_loop_seq.fa > combined_stem_mature_seq.fa
#cat mature_seq.fa | cut -d ' ' -f1 | tr 'U' 'T' > $mature
#cat stem_loop_seq.fa | cut -d ' ' -f1 | tr 'U' 'T' > $hsa_mirbase
##############################
#building new index for all the other sncRNA from DASHR2 based on hg38
#cat DASHR2_GEO_hg38_sequenceTable_export.csv | egrep -v 'mir|miRNA|rnaClass' | cut -d, -f2,8 | tr 'U' 'T' | tr 'u' 't' > dashr2_geo_hg38.csv
#awk 'BEGIN{OFS=""} {print ">",$1}' dashr2_geo_hg38.csv | tr ',' '\n' > dashr2_geo_hg38_edt.fa
##############################
#bowtie_build_patched $hsa_mirbase stem_loop
#bowtie_build_patched $hsa_mirbase  stem_loop
#bowtie --seedlen=23 --un output_file.fastq rRNA_hsa your_trimmed_file.fastq > /dev/null

echo "################"
echo -e "starting shortstack analysis"
date
echo "################"

for fq in $(find $cleanReads  -name "*.gz")
 do
	name=$(basename $fq | cut -d "." -f1)
	ShortStack --locifile $annotations --readfile $fq --genomefile $genome --outdir $shortStack_out/$name
done
#run multiqc to view stats of output files
multiqc -d $shortStack_out -o $shortStack_out

echo -e "shortstack analysis completed\t$today\t$tym\n"
echo -e "Starting downstream editing of the counts files\t$today\t$tym\n"
## STEP 3: Final step, including:
## downstream editing of the counts files

#add patient ID to the counts file
for i in $(find $shortStack_out -name "Counts.txt")
 do
        #echo $i
        name=$(dirname $i | awk -F "/" '{print $NF}');
        echo $name
        cp $i `echo $i | sed s/Counts.txt/$name.cts/`
done

# take only miRNA name column and the counts column
for file in $(find $shortStack_out -name "*.cts")
 do
        name=$(basename $file)
        echo $name
        cat $file | cut -f2,4 | awk 'NR==1 || /miR/ || /let/' > $countOut/$name\.txt
done

## combine counts for miRNAs with similar IDs (sum miRNA duplicates)
for i in $countOut/*.txt
 do 
	head -n 1 $i > $i.sorted && \
	cat $i | tr ' ' '\t' | \
	awk 'BEGIN {FS=OFS="\t"} {a[$1]+=$2}END{for(k in a) print k,a[k]}' | \
	sort -k1,1 >> $i.sorted
done

## join all files to make a count matrix (input count matrix for DESeq2)
bash $scriptsDir/miRNA_joinFiles_29May18.sh $countOut/*.sorted > $outdir/miRNA_countMatrix.tab

echo -e "miRNA analysis done\t$today\t$tym\n"
echo -e "The generated sample countMatrix is ready to use as DESeq2 input for miRNA DE analysis"


