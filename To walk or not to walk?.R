#### Data Project -- 03/16/2018 ####

library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)

Yellow_Taxi_Data = read_csv("~/Documents/Work-related material/Yellow_Taxi_Data.csv")
summary(Yellow_Taxi_Data)

Yellow_Taxi_Data = Yellow_Taxi_Data[Yellow_Taxi_Data$trip_distance <= 1.5, ]
Yellow_Taxi_Data = Yellow_Taxi_Data[order(Yellow_Taxi_Data$pickup_datetime), ]
Yellow_Taxi_Data$Obs_Number = seq.int(nrow(Yellow_Taxi_Data))


Yellow_Taxi_Data$Walk_duration = Yellow_Taxi_Data$trip_distance*19.354
Yellow_Taxi_Data$Walk_duration_secs = Yellow_Taxi_Data$Walk_duration*60

Yellow_Taxi_Data$Trip_Duration_mins = as.numeric(Yellow_Taxi_Data$Trip_Duration, units = "seconds")/60 + 3
# We estimate that it takes on average (w/o adjusting for time of day) three minutes to hail a cab

## Removing nonsensical outliers (data input errors) ##

Yellow_Taxi_Data = Yellow_Taxi_Data[Yellow_Taxi_Data$Trip_Duration_mins <= 150, ] 
# Limiting to rides no longer than 150 minutes

Yellow_Taxi_Data = Yellow_Taxi_Data[Yellow_Taxi_Data$PU_x_coord < 0, ] 
Yellow_Taxi_Data = Yellow_Taxi_Data[Yellow_Taxi_Data$PU_y_coord > 0, ] 
Yellow_Taxi_Data = Yellow_Taxi_Data[Yellow_Taxi_Data$DO_x_coord < 0, ] 
Yellow_Taxi_Data = Yellow_Taxi_Data[Yellow_Taxi_Data$DO_y_coord > 0, ] 

Yellow_Taxi_Data$Trip_dummy = ifelse(Yellow_Taxi_Data$Trip_Duration_mins > Yellow_Taxi_Data$Walk_duration, 1, 0)
# Ride takes longer ==> 1; walk takes longer ==> 0

Yellow_Taxi_Data$Time_diff = Yellow_Taxi_Data$Trip_Duration_mins - Yellow_Taxi_Data$Walk_duration

write.csv(Yellow_Taxi_Data, "YellowTaxiData_ProjectPop.csv")


## Histogram of project's population dataset (with time difference being the variable of interest) ##

# Crazy to see the CLT in action ==> distribution is almost perfectly normal (or Poisson) (adding constant of 
# 3 to walking duration merely shifts the dist., affecting the mean but not the variance)
Histogram_Data = Yellow_Taxi_Data[Yellow_Taxi_Data$Time_diff <= 60, ]
ggplot(data=Yellow_Taxi_Data, aes(Yellow_Taxi_Data$Time_diff)) + 
  geom_histogram(breaks=seq(-30, 30, by=2), 
               col = "red", 
               fill = "green", 
               alpha = .2) + 
  labs(title="Trip Duration minus Walk Duration", x = "Difference in Time", y="Count") + 
  xlim(c(-32,20)) + 
  ylim(c(0, 65000))


## Pie Chart ##

Walk_Trip_Perc_Matrix = matrix(
  c(Walk_Perc, Trip_Perc),
  nrow = 1,
  ncol = 2)

pie(Walk_Trip_Perc_Matrix, c("Walk", "Take a cab"), main = "To walk or not to walk?", col = rainbow(length(Walk_Trip_Perc_Matrix)))


## Splitting Times into different classes (using dummies) ##

Yellow_Taxi_Data$Walk_indicator = ifelse(Yellow_Taxi_Data$Trip_Duration_mins > Yellow_Taxi_Data$Walk_duration, 1, 0)
Yellow_Taxi_Data$PU_Time = as.numeric(Yellow_Taxi_Data$pickup_time, units = "seconds")/3600 # Reports PU time in hour of day
Yellow_Taxi_Data$DO_Time = as.numeric(Yellow_Taxi_Data$dropoff_time, units = "seconds")/3600 # Same for DO time


## Sample dataset for analysis ##

Subsetted_data = Yellow_Taxi_Data[sample(nrow(Yellow_Taxi_Data), replace = F, size = 0.08*nrow(Yellow_Taxi_Data)),
                                  ]
summary(Subsetted_data)

write.csv(Subsetted_data, "Subsetted_data.csv")

Subsetted_Carto <- 
  Yellow_Taxi_Data %>%
  filter(Walk_indicator == 1)
summary(Subsetted_Carto)

write.csv(Subsetted_Carto, "Walk_indicator.csv")

Subsetted_Carto = Subsetted_data[sample(nrow(Subsetted_data), replace = F, size = 0.025*nrow(Subsetted_data)),
                                   ]

write.csv(Subsetted_Carto, "Subsetted_Carto_Dropoff.csv")


## Histogram of sample dataset (with time difference being the variable of interest) ##

Histogram_Data1 = Subsetted_data[Subsetted_data$Time_diff <= 60, ]
ggplot(data=Subsetted_data, aes(Subsetted_data$Time_diff)) + 
  geom_histogram(breaks=seq(-30, 30, by=2), 
                 col = "red", 
                 fill = "green", 
                 alpha = .2) + 
  labs(title="Trip Duration minus Walk Duration", x = "Difference in Time", y="Count") + 
  xlim(c(-32,20)) + 
  ylim(c(0, 6000))


## Histogram of a subset of the sample dataset (with time difference being the variable of interest) ##

Histogram_Data1 = Subsetted_Carto[Subsetted_Carto$Time_diff <= 60, ]
ggplot(data=Subsetted_Carto, aes(Subsetted_Carto$Time_diff)) + 
  geom_histogram(breaks=seq(-30, 30, by=2), 
                 col = "red", 
                 fill = "green", 
                 alpha = .2) + 
  labs(title="Trip Duration minus Walk Duration", x = "Difference in Time", y="Count") + 
  xlim(c(-32,20)) + 
  ylim(c(0, 150))


## Time Dummies ##


Subsetted_data$Twel_to_4_AM = ifelse(Subsetted_data$PU_Time > 0 & Subsetted_data$PU_Time < 4, 1, 0)
Subsetted_data$Four_to_8_AM = ifelse(Subsetted_data$PU_Time > 4 & Subsetted_data$PU_Time < 8, 1, 0)
Subsetted_data$Eight_to_12_PM = ifelse(Subsetted_data$PU_Time > 8 & Subsetted_data$PU_Time < 12, 1, 0)
Subsetted_data$Twel_to_4_PM = ifelse(Subsetted_data$PU_Time > 12 & Subsetted_data$PU_Time < 16, 1, 0)
Subsetted_data$Four_to_8_PM = ifelse(Subsetted_data$PU_Time > 16 & Subsetted_data$PU_Time < 20, 1, 0)
Subsetted_data$Eight_to_12_AM = ifelse(Subsetted_data$PU_Time > 20 & Subsetted_data$PU_Time < 24, 1, 0)


## Splitting up by Pick Up Times ##

Twel_to_4_AM <- 
  Subsetted_data %>%
  filter(Twel_to_4_AM == 1)
Twel_to_4_AM = subset(Twel_to_4_AM, select = -c(8, 13, 14, 15, 16, 17, 20, 22, 28, 29, 30, 31, 32)) 
# Removing extraneous variables

Four_to_8_AM <- 
  Subsetted_data %>%
  filter(Four_to_8_AM == 1)
Four_to_8_AM = subset(Four_to_8_AM, select = -c(8, 13, 14, 15, 16, 17, 20, 22, 28, 29, 30, 31, 32)) 


Eight_to_12_PM <- 
  Subsetted_data %>%
  filter(Eight_to_12_PM == 1)

Eight_to_12_PM = subset(Eight_to_12_PM, select = -c(8, 13, 14, 15, 16, 17, 20, 22, 28, 29, 30, 31, 32)) 


Twel_to_4_PM <- 
  Subsetted_data %>%
  filter(Twel_to_4_PM == 1)

Twel_to_4_PM = subset(Twel_to_4_PM, select = -c(8, 13, 14, 15, 16, 17, 20, 22, 28, 29, 30, 31, 32)) 


Four_to_8_PM <- 
  Subsetted_data %>%
  filter(Four_to_8_PM == 1)

Four_to_8_PM = subset(Four_to_8_PM, select = -c(8, 13, 14, 15, 16, 17, 20, 22, 28, 29, 30, 31, 32)) 


Eight_to_12_AM <- 
  Subsetted_data %>%
  filter(Eight_to_12_AM == 1)

Eight_to_12_AM = subset(Eight_to_12_AM, select = -c(8, 13, 14, 15, 16, 17, 20, 22, 28, 29, 30, 31, 32)) 


## Analysis for each time period ##

# Twelve to 4 AM 
Hist_Twel_to_4_AM = Twel_to_4_AM[Time_diff <= 60, ]
ggplot(data=Twel_to_4_AM, aes(Time_diff)) + 
  geom_histogram(breaks = seq(-30, 30, by=2), 
                 col = "red", 
                 fill = "green", 
                 alpha = .2) + 
  labs(title="12:00 to 4:00 AM", x = "Difference in Time", y="Count") + 
  xlim(c(-28, 16)) + 
  ylim(c(0, 1250))

Twel_to_4_AM_Perc = sum(Twel_to_4_AM$Walk_indicator)/length(Twel_to_4_AM$Obs_Number)


# Four to 8 AM

Hist_Four_to_8_AM = Four_to_8_AM[Time_diff <= 60, ]
ggplot(data = Four_to_8_AM, aes(Time_diff)) + 
  geom_histogram(breaks = seq(-30, 30, by=2), 
                 col = "red", 
                 fill = "green", 
                 alpha = .2) + 
  labs(title="4:00 to 8:00 AM", x = "Difference in Time", y="Count") + 
  xlim(c(-28, 16)) + 
  ylim(c(0, 1250))

Four_to_8_AM_Perc = sum(Four_to_8_AM$Walk_indicator)/length(Four_to_8_AM$Obs_Number)


# Eight AM to 12 PM

Hist_Eight_to_12_PM = Eight_to_12_PM[Time_diff <= 60, ]
ggplot(data = Eight_to_12_PM, aes(Time_diff)) + 
  geom_histogram(breaks = seq(-30, 30, by=2), 
                 col = "red", 
                 fill = "green", 
                 alpha = .2) + 
  labs(title="8:00 AM to 12:00 PM", x = "Difference in Time", y="Count") + 
  xlim(c(-28,16)) + 
  ylim(c(0, 1250))

Eight_to_12_PM_Perc = sum(Eight_to_12_PM$Walk_indicator)/length(Eight_to_12_PM$Obs_Number)


# Twelve to 4 PM

Hist_Twel_to_4_PM = Twel_to_4_PM[Time_diff <= 60, ]
ggplot(data=Twel_to_4_PM, aes(Time_diff)) + 
  geom_histogram(breaks = seq(-30, 30, by=2), 
                 col = "red", 
                 fill = "green", 
                 alpha = .2) + 
  labs(title="12:00 PM to 4:00 PM", x = "Difference in Time", y="Count") + 
  xlim(c(-28, 16)) + 
  ylim(c(0, 1250))

Twel_to_4_PM_Perc = sum(Twel_to_4_PM$Walk_indicator)/length(Twel_to_4_PM$Obs_Number)


# Four to 8 PM

Hist_Four_to_8_PM = Four_to_8_PM[Time_diff <= 60, ]
ggplot(data = Four_to_8_PM, aes(Time_diff)) + 
  geom_histogram(breaks = seq(-30, 30, by=2), 
                 col = "red", 
                 fill = "green", 
                 alpha = .2) + 
  labs(title="4:00 PM to 8:00 PM", x = "Difference in Time", y="Count") + 
  xlim(c(-28, 16)) + 
  ylim(c(0, 1250))

Four_to_8_PM_Perc = sum(Four_to_8_PM$Walk_indicator)/length(Four_to_8_PM$Obs_Number)


# Eight to 12 AM

Hist_Eight_to_12_AM = Eight_to_12_AM[Time_diff <= 60, ]
ggplot(data = Eight_to_12_AM, aes(Time_diff)) + 
  geom_histogram(breaks = seq(-30, 30, by=2), 
                 col = "red", 
                 fill = "green", 
                 alpha = .2) + 
  labs(title="8:00 PM to 12:00 AM", x = "Difference in Time", y="Count") + 
  xlim(c(-28, 16)) + 
  ylim(c(0, 1250))

Eight_to_12_AM_Perc = sum(Eight_to_12_AM$Walk_indicator)/length(Eight_to_12_AM$Obs_Number)


## Region Dummies ##

# MIDTOWN

Subsetted_data$Midtown_Indicator = ifelse(Subsetted_data$PU_x_coord > -73.9906902 & Subsetted_data$PU_x_coord < -73.9734576 & Subsetted_data$PU_y_coord > 40.7396835 & Subsetted_data$PU_y_coord < 40.765891, 1, 0)


# LOWER MANHATTAN

Subsetted_data$Lower_Manhattan_Indicator = ifelse(Subsetted_data$PU_x_coord > -74.0191965 & Subsetted_data$PU_x_coord < -74.0112105 & Subsetted_data$PU_y_coord > 40.7046437 & Subsetted_data$PU_y_coord < 40.7396835, 1, 0)


# UPPER EAST  

Subsetted_data$Upper_East_Indicator = ifelse(Subsetted_data$PU_x_coord > -73.9664882 & Subsetted_data$PU_x_coord < -73.9535211 & Subsetted_data$PU_y_coord > 40.7557326 & Subsetted_data$PU_y_coord < 40.7849539, 1, 0)


# UPPER WEST

Subsetted_data$Upper_West_Indicator = ifelse(Subsetted_data$PU_x_coord > -74.0317422 & Subsetted_data$PU_x_coord < -73.9725753 & Subsetted_data$PU_y_coord > 40.765891 & Subsetted_data$PU_y_coord < 40.7937722, 1, 0)

summary(Subsetted_data)


## Analysis for each zone/region, irrespective of time ##

# Probability of walking in a given zone #

Subsetted_data$Midtown_Walk = (ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Walk_indicator > 0, 1, 0))/(ifelse(Subsetted_data$Midtown_Indicator > 0, 1, 0))
summary(Subsetted_data$Midtown_Walk)

Subsetted_data$LowerManhattan_Walk = (ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Walk_indicator > 0, 1, 0))/(ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0, 1, 0))
summary(Subsetted_data$LowerManhattan_Walk)

Subsetted_data$UpperEast_Walk = (ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Walk_indicator > 0, 1, 0))/(ifelse(Subsetted_data$Upper_East_Indicator > 0, 1, 0))
summary(Subsetted_data$UpperEast_Walk)

Subsetted_data$UpperWest_Walk = (ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Walk_indicator > 0, 1, 0))/(ifelse(Subsetted_data$Upper_West_Indicator > 0, 1, 0))
summary(Subsetted_data$UpperWest_Walk)


## Midtown and Lower Manhattan the most probable places to WALK ##

Subsetted_data$MidtownWalk_WeeHours = (ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Twel_to_4_AM > 0, 1, 0))/(ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Twel_to_4_AM > 0, 1, 0))
summary(Subsetted_data$MidtownWalk_WeeHours)

Subsetted_data$MidtownWalk_EarlyMorning = (ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Four_to_8_AM > 0, 1, 0))/(ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Four_to_8_AM > 0, 1, 0))
summary(Subsetted_data$MidtownWalk_EarlyMorning)

Subsetted_data$MidtownWalk_Morning = (ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Eight_to_12_PM > 0, 1, 0))/(ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Eight_to_12_PM > 0, 1, 0))
summary(Subsetted_data$MidtownWalk_Morning)

Subsetted_data$MidtownWalk_EarlyAfternoon = (ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Twel_to_4_PM > 0, 1, 0))/(ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Twel_to_4_PM > 0, 1, 0))
summary(Subsetted_data$MidtownWalk_EarlyAfternoon)

Subsetted_data$MidtownWalk_RushHour = (ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Four_to_8_PM > 0, 1, 0))/(ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Four_to_8_PM > 0, 1, 0))
summary(Subsetted_data$MidtownWalk_RushHour)

Subsetted_data$MidtownWalk_Evening = (ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Eight_to_12_AM > 0, 1, 0))/(ifelse(Subsetted_data$Midtown_Indicator > 0 & Subsetted_data$Eight_to_12_AM > 0, 1, 0))
summary(Subsetted_data$MidtownWalk_Evening)

##########

Subsetted_data$LowerManhattanWalk_WeeHours = (ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Twel_to_4_AM > 0, 1, 0))/(ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Twel_to_4_AM > 0, 1, 0))
summary(Subsetted_data$LowerManhattanWalk_WeeHours)

Subsetted_data$LowerManhattanWalk_EarlyMorning = (ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Four_to_8_AM > 0, 1, 0))/(ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Four_to_8_AM > 0, 1, 0))
summary(Subsetted_data$LowerManhattanWalk_EarlyMorning)

Subsetted_data$LowerManhattanWalk_Morning = (ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Eight_to_12_PM > 0, 1, 0))/(ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Eight_to_12_PM > 0, 1, 0))
summary(Subsetted_data$LowerManhattanWalk_Morning)

Subsetted_data$LowerManhattanWalk_EarlyAfternoon = (ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Twel_to_4_PM > 0, 1, 0))/(ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Twel_to_4_PM > 0, 1, 0))
summary(Subsetted_data$LowerManhattanWalk_EarlyAfternoon)

Subsetted_data$LowerManhattanWalk_RushHour = (ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Four_to_8_PM > 0, 1, 0))/(ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Four_to_8_PM > 0, 1, 0))
summary(Subsetted_data$LowerManhattanWalk_RushHour)

Subsetted_data$LowerManhattanWalk_Evening = (ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Eight_to_12_AM > 0, 1, 0))/(ifelse(Subsetted_data$Lower_Manhattan_Indicator > 0 & Subsetted_data$Eight_to_12_AM > 0, 1, 0))
summary(Subsetted_data$LowerManhattanWalk_Evening)

##########

Subsetted_data$UpperEastWalk_WeeHours = (ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Twel_to_4_AM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Twel_to_4_AM > 0, 1, 0))
summary(Subsetted_data$UpperEastWalk_WeeHours)

Subsetted_data$UpperEastWalk_EarlyMorning = (ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Four_to_8_AM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Four_to_8_AM > 0, 1, 0))
summary(Subsetted_data$UpperEastWalk_EarlyMorning)

Subsetted_data$UpperEastWalk_Morning = (ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Eight_to_12_PM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Eight_to_12_PM > 0, 1, 0))
summary(Subsetted_data$UpperEastWalk_Morning)

Subsetted_data$UpperEastWalk_EarlyAfternoon = (ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Twel_to_4_PM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Twel_to_4_PM > 0, 1, 0))
summary(Subsetted_data$UpperEastWalk_EarlyAfternoon)

Subsetted_data$UpperEastWalk_RushHour = (ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Four_to_8_PM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Four_to_8_PM > 0, 1, 0))
summary(Subsetted_data$UpperEastWalk_RushHour)

Subsetted_data$UpperEastWalk_Evening = (ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Eight_to_12_AM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_East_Indicator > 0 & Subsetted_data$Eight_to_12_AM > 0, 1, 0))
summary(Subsetted_data$UpperEastWalk_Evening)

##########

Subsetted_data$UpperWestWalk_WeeHours = (ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Twel_to_4_AM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Twel_to_4_AM > 0, 1, 0))
summary(Subsetted_data$UpperWestWalk_WeeHours)

Subsetted_data$UpperWestWalk_EarlyMorning = (ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Four_to_8_AM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Four_to_8_AM > 0, 1, 0))
summary(Subsetted_data$UpperWestWalk_EarlyMorning)

Subsetted_data$UpperWestWalk_Morning = (ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Eight_to_12_PM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Eight_to_12_PM > 0, 1, 0))
summary(Subsetted_data$UpperWestWalk_Morning)

Subsetted_data$UpperWestWalk_EarlyAfternoon = (ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Twel_to_4_PM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Twel_to_4_PM > 0, 1, 0))
summary(Subsetted_data$UpperWestWalk_EarlyAfternoon)

Subsetted_data$UpperWestWalk_RushHour = (ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Four_to_8_PM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Four_to_8_PM > 0, 1, 0))
summary(Subsetted_data$UpperWestWalk_RushHour)

Subsetted_data$UpperWestWalk_Evening = (ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Walk_indicator > 0 & Subsetted_data$Eight_to_12_AM > 0, 1, 0))/(ifelse(Subsetted_data$Upper_West_Indicator > 0 & Subsetted_data$Eight_to_12_AM > 0, 1, 0))
summary(Subsetted_data$UpperWestWalk_Evening)


## Generating a Walking Percentage Matrix ##

Walk_Perc = matrix(
  c(Twel_to_4_AM_Perc, Four_to_8_AM_Perc, Eight_to_12_PM_Perc, Twel_to_4_PM_Perc, Four_to_8_PM_Perc, Eight_to_12_AM_Perc),
  nrow = 1,
  ncol = 6)

colnames(Walk_Perc) <- paste("Twel_to_4_AM_Perc", "Four_to_8_AM_Perc", "Eight_to_12_PM_Perc", "Twel_to_4_PM_Perc", "Four_to_8_PM_Perc", "Eight_to_12_AM_Perc")
# Percentage is HIGHEST from four to 8PM, as expected


## Generating a Walking Indicator Sum Matrix for a Pie Chart ##

Twel_to_4_AM_Sum = sum(Twel_to_4_AM$Walk_indicator)
Four_to_8_AM_Sum = sum(Four_to_8_AM$Walk_indicator)
Eight_to_12_PM_Sum = sum(Eight_to_12_PM$Walk_indicator)
Twel_to_4_PM_Sum = sum(Twel_to_4_PM$Walk_indicator)
Four_to_8_PM_Sum = sum(Four_to_8_PM$Walk_indicator)
Eight_to_12_AM_Sum = sum(Eight_to_12_AM$Walk_indicator)

total_walk_sum = sum(Twel_to_4_AM_Sum, Four_to_8_AM_Sum, Eight_to_12_PM_Sum, Twel_to_4_PM_Sum, Four_to_8_PM_Sum, Eight_to_12_AM_Sum)

Total_Walk_Perc = matrix(
  c(Twel_to_4_AM_Sum/total_walk_sum, Four_to_8_AM_Sum/total_walk_sum, Eight_to_12_PM_Sum/total_walk_sum, Twel_to_4_PM_Sum/total_walk_sum, Four_to_8_PM_Sum/total_walk_sum, Eight_to_12_AM_Sum/total_walk_sum),
  nrow = 1,
  ncol = 6)

pie(Total_Walk_Perc, c("12:00 to 4:00 AM", "4:00 to 8:00 AM", "8:00 AM to 12 PM", "12:00 to 4:00 PM", "4:00 to 8:00 PM", "8:00 PM to 12:00 AM"), main = "Walking Pie Chart", col = rainbow(length(Total_Walk_Perc)))

Walk_Perc = sum(Yellow_Taxi_Data$Walk_indicator)/max(Yellow_Taxi_Data$Obs_Number)
Trip_Perc = (max(Yellow_Taxi_Data$Obs_Number) - sum(Yellow_Taxi_Data$Walk_indicator))/max(Yellow_Taxi_Data$Obs_Number)


# While there *should* be more walkers from 4:00 PM to 8:00 PM, we should ALSO be more inclined to
# walk, on average, around that time as well. The uptick in the walking indicator can most likely be
# explained by rush hour traffic congestion

# We must assume that the extra walkers does NOT slow down the average walking pace
