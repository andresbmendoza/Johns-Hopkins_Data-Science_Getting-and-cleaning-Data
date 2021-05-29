library(dplyr)
library(data.table)
## 1- Merges the training and the test sets to create one data set.

tempXtraining <- read.table("UCI HAR Dataset/train/X_train.txt")                ## training measurments
tempXtest <- read.table("UCI HAR Dataset/test/X_test.txt")                      ## test measurments
X <- rbind(tempXtraining,tempXtest)                                             ## complete measurments

tempYtraining <- read.table("UCI HAR Dataset/train/y_train.txt")                ## training table activities name
tempYtest <- read.table("UCI HAR Dataset/test/y_test.txt")                      ## training table activities name
Y <- rbind(tempYtraining,tempYtest)                                             ## Complete Activities

tempSubjectTraining <- read.table("UCI HAR Dataset/train/subject_train.txt")    ##Load training subject
tempSubjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")          ##Load testing subject
subject <- rbind(tempSubjectTraining,tempSubjectTest)                           ##Complete subjects
names(subject) <- c("subject")                                                  ##Naming Table

##2- Extracts only the measurements on the mean and standard deviation
##for each measurement. 

VarsName <-  read.table("UCI HAR Dataset/features.txt")                         ##Load File
isAvgOrStd <- grepl("-(mean|std)\\(\\)",VarsName[, 2])                          ## Create logic vector where mean and std appeared on :

## Select only de variables (columns) with mean and standard deviation:
X1 <- X[, isAvgOrStd]                                                           ## create a data set only mean and std variables(columns) 
VectVarsName <- gsub("\\(\\)", "", VarsName[isAvgOrStd, 2])                     ## Remove "()" from each var name
names(X1) <- VectVarsName                                                       ## labeling the vars with their feature names

##3- Uses descriptive activity names to name the activities in the data set

ActivitiesLabels <- read.table("UCI HAR Dataset/activity_labels.txt")           ##Load Activity names File
ActivitiesLabels[,2] <- tolower(sub("_", " ", ActivitiesLabels[,2]))            ##Rename Var lower without underscore
Y1 = Y                                                                          ##Temp Variable
Y1[,1] = ActivitiesLabels[Y1[,1],2]                                             ## write all activities name for each index 
names(Y1) <- c("Activity")                                                      #Labeling DT

##4- Appropriately labels the data set with descriptive variable names. 
TidyTable <- cbind(subject, Y1, X1)                                             ## Create a Data Table with subject, Data activity name and measures Tided
write.table(TidyTable, file = "merged_Tidy_Data.txt")                                ## Create a plain file with Tidy Data

##5- From the data set in step 4, creates a second, independent tidy data set with
##the average of each variable for each activity and each subject.

RawDT <- read.table("merged_Tidy_Data.txt", header = TRUE)                           ##Create new independent table from output into working directory

Title <- colnames(RawDT)
measures <- Title[3:length(Title)]                                              ##Create a Vector with Only measured variables

summaryTable <- RawDT %>%                                                       ##Create a pipeline to summarize into 
  group_by(subject, Activity) %>%                                               ## grouping by each Subject and Activity
  summarise_at(measures, mean)                                                  ## Summarize by mean of each measured variable on activity and subject
write.table(summaryTable, file = "summarized_Mean_data.txt", row.names = FALSE)
