#!/usr/bin/env python3
import numpy as np
np.set_printoptions(threshold=np.inf) # setting the print threshold to infinity
import pandas as pd
from sklearn.pipeline import Pipeline
import sys

pop=sys.argv[1]
model=sys.argv[2]
metric=sys.argv[3]
ntree=int(sys.argv[4])

print(pop, model, metric,ntree)
train_file="/ml_models/"+pop+'_model'+model+'_train.txt'

# read in data
train=pd.read_csv(train_file, delimiter="\t")

# get the dataset for analyisis
train_y = train['opices']

#train_x = train[train.columns[0:100]]
train_x = train.drop(['opices'],axis=1)
print(train_x.shape)



print('---------------------finish loading data -------------------------')
#-----------------set up parameters--------------
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_selection import RFECV
from sklearn.metrics import roc_auc_score
from sklearn.metrics import f1_score


RF=RandomForestClassifier(n_estimators=ntree,max_features="auto", bootstrap=True, oob_score=False, n_jobs=-1, random_state=1, class_weight='balanced')
print("a")
if metric =="auc":
	scores ='roc_auc'

if metric =="f1":
	scores='f1_micro'

rfe = RFECV(estimator=RF, cv=10 , step=1, scoring =scores, n_jobs = 5 ) #set -omp to 8 core although need 5
result =  rfe.fit(train_x, train_y)
print('rfe fit')
score = result.score(train_x, train_y)
print('result score')
rf_result = RF.fit(train_x, train_y)


print ('the # of tree is', ntree)
print ('the metric is ', metric)
print ('the score on the training set is ', score)
print ('the number of features assoicated with cross validation is', result.n_features_)
print ('the features left for the best auc is', train_x.columns[result.support_].values)
# should not use result.gridscore, since its definition is not the importance of each feature but rather the total score drop after removing features one by one
# print ('the weight for each selected variable is', result.grid_scores_[result.support_])
print ('the importance for each selected variable is', rf_result.feature_importances_[result.support_])
