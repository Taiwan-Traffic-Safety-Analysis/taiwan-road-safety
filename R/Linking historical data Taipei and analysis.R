pacman::p_load(tsibble, tidyverse, data.table,feasts,fable,urca,scales)
test <- fread("https://data.taipei/api/dataset/68767aa4-6703-4760-8a0e-74c641d66b90/resource/e2311fce-e104-41cd-b8c7-57ad433fc49a/download")
a1_ts <- a1_daily %>%
  as_tsibble(index = date)

test %>% select(4) %>% pull
test <- tpe_hist_accident_weather %>%  names() %>%  as.data.frame()


# Summarize non-fatal accidents
a2_nonfatal <- tpe_hist_accident_weather %>%
  mutate(epiweek = yearweek(date, week_start = 1)) %>% 
  
  filter(handling_type == "2") %>%
  group_by(epiweek) %>%
  summarise(
 
    a2_count = n(),
    temperature = mean(daily_temperature_2m_mean)
  ) %>%
  ungroup() %>%
  # complete(date = seq(min(date), max(date), by = "day"),
  #          fill = list(a2_count = 0)) %>%
  mutate(type = "nonfatal") 
a2_nonfatal %>% duplicates()
a2_nonfatal <- tsibble(a2_nonfatal, index = epiweek) %>% mutate(year=year(epiweek))
names(a2_nonfatal)
ggplot(a2_nonfatal %>% slice(-1,-nrow(.)), aes(x = epiweek, y = a2_count)) + 
  geom_line()

## create a moving average variable (deals with missings)
a2_nonfatal <- a2_nonfatal %>% 
  ## create the ma_4w variable 
  ## slide over each row of the case variable
  mutate(ma_4wk = slider::slide_dbl(a2_count, 
                                    ## for each row calculate the name
                                    ~ mean(.x, na.rm = TRUE),
                                    ## use the four previous weeks
                                    .before = 4))
str(a2_nonfatal)
## make a quick visualisation of the difference 
ggplot(a2_nonfatal %>% filter(year==2015), aes(x = epiweek)) + 
  geom_line(aes(y = a2_count)) + 
  geom_line(aes(y = ma_4wk), colour = "red") %>% 
  scale_x_date(
    NULL,
    breaks = scales::breaks_width("1 week"),
    labels = scales::label_date("W%-%y")
  )
# Summarize fatal accidents
a1_fatal <- tpe_hist_accident_weather %>%
  # Group by date first to ensure temperature is summarized for all dates
  group_by(date) %>%
  summarise(
    # Check if a fatal accident occurred on this date
    a1_count = sum(handling_type == "1"),
    temperature = max(daily_temperature_2m_mean)
  ) %>%
  ungroup() %>%
  # Complete the date sequence if there are any missing dates in the original data
  complete(date = seq(min(date), max(date), by = "day"),
           fill = list(a1_count = 0)) %>%
  # Ensure temperature is also filled for newly completed dates if they truly had no weather data
  # This step might not be strictly necessary if your original data has complete weather for all days,
  # but it's good practice if there could be gaps in temperature data itself.
  # For the purpose of getting temperature for days WITHOUT fatal accidents, this is crucial.
  # If 'daily_temperature_2m_mean' is only available on accident days,
  # you'll need to join with a separate complete weather dataset.
  # Assuming 'daily_temperature_2m_mean' is available for ALL days in tpe_hist_accident_weather.
  mutate(type = "fatal")

together <- tpe_hist_accident_weather %>%
 
  group_by(date) %>%
  summarise(
    count = n(),
    temperature = unique(daily_temperature_2m_mean)
  ) %>%
  ungroup() %>%
  complete(date = seq(min(date), max(date), by = "day"),
           fill = list(count = 0)) %>%
  mutate(type = "together")

fatal <- a1_fatal %>%
  as_tsibble(index = date)

fatal %>%
  model(STL(a1_count)) %>%
  components() %>%
  autoplot()
  

fit <- fatal %>%
  model(ARIMA(a1_count))

report(fit)



fit_reg <- fatal %>%
  model(ARIMA(a1_count ~ temperature))

fit_reg <- a1_ts %>%
  model(ARIMA(a1_count ~ temperature))
report(fit_reg)

non_fatal <- a2_nonfatal %>%
  as_tsibble(index = date)

fit_reg <- non_fatal %>%
  model(ARIMA(a2_count))

fit_reg <- non_fatal %>%
  model(ARIMA(a2_count))
report(fit_reg)



a1_combined <- bind_rows(a2_nonfatal %>% rename(count=a2_count), a1_fatal %>% rename(count=a1_count)) %>%
  arrange(type, date) %>%
  as_tsibble(index = date, key = type)

together <- together %>%
  as_tsibble(index = date)
together %>%
  model(STL(count)) %>%
  components() %>%
  autoplot()

fit_together <- together %>%
  model(ARIMA(count ~ temperature))



report(fit_together)
a1_combined <- a1_combined %>%
  mutate(type = factor(type))

fit_interact <- a1_combined %>%
  model(ARIMA(a1_count ~ temperature * type))


report(fit_interact)


# Forecast
fit %>%
  forecast(h = "10 years") %>%
  autoplot(a1_ts)
weather_history_taipei_daily %>% select(date, daily_temperature_2m_mean) %>% filter(date>2019)


test <- taipei_historical_zh %>% filter(year==104)
