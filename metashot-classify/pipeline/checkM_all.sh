#!/bin/bash -l
#
#SBATCH -n 48 #number cores
#SBATCH -p batch
#SBATCH -o logs/checkm_all.log
#SBATCH -e logs/checkm_all.elog
#SBATCH --mem 192G #memory in Gb

module load checkm

MIN=2500
BINFOLDER=groups/all
OUTPUT=groups_checkM
NAME=all

CPU=24
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

mkdir -p $OUTPUT/$NAME
checkm lineage_wf -t $CPU -x fa $BINFOLDER $OUTPUT/$NAME

checkm tree $BINFOLDER -x .fa -t $CPU $OUTPUT/$NAME/tree

checkm tree_qa $OUTPUT/$NAME/tree -f $OUTPUT/$NAME/checkm.txt

