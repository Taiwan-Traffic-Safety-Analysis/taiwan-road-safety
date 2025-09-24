# Accidents by sex
library(ggplot2)
library(dplyr)

# read in age structure data for Taipei
taipei_pop_2024_zh <- read.csv("data/population_data/taipei_pop_2024_zh.csv" )

taipei_accidents_eng |>  
  count(sex) |> 
  ggplot() + 
  geom_col(aes(x=sex, y = n)) +
  scale_y_continuous(labels = scales::comma) + 
  labs(title = "Traffic Accidents by Gender - Taipei City", 
       y = "Number of Accidents", 
       x = "Gender")


# Accidents by age (18 highlighted)


taipei_accidents_eng |>  
  count(age) |>
  filter(age > 0) |>
  
  # Add a value for 18
  mutate(age_18 = ifelse(age == 18,
                         "yes",
                         "no")) |>
  ggplot(aes(x=age, y = n)) + 
  geom_col() +
  geom_col(aes(fill = age_18)) + 
  scale_fill_manual(values = c("no" = "gray70", 
                               "yes" = "green"),
                    guide = "none") +
  
  geom_text(
    data = \(taipei_accidents_eng) dplyr::filter(taipei_accidents_eng, age == 18),
    aes(label = "18"),
    vjust = -0.5,
    color = "black",
    fontface = "bold"
  ) +
 
  scale_y_continuous(labels = scales::comma) + 
  labs(title = "Traffic Accidents by Age - Taipei City", y = "Number of Accidents", x = "Age")


# Accidents by sex and age

taipei_accidents_eng |> 
  filter(sex %in% c("Male", "Female")) |>
  group_by(sex) |>
  count(age) |>
  filter(age > 0) |>
  
  # Add a value for 18
  mutate(age_18 = ifelse(age == 18,
                         "yes",
                         "no")) |>
  ggplot() + 
  geom_col(aes(x=age, y = n, fill = sex)) +
  
  scale_y_continuous(labels = scales::comma) + 
  labs(title = "Traffic Accidents by Age and Sex - Taipei City", y = "Number of Accidents", x = "Age")


# age adjusted accident rate

# clean the population structure a bit
taipei_by_age_pop <- taipei_pop_2024_zh |> 
  
  # coerce age to a number
  mutate(age_category = as.numeric(age_category )) |>
  
  # filter out NA numbers (age ranges)
  # and for total population for all of taipei (not by district)
  filter(!is.na(age_category),
         district == "總  計",
         sex == "計"
         ) |>
  
  # pull only the columns we need for a left join
  select(age = age_category,
         population)
  
  
taipei_accidents_eng |>
  
  # Filter out NA ages
  filter(!is.na(age)) |>
  

  
  # combine everything over 100 into a 100+ category
  #mutate(age = ifelse(age < 100, 
   #                   age,
    #                  100)) |>
  filter(incident_year == 2024,
         
         # exclude ages over 100 (bc people put dates where age goes gahhh)
         age > 0 & age < 100) |>
  
  count(age) |>
  # combine on population data
  left_join(taipei_by_age_pop) |>
  
  # calculate per age group rate
  mutate(accident_rate = n/population * 100000) |> 
  
  # Add a value for 18
  mutate(age_18 = ifelse(age == 18,
                         "yes",
                         "no")) |>
  ggplot(aes(x=age, y = accident_rate)) + 
  geom_col() +
  geom_col(aes(fill = age_18)) + 
  scale_fill_manual(values = c("no" = "gray70", 
                               "yes" = "green"),
                    guide = "none") +
  
  geom_text(
    data = \(taipei_accidents_eng) dplyr::filter(taipei_accidents_eng, age == 18),
    aes(label = "18"),
    vjust = -0.5,
    color = "black",
    fontface = "bold"
  ) +
  
  scale_y_continuous(labels = scales::comma) + 
  labs(title = "Age Adjusted Rate of Traffic Accidents - Taipei City", y = "Number of Accidents per 100,000", x = "Age")
  
