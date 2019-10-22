#!/usr/bin/env python3
import numpy as np
import pandas as pd
from sklearn.pipeline import Pipeline
import sys

pop=sys.argv[1]
model=sys.argv[2]
metric=sys.argv[3]

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
from sklearn.ensemble import RandomForestClassifier

# set up parameters for rf
# # # use the square root of the features as the mtry average value, and test +-20 from that
# # Gene selection and classification of microarray data using random forest, BMC bioinformatics
mtry= np.arange((round(len(train_x.columns)**(1/2))-20), (round(len(train_x.columns)**(1/2))+20), 1)
# #https://www.researchgate.net/publication/230766603_How_Many_Trees_in_a_Random_Forest how many trees are needed for rf
#
# #---- the start point of the number of trees need to have some experiemnt done before qsub
# #-----
ntree=np.logspace(7,11,base=2,num=10,dtype=int) # since according to the above paper, >128 trees, the score is not changing much in several dataset
#
tuned_parameters=[{'n_estimators':ntree}]
#tuned_parameters =[{'n_estimators':ntree, 'max_features': mtry}]
#
RF=RandomForestClassifier(bootstrap=True, oob_score=True, n_jobs=-1, random_state=1, class_weight='balanced') # the number of jobs is set to the number of cores
#

if metric =="auc":
	scores ='roc_auc'
if metric =="f1":
	scores='f1_micro'


clf = GridSearchCV(RF, tuned_parameters, cv=10, scoring =scores,return_train_score=False )


clf.fit(train_x, train_y)

print("best score (best mean cv score of the best estimator)", clf.best_score_)
print("best paramerter", clf.best_params_)



