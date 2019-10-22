# this script evaluate auc and f1 result at once
rm(list=ls())
library(glmnet)
library(doMC)
#library(pROC)
library(AUC)

# use parallel computing
registerDoMC(cores=2)

args = commandArgs(trailingOnly=TRUE)
pop=args[1]
model=args[2]
lambda_mis_min=as.numeric(args[3])
lambda_mis_1se=as.numeric(args[4])
lambda_auc_min=as.numeric(args[5])
lambda_auc_1se=as.numeric(args[6])


print(paste(pop, "model",model))

# load zscore normalized data
# ea.zscore_train<-read.table("/restricted/projectnb/addiction/users/jiayiwu/phenotype/ea.ml.train.z.txt",header=T, as.is=T, sep='\t',comment.char="",quote="", na.strings=c(NA,"NA",""))
train<-read.table(paste0("/usr3/graduate/jiayiwu/jiayiwu/phenotype/ml_models/",pop,"_model",model,"_train.txt"),header=T, as.is=T, sep='\t',comment.char="",quote="", na.strings=c(NA,"NA",""))
test<-read.table(paste0("/usr3/graduate/jiayiwu/jiayiwu/phenotype/ml_models/",pop,"_model",model,"_test.txt"),header=T, as.is=T, sep='\t',comment.char="",quote="", na.strings=c(NA,"NA",""))


train.zscore = model.matrix(~ ., train[,!(names(train) %in% 'opices') ])
train=train$opices



## run the model with cv to get lambda
# use binomial logistic regression loss : "class"
#cv1 = cv.glmnet(ea.x.train, train, nfold=10, family="binomial",type.measure="class", keep =T, alpha=1, standardize=F)
# standardize is a logical flag for x variable standardization, prior to fitting the model sequence.
# the coefficient are always returned on the origial scale. 


# use misclassification error
# optimal lambda.min = 0.00531
predict.mis.z.min<-glmnet(train.zscore, train, family="binomial", alpha=1, standardize=F, lambda=lambda_mis_min)
mis.z.min.beta<-as.data.frame(cbind(rownames(predict.mis.z.min$beta),predict.mis.z.min$beta[1:length(predict.mis.z.min$beta)]))
mis.z.min.beta<-mis.z.min.beta[mis.z.min.beta[,2]!=0,]
print('result for misclassifation min')
print(paste('number of features:', dim(mis.z.min.beta)))

print(mis.z.min.beta)

# optimal lambda.1se = 0.0116
predict.mis.z.1se<-glmnet(train.zscore, train, family="binomial", alpha=1, standardize=F, lambda=lambda_mis_1se)
mis.z.1se.beta<-as.data.frame(cbind(rownames(predict.mis.z.1se$beta),predict.mis.z.1se$beta[1:length(predict.mis.z.1se$beta)]))
mis.z.1se.beta<-mis.z.1se.beta[mis.z.1se.beta[,2]!=0,]
print('result for misclassifation 1se')
print(paste('number of features:', dim(mis.z.1se.beta)))
print(mis.z.1se.beta)

# fit data in test
test.zscore=model.matrix(~ ., test[,!(names(test) %in% 'opices') ])
test=test$opices


#---
# github.com/glmnet/inst/doc/glmnet_beta.rmd, 
# why shouldn't I use linear regresssion if my outcome is binary
# since "link" is the linear prediction of binary outcome, the 'normality' assumption 
#is violated (the redsiduals from a regression model on a binary outcome will not look bell shaped)
# but this could be solved with sufficiently large sample 
# "class" produces the class label correonding to the max probability 
result.cv3.min.prob<-as.data.frame(predict(predict.mis.z.min, test.zscore,type="response"))
result.cv3.1se.prob<-as.data.frame(predict(predict.mis.z.1se, test.zscore,type="response"))


# analyse prediction error
result.cv3.prob<-as.data.frame(cbind(result.cv3.min.prob, result.cv3.1se.prob, test))
names(result.cv3.prob)<-c("lambda.min","lambda.1se","test")

result.cv3.prob$perform.min<-ifelse(result.cv3.prob$lambda.min>0.5, 1, 0)
result.cv3.prob$perform.1se<-ifelse(result.cv3.prob$lambda.1se>0.5, 1, 0)

#result.cv3.prob$crs_entropy.min<--(result.cv3.prob$test*log2(result.cv3.prob$lambda.min)+(1-result.cv3.prob$test)*(log2(1-result.cv3.prob$lambda.min)))
#result.cv3.prob$crs_entropy.1se<--(result.cv3.prob$test*log2(result.cv3.prob$lambda.1se)+(1-result.cv3.prob$test)*(log2(1-result.cv3.prob$lambda.1se)))

#-----make confusion matrix for error detection
#--------------------------------
pred0<-c(sum(result.cv3.prob$test==0 & result.cv3.prob$perform.min==0),
         sum(result.cv3.prob$test==1 & result.cv3.prob$perform.min==0))  
pred1<-c(sum(result.cv3.prob$test==0 & result.cv3.prob$perform.min==1),
         sum(result.cv3.prob$test==1 & result.cv3.prob$perform.min==1))

b<-data.frame(pred0, pred1,row.names=c("true0", "true1"))
# calculate balanced accuracy:
score=(b[1,1]/(b[1,1]+b[1,2])  +b[2,2]/(b[2,2]+b[2,1])  )/2
print (paste('F1 score for misclassification min:', score))
auc=auc(roc(as.factor(result.cv3.prob$perform.min),as.factor(test)))
print (paste('auc misclassification min:', auc))

pred0<-c(sum(result.cv3.prob$test==0 & result.cv3.prob$perform.1se==0),
         sum(result.cv3.prob$test==1 & result.cv3.prob$perform.1se==0))  
pred1<-c(sum(result.cv3.prob$test==0 & result.cv3.prob$perform.1se==1),
         sum(result.cv3.prob$test==1 & result.cv3.prob$perform.1se==1))##

b<-data.frame(pred0, pred1,row.names=c("true0", "true1"))
# calculate balanced accuracy
score=(b[1,1]/(b[1,1]+b[1,2])  +b[2,2]/(b[2,2]+b[2,1])  )/2
print (paste('F1 score for misclassification 1se:', score))
auc=auc(roc(as.factor(result.cv3.prob$perform.1se),as.factor(test)))
print (paste('auc misclassification 1se:', auc))

#====

# use auc error

# optimal lambda.min = 0.0081
predict.auc.z.min<-glmnet(train.zscore, train, family="binomial", alpha=1, standardize=F, lambda=lambda_auc_min)
auc.z.min.beta<-as.data.frame(cbind(rownames(predict.auc.z.min$beta),predict.auc.z.min$beta[1:length(predict.auc.z.min$beta)]))
auc.z.min.beta<-auc.z.min.beta[auc.z.min.beta[,2]!=0,]
print('result for auc min')
print(paste('number of features:', dim(auc.z.min.beta)))
print(auc.z.min.beta)


# optimal lambda.1se = 0.0134
predict.auc.z.1se<-glmnet(train.zscore, train, family="binomial", alpha=1, standardize=F, lambda=lambda_auc_1se)
auc.z.1se.beta<-as.data.frame(cbind(rownames(predict.auc.z.1se$beta),predict.auc.z.1se$beta[1:length(predict.auc.z.1se$beta)]))
auc.z.1se.beta<-auc.z.1se.beta[auc.z.1se.beta[,2]!=0,]
print('result for auc 1se')
print(paste('number of features:', dim(auc.z.1se.beta)))
print(auc.z.1se.beta)


# fit data in test
result.cv4.min.prob<-as.data.frame(predict(predict.auc.z.min, test.zscore,type="response"))
result.cv4.1se.prob<-as.data.frame(predict(predict.auc.z.1se, test.zscore,type="response"))



# analyse prediction error
result.cv4.prob<-as.data.frame(cbind(result.cv4.min.prob,result.cv4.1se.prob,test))
names(result.cv4.prob)<-c("lambda.min","lambda.1se","test")

result.cv4.prob$perform.min<-ifelse(result.cv4.prob$lambda.min>0.5, 1, 0)
result.cv4.prob$perform.1se<-ifelse(result.cv4.prob$lambda.1se>0.5, 1, 0)

result.cv4.prob$crs_entropy.min<--(result.cv4.prob$test*log(result.cv4.prob$lambda.min)+(1-result.cv4.prob$test)*(log(1-result.cv4.prob$lambda.min)))
result.cv4.prob$crs_entropy.1se<--(result.cv4.prob$test*log(result.cv4.prob$lambda.1se)+(1-result.cv4.prob$test)*(log(1-result.cv4.prob$lambda.1se)))

#-----make confusion matrix for error detection

#--------------------------------
pred0<-c(sum(result.cv4.prob$test==0 & result.cv4.prob$perform.min==0),
         sum(result.cv4.prob$test==1 & result.cv4.prob$perform.min==0))  
pred1<-c(sum(result.cv4.prob$test==0 & result.cv4.prob$perform.min==1),
         sum(result.cv4.prob$test==1 & result.cv4.prob$perform.min==1))

b<-data.frame(pred0, pred1,row.names=c("true0", "true1"))
# calculate balanced accuracy:
score=(b[1,1]/(b[1,1]+b[1,2])  +b[2,2]/(b[2,2]+b[2,1])  )/2
print (paste('F1 score for auc min:', score))
auc=auc(roc(as.factor(result.cv4.prob$perform.min),as.factor(test)))
print (paste('auc of auc min:', auc))



pred0<-c(sum(result.cv4.prob$test==0 & result.cv4.prob$perform.1se==0),
         sum(result.cv4.prob$test==1 & result.cv4.prob$perform.1se==0))  
pred1<-c(sum(result.cv4.prob$test==0 & result.cv4.prob$perform.1se==1),
         sum(result.cv4.prob$test==1 & result.cv4.prob$perform.1se==1))

b<-data.frame(pred0, pred1,row.names=c("true0", "true1"))
# calculate balanced accuracy:
score=(b[1,1]/(b[1,1]+b[1,2])  +b[2,2]/(b[2,2]+b[2,1])  )/2
print (paste('F1 score for auc 1se:', score))
auc=auc(roc(as.factor(result.cv4.prob$perform.1se),as.factor(test)))
print (paste('auc of auc 1se:', auc))



