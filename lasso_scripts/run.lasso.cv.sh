module load R

pop=$1
model=$2
metric=$3

Rscript 1.lasso.cv.R $pop $model $metric

