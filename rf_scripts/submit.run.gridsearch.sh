for race in aa ea; do for model in 1 2 3 ; do for metric in auc f1; do ./run.gridsearch.sh gridsearch.rf.py $race $model $metric;done;done;done

