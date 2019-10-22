#!/bin/bash -l

module load R
pop=$1
model=$2
lambda_mis_min=$3
lambda_mis_1se=$4
lambda_auc_min=$5
lambda_auc_1se=$6


Rscript 2.lasso.fit.R  $pop $model $lambda_mis_min $lambda_mis_1se $lambda_auc_min $lambda_auc_1se


