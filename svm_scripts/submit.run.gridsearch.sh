for race in aa ea; do for m in 1 2 3; do for metric in auc f1; do ./run.gridsearch.sh gridsearch.svm.py $race $m $metric;done;done;done
