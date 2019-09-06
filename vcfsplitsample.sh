#!/bin/sh

fullfile=$1
filename=$(basename -- "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
datenow=$(date)

# set z based on file extention for zcat or zgrep
if [ "$extension" = "gz" ]
then
	z="z"
else [ "$extension" = "vcf" ]
	z=""
fi

samples=$("$z"grep "#CHROM" "$fullfile" | awk '{for(i=10;i<=NF;i++){printf "%s ", $i}; printf "\n"}')

i=10
for sample in $samples
do
	# write metalines
	"$z"grep '^##' "$fullfile" > "$sample".vcf
	# write source metaline
	echo "##source $datenow=splitsample $*" >> "$sample".vcf
	# write header and columns
	# filter none variants
	"$z"grep -v '^##' "$fullfile" | awk -v i=$i '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$i}' OFS='\t' | sed '/\.$/d' | sed '/0\/0/d' | sed '/\.\/\./d' >> "$sample".vcf
	i=$((i+1))
done
