#!/usr/bin/bash -l
#SBATCH -p batch -N 1 -n 32 --mem 128gb --out logs/awemag.%a.log --time 24:00:00 -a 1

module load singularity
module load workspace/scratch
INPUT=$(realpath results) # MAG results
OUT=$(realpath results_awemags)
mkdir -p $OUT
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

RUNDIR=awemags_run
mkdir -p $RUNDIR
LIB=samples.csv
IFS=,
sed -n ${N}p $LIB | while read JWWNAME PREFIX
do
  mkdir -p $OUT/$PREFIX
  pushd  $RUNDIR
  if [ ! -d fungi_odb10 ]; then
	  ln -s /srv/projects/db/BUSCO/v10/lineages/fungi_odb10
  fi
  if [ ! -d eggnog ]; then
	  ln -s /srv/projects/db/eggNOG/5.0.2 eggnog
  fi
  if [ ! -d mmseqs2_db ]; then
	  ln -s /srv/projects/db/ncbi/mmseqs mmseqs2_db
  fi
  if [ ! -f process.config ]; then ln -s ../process-awemags.config process.config; ln -s ../process-awemags.config ./; fi
  if [ ! -f metashot-awemags.cfg ]; then ln -s ../metashot-awemags.cfg ./; fi
  if [ ! -f nextflow ]; then ln -s ../nextflow ./; fi 
  ./nextflow run metashot/awemags -r 1.0.0 --genomes "$INPUT/$PREFIX/bins/*.fa" \
	     --outdir $OUT/$PREFIX --max_cpus $CPU \
	     --scratch $SCRATCH -c metashot-awemags.cfg \
	     --skip_filtering --eggnog_db eggnog --mmseqs_db mmseqs2_db/swissprot \
	     --lineage ./fungi_odb10 --busco_db ./fungi_odb10
done

