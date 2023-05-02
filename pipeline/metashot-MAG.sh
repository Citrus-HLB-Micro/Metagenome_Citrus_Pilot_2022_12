#!/usr/bin/bash -l
#SBATCH -p highmem -N 1 -n 32 --mem 512gb --out logs/mag.%a.log --time 8-0:00:00 -a 1-4
# may need more memory?
module load singularity
module load workspace/scratch
INPUT=input
SAMPFILE=samples.csv
export NXF_SINGULARITY_CACHEDIR=/bigdata/stajichlab/shared/singularity_cache/
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
LIB=samples.csv
IFS=,
sed -n ${N}p $LIB | while read JWWNAME PREFIX
do
  R="$INPUT/${PREFIX}_[12].fastq.gz"
  echo "O is $R"
  ./nextflow run metashot/mag-illumina \
	     --reads "$R" \
	     --outdir results/$PREFIX --max_cpus $CPU \
	     --scratch $SCRATCH -c metashot-MAG.cfg
done

