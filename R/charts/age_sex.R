# Accidents by sex

taipei_accidents_df |>  
  count(性別) |> 
  ggplot() + 
  geom_col(aes(x=性別, y = n)) +
  scale_y_continuous(labels = scales::comma) + 
  labs(title = "Traffic Accidents by Gender - Taipei City", 
       y = "Number of Accidents", 
       x = "Gender")









# Accidents by age (18 highlighted)


taipei_accidents_df |>  
  count(年齡) |>
  filter(年齡 > 0) |>
  
  # Add a value for 18
  mutate(age_18 = ifelse(年齡 == 18,
                         "yes",
                         "no")) |>
  ggplot(aes(x=年齡, y = n)) + 
  geom_col() +
  geom_col(aes(fill = age_18)) + 
  scale_fill_manual(values = c("no" = "gray70", 
                               "yes" = "green"),
                    guide = "none") +
  
  geom_text(
    data = \(taipei_accidents_df) dplyr::filter(taipei_accidents_df, 年齡 == 18),
    aes(label = "18"),
    vjust = -0.5,
    color = "black",
    fontface = "bold"
  ) +
 
  scale_y_continuous(labels = scales::comma) + 
  labs(title = "Traffic Accidents by Age - Taipei City", y = "Number of Accidents", x = "Age")


# Accidents by sex and age

taipei_accidents_df |> 
  filter(性別 %in% c("男", "女")) |>
  group_by(性別) |>
  count(年齡) |>
  filter(年齡 > 0) |>
  
  # Add a value for 18
  mutate(age_18 = ifelse(年齡 == 18,
                         "yes",
                         "no")) |>
  ggplot() + 
  geom_col(aes(x=年齡, y = n, fill = 性別)) +
  
  scale_y_continuous(labels = scales::comma) + 
  labs(title = "Traffic Accidents by Age and Sex - Taipei City", y = "Number of Accidents", x = "Age")



