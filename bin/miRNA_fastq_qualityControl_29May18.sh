#!/bin/bash

##########
## NOTES ##
# 1. change name of the kit accordingly under files
# - kit can either be truseq or nextflex only
###########

#date and time of running script
#tym=$(date +"%H_%M%P")
#today=$(date +"%d_%m_%Y")
#report="bowtieReport.$now.miRNA.txt"

# path to input fq files directory
#indir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/Gemma/inputFastq
# parent output directory
#outdir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/GemmaFinal

#create new directories
fqc=$outdir/fastqcReports.${today}
trimdir=$outdir/trimTemp
trimGalore=$outdir/trimGalore
qcReports=$fqc/trimGalore
stats=$qcReports/bowtie_stats

#create new directories
mkdir -p $fqc
mkdir -p $trimdir
mkdir -p $trimGalore
mkdir -p $qcReports
mkdir -p $cleanReads
mkdir -p $stats

# files
#contaminants=/home/stan/FastQC/Configuration/contaminant_list_edt.txt
#adapters=/home/stan/FastQC/Configuration/adapter_list_edt.txt
kit="nextflex" # or "truseq"

#script
for i in $(find $indir -name "*.gz")
 do
	name=$(basename $i | cut -d '_' -f1)
	echo $name
	if [[ "$i" == *$kit* ]]; 
	 then
		#trim 3' adapters using this option when small RNAseq performed using NextFlex
                ## STEP 1:
                cutadapt -a TGGAATTCTCGGGTGCCAAGG -o $trimdir/$name\.trm.1.fastq.gz --minimum-length 23 $i
                ## STEP 2
                cutadapt -u 4 -u -4 -o $trimdir/$name\.trm.fastq.gz $trimdir/$name\.trm.1.fastq.gz

	else
		## Use this cutadapt for truSeq or any other Illumina kits
                cutadapt -a TGGAATTCTCGGGTG -a ATCTCGTATGCCGTCTTCTGCTTG -g GTTCAGAGTTCTACAGTCCGACGATC \
                -e 0.1 -O 5 -m 15 --trim-n -o $trimdir/$name\.trm.fastq.gz $i
                #name=$(basename $i | cut -d '_' -f1)
                #fastqc -o $fqc --contaminants $contaminants --adapters $adapters $i

	fi

	#filter out reads with Q<30
	#filter reads longer than 40 bp
	#run fastqc for filtered reads
	# trim trailing N's (if any)
	trim_galore -q 30 --fastqc_args "-o $qcReports --contaminants $contaminants \
	--adapters $adapters" --max_length 40 --length 15 --trim-n -o $trimGalore $trimdir/$name\.trm.fastq.gz

done
rm -r $trimdir
multiqc -d $qcReports -o $qcReports

echo -e "Read QC completed successfully"
date
echo -e "Now removing all rRNA, tRNA and other non miRNA sRNA sequences\t$tym"

#remove rRNA sequences/ reads
for fq in $(find $trimGalore -name "*.gz")
 do
	name=$(basename $fq | cut -d "." -f1)
	echo $name
	bowtie --seedlen=23 --un $cleanReads/$name\.fq RNA_hsa $fq > /dev/null 2> $stats/${name}.file.log
done
#compress all clean fastq files
gzip $cleanReads/*.fq
#check read quality after removal of all non miRNA reads
fastqc -o $stats --contaminants $contaminants --adapters $adapters $cleanReads/*
#Generate reports for visualization
multiqc -d $stats -o $stats


