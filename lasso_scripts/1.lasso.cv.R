library(glmnet)
library(doMC)

# use parallel computing
registerDoMC(cores=2)


args = commandArgs(trailingOnly=TRUE)
pop=args[1]
model=args[2]
metric=args[3]  # either auc or class

print(paste(pop, "model",model, metric))

# load zscore normalized data
train<-read.table(paste0("/ml_models/",pop,"_model",model,"_train.txt"),header=T, as.is=T, sep='\t',comment.char="",quote="", na.strings=c(NA,"NA",""))



train.zscore = model.matrix(~ ., train[,!(names(train) %in% 'opices') ])
train=train$opices

## run the model with cv to get lambda
# use binomial logistic regression loss : "class"
#cv1 = cv.glmnet(ea.x.train, ea.y.train, nfold=10, family="binomial",type.measure="class", keep =T, alpha=1, standardize=F)
# standardize is a logical flag for x variable standardization, prior to fitting the model sequence.
# the coefficient are always returned on the origial scale. 

# use auc error as a measure


for (i in (1:10)){
  assign(paste0("cv4.", i, sep=""), cv.glmnet(train.zscore, train, nfold=10,
                                              family="binomial",type.measure=metric, keep =T, alpha=1, standardize=F,parallel=T))
}

cv.misclass.lambda.4<-c()

for (i in (1:10)){
  index<-paste0("cv4.",i)
  cv.misclass.lambda.4<-append(cv.misclass.lambda.4, get(noquote(index))$lambda.min )
}

cv.misclass.lambda.1se.4<-c()

for (i in (1:10)){
  index<-paste0("cv4.",i)
  cv.misclass.lambda.1se.4<-append(cv.misclass.lambda.1se.4, get(noquote(index))$lambda.1se )
}

print("mean(cv.misclass.lambda.4)")
print(mean(cv.misclass.lambda.4))
print("mean(cv.misclass.lambda.1se.4)")
print(mean(cv.misclass.lambda.1se.4))
