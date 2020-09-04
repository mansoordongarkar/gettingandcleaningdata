### Introduction

The objective of this analysis is to obtain a tidy data set from an experimental data of 30 volunteers within an age bracket of 19-48 years randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The experiment consisted of each volunteer performing six activities *(WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)* wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, a 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz readings are captured.

For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

As stated above the features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ.The said data is passed through various filters to obtain the full 561 feature vector denoted as..(XYZ indicates the 3 axis)

- tBodyAcc-XYZ
- tGravityAcc-XYZ
- tBodyAccJerk-XYZ
- tBodyGyro-XYZ
- tBodyGyroJerk-XYZ
- tBodyAccMag
- tGravityAccMag
- tBodyAccJerkMag
- tBodyGyroMag
- tBodyGyroJerkMag
- fBodyAcc-XYZ
- fBodyAccJerk-XYZ
- fBodyGyro-XYZ
- fBodyAccMag
- fBodyAccJerkMag
- fBodyGyroMag
- fBodyGyroJerkMag

Additional variables are estimated from the above signals.

**Please refer the associated codebook for a detailed explanation of the various datasets and their details**

## Work Process

*Please ensure you are in your working directory prior to runiing the script, as files will be downloaded and extracted.*

The complete data set is downloaded from the  following site in the form of a zip file and stored locally as "Master.zip". https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

```{r}
library(dplyr)
library(reshape2)
library(tidyr)
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "Master.zip")
filelist <- unzip("Master.zip")
```


**The dataset includes the following files:**

- README.txt
- features_info.txt: Shows information about the variables used on the feature vector.
- features.txt: List of all features, loaded into R as a dataframe.
```{r}
features <- read.table(filelist[grep("features.txt",filelist)])
```
- activity_labels.txt: Links the class labels with their activity name.
- train/X_train.txt: Training set.
- train/y_train.txt: Training labels.
- test/X_test.txt: Test set.
- test/y_test.txt: Test labels.
- train/subject_train.txt: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.(*Similar file also exists for Testing data*)

Additional files are available for the train and test data highlighting further details.

**Following steps in general are implemented to arrive at our goal...**

### Merges the training and the test sets to create one data set.

Below is the logic flow implemented for the same...

- Training data set is loaded from file 'train/X_train.txt'.   
- Feature set of the training data is also loaded from file 'features.txt'.  
- Column names of training data is updated with data from features.txt, to ensure compatibility with experimental data, the data labels are maintained identical as per "feature" data set.  
- Training labels are loaded from 'train/y_train.txt' and are labeled as per information provided in 'activity_labels.txt'.  
- The training label data is merged into main training data and renamed as "activity".  
- Finally the subject / volunteer data is loaded from 'train/subject_train.txt'and to ensure easy identification even after merging with test data, individual volunteer ids are prefixed with "trainingvolunteer".  
- To conclude the subject data is also merged with main training data and the column name is updated to "volunteer.  

Below is the code chunk that carries out the above logic flow...

```{r}
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
```

All the steps mentioned above are repeated for test data set as below.

```{r}
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
```

**We now end with two data sets namely "trainingdata" and "testingdata" having identical column names and data structure, these are now merged as "mergedata"..**

```{r}
mergedata <- rbind(trainingdata,testingdata)
```

### Extracts only the measurements on the mean and standard deviation for each measurement.

As stated earlier the column names utilized are from the feature set provided in the zip file and it consists of evaluations of...

- mean(): Mean value.  
- std(): Standard deviation.  
- mad(): Median absolute deviation.   
- max(): Largest value in array.  
- min(): Smallest value in array.  
- sma(): Signal magnitude area.  
- energy(): Energy measure. Sum of the squares divided by the number of values.   
- iqr(): Interquartile range.   
- entropy(): Signal entropy.  
- arCoeff(): Autorregresion coefficients with Burg order equal to 4.  
- correlation(): correlation coefficient between two signals.  
- maxInds(): index of the frequency component with largest magnitude.  
- meanFreq(): Weighted average of the frequency components to obtain a mean frequency.  
- skewness(): skewness of the frequency domain signal.   
- kurtosis(): kurtosis of the frequency domain signal.   
- bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.  
- angle(): Angle between to vectors.  

Since the indications of evaluated values are already in the feature name, these columns are isolated from the mergedata per below..

```{r}
meanstddata <- cbind(select(mergedata,volunteer,activity,grep("mean",colnames(mergedata))),select(mergedata,grep("std",colnames(mergedata))))
```

The individual column names of this new data set is also derived from the mergedata which has already been aligned as per experimental indications of features.

**Hence now we have a subset of mergedata as "meanstddata" which only contains details of the volunteer, the activity and the expected mean and std estimations.**

### Finally create an independent tidy data set with the average of each variable for each activity and each subject.

This is obtained by utilizing the melt and dcast functionality of tidyr package as indicated below..

- The meanstddata is narrowed down by using the melt function using the feature names as measure.vars against the id of volunteer and activity.  
- The dcast function is subsequently used to obtain the desired results.  
- Finally data set "tidyata" is obtained by reshaping and cleaning the results obtained from dcast function.  

The code that implements the above logic is...

```{r}
meltnewdata <- melt(meanstddata,id = colnames(meanstddata[1:2]),measure.vars = colnames(meanstddata[3:length(colnames(meanstddata))]))
meltnewdata <- mutate(meltnewdata,"vol_act_cam" = paste(volunteer,activity,sep = "_"))
dcastdata <- dcast(meltnewdata,vol_act_cam~variable,mean)
dcastdata <- separate(dcastdata,col = vol_act_cam,into = c("vol","act","cam"))
colnames(dcastdata) <- gsub("vol","volunteer",colnames(dcastdata))
colnames(dcastdata) <- gsub("act","activity",colnames(dcastdata))
dcastdata <- mutate(dcastdata,activity = paste(activity,cam,sep = "_"))
dcastdata <- mutate(dcastdata,activity = sub("_NA$","",activity))
tidydata <- select(dcastdata,volunteer,activity,4:length(colnames(dcastdata)))
```

**The output is a tidy data set summarizing the desired results**

Finally the environment is cleaned of the intermediate variables and temporary data sets..

```{r}
rm(filelist)
rm(meltnewdata)
rm(dcastdata)
rm(trainingdata)
rm(testingdata)
rm(features)
```

We end up with...

- **mergedata :** the original merged data of training and test data.  
- **meanstddata :** the subset of mergedata consisting of only mean and std evaluations.  
- **tidydata :** the final tidy data summarizing the results.  
