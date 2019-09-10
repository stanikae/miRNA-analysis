#!/bin/bash
#script to join count files that are sorted by name
#to use this script, run it plus directory  of input files as 
#e.g. bash miRNA_joinFiles.sh finalAnalysis/shortStacks_rptd/allCounts/*
if [[ $# -ge 2 ]]; then
function __r {
if [[ $# -gt 1 ]]; then
exec join - "$1" | __r "${@:2}"
else
exec join - "$1"
fi
}
__r "${@:2}" < "$1"
fi
