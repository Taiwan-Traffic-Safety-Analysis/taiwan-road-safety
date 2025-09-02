library(dplyr)

# Find unique accidents
# instead of unique injuries/deaths

unique_accidents <- 
  
  # select enough variables to determine uniqueness
  taipei_accidents_zh |> select(發生日期,
                              發生年度,
                              發生月,
                              發生日,
                              發生時_Hours,
                              發生分,
                              區序,
                              肇事地點,
                              死亡人數,
                              受傷人數,
                              座標_X,
                              座標_Y) |>
  
  # select unique incidents
  distinct() 
  

unique_accidents <-  unique_accidents |> 
  # Assign accident id
  mutate(accident_id = 1:nrow(unique_accidents))


# join the accident id back to the original dataset
taipei_accidents_zh <- taipei_accidents_zh |>
                       left_join(unique_accidents)
