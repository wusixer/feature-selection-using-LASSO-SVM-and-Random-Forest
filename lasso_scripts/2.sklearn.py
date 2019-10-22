#!/usr/bin/env python3
import numpy as np
np.set_printoptions(threshold=np.inf) # setting the print threshold to infinity
import pandas as pd
from sklearn.pipeline import Pipeline
import sys

pop=sys.argv[1]
model=sys.argv[2]
metric=sys.argv[3]
lambda1=float(sys.argv[4])
se_used=sys.argv[5]

print(pop, model, metric,lambda1)
train_file="ml_models/"+pop+'_model'+model+'_train.txt'
test_file="/ml_models/"+pop+'_model'+model+'_test.txt'

# read in data
train=pd.read_csv(train_file, delimiter="\t")
test=pd.read_csv(test_file, delimiter="\t")

# get the dataset for analyisis
train_y = train['opices']
test_y=test['opices']

#train_x = train[train.columns[0:100]]
train_x = train.drop(['opices'],axis=1)
test_x=test.drop(['opices'],axis=1)

print(train_x.shape)
print(test_x.shape)


print('---------------------finish loading data -------------------------')
#-----------------set up parameters--------------
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score
from sklearn.metrics import f1_score

C=1/lambda1
LR=LogisticRegression(penalty='l1', C=C, class_weight='balanced', random_state=1,multi_class='ovr')
result=LR.fit(train_x, train_y)
non_zero_index=np.nonzero(result.coef_[0])[0]


predict_train_y=result.predict(train_x)
predict_test_y=result.predict(test_x)

if metric =="auc":
	train_accuracy=roc_auc_score(train_y, predict_train_y)
	test_accuracy=roc_auc_score(test_y,predict_test_y)

if metric=="f1":
	train_accuracy=f1_score(train_y, predict_train_y)
	test_accuracy=f1_score(test_y,predict_test_y)


print ('the lambda is', lambda1)
print ('the metric is ', metric)
print ('1se is used', se_used)
print ('the number of features associated with lambda is', len(non_zero_index))
print ('name of the features are:',[train_x.columns[i] for i in non_zero_index])
print ('the weight of the featurs are:', ["{0:.2f}".format(round(result.coef_[0][i] ,2)) for i in non_zero_index])
print ('the train accuracy is:' ,train_accuracy)
print ('the test accuracy is:',test_accuracy)

