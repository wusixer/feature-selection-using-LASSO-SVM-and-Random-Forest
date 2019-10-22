#!/bin/bash -l
echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "Task index number : $SGE_TASK_ID"
echo "=========================================================="

echo "$script $pop $model $metric"
module load python/3.6.2
script=$1
pop=$2
model=$3
metric=$4
fn_for_cost="cost.csv"

num=0
cat $fn_for_cost| while read line; do
## use tail -n +K filename to select the line number from where you want to read
#cat $fn_for_cost | while read line; do
	num=$((num+1))
	Cost=`echo $line`
	echo $Cost

	jname=$pop.$Cost.m$model.$metric

	echo $pop
	echo $jname

	fn_qlog=/m$model/gridsearch/$jname.qlog
	cmd="$script $Cost $pop $model $metric"

	qsubcmd="qsub -P addiction -j y -o $fn_qlog -N $jname -S $(which python) -V $cmd"
	echo $qsubcmd
	eval $qsubcmd


done




echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="

# -l mem_per_core=18G -pe omp 28 -l h_rt=200:00:00 
