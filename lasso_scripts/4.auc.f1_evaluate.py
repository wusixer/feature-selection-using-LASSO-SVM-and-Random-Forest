#!/usr/bin/env python3
import numpy as np
np.set_printoptions(threshold=np.inf) # setting the print threshold to infinity
import pandas as pd
from sklearn.pipeline import Pipeline
import sys
from sklearn.metrics import roc_auc_score
from sklearn.metrics import f1_score


pop=sys.argv[1]
model=sys.argv[2]
true_y=sys.argv[3]
predict_y=sys.argv[4]

print(pop, model, true_y, predict_y)

true_file="/m"+model+'/result/'+true_y
pred_file="/m"+model+'/result/'+predict_y

# read in data
true=pd.read_csv(true_file, delimiter="\t")
pred=pd.read_csv(pred_file, delimiter="\t")

true=true['x']
pred=pred['s0']

print ('auc for the best set of var is:', roc_auc_score(true, pred) )

new_pred=[]
for p in pred:
	if p>=0.5:
		new_pred.append(1)
	else:
		new_pred.append(0)

print ('F1 for the best set of var is:' , f1_score(true, new_pred))
