#!/bin/bash

#replacing multiple tabs with single tab in adapter and contaminats files
#tr -s '\t' '\t' < adapter_list.txt > adapter_list_edt.txt 
#tr -s '\t' '\t' < contaminant_list.txt > contaminant_list_edt.txt
#outdir=/home/stan/Gemma_miRNA/Gemma/finalAnalysis/fastqc_reports

#date and time of running script
#now=$(date +"%d.%m.%Y")
#tym=$(date +"%H.%M%P")
#report="miRNA_analysis_Report.${now}.txt"

# path to input fq files directory
#indir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/Gemma/inputFastq
#outdir=/mnt/c/Users/Stanford/Documents/Gemma_miRNA/GemmaFinal

fqc=$outdir/fastqcReports.${today}
mkdir -p $fqc

# files
contaminants=/home/stan/FastQC/Configuration/contaminant_list_edt.txt
adapters=/home/stan/FastQC/Configuration/adapter_list_edt.txt

#script
for i in $(find $indir -name "*.gz")
 do
#	#name=$(basename $i | cut -d '_' -f1)
	fastqc -o $fqc --contaminants $contaminants --adapters $adapters $i
done

echo -e "fastq check completed successfully\t${tym}\nfor detailed output check: ${fqc}\n" > $report
# visualization of fastqc output using multiqc
multiqc -d $fqc -o $fqc

echo -e "multiqc report generated successfully\t${tym}\nReport written to: ${fqc}\n" >> $report
echo -e "## Now begining fastq quality control ##\t${tym}\n" >> $report

echo -e "multiqc report generated successfully\t${tym}\nReport written to: ${fqc}\n"
echo -e "## Now begining fastq quality control ##\t${tym}\n"
date
