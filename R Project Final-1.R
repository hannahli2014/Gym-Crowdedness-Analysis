library(ISLR)
setwd("C:/Users/hanna/OneDrive/Desktop")
raw_data = read.csv('data.csv')
n = dim(raw_data)[1]

library(DataExplorer)
library(ggplot2)
str(raw_data)

raw_data$date_clean <- substr(raw_data$date, 0, 19)
raw_data$date_new <- substr(raw_data$date, 0, 14)
raw_data$date_new_half <- substr(raw_data$date, 15, 15)
raw_data$data_new_half <- as.numeric(raw_data$date_new_half)
raw_data$minutes_hour <- ifelse(raw_data$data_new_half <= 3,'00:00', '30:00')
raw_data$time_clean <- paste( raw_data$date_new, raw_data$minutes_hour,sep='') 

#library(DataCombine)
#DataSlid1 <- slide(Data1, Var = "A", slideBy = -1)
raw_data$date_object <- strptime(as.character(raw_data$time_clean), "%Y-%m-%d %H:%M:%S")
raw_data$day_of_wk <- weekdays(raw_data$date_object)
raw_data$month_txt <- months(raw_data$date_object)

library(data.table)
#new_data <- raw_data %>% group_by(time_clean) %>% #summarise(mean_peop =
#mean(number_people),
#temperature = mean(temperature),
#is_holiday = mean(is_holiday),
#is_start_semester = mean(is_start_of_semester),
#is_during_semester = mean(is_during_semester),
#)
setDT(raw_data)
#raw_data[,.(number_people=mean(number_people, na.rm = T),.(date_object)]

raw_data$is_holiday <- as.numeric(raw_data$is_holiday)
raw_data$is_weekend <- as.numeric(raw_data$is_weekend)
raw_data$is_during_semester <- as.numeric(raw_data$is_during_semester)
raw_data$is_start_of_semester <- as.numeric(raw_data$is_start_of_semester)

str(raw_data)
new_data <- as.data.frame(raw_data[,list(temperature=mean(temperature),
                                         num_people= mean(number_people),
                                         is_holiday = mean(is_holiday),
                                         is_weekend = mean(is_weekend),
                                         is_start_of_semester =mean(is_start_of_semester),
                                         is_during_semester = mean(is_during_semester)), by=list(time_clean)])
new_data$date_object <- strptime(as.character(new_data$time_clean), "%Y-%m-%d %H:%M:%S")

new_data$day_of_wk <- weekdays(new_data$date_object)
new_data$month_txt <- months(new_data$date_object)
new_data$hour_of_the_day <- hour(new_data$date_object)

start <- as.POSIXct("2015-08-14")
interval <- 30

end <- start + as.difftime(583, units="days")

dates<-seq(from=start, by=interval*60, to=end)

fresh_data <- data.frame(dates, '0')
#fresh_data$ID <- seq.int(nrow(fresh_data))
#fresh_data$date <- 0
#fresh_data$date <- dates
fresh_data$time_clean <- fresh_data$dates
fresh_data$time_clean <- as.character(fresh_data$time_clean)
fresh_data_new<- merge(x =fresh_data, y =new_data, by = "time_clean", all.x = TRUE)

fresh_data_new[1,c('is_holiday')] <- 0
fresh_data_new[1,c('is_weekend')] <- 0
fresh_data_new[1,c('is_start_of_semester')] <- 0
fresh_data_new[1,c('is_during_semester')] <- 0
fresh_data_new[1,c('num_people')] <- 0
fresh_data_new[1,c('temperature')] <- 71.760

library(zoo)
fresh_data_new$temperature <- (na.locf(fresh_data_new$temperature) + rev(na.locf(rev(fresh_data_new$temperature))))/2

fresh_data_new$num_people <- ifelse(is.na(fresh_data_new$num_people),0,
                                    fresh_data_new$num_people)
fresh_data_new$is_holiday <- (na.locf(fresh_data_new$is_holiday) + rev(na.locf(rev(fresh_data_new$is_holiday))))/2
fresh_data_new$is_weekend <- (na.locf(fresh_data_new$is_weekend) + rev(na.locf(rev(fresh_data_new$is_weekend))))/2

fresh_data_new$is_start_of_semester <- (na.locf(fresh_data_new$is_start_of_semester) + rev(na.locf(rev(fresh_data_new$is_start_of_semester))))/2


fresh_data_new$is_during_semester <- (na.locf(fresh_data_new$is_during_semester) + rev(na.locf(rev(fresh_data_new$is_during_semester))))/2

fresh_data_new$date_object <- NULL
fresh_data_new$day_of_wk <- NULL
fresh_data_new$month_txt <- NULL
fresh_data_new$hour_of_the_day <- NULL
fresh_data_new$X.0. <- NULL

str(fresh_data_new)

fresh_data_new$day_of_wk <- weekdays(fresh_data_new$dates)
fresh_data_new$month <- months(fresh_data_new$dates)
fresh_data_new$hour_of_day <- hour(fresh_data_new$dates)

library(DataCombine)

fresh_data_new <- slide(fresh_data_new, Var = "num_people", slideBy = -48)
fresh_data_new$lag_1_day <- fresh_data_new$`num_people-48`

fresh_data_new <- fresh_data_new[-c(27985),]
fresh_data_new <- slide(fresh_data_new, Var = "num_people", slideBy = -336)
fresh_data_new$lag_1_week <- fresh_data_new$`num_people-336`

fresh_data_new$`num_people-48` <- NULL 
fresh_data_new$`num_people-336` <- NULL

fresh_data_new$lag_1_day <- ifelse(is.na(fresh_data_new$lag_1_day), 0,
                                   fresh_data_new$lag_1_day)
fresh_data_new$lag_1_week <- ifelse(is.na(fresh_data_new$lag_1_week), 0,
                                    fresh_data_new$lag_1_week)

fresh_data_new<- fresh_data_new[order(fresh_data_new$dates),]

library(chron)
library(timeDate)

#making a list of holidays
hlist <- c("USChristmasDay","USGoodFriday","USIndependenceDay","USLaborDay",
           "USNewYearsDay","USThanksgivingDay")        
myholidays  <- dates(as.character(holiday(2015:2018,hlist)),format="Y-M-D")

fresh_data_new$public_holiday <-is.holiday(fresh_data_new$dates,myholidays)

fresh_data_new$is_weekend <- ifelse(fresh_data_new$is_weekend > 0.6, 1,0)
fresh_data_new$is_holiday <- ifelse(fresh_data_new$is_holiday > 0.6, 1,0)
fresh_data_new$is_during_semester <- ifelse(fresh_data_new$is_during_semester > 0.6, 1,0)
fresh_data_new$is_start_of_semester <- ifelse(fresh_data_new$is_start_of_semester > 0.6, 1,0)

library(fastDummies)
str(fresh_data_new)
fresh_data_new$is_start_of_semester <-factor(fresh_data_new$is_start_of_semester)
fresh_data_new$is_during_semester <- factor(fresh_data_new$is_during_semester)
fresh_data_new$day_of_wk <- factor(fresh_data_new$day_of_wk )
fresh_data_new$is_weekend  <- factor(fresh_data_new$is_weekend )
fresh_data_new$month <- factor(fresh_data_new$month)
fresh_data_new$hour_of_day <- factor(fresh_data_new$hour_of_day)
fresh_data_new$is_holiday <- factor(fresh_data_new$is_holiday)
fresh_data_new$public_holiday <- factor(fresh_data_new$public_holiday)

str(fresh_data_new)

### all features
#train_all <- fresh_data_new[1:22368,]
#test_all <- fresh_data_new[22369:nrow(fresh_data_new),]

features <- names(fresh_data_new)[3:14]
features <- features[features != "is_holiday"]
#creating train and test set
train <- fresh_data_new[1:22368,features]
test <- fresh_data_new[22369:nrow(fresh_data_new),features]

#write new train/test.csv to csv files
write.csv(train, 'train_final.csv', row.names=FALSE)
write.csv(test, 'test_final.csv',row.names=FALSE)


##############################################################################################
                                        #MODEL TESTING
##############################################################################################
#testing with simple mean model
mean_model <- mean(train$num_people)
sqrt(mean(mean_model - test$num_people)^2)
#RMSE = 19.99802 for mean model

#testing with MLR
lm.fit <- lm(num_people~., data = train)
summary(lm.fit)
plot(lm.fit)

y_test <- test$num_people

#need to take out num_people before doing prediction bc it is the response variable
test$num_people <- NULL
predictions_lm <- predict(lm.fit, test)
predictions_lm
#WE SEE IT PRODUCES NEGATIVE PREDICTED VALUES. We cannot have negative number of people at the gym so we must use
#a different distribution.
rmse = sqrt(mean(predictions_lm - y_test)^2)
rmse

#RMSE for MLR (no interaction) is 3.196
#residuals show non-normal distributions in Normal Q-Q Plot
plot(lm.fit)
plot(predictions_lm, y_test,
     xlab="predicted",ylab="actual", title("MLR"))
abline(0,1, col = 'red')
#############################################################################################
                                      #Negative Binomial Distribution
#############################################################################################
library(MASS)
set.seed(123)
nb.fit = glm.nb(num_people~., data = train)
summary(nb.fit)
test <- fresh_data_new[22369:nrow(fresh_data_new),features]
y_test <- test$num_people
#need to take out num_people before doing prediction bc it is the response variable
test$num_people <- NULL
predictions_nb <- predict(nb.fit, test, type = 'response')
predictions_nb
rmse_nb = sqrt(mean(predictions_nb - y_test)^2)
rmse_nb
#RMSE = 6.70225
plot(nb.fit)
plot(predictions_nb, y_test,
     xlab="predicted",ylab="actual", title("Negative Binomial"))
abline(0,1, col = 'red')
#############################################################################################
                                      #Poisson Distribution
#############################################################################################
library(MASS)
set.seed(123)
poisson.fit <- glm(num_people~., family="poisson", data=train)
summary(poisson.fit)
test <- fresh_data_new[22369:nrow(fresh_data_new),features]
y_test <- test$num_people
#need to take out num_people before doing prediction bc it is the response variable
test$num_people <- NULL
predictions_poisson <- predict(poisson.fit, test, type = 'response')
predictions_poisson
rmse_poisson = sqrt(mean(predictions_poisson - y_test)^2)
rmse_poisson
#RMSE = 7.940207
plot(poisson.fit)
plot(predictions_poisson, y_test,
     xlab="predicted",ylab="actual", title("Poisson"))
abline(0,1, col = 'red')



#optimization
###################################################################################
#Best Subset Selection
###################################################################################
library(leaps)
test <- fresh_data_new[22369:nrow(fresh_data_new),features]
y_test <- test$num_people
#VALIDATION SET APPROACH
#now apply regsubsets to training data to perform best subset selection
regfit.best = regsubsets(num_people~., train, nvmax = 10)
test.mat = model.matrix(num_people~., test)
val.errors = rep(NA, 10)
for (i in 1:10){
  gym_coefi = coef(regfit.best, id = i)
  pred = test.mat[,names(gym_coefi)]%*%gym_coefi
  val.errors[i]=mean((y_test-pred)^2)
}
val.errors
which.min(val.errors)
coef(regfit.best,6)

lm.bestsub = lm(num_people~+lag_1_week+is_start_of_semester+public_holiday+day_of_wk+lag_1_day, data = train)
summary(lm.bestsub)
test <- fresh_data_new[22369:nrow(fresh_data_new),features]
y_test <- test$num_people
#need to take out num_people before doing prediction bc it is the response variable
test$num_people <- NULL
predictions_lm_best <- predict(lm.bestsub, test, type = 'response')
predictions_lm_best
rmse_lm = sqrt(mean(predictions_lm_best - y_test)^2)
rmse_lm
plot(predictions_lm_best, y_test,
     xlab="predicted",ylab="actual", title("MLR (Best Subset)"))
abline(0,1, col = 'red')

nb.bestsub = glm.nb(num_people~+lag_1_week+is_start_of_semester+public_holiday+day_of_wk+lag_1_day, data = train)
summary(nb.bestsub)
test <- fresh_data_new[22369:nrow(fresh_data_new),features]
y_test <- test$num_people
#need to take out num_people before doing prediction bc it is the response variable
test$num_people <- NULL
predictions_nb_best <- predict(nb.bestsub, test, type = 'response')
predictions_nb_best
rmse_nb = sqrt(mean(predictions_nb_best - y_test)^2)
rmse_nb

plot(predictions_nb_best, y_test,
     xlab="predicted",ylab="actual", title("Negative Binomial (Best Subset)"))
abline(0,1, col = 'red')
#rmse of 4.914 after doing best subset on these 6 predictors.

####################################################################
#Ridge Regression
####################################################################
library(glmnet)
test <- fresh_data_new[22369:nrow(fresh_data_new),features]
x_train = model.matrix(num_people~., train)[,-1]
#here I am creating the y vector from the training set
y_train = train$num_people
#creating x matrix for test set.
x_test = model.matrix(num_people~., test)[,-1]
#creating y vector for test set.
y_test = test$num_people
set.seed(123)
#calculate cv for ridge to get best lambda
cvR = cv.glmnet(x_train, y_train, alpha = 0)
#choosing the lambda with the smallest CV error
lamR = cvR$lambda.min
lamR

#now we can create the ridge model with this lambda we found using CV.
ridge_model = glmnet(x_train, y_train, alpha = 0, lambda = lamR)
#now using model to predict for test set
ridge_pred = predict(ridge_model, s = lamR, newx = x_test, type = 'coefficients')
rmse_ridge = sqrt(mean((ridge_pred - y_test)^2))
rmse_ridge
