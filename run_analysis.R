# Read only needed features labels.
features <- fread("UCI HAR Dataset\\features.txt",
                  sep = " ",
                  col.names = c("code", "name")
)[grepl("(mean|std)\\w*\\(\\)", name, ignore.case = T)]

# Read source files and form a single dataset.
# Only needed features values (columns) are loaded.
ds.initial <- rbindlist(list(
     cbind(
          fread("UCI HAR Dataset\\train\\subject_train.txt")
         ,fread("UCI HAR Dataset\\train\\y_train.txt")
         ,fread("UCI HAR Dataset\\train\\X_train.txt", select = features$code)
     )
    ,cbind(
          fread("UCI HAR Dataset\\test\\subject_test.txt")
         ,fread("UCI HAR Dataset\\test\\y_test.txt")
         ,fread("UCI HAR Dataset\\test\\X_test.txt", select = features$code)
     )
))

# Name columns.
colnames(ds.initial) <- c("subject", "activityCode", features$name)

# Read activity labels...
labels <- fread("UCI HAR Dataset\\activity_labels.txt",
                sep = " ",
                col.names = c("activityCode", "activity"))

# ...and join them to the dataset.
ds.initial <- merge(x = ds.initial, y = labels,
                     by = "activityCode", all.x = T)

# Remove "code" column and reorder the rest.
ds.initial[, activityCode := NULL]
setcolorder(ds.initial,
            neworder = c("activity", setdiff(names(ds.initial), "activity"))
)

rm(features, labels)

# Form tidy dataset.
ds.tidy <- ds.initial[, lapply(.SD, mean), keyby = .(activity, subject)]

# Save result to file.
write.table(ds.tidy, file = "HAR_dataset_tidy.txt", row.names = F)
