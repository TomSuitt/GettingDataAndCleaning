## Getting And Cleaning Data Project

library(dplyr)
library(data.table)

##Set working directory to where data is saved
homedir <- "c:/users/Tom Suitt/Desktop/Coursera/CleanDataProject/"
setwd(homedir)

##Set filenames
trnset  <- "train/X_train.txt"  ##Training set
trnactv <- "train/y_train.txt"   ##Training labels (activity)

testset  <- "test/X_test.txt"    ##Test set
tstactv  <- "test/y_test.txt"     ##Test labels (activity)

subjecttrn <- "train/subject_train.txt" ##Subject who perf activity
subjecttst <- "test/subject_test.txt"   ##Subject test info

featuresfile <- "features.txt"
activityfile <- "activity_labels.txt"

FtrTable <- read.table(featuresfile)
ActvTable <- read.table(activityfile, header=FALSE)

##  --> Merges the training and the test sets to create one data set.
SubTrain <- read.table(subjecttrn, header=FALSE)
TrainingData <- read.table(trnactv, header=FALSE)
TrainingLabels <- read.table(trnset, header=FALSE)

SubTest <- read.table(subjecttst, header=FALSE)
TestData <- read.table(tstactv, header=FALSE)
TestLabels <- read.table(testset, header=FALSE)

SubjectTable <- rbind(SubTrain, SubTest)
DataTable    <- rbind(TrainingData, TestData)
LabelTable   <- rbind(TrainingLabels, TestLabels)

##Name columns
colnames(SubjectTable) <- c("Subject")
colnames(DataTable)    <- c("Data")
colnames(LabelTable)   <- FtrTable$V2

##Finally combine all data together
AllData <- cbind(LabelTable, SubjectTable, DataTable)

##  -->Extracts only the measurements on the mean and standard deviation for each measurement. 

##Pull all Mean and STD columns from AllData
MeanSTDSubset <- grep(".*Mean.*|.*Std.*", names(AllData), ignore.case=TRUE)

##Build variable to use for subset of AllData
OnlyMeanSTDCols <- c(MeanSTDSubset, 562, 563)

AllDataExtract <- AllData[, OnlyMeanSTDCols]


##  -->Uses descriptive activity names to name the activities in the data set
AllDataExtract$Data <- as.character(AllDataExtract$Data)

##ActvTable is where the Activity names are
for (i in 1:6) { 

	AllDataExtract$Data[AllDataExtract$Data == i] <- as.character(ActvTable[i,2])
}

AllDataExtract$Data <- as.factor(AllDataExtract$Data)

##  -->Appropriately labels the data set with descriptive variable names. 
##By using names() on dataset, set descriptive names manually
names(AllDataExtract) <- gsub("Acc", "Acclerometer", names(AllDataExtract))
names(AllDataExtract) <- gsub("BodyBody", "Body", names(AllDataExtract))
names(AllDataExtract) <- gsub("Gyro", "Gyroscope", names(AllDataExtract))
names(AllDataExtract) <- gsub("tBody", "TimeBody", names(AllDataExtract))
names(AllDataExtract) <- gsub("^t", "Time", names(AllDataExtract))
names(AllDataExtract) <- gsub("^f", "Frequency", names(AllDataExtract))

##  -->From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

AllDataExtract$Subject <- as.factor(AllDataExtract$Subject)

##Convert list to table
AllDataTable <- data.table(AllDataExtract)

##Make it tidy!
TidyTable <- aggregate(. ~Subject + Data, AllDataTable, mean)
TidyTable <- TidyTable[order(TidyTable$Subject, TidyTable$Data), ]

##  -->Please upload your data set as a txt file created with write.table() using row.name=FALSE
write.table(TidyTable, file = "run_analysis_out.txt", row.names=FALSE)
