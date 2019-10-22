# this script evaluate auc and f1 result at once
rm(list=ls())
library(glmnet)
library(doMC)
#library(pROC)
library(AUC)

print (paste("only give the number of lambdas not in use as 0"))
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


# use misclassification error
# optimal lambda.min = 0.00531
if (lambda_mis_min !=0 ){
predict.mis.z.min<-glmnet(train.zscore, train, family="binomial", alpha=1, standardize=F, lambda=lambda_mis_min)
mis.z.min.beta<-as.data.frame(cbind(rownames(predict.mis.z.min$beta),predict.mis.z.min$beta[1:length(predict.mis.z.min$beta)]))
mis.z.min.beta<-mis.z.min.beta[mis.z.min.beta[,2]!=0,]
print('result for misclassifation min')
print(paste('number of features:', dim(mis.z.min.beta)))

print(mis.z.min.beta)
}

# optimal lambda.1se = 0.0116
if (lambda_mis_1se !=0 ){ 
predict.mis.z.1se<-glmnet(train.zscore, train, family="binomial", alpha=1, standardize=F, lambda=lambda_mis_1se)
mis.z.1se.beta<-as.data.frame(cbind(rownames(predict.mis.z.1se$beta),predict.mis.z.1se$beta[1:length(predict.mis.z.1se$beta)]))
mis.z.1se.beta<-mis.z.1se.beta[mis.z.1se.beta[,2]!=0,]
print('result for misclassifation 1se')
print(paste('number of features:', dim(mis.z.1se.beta)))
print(mis.z.1se.beta)
}

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
if (lambda_mis_min !=0 ){
result.cv3.min.prob<-as.data.frame(predict(predict.mis.z.min, test.zscore,type="response"))
write.table(result.cv3.min.prob, paste0("/usr3/graduate/jiayiwu/jiayiwu/ML/lasso/m", model,"/result/",pop,".mis_min.txt"), col.names=T, quote=F, row.names=F )
write.table(test, paste0("/usr3/graduate/jiayiwu/jiayiwu/ML/lasso/m", model,"/result/",pop,".true.txt"), col.names=T, quote=F, row.names=F )
}
if (lambda_mis_1se !=0 ){
result.cv3.1se.prob<-as.data.frame(predict(predict.mis.z.1se, test.zscore,type="response"))
write.table(result.cv3.1se.prob, paste0("/usr3/graduate/jiayiwu/jiayiwu/ML/lasso/m", model,"/result/",pop,".mis_1se.txt"), col.names=T, quote=F, row.names=F )
write.table(test, paste0("/usr3/graduate/jiayiwu/jiayiwu/ML/lasso/m", model,"/result/",pop,".true.txt"), col.names=T, quote=F, row.names=F )
}



#====

# use auc error

# optimal lambda.min = 0.0081
if (lambda_auc_min !=0 ){
predict.auc.z.min<-glmnet(train.zscore, train, family="binomial", alpha=1, standardize=F, lambda=lambda_auc_min)
auc.z.min.beta<-as.data.frame(cbind(rownames(predict.auc.z.min$beta),predict.auc.z.min$beta[1:length(predict.auc.z.min$beta)]))
auc.z.min.beta<-auc.z.min.beta[auc.z.min.beta[,2]!=0,]
print('result for auc min')
print(paste('number of features:', dim(auc.z.min.beta)))
print(auc.z.min.beta)
}

# optimal lambda.1se = 0.0134
if (lambda_auc_1se !=0) {
predict.auc.z.1se<-glmnet(train.zscore, train, family="binomial", alpha=1, standardize=F, lambda=lambda_auc_1se)
auc.z.1se.beta<-as.data.frame(cbind(rownames(predict.auc.z.1se$beta),predict.auc.z.1se$beta[1:length(predict.auc.z.1se$beta)]))
auc.z.1se.beta<-auc.z.1se.beta[auc.z.1se.beta[,2]!=0,]
print('result for auc 1se')
print(paste('number of features:', dim(auc.z.1se.beta)))
print(auc.z.1se.beta)
}

# fit data in test
if (lambda_auc_min !=0 ){
result.cv4.min.prob<-as.data.frame(predict(predict.auc.z.min, test.zscore,type="response"))
write.table(result.cv4.min.prob, paste0("/usr3/graduate/jiayiwu/jiayiwu/ML/lasso/m", model,"/result/",pop,".auc_min.txt"), col.names=T, quote=F, row.names=F )
write.table(test, paste0("/usr3/graduate/jiayiwu/jiayiwu/ML/lasso/m", model,"/result/",pop,".true.txt"), col.names=T, quote=F, row.names=F )
}

if (lambda_auc_1se !=0 ){
result.cv4.1se.prob<-as.data.frame(predict(predict.auc.z.1se, test.zscore,type="response"))
write.table(result.cv4.1se.prob, paste0("/usr3/graduate/jiayiwu/jiayiwu/ML/lasso/m", model,"/result/",pop,".auc_1se.txt"), col.names=T, quote=F, row.names=F )
write.table(test, paste0("/usr3/graduate/jiayiwu/jiayiwu/ML/lasso/m", model,"/result/",pop,".true.txt"), col.names=T, quote=F, row.names=F )
}



