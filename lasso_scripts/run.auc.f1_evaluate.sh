#!/bin/bash -l
echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "Task index number : $SGE_TASK_ID"
echo "=========================================================="

echo 'Example: ./run.auc.f1_evaluate.sh $pop $model $true_y $predict_y'

module load python/3.6.2

pop=$1
model=$2
true_y=$3
predict_y=$4



jname=$pop.$model.auc_f1_of_best_var

echo $jname

fn_qlog=/m$model/result/$jname.qlog
cmd="4.auc.f1_evaluate.py $pop $model $true_y $predict_y"

qsubcmd="qsub -P casa -j y -o $fn_qlog   -N $jname -V $cmd"
echo $qsubcmd
eval $qsubcmd



echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="

# -l mem_per_core=18G -pe omp 28 -l h_rt=200:00:00 
