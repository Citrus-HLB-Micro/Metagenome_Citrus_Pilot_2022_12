#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 64 --mem 200gb  --out logs/gtdbtk.wf_classify.log

module load gtdbtk
module load workspace/scratch
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

gtdbtk classify_wf --genome_dir bins --out_dir bins_classify -x .fa --cpus $CPU --scratch_dir $SCRATCH --tmpdir $SCRATCH --keep_intermediates 
