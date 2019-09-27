
data <- read.csv('train_rs.csv')

#str(train)

#Remove the columns that we don't want to use
data$artist_name <- NULL
data$composer <- NULL
data$lyricist <- NULL
 
library(fastDummies)
#Create dummy variables for categorical variables 
data <- dummy_cols(data,select_columns = "source_system_tab",remove_first_dummy = TRUE)
data <- dummy_cols(data,select_columns = "source_screen_name",remove_first_dummy = TRUE)
data <- dummy_cols(data,select_columns = "source_type",remove_first_dummy = TRUE)
data <- dummy_cols(data,select_columns = "gender",remove_first_dummy = TRUE)

#Create the train data size 
train_size <- floor(0.75 * nrow(data))

## set the seed to make your partition reproducible
set.seed(123)
train_indices <- sample(seq_len(nrow(data)), size = train_size)

#Subset the data using indices selected
train <- data[train_indices, ]
test <- data[-train_indices, ]


################ MODELLING BEGINS ############
