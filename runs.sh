#!/bin/bash

if [ ! -r Homo_sapiens.GRCh38.pep.all.fa.fai ] ; then

  wget http://ftp.ensembl.org/pub/release-104/fasta/homo_sapiens/pep/Homo_sapiens.GRCh38.pep.all.fa.gz
  gunzip -f -k Homo_sapiens.GRCh38.pep.all.fa.gz

  cat Homo_sapiens.GRCh38.pep.all.fa | cut -d ' ' -f1,8 \
  | sed 's/ gene_symbol:/_/' > tmp
  mv tmp Homo_sapiens.GRCh38.pep.all.fa

  samtools faidx Homo_sapiens.GRCh38.pep.all.fa

fi

max_run() {
PEP=$1
MAX_REP=$(samtools faidx Homo_sapiens.GRCh38.pep.all.fa $PEP \
| perl unwrap_fasta.pl - - \
| sed 1d \
| sed 's/./&\n/g' \
| uniq -c \
| sort -k1nr \
| head -1 \
| sed 's/^ *//g' )
echo $PEP $MAX_REP
}
export -f max_run

# sudo apt install parallel
cut -f1 Homo_sapiens.GRCh38.pep.all.fa.fai | parallel max_run  {} > runs_result.txt

sort -k2nr runs_result.txt | sed 's/_/ /' \
| awk '!arr[$2]++' | head -20 | nl | tr ' ' '\t' | column -t > runs_result_top.txt

sed '/>/!s/K/+/g' Homo_sapiens.GRCh38.pep.all.fa > Homo_sapiens.GRCh38.pep.all.charges.fa
sed -i '/>/!s/R/+/g' Homo_sapiens.GRCh38.pep.all.charges.fa
sed -i '/>/!s/H/+/g' Homo_sapiens.GRCh38.pep.all.charges.fa
sed -i '/>/!s/D/-/g' Homo_sapiens.GRCh38.pep.all.charges.fa
sed -i '/>/!s/E/-/g' Homo_sapiens.GRCh38.pep.all.charges.fa

samtools faidx Homo_sapiens.GRCh38.pep.all.charges.fa

max_pos_run() {
PEP=$1
MAX_REP=$(samtools faidx Homo_sapiens.GRCh38.pep.all.charges.fa $PEP \
| perl unwrap_fasta.pl - - \
| sed 1d \
| sed 's/./&\n/g' \
| uniq -c \
| grep "+" \
| sort -k1nr \
| head -1 \
| sed 's/^ *//g' )
echo $PEP $MAX_REP
}
export -f max_pos_run

cut -f1 Homo_sapiens.GRCh38.pep.all.fa.fai  | parallel max_pos_run  {} > runs_pos_result.txt

sort -k2nr runs_pos_result.txt | sed 's/_/ /' \
| awk '!arr[$2]++' | head -20 | nl | tr ' ' '\t' | column -t > runs_pos_result_top.txt

max_neg_run() {
PEP=$1
MAX_REP=$(samtools faidx Homo_sapiens.GRCh38.pep.all.charges.fa $PEP \
| perl unwrap_fasta.pl - - \
| sed 1d \
| sed 's/./&\n/g' \
| uniq -c \
| grep "-" \
| sort -k1nr \
| head -1 \
| sed 's/^ *//g' )
echo $PEP $MAX_REP
}
export -f max_neg_run

cut -f1 Homo_sapiens.GRCh38.pep.all.fa.fai  | parallel max_neg_run  {} > runs_neg_result.txt

sort -k2nr runs_neg_result.txt | sed 's/_/ /' \
| awk '!arr[$2]++' | head -20 | nl | tr ' ' '\t' | column -t > runs_neg_result_top.txt

head runs_pos.txt
head runs_neg.txt
head runs_result.txt
