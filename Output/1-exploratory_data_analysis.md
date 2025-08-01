```{r setup, include=FALSE}
# --- Chunk Options ---
# This sets the default options for all code chunks in the document.
knitr::opts_chunk$set(
  echo = TRUE,       # Display the code in the final document
  message = FALSE,   # Don't display messages
  warning = FALSE,   # Don't display warnings
  fig.width = 10,    # Set default figure width
  fig.height = 6     # Set default figure height
)
```

# Initial descriptive statistics and visualizations

In this document you will find the steps required to perform an initial exploration analysis of the traffic & climate data combined in [`R/1-import.R`](../R/1-import.R).

## Load packages

To conduct this analysis we need a few packages loaded in the R environment. `pacman` is used for convenience as it will install (and if required easily update) required packages when not installed. If you prefer you could run `install.packages("packagename")` and `library("packagename")` instead.

```{r loadpackages, echo=TRUE}
pacman::p_load(tidyverse, data.table, lubridate, skimr, knitr, leaflet,RColorBrewer)
```



# 1. Introduction and Data Loading

This report conducts an exploratory data analysis (EDA) of a traffic accident dataset. The goal is to understand the key characteristics of the data, identify patterns, and visualize trends related to when, where, and to whom accidents occur.

## 1.1. Data Loading

First we copy the data, so we always have the original at hand. 

```{r load-data}
source("../R/2-load.R") # load data
accidents <- copy(tpe_hist_accident_weather) # make copy
```


And the data needs to be inspected, to ensure the Taipei accident data is properly loaded, and combined with the climate data. The imported and combined dataset is named *tpe_hist_accident_weather*.

```{r inspect, echo=TRUE}
accidents %>% head(n = 10) # display/print the first 10 rows
accidents %>% str() # inspect column names and datatype

```

## 1.2. Initial Data Overview

Let's start with a high-level overview of the dataset using `glimpse()` to see the column types and `skim()` to get detailed summary statistics, including missing values.

```{r initial-overview}
# Glimpse provides a transposed view of str()
glimpse(accidents)

# Skimr provides a powerful and readable summary
# Note: This can be slow on very large datasets. We will look at the first 10k rows.
skim(accidents[1:10000, ])
```

**Initial Findings:**
* The dataset is at the **party level**, not the accident level (i.e., one accident with multiple parties will have multiple rows).
* A significant number of columns (`lighting`, `road_category`, etc.) appear to be completely or mostly `NA`.
* The `year` is in the Minguo calendar format (e.g., 105 = 2016).
* Several columns like `gender`, `weather`, and `road_type` are stored as integers but represent categorical concepts.

# 2. Data Cleaning and Preprocessing

Before analysis, we need to clean the data. This involves handling missing values, creating a proper `datetime` column, and converting variables to appropriate types (e.g., factors).

```{r data-cleaning}
# --- Handling Missing Values ---
# Many columns are entirely NA based on the provided structure. We will remove them.
# Calculate the percentage of NAs in each column
na_percentage <- sapply(accidents, function(x) sum(is.na(x)) / length(x) * 100)

# Identify columns that are, for example, more than 95% NA
cols_to_remove <- names(na_percentage[na_percentage > 95])
print("Columns with >95% NA to be removed:")
print(cols_to_remove)

# Remove these columns
accidents[, (cols_to_remove) := NULL]

# --- Feature Engineering and Type Conversion ---
# 1. Create a proper datetime object
# Convert Minguo year to Gregorian year (105 -> 2016)
accidents[, gregorian_year := year + 1911]
# Create a robust datetime column
accidents[, datetime := ymd_hms(paste(gregorian_year, month, day, hour, minute, 0), tz = "Asia/Taipei")]
# Create a date column
accidents[, date := as.Date(datetime)]

# 2. Convert categorical integers to factors with meaningful labels
# (Note: These labels are assumed based on common conventions. You should verify with your data dictionary)
accidents[, gender_f := factor(gender, 
                               levels = c(1, 2), 
                               labels = c("Male", "Female"))]

accidents[, injury_severity_f := factor(injury_severity, 
                                        levels = c(1, 2, 3), 
                                        labels = c("Fatal (24h)", "Injured", "Unharmed"))]

accidents[, weather_f := factor(weather,
                                levels = c(1, 2, 8), # Based on common codes
                                labels = c("Clear", "Cloudy/Overcast", "Rain"))]

# 3. Clean up age data (remove unrealistic values)
accidents <- accidents[age > 0 & age < 100]

# 4. Create a unique accident identifier
accidents[, accident_id := .GRP, by = .(datetime, district_code)]

# --- Display the cleaned data structure ---
cat("\n\nStructure of the cleaned data:\n")
glimpse(accidents)
```

# 3. Descriptive Statistics

Now that the data is cleaned, we can compute descriptive statistics. We will look at both party-level stats and aggregate to the accident-level.

## 3.1. Party-Level Statistics

We summarize key variables for the individuals involved in the accidents.

```{r party-stats}
# Summary for key numeric and factor variables
summary(accidents[, .(age, injuries, gender_f, injury_severity_f, weather_f)])
```

## 3.2. Accident-Level Aggregation

To analyze accidents as single events, we group the data by our `accident_id`.

```{r accident-level-aggregation}
# Aggregate by accident_id
# We take the first value for environmental factors (they should be the same for all parties in an accident)
# We sum the deaths and injuries
accidents_agg <- accidents[, .(
  total_deaths = sum(deaths),
  total_injuries = sum(injuries),
  num_parties = .N,
  datetime = first(datetime),
  date = first(date),
  coord_x = first(coord_x), # <<< CORRECTION: Added this line
  coord_y = first(coord_y), # <<< CORRECTION: Added this line
  district_code = first(district_code),
  weather_f = first(weather_f),
  speed_limit = first(speed_limit)
), by = accident_id]

cat(paste("Original number of rows (parties):", nrow(accidents)))
cat(paste("\nAggregated number of rows (unique accidents):", nrow(accidents_agg)))

# Now let's check the new columns exist
cat("\n\nColumns in the new aggregated data frame:\n")
print(names(accidents_agg))

# Summary of aggregated data
summary(accidents_agg[, .(total_deaths, total_injuries, num_parties, speed_limit)])
```

# 4. Data Visualization

Visuals are the best way to uncover patterns in the data.

## 4.1. When do accidents occur? (Temporal Patterns)

We'll analyze accident frequency over time.

```{r temporal-plots}
# --- Accidents by Hour of Day ---
ggplot(accidents_agg, aes(x = hour(datetime))) +
  geom_bar(fill = "#0072B2", alpha = 0.8) +
  labs(
    title = "Accident Frequency by Hour of Day",
    x = "Hour of Day (0-23)",
    y = "Number of Accidents"
  ) +
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, 23, 2))

# --- Accidents by Day of the Week ---
accidents_agg[, weekday := lubridate::wday(date, label = TRUE, week_start = 1)]
ggplot(accidents_agg, aes(x = weekday)) +
  geom_bar(fill = "#D55E00", alpha = 0.8) +
  labs(
    title = "Accident Frequency by Day of the Week",
    x = "Day of the Week",
    y = "Number of Accidents"
  ) +
  theme_minimal()
```

**Observations:**
* There are clear peaks in accident frequency during morning (8-9 AM) and evening (5-7 PM) rush hours.
* Accidents appear to be more frequent on Fridays and weekends.

## 4.2. Who is involved in accidents? (Demographics)

Let's look at the age and gender of the parties involved.

```{r demographic-plots}
# --- Age Distribution of Parties ---
ggplot(accidents, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "#56B4E9", color = "white") +
  labs(
    title = "Age Distribution of Parties Involved in Accidents",
    x = "Age",
    y = "Frequency"
  ) +
  theme_minimal()

# --- Accidents by Gender ---
accidents %>%
  count(gender_f) %>%
  ggplot(aes(x = reorder(gender_f, -n), y = n)) +
  geom_col(fill = c("#E69F00", "#009E73", "lightgrey")) +
  geom_text(aes(label = n), vjust = -0.5) +
  labs(
    title = "Parties Involved by Gender",
    x = "Gender",
    y = "Number of Parties"
  ) +
  theme_minimal()
```
**Observations:**
* The age distribution shows a high number of individuals in their 20s and 30s are involved in accidents.
* A significantly higher number of males are involved in accidents compared to females.

## 4.3. What are the circumstances? (Conditions & Vehicle Types)

Here we explore weather conditions, vehicle types, and locations.

```{r circumstance-plots}
# --- Accidents by Weather Condition ---
accidents_agg %>%
  count(weather_f, sort = TRUE) %>%
  ggplot(aes(x = reorder(weather_f, -n), y = n)) +
  geom_col(aes(fill = weather_f), show.legend = FALSE) +
  labs(
    title = "Accident Count by Weather Condition",
    x = "Weather",
    y = "Number of Accidents"
  ) +
  theme_minimal() +
  scale_fill_brewer(palette = "Blues")

# --- Top 10 Vehicle Types Involved ---
accidents %>%
  count(vehicle_type, sort = TRUE) %>%
  top_n(10, n) %>%
  ggplot(aes(x = reorder(vehicle_type, n), y = n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Vehicle Types Involved in Accidents",
    x = "Vehicle Type Code",
    y = "Number of Parties"
  ) +
  theme_minimal()
```
**Observations:**
* The vast majority of accidents happen in clear weather, which is expected as this is the most common condition.
* We see that specific vehicle types (codes need a dictionary for interpretation) are far more common in accidents than others.

## 4.4. Where do accidents occur? (Geospatial Analysis)

We can visualize accident locations by district and create an interactive map.

```{r spatial-plots}
# --- Accidents by District ---
accidents_agg %>%
  count(district_code, sort = TRUE) %>%
  ggplot(aes(x = reorder(district_code, n), y = n)) +
  geom_col(fill = "#CC79A7") +
  coord_flip() +
  labs(
    title = "Total Accidents by District",
    x = "District",
    y = "Number of Accidents"
  ) +
  theme_minimal()

# --- Interactive Map of Accident Hotspots ---
# NOTE: Plotting all points is too slow. We take a random sample of 5000.
# Using efficient data.table syntax for sampling.
accidents_sample_map <- accidents_agg[sample(.N, 5000)]

# Approximate coordinates for the center of Taipei
taipei_lat <- 25.0478
taipei_lng <- 121.5319

leaflet(data = accidents_sample_map) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  # --- ADD THIS LINE ---
  # Sets the map's center to Taipei with a specific zoom level.
  # Adjust zoom level as needed (e.g., 12 for closer, 10 for wider).
  setView(lng = taipei_lng, lat = taipei_lat, zoom = 11) %>%
  # ---
  addCircleMarkers(
    lng = ~coord_x,
    lat = ~coord_y,
    radius = ~ifelse(total_deaths > 0, 8, 3),
    color = ~ifelse(total_deaths > 0, "red", "blue"),
    stroke = FALSE,
    fillOpacity = 0.5,
    popup = ~paste(
      "<b>District:</b>", district_code, "<br>",
      "<b>Date:</b>", date, "<br>",
      "<b>Injuries:</b>", total_injuries, "<br>",
      "<b>Deaths:</b>", total_deaths
    )
  ) %>%
  addLegend("bottomright", 
            colors = c("red", "blue"), 
            labels = c("Fatal Accident", "Injury/No-Injury Accident"),
            title = "Accident Severity")
```
**Observations:**
* Certain districts have a much higher frequency of accidents than others.
* The interactive map allows for drilling down into specific locations to see accident details and identify potential hotspots. Fatal accidents are highlighted in red.



# 5. Deeper Dive: Daily and Hourly Patterns

The dataset includes detailed daily and hourly weather metrics. Let's explore how these environmental factors correlate with accident frequency. For this, we first need to ensure our aggregated dataset has the necessary time components.

```{r prepare-time-components}
# Add weekday and hour columns to the aggregated accident data
accidents_agg[, weekday := lubridate::wday(datetime, label = TRUE, week_start = 1)]
accidents_agg[, hour := hour(datetime)]

# We also need to merge the daily/hourly weather data into our aggregated table
# For simplicity, we'll merge them back from the original 'accidents' table
# (In a real scenario, you'd have a separate weather table to join)
weather_to_join <- unique(accidents[, .(
  date, daily_precipitation_sum, daily_temperature_2m_mean, 
  hourly_precipitation, hourly_temperature_2m, hour = hour(datetime)
)], by = c("date", "hour"))

# Note: This join is simplified. A more robust method would be to create a clean daily/hourly weather key.
# For this exploration, we'll create a summary table directly.

# 
# # --- Create a daily summary table ---
# daily_summary <- accidents_agg[, .(
#     num_accidents = .N,
#     # Grab the first value for daily metrics, since they are the same for any given day
#     precipitation = first(daily_precipitation_sum),
#     mean_temp = first(daily_temperature_2m_mean)
#   ), by = date]

# # --- Time Series of Daily Accidents ---
# ggplot(daily_summary, aes(x = date, y = num_accidents)) +
#   geom_line(alpha = 0.5, color = "darkblue") +
#   geom_smooth(method = "loess", se = FALSE, color = "red", span = 0.1) +
#   labs(
#     title = "Total Number of Accidents Per Day",
#     subtitle = "Red line shows the smoothed trend (seasonality)",
#     x = "Date",
#     y = "Number of Unique Accidents"
#   ) +
#   theme_bw()
# 
# --- Accidents vs. Daily Precipitation ---
# ggplot(daily_summary, aes(x = precipitation, y = num_accidents)) +
#   geom_point(alpha = 0.4, color = "dodgerblue") +
#   geom_smooth(method = "lm", color = "firebrick") +
#   scale_x_log10(labels = scales::comma) + # Log scale for better visualization of rainfall
#   labs(
#     title = "Does Rain Increase Accidents?",
#     subtitle = "Number of daily accidents vs. total daily precipitation",
#     x = "Total Daily Precipitation (mm) - Log Scale",
#     y = "Number of Unique Accidents"
#   ) +
#   theme_bw()

# --- Create a summary table for the heatmap ---
# Count accidents for each combination of weekday and hour
heatmap_data <- accidents_agg[, .N, by = .(weekday, hour)]

# --- Generate the Heatmap ---
ggplot(heatmap_data, aes(x = hour, y = weekday, fill = N)) +
  geom_tile(color = "white", lwd = 0.1) +
  scale_fill_viridis_c(option = "plasma", name = "Accident\nCount") + # Use a vibrant color scale
  scale_y_discrete(limits = rev) + # Puts Monday at the top
  scale_x_continuous(breaks = seq(0, 23, 2)) +
  labs(
    title = "Heatmap of Accident Frequency by Day and Hour",
    subtitle = "Bright spots indicate a high volume of accidents",
    x = "Hour of Day",
    y = "Day of Week"
  ) +
  coord_equal() + # Makes the tiles square
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.text = element_text(size = 10)
  )

```










# 6. Conclusion

This initial exploratory analysis has revealed several key patterns:
1.  **Time:** Accidents peak during daily commute hours and are more frequent towards the end of the week.
2.  **People:** Young adults and males are disproportionately involved.
3.  **Conditions:** While most accidents occur in clear weather, understanding the rate of accidents during adverse weather would be a valuable next step.
4.  **Location:** Accident distribution is not uniform across the city; specific districts and locations are clear hotspots.

Further analysis could involve modeling accident severity based on these factors or performing a more in-depth time-series analysis.

---