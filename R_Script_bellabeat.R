# Installing necessary packages for analysis
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("patchwork")
install.packages("reshape2")
install.packages("GGally")
install.packages("plotly")

# Loading required libraries
library(tidyverse)
library(ggplot2)
library(dplyr)
library(patchwork)
library(reshape2)
library(GGally)
library(plotly)

# Checking files in the specified directory
list.files("/Home/CaseStudy/bellabeat/archive (2)")

# Setting working directories for two different datasets
setwd("~/CaseStudy/bellabeat/archive (2)/mturkfitbit_export_3.12.16-4.11.16/Fitabase Data 3.12.16-4.11.16")
setwd("~/CaseStudy/bellabeat/archive (2)/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16")

# Reading data from CSV files
daily_activity <- read.csv("dailyActivity_merged.csv")
sleep_day <- read.csv("sleepDay_merged.csv")
daily_steps <- read.csv("dailySteps_merged.csv")

# Combining the data from multiple datasets
combined_data <- daily_activity %>%
  left_join(daily_steps, by = "Id") %>%
  left_join(sleep_day, by = "Id")

# Displaying the structure of the combined dataset
str(combined_data)

# Displaying the first few rows of the daily_activity dataset
head(daily_activity)

# Displaying column names of the daily_activity dataset
colnames(daily_activity)

# Displaying the first few rows of the sleep_day dataset
head(sleep_day)

# Displaying column names of the sleep_day dataset
colnames(sleep_day)

# Calculating the number of unique IDs in each dataset
n_distinct(daily_activity$Id)
n_distinct(sleep_day$Id)

# Calculating the number of rows in each dataset
nrow(daily_activity)
nrow(sleep_day)

# Summary statistics for selected variables in the daily_activity dataset
daily_activity %>%
  select(TotalSteps,
         TotalDistance,
         SedentaryMinutes) %>%
  summary()

# Summary statistics for selected variables in the sleep_day dataset
sleep_day %>%
  select(TotalSleepRecords,
         TotalMinutesAsleep,
         TotalTimeInBed) %>%
  summary()

# Creating a scatter plot of TotalSteps against SedentaryMinutes
ggplot(data=daily_activity, aes(x=TotalSteps, y=SedentaryMinutes)) + geom_point()

# Creating a scatter plot of TotalMinutesAsleep against TotalTimeInBed
ggplot(data=sleep_day, aes(x=TotalMinutesAsleep, y=TotalTimeInBed)) + geom_point()

# Merging sleep_day and daily_activity datasets by Id
combined_data <- merge(sleep_day, daily_activity, by="Id")

# Checking the number of unique IDs in the combined dataset
n_distinct(combined_data$Id)

# Creating a histogram of TotalSteps
total_steps_hist <- ggplot(combined_data, aes(x = TotalSteps)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 30) +
  labs(title = "Distribution of Total Steps",
       x = "Total Steps",
       y = "Frequency") +
  theme_minimal()

# Displaying the histogram of TotalSteps
total_steps_hist

# Creating a time series plot of daily steps over time
daily_steps_time_series <- ggplot(combined_data, aes(x = as.Date(ActivityDate, format="%m/%d/%Y"), y = TotalSteps)) +
  geom_line(color = "green") +
  labs(title = "Daily Steps Over Time",
       x = "Date",
       y = "Total Steps") +
  theme_minimal()

# Displaying the time series plot of daily steps over time
daily_steps_time_series

# Creating a violin plot of VeryActiveMinutes distribution
very_active_violin <- ggplot(combined_data, aes(x = "", y = VeryActiveMinutes, fill = factor(1))) +
  geom_violin(trim = FALSE) +
  scale_fill_manual(values = c("skyblue")) +
  labs(title = "Distribution of Very Active Minutes",
       x = NULL,
       y = "Very Active Minutes") +
  theme_minimal() +
  theme(legend.position="none")

# Displaying the violin plot of VeryActiveMinutes distribution
very_active_violin

# Combining daily_activity, sleep_day, and daily_steps datasets
combined_data <- daily_activity %>%
  full_join(sleep_day, by = "Id") %>%
  left_join(daily_steps, by = "Id")

# Checking the structure of the combined dataset
str(combined_data)

# Calculating correlation coefficient between TotalSteps and TotalMinutesAsleep
correlation <- cor(combined_data$TotalSteps, combined_data$TotalMinutesAsleep)

# Fitting a linear regression model
model <- lm(TotalSteps ~ TotalMinutesAsleep, data = combined_data)
summary(model)

# Creating a scatter plot of TotalMinutesAsleep against TotalSteps
scatter_plot <- ggplot(combined_data, aes(x = TotalMinutesAsleep, y = TotalSteps)) +
  geom_point() +
  labs(title = "Total Steps vs. Total Minutes Asleep",
       x = "Total Minutes Asleep",
       y = "Total Steps")

# Displaying the scatter plot
scatter_plot

# Aggregating daily activity data
daily_activity_agg <- daily_activity %>%
  group_by(Id, ActivityDate) %>%
  summarize(
    TotalSteps = sum(TotalSteps),
    TotalDistance = sum(TotalDistance),
    VeryActiveMinutes = sum(VeryActiveMinutes),
    FairlyActiveMinutes = sum(FairlyActiveMinutes),
    LightlyActiveMinutes = sum(LightlyActiveMinutes),
    SedentaryMinutes = sum(SedentaryMinutes),
    Calories = sum(Calories)
  )

# Aggregating sleep data
sleep_day_agg <- sleep_day %>%
  group_by(Id, SleepDay) %>%
  summarize(
    TotalMinutesAsleep = sum(TotalMinutesAsleep),
    TotalTimeInBed = sum(TotalTimeInBed)
  )

# Rename SleepDay to ActivityDate
sleep_day_agg <- sleep_day %>%
  group_by(Id, SleepDay) %>%
  summarize(
    TotalMinutesAsleep = sum(TotalMinutesAsleep),
    TotalTimeInBed = sum(TotalTimeInBed)
  ) %>%
  rename(ActivityDate = SleepDay)

# Combining aggregated data using an outer join
combined_data <- full_join(daily_activity_agg, sleep_day_agg, by = c("Id", "ActivityDate"))

# Checking the structure of the combined dataset
str(combined_data)

# Creating a scatter plot of TotalTimeInBed against TotalMinutesAsleep
sleep_plot <- ggplot(combined_data, aes(x = TotalTimeInBed, y = TotalMinutesAsleep)) +
  geom_point(color = "blue", alpha = 0.5) +
  labs(title = "Total Minutes Asleep vs. Total Time in Bed",
       x = "Total Time in Bed (minutes)",
       y = "Total Minutes Asleep (minutes)") +
  theme_minimal()

# Displaying the scatter plot
sleep_plot

# Convert ActivityDate to Date class
combined_data <- combined_data %>%
  mutate(ActivityDate = as.Date(ActivityDate, format = "%m/%d/%Y"))

#
head(combined_data)

# Check for missing values in key columns
colSums(is.na(combined_data[, c("TotalSteps", "VeryActiveMinutes", "FairlyActiveMinutes", "SedentaryMinutes")]))

# Create daily activity patterns visualization
daily_activity_patterns <- combined_data %>%
  mutate(Weekday = weekdays(ActivityDate)) %>%
  group_by(Weekday) %>%
  summarize(
    AvgSteps = mean(TotalSteps, na.rm = TRUE),
    AvgActiveMinutes = mean(VeryActiveMinutes + FairlyActiveMinutes, na.rm = TRUE),
    AvgSedentaryMinutes = mean(SedentaryMinutes, na.rm = TRUE)
  )
daily_activity_patterns %>%
  gather(ActivityMetric, AverageValue, -Weekday) %>%
  ggplot(aes(x = Weekday, y = AverageValue, fill = ActivityMetric)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Average Daily Activity Patterns",
       x = "Weekday",
       y = "Average Value") +
  theme_minimal() +
  facet_wrap(~ActivityMetric, scales = "free_y") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Convert ActivityDate to Date type
combined_data <- combined_data %>%
  mutate(ActivityDate = as.Date(ActivityDate, format = "%m/%d/%Y"),
         Weekday = weekdays(ActivityDate),
         IsWeekend = ifelse(Weekday %in% c("Saturday", "Sunday"), "Weekend", "Weekday"))

# Verify the transformation
head(combined_data)

# Aggregate Data
daywise_comparison <- combined_data %>%
  group_by(IsWeekend) %>%
  summarize(
    AvgSteps = mean(TotalSteps, na.rm = TRUE),
    AvgActiveMinutes = mean(VeryActiveMinutes + FairlyActiveMinutes, na.rm = TRUE),
    AvgSedentaryMinutes = mean(SedentaryMinutes, na.rm = TRUE)
  )

# Verify the aggregated data
print(daywise_comparison)

#
# Create Weekday and IsWeekend columns
combined_data <- combined_data %>%
  mutate(
    Weekday = weekdays(ActivityDate),
    IsWeekend = ifelse(Weekday %in% c("Saturday", "Sunday"), "Weekend", "Weekday")
  )

# Verify the transformation
head(combined_data)
unique(combined_data$Weekday)
unique(combined_data$IsWeekend)

# Aggregate Data
daywise_comparison <- combined_data %>%
  group_by(IsWeekend) %>%
  summarize(
    AvgSteps = mean(TotalSteps, na.rm = TRUE),
    AvgActiveMinutes = mean(VeryActiveMinutes + FairlyActiveMinutes, na.rm = TRUE),
    AvgSedentaryMinutes = mean(SedentaryMinutes, na.rm = TRUE)
  )

# Verify the aggregated data
print(daywise_comparison)

library(tidyr)
library(ggplot2)

#
daywise_comparison_plot <- daywise_comparison %>%
  gather(ActivityMetric, AverageValue, -IsWeekend) %>%
  ggplot(aes(x = IsWeekend, y = AverageValue, fill = ActivityMetric)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Day-wise Comparison of Activity",
       x = "Day Type",
       y = "Average Value") +
  theme_minimal()

# Display the day-wise comparison plot
print(daywise_comparison_plot)

# Analyzing correlation between TotalSteps and TotalMinutesAsleep
correlation <- cor(combined_data$TotalSteps, combined_data$TotalMinutesAsleep)
cat("Correlation between Total Steps and Total Minutes Asleep:", correlation, "\n")

# Fitting a linear regression model
model <- lm(TotalSteps ~ TotalMinutesAsleep, data = combined_data)
summary(model)

# Verify the structure and contents of combined_data
str(combined_data)
head(combined_data)

# Check the percentage of missing values in each column
missing_percentages <- sapply(combined_data, function(x) sum(is.na(x)) / length(x) * 100)
print(missing_percentages)

# Clean the data by removing rows with missing values in selected columns
cleaned_data <- combined_data %>%
  filter(!is.na(TotalSteps) & 
           !is.na(VeryActiveMinutes) & 
           !is.na(SedentaryMinutes))

# Verify the cleaned data
str(cleaned_data)
head(cleaned_data)

# Load necessary library
library(GGally)

# Create pairwise plots with cleaned data
pairwise_plots <- ggpairs(cleaned_data[, c("TotalSteps", "VeryActiveMinutes", "SedentaryMinutes")])

# Display the pairwise plots
print(pairwise_plots)

# Creating additional plots
ggplot(data=daily_activity, aes(x=Calories)) + geom_histogram(bins=30) + theme_minimal()
ggplot(data=daily_activity, aes(x=TotalSteps, y=Calories)) + geom_point() + geom_smooth(method="lm") + theme_minimal()
ggplot(data=sleep_day, aes(x=TotalMinutesAsleep, y=TotalTimeInBed)) + geom_point() + geom_smooth(method="lm") + theme_minimal()

# Installing and loading reshape2 package
install.packages("reshape2")
library(reshape2)

# Calculating correlation matrix
correlation_matrix <- cor(daily_activity[, c("TotalSteps", "TotalDistance", "SedentaryMinutes", "Calories")])

# Creating a heatmap of correlation matrix
ggplot(melt(correlation_matrix), aes(Var1, Var2, fill=value)) +
  geom_tile(color="white") +
  scale_fill_gradient2(low="blue", high="red", mid="white", 
                       midpoint=0, limit=c(-1,1), space="Lab", 
                       name="Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1))

# Creating a bar chart for total steps by user
ggplot(daily_activity, aes(x = as.factor(Id), y = TotalSteps)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(x = "User ID", y = "Total Steps", title = "Total Steps by User") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

#
library(RColorBrewer)
library(ggplot2)

# Determine the number of levels in the factor
num_levels <- length(levels(factor(combined_data$VeryActiveMinutes)))

# Generate a color palette with the appropriate number of colors
custom_colors <- colorRampPalette(brewer.pal(8, "Dark2"))(num_levels)

# Create the polar bar chart with the adjusted color palette
ggplot(combined_data, aes(x = "", y = VeryActiveMinutes, fill = factor(VeryActiveMinutes))) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start = 0) +
  labs(fill = "Very Active Minutes", title = "Very Active Minutes Distribution") +
  scale_fill_manual(values = custom_colors) +
  theme_void()

# Creating a line chart for daily steps over time
ggplot(combined_data, aes(x = ActivityDate, y = TotalSteps)) +
  geom_line(color = "blue") +
  labs(x = "Date", y = "Total Steps", title = "Daily Steps Over Time") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# Creating a histogram for distribution of total steps
ggplot(daily_activity, aes(x = TotalSteps)) +
  geom_histogram(fill = "skyblue", bins = 30) +
  labs(x = "Total Steps", y = "Frequency", title = "Distribution of Total Steps") +
  theme_minimal()

# Creating a scatter plot for daily steps vs. daily calories burned
ggplot(daily_activity, aes(x = TotalSteps, y = Calories)) +
  geom_point(color = "darkblue", alpha = 0.7) +
  labs(x = "Total Steps", y = "Calories Burned", title = "Daily Steps vs. Daily Calories Burned") +
  theme_minimal()

# Writing daily_activity dataset to a CSV file
write.csv(daily_activity, file = "daily_activity.csv", row.names = FALSE)

# Listing files in the directory
list.files()