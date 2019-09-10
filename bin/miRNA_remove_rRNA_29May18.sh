#!/bin/bash
set -x

#now=$(date +"%d-%m-%Y-%I_%M%P")
#report="bowtieReport.${now}.miRNA.txt"
work_dir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA
echo $report
#dir=/home/stan/Gemma_miRNA/Gemma/clean_data

currentDir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/Gemma/finalAnalysis
indir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/Gemma/finalAnalysis/trimGalore
outdir=$currentDir/clean_data
stats=$currentDir/clean_data/stats


# files
contaminants=/home/stan/FastQC/Configuration/contaminant_list_edt.txt
adapters=/home/stan/FastQC/Configuration/adapter_list_edt.txt


mkdir -p $stats

cd $work_dir
## combine hsa rRNA sequences from different sources
#cat gencode.v25.rRNA_transcripts.fasta \
#arb-silva.de_2017-06-01_id437133_tax_silva.fasta \
#arb-silva.de_2017-06-01_id437134_tax_silva.fasta gencode.v26.tRNAs.fasta > human_rRNA.fa

#cat hsa_sncRNA.fa human_rRNA.fa > hsa_sncRNA_rvsd.fa
#cd $work_dir

#bowtie_build_patched human_rRNA.fa rRNA_hsa
# database of human small ncRNA ==> http://lisanwanglab.org/DASHR/smdb.php#tabHome
#bowtie hsa_sncRNA_rvsd.fa RNA_hsa
#bowtie --seedlen=23 --un output_file.fastq rRNA_hsa your_trimmed_file.fastq > /dev/null

## 29 May 2018: Can't locate bowtie_patched
## building index using bowtie
#bowtie-build hsa_sncRNA_rvsd.fa RNA_hsa

#script
for fq in $(find $indir -name "BC*.gz"

#for i in `echo -e "trimGalore\ntrimmed_fastq"`
#for i in `echo -e "SecondSet_trimmed_maxLen"`
#for i in `echo -e "firstBatch\nsecondBatch\nthirdBatch"`
for i in `echo -e "fourthBatch\n"`
do
#dir=/home/stan/Gemma_miRNA/Gemma/clean_data/$i
#mkdir $dir
#trimmedReads_dir=/home/stan/Gemma_miRNA/Gemma/$i
trimmedReads_dir=$indir/$i
#trimmedReads_dir=/home/stan/Gemma_miRNA/Gemma/trimGalore/SecondSet_trimmed_maxLen/
for fq in $(find $trimmedReads_dir  -name "*.gz")
do
name=$(basename $fq | cut -d "." -f1)
echo $name
bowtie --seedlen=23 --un $outdir/$name\.clean.fq RNA_hsa $fq > /dev/null 2> $stats/${name}.file.log

#trimmedReads_dir=/home/stan/Gemma_miRNA/Gemma/$i
#outdir=/home/stan/Gemma_miRNA/Gemma/fastQC_reports/$i
#mkdir $outdir
#contaminants=/home/stan/FastQC/Configuration/contaminant_list_edt.txt
#adapters=/home/stan/FastQC/Configuration/adapter_list_edt.txt
#fastqc -o $outdir --contaminants $contaminants --adapters $adapters $rawReads_dir/*
#source activate py2.7
#multiqc -d $stats -o $stats
#source deactivate py2.7
done
#check read quality after removal of all non miRNA reads
fastqc -o $stats --contaminants $contaminants --adapters $adapters $outdir/*
done
multiqc -d $stats -o $stats
