#!/usr/bin/env python3
import numpy as np
np.set_printoptions(threshold=np.inf) # setting the print threshold to infinity
import pandas as pd
from sklearn.pipeline import Pipeline
import sys


# get the dataset for analyisis
Cost=float(sys.argv[1])
pop=sys.argv[2]
model=sys.argv[3]
metric=sys.argv[4]


print(Cost, pop, model, metric)
train_file="ml_models/"+pop+'_model'+model+'_train.txt'
test_file="/ml_models/"+pop+'_model'+model+'_test.txt'

# read in data
train=pd.read_csv(train_file, delimiter="\t")
test=pd.read_csv(test_file, delimiter="\t")
# get the dataset for analyisis
train_y = train['opices']
train_x = train.drop(['opices'],axis=1)
print(train_x.shape)

test_y = test['opices']
test_x = test.drop(['opices'],axis=1)
print(test_x.shape)




print('---------------------finish loading data -------------------------')
#-----------------set up parameters--------------
from sklearn.svm import SVC
from sklearn.feature_selection import RFECV #A recursive feature elimination example with automatic tuning of the number of features selected with cross-validation. NO NEED TO SPECIFY NUMBER OF FEATURES SELECTED.

#---start doing analyisis-------------------------------

svm = SVC(Cost, kernel="linear", cache_size=1000, class_weight='balanced', probability=False)
	  ## parameters = {'kernel':('linear'), 'C':[1, 10]}
	  ## svc = SVC()
	  ## clf=GridSearchCV(svc, parameters)
#split the training data into 200 per validation to get the best # of features
# use RFECV instead of RFE so that it can autimatically select the # of features based on scores, if use RFE function need to specify the number of features one is going to select
# scoring could be auc or 'f1_weighted' for weighted average, estimator=svm uses coef which is (the Weights assigned to the features (coefficients in the primal problem). This is only available in the case of a linear kernel.

if metric =="auc":
        scores ='roc_auc'
if metric =="f1":
        scores='f1_micro'


rfe = RFECV(estimator=svm, cv=10 , step=1, scoring =scores, n_jobs = 5 ) #set -omp to 8 core although need 5
result =  rfe.fit(train_x, train_y)  
score = result.score(train_x, train_y)
svm_result = svm.fit(train_x, train_y)


# predict the test set
test_accuracy =  result.score(test_x, test_y)


#
print ('the cost is', Cost)
print ('the f1 on the training set is ', score)
print ('the number of features assoicated with cross validation is', result.n_features_)
print ('the ranking of features associated with the best F1 is', result.ranking_)
print ('the features left for the best F1 is', train_x.columns[result.support_].values)
print ('the weight for each selected variable is', svm_result.coef_[:,result.support_])
print ('the accuracy in test set is ', test_accuracy)

