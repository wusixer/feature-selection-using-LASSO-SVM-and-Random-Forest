module load R

script=$1
pop=$2
model=$3
metric=$4

jname=$pop.m$model.$metric

echo $jname

fn_qlog=/m$model/gridsearch/$jname.qlog
cmd="$script $pop $model $metric"

qsubcmd="qsub -P casa -j y -o $fn_qlog -l mem_per_core=4G -l h_rt=120:00:00 -N $jname  -V $cmd"
echo $qsubcmd
eval $qsubcmd


