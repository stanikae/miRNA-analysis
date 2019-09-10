#!/bin/bash
file=$1

#awk '{a[$1]+=$2}END{for(k in a) print k,a[k]}' FS='\t' OFS='\t' $file

#for i in *.txt; do head -n 1 $i > ../sortedCounts/$i.sorted && awk '{a[$1]+=$2}END{for(k in a) print k,a[k]}' $i |
#sort -n -k1,1 >> ../sortedCounts/$i.sorted;done

for i in *.txt; 
do head -n 1 $i > ../sortedCounts/$i.sorted && cat $i | tr ' ' '\t' | awk 'BEGIN {FS=OFS="\t"} {a[$1]+=$2}END{for(k in a) print k,a[k]}' | sort -k1,1 >> ../sortedCounts/$i.sorted
done

#use this loop to sum up duplicared rows
#join the count files into one matrix after adding miRNA with duplicated counts
for i in *.txt;
do head -n 1 $i > $i.sorted && cat $i | tr ' ' '\t' | awk 'BEGIN {FS=OFS="\t"} {a[$1]+=$2}END{for(k in a) print k,a[k]}' | sort -k1,1 >> $i.sorted
done
