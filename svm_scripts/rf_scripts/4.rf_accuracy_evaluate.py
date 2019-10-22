#!/usr/bin/env python3
import numpy as np
np.set_printoptions(threshold=np.inf)
import pandas as pd
from sklearn.pipeline import Pipeline
import sys


pop=sys.argv[1]
model=sys.argv[2]
ntree=int(sys.argv[3])
var_fn=sys.argv[4]


print(pop, model, ntree)
train_file="/ml_models/"+pop+'_model'+model+'_train.txt'
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




## select columns needed
var_file="/usr3/graduate/jiayiwu/jiayiwu/ML/random_forest/sklearn/m" + model +"/result/"+var_fn


var=pd.read_csv(var_file, sep=' ')

# get the rigth dataset
train_y = train['opices']
train_x = train[var.iloc[:,0].tolist()]

test_y=test['opices']
test_x=test[var.iloc[:,0].tolist()]


print('---------------------finish loading data -------------------------')
#-----------------set up parameters--------------
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score
from sklearn.metrics import f1_score



RF=RandomForestClassifier(n_estimators=ntree,max_features="auto", bootstrap=True, oob_score=False, n_jobs=-1, random_state=1, class_weight='balanced')

RF.fit(train_x, train_y.values)
#cross_validation = cross_val_score(RF,train_x, train_y.values,scoring="roc_auc_micro",cv=10 )
##score=sum(cross_validation)/10
#
## do on test set
y_pred= RF.predict(test_x)
test_accuracy_auc=roc_auc_score(test_y.values, y_pred)
test_accuracy_f1=f1_score(test_y.values, y_pred)

# print result to log
print ('the # of tree is', ntree)
#print ('the auc on the training set is ', score)
#print ('feature columns and their importance', pd.DataFrame(test_result.feature_importances_.tolist(), aa_train_x.columns.values.tolist()))
print ('the AUC on test set is ', test_accuracy_auc )
print ('the F1 on test set is ', test_accuracy_f1 )

