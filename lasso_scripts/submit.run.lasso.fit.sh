#!/bin/bash -l
echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "Task index number : $SGE_TASK_ID"
echo "=========================================================="

echo 'Example: ./submit.run.lasso.fit.sh   aa 3  0.01063495 0.01609036 0.01065356 0.02114205'

module load R
pop=$1
model=$2
lambda_mis_min=$3
lambda_mis_1se=$4
lambda_auc_min=$5
lambda_auc_1se=$6


jname=$pop.m$model

echo $jname

fn_qlog=/m$model/result/$jname.qlog
cmd="run.lasso.fit.sh $pop $model $lambda_mis_min $lambda_mis_1se $lambda_auc_min $lambda_auc_1se"

# the script will only work with 28 cores otherwise it will stop unfinished without errors
qsubcmd="qsub -P casa -j y -o $fn_qlog   -N $jname -V $cmd"
echo $qsubcmd
eval $qsubcmd



echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="

# -l mem_per_core=18G -pe omp 28 -l h_rt=200:00:00 
