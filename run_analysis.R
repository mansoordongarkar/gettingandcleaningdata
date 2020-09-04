#
#Please set your working directory before running this script.
#This script downloads and unzips a file from the internet
library(dplyr)
library(reshape2)
library(tidyr)
#Please set your own working directory
#setwd("D:/Data Science/Course/03_Getting and Cleaning Data/Week 4/Project/gettingandcleaningdata")

#Downloading and unzipping the file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "Master.zip")
filelist <- unzip("Master.zip")
features <- read.table(filelist[grep("features.txt",filelist)])

#Loading and cleaning the complete training data set
trainingdata <- read.table(filelist[grep("X_train.txt",filelist)])
colnames(trainingdata) <- features$V2 # using the same features description as in experiment
trainingdatalbl <- read.table(filelist[grep("train/y_train.txt",filelist)])
trainingdatalbl <- factor(trainingdatalbl$V1,labels = c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")) # using the same activity description as in experiment.
trainingdata <- cbind(trainingdatalbl,trainingdata)
colnames(trainingdata) <- gsub("trainingdatalbl","activity",colnames(trainingdata))
rm(trainingdatalbl)
trainsubject <- read.table(filelist[grep("train/subject_train.txt",filelist)])
trainsubject <- mutate(trainsubject,V1 = paste("trainingvolunteer",V1,sep = "")) # prefixing the volunteer id with "trainingvolunteer" for easy identification in merged data
trainingdata <- cbind(trainsubject,trainingdata)
colnames(trainingdata) <- gsub("V1","volunteer",colnames(trainingdata))
rm(trainsubject)

#Loading and cleaning the complete testing data set
testingdata <- read.table(filelist[grep("test/X_test.txt",filelist)])
colnames(testingdata) <- features$V2 # using the same features description as in experiment
testingdatalbl <- read.table(filelist[grep("test/y_test.txt",filelist)])
testingdatalbl <- factor(testingdatalbl$V1,labels = c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")) # using the same activity description as in experiment.
testingdata <- cbind(testingdatalbl,testingdata)
colnames(testingdata) <- gsub("testingdatalbl","activity",colnames(testingdata))
rm(testingdatalbl)
testsubject <- read.table(filelist[grep("test/subject_test.txt",filelist)])
testsubject <- mutate(testsubject,V1 = paste("testvolunteer",V1,sep = "")) # prefixing the volunteer id with "testvolunteer" for easy identification in merged data
testingdata <- cbind(testsubject,testingdata)
colnames(testingdata) <- gsub("V1","volunteer",colnames(testingdata))
rm(testsubject)

#Combining the two data sets training data and test data
mergedata <- rbind(trainingdata,testingdata) #using rbind since the individual volunteers have been prefixed with their group


#Isolating only the mean (Average) and std (Standard Deviation) columns based on descriptions provided in feature data
meanstddata <- cbind(select(mergedata,volunteer,activity,grep("mean",colnames(mergedata))),select(mergedata,grep("std",colnames(mergedata))))

#Independent tidy data set with average of each variable for each activity and each subject utilising the melt and dcast functions
meltnewdata <- melt(meanstddata,id = colnames(meanstddata[1:2]),measure.vars = colnames(meanstddata[3:length(colnames(meanstddata))]))
meltnewdata <- mutate(meltnewdata,"vol_act_cam" = paste(volunteer,activity,sep = "_"))
dcastdata <- dcast(meltnewdata,vol_act_cam~variable,mean)
dcastdata <- separate(dcastdata,col = vol_act_cam,into = c("vol","act","cam"))
colnames(dcastdata) <- gsub("vol","volunteer",colnames(dcastdata))
colnames(dcastdata) <- gsub("act","activity",colnames(dcastdata))
dcastdata <- mutate(dcastdata,activity = paste(activity,cam,sep = "_"))
dcastdata <- mutate(dcastdata,activity = sub("_NA$","",activity))
tidydata <- select(dcastdata,volunteer,activity,4:length(colnames(dcastdata)))

#Final removing of all the unwanted and temporary variables and datasets
rm(filelist)
rm(meltnewdata)
rm(dcastdata)
rm(trainingdata)
rm(testingdata)
rm(features)
