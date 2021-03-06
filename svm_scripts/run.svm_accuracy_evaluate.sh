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
pop=$1
model=$2
Cost=$3
var_fn=$4



jname=$pop.m$model.$Cost.accuracy

echo $jname

fn_qlog=/m$model/result/$jname.qlog
cmd="4.svm_accuracy_evaluate.py  $pop $model $Cost $var_fn"

qsubcmd="qsub -P casa -j y -o $fn_qlog -l mem_per_core=4G -pe omp 8 -l h_rt=30:00:00 -N $jname -S $(which python) -V $cmd"
echo $qsubcmd
eval $qsubcmd






echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="

# -l mem_per_core=18G -pe omp 28 -l h_rt=200:00:00 
