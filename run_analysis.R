library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load dataser activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresSelected <- grep(".*mean.*|.*std.*", features[,2])
featuresSelected.names <- features[featuresSelected,2]
featuresSelected.names = gsub('-mean', 'Mean', featuresSelected.names)
featuresSelected.names = gsub('-std', 'Std', featuresSelected.names)
featuresSelected.names <- gsub('[-()]', '', featuresSelected.names)


# Load training and test datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresSelected]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresSelected]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)
library(reshape2)

# merge datasets and add labels
MergedData <- rbind(train, test)
colnames(MergedData) <- c("subject", "activity", featuresSelected.names)

# turn activities & subjects into factors
MergedData$activity <- factor(MergedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
MergedData$subject <- as.factor(MergedData$subject)

MergedData.melted <- melt(MergedData, id = c("subject", "activity"))
MergedData.mean <- dcast(MergedData.melted, subject + activity ~ variable, mean)

write.table(MergedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)


