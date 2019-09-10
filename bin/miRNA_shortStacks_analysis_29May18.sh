#!/bin/bash
# Absolute path to this script, e.g. /home/user/bin/foo.sh
script=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
scripttPath=$(dirname "$script")
#echo $scriptPath

#date and time of running script
#now=$(date +"%d-%m-%Y-%I_%M%P")
#report="bowtieReport.$now.miRNA.txt"
#echo $now
#work_dir=/home/stan/Gemma_miRNA/bowtie1_index/
work_dir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/bowtie1_index

#currentDir=/home/stan/Gemma_miRNA/Gemma/finalAnalysis
#currentDir=$(pwd)
#/mnt/c/Users/Stanford/Documents/Gemma_miRNA/Gemma/finalAnalysis/fastxTrimmer/shortStack_input
#indir=$currentDir/finalAnalysis/clean_data
#indir=$currentDir/finalAnalysis/fastxTrimmer/shortStack_input
#indir=/home/stan/Gemma_miRNA/Gemma/finalAnalysis/clean_data
indir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/Gemma/inputFastq/secondBatch
#outdir=$currentDir/finalAnalysis/shortStacks_rptd
outdir=~/shortStack_testB
mkdir -p $outdir

#bwt=/home/stan/Gemma_miRNA/bowtie1_index
#genome=/home/stan/Gemma_miRNA/bowtie1_index/hsa_genom.fa
genome=$work_dir/hsa_genom.fa
#formatting annotation file
#cat hsa.gff3 | cut -f1,4,5,9 | sed 's/ID=.*Name=//g' | sed 's/;.*//g' | tr '\t' ':' | sed 's/:/-/2' | sed 's/:/  /2' > hsa_shortStack.tab
annotations=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/hsa_shortStack.tab

cd $work_dir
#hsa_mirbase=stem_loop_seq_edt.fa
#mature=mature_seq_edt.fa
#cat mature_seq.fa stem_loop_seq.fa > combined_stem_mature_seq.fa
#cat mature_seq.fa | cut -d ' ' -f1 | tr 'U' 'T' > $mature
#cat stem_loop_seq.fa | cut -d ' ' -f1 | tr 'U' 'T' > $hsa_mirbase

#bowtie_build_patched $hsa_mirbase stem_loop
#bowtie_build_patched $hsa_mirbase  stem_loop
#bowtie --seedlen=23 --un output_file.fastq rRNA_hsa your_trimmed_file.fastq > /dev/null

for fq in $(find $indir  -name "NP1044*.gz")
do
name=$(basename -s .fastq.gz $fq | cut -d "_" -f1)
#echo $name
#bowtie_patched -a --best --strata -k 1 -m 1 --sam $bwt/hsa_genom $fq $dir/$name\.sam 2> $dir/$name.stats
#bowtie_patched --sam stem_loop $fq $dir/$name\.sam 2> $dir/$name.stats
#bowtie_patched -a --best --strata -k 1 -m 1 --sam mature $fq $dir/$name\.sam 2> $dir/$name.stats
#bowtie_patched -a --best --strata -k 1 -m 1 --sam stem_loop $fq $dir/$name\.sam 2> $dir/$name.stats
#bowtie_patched --seedlen=23 --un $dir/$name\.clean.fq rRNA_hsa $fq > /dev/null
#samtools view $dir/$name\.sam | grep "hsa" | awk '{print $3}' | sort | uniq -c | sort -k1,1nr > $dir/$name.counts
#featureCounts -t miRNA -g Name -a $annotations -o $dir/$name  $fq

#mkdir -p $outdir/$name
ShortStack --locifile $annotations --readfile $fq --genomefile $genome --outdir $outdir/$name &> $outdir/${name}.log
done
#run multiqc to view stats of output files
multiqc -d $outdir/$name -o $outdir/$name
#done
#ShortStack --locifile $annotations --readfile /mnt/c/Users/Stanford/Documents/Gemma_miRNA/Gemma/finalAnalysis/fastxTrimmer/firstBatch/PM050.fq --genomefile $genome --outdir /mnt/c/Users/Stanford/Documents/Gemma_miRNA/Gemma/finalAnalysis/fastxTrimmer/PM050_test

