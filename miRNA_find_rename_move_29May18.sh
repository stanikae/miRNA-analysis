#!/bin/bash
########################
## Include path to include directory when executing this script as $1
#######################

#dir=finalAnalysis/shortStacks
#outdir=finalAnalysis/shortStacks/allCounts

#dir=finalAnalysis/shortStacks_rptd
#outdir=finalAnalysis/shortStacks_rptd/allCounts
dir=$1
countOut=finalAnalysis/shortStacks/allCounts
mkdir -p $countOut

#add patient ID to the counts file
for i in $(find $dir -name "Counts.txt")
 do
	#echo $i
	name=$(dirname $i | awk -F "/" '{print $NF}');
	echo $name
	cp $i `echo $i | sed s/Counts.txt/$name.cts/`
done

for file in $(find $dir -name "*.cts")
 do
	name=$(basename $file)
	echo $name
	cat $file | cut -f2,4 | awk 'NR==1 || /miR/' | cut -d '_' -f1 > $countOut/$name\.txt
done
