#!/usr/bin/env python3
import numpy as np
import pandas as pd
from sklearn.pipeline import Pipeline
import sys

pop=sys.argv[2]
model=sys.argv[3]
metric=sys.argv[4]

print(pop, model, metric)
train_file="/ml_models/"+pop+'_model'+model+'_train.txt'

# read in data
train=pd.read_csv(train_file, delimiter="\t")

# get the dataset for analyisis
train_y = train['opices']
train_x = train.drop(['opices'],axis=1)
print(train_x.shape)

print('---------------------finish loading data -------------------------')
#-----------------set up parameters--------------

from sklearn.model_selection import GridSearchCV
from sklearn.svm import SVC
from sklearn.metrics import roc_auc_score
from sklearn.metrics import f1_score

# set up parameters for linear svm
C=np.logspace(int(sys.argv[1]), int(sys.argv[1])+2, base=2, endpoint=True, num=5 )

print(int(sys.argv[1]))
print(int(sys.argv[1])+2)

tuned_parameters =[{'kernel':['linear'], 'C':C}]

svm = SVC(cache_size=1000, class_weight='balanced', probability=False)

if metric =="auc":
	scores ='roc_auc'
if metric =="f1":
	scores='f1_micro'

clf = GridSearchCV(svm, tuned_parameters, cv=10, scoring = scores,return_train_score=False )

clf.fit(train_x, train_y)

print("best score (best mean cv score of the best estimator)", clf.best_score_)
print("best paramerter", clf.best_params_)



