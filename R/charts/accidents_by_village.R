library(forcats)
library(ggplot2)
library(scales)




taiwan_historical2 |> 
  count(縣市_區鄉鎮) |>
  filter(n > 100000) |>
  mutate(縣市_區鄉鎮 = fct_reorder(縣市_區鄉鎮, n, .desc = TRUE)) |> 
  ggplot() + geom_col(aes(x = 縣市_區鄉鎮, y = n)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+ 
  scale_y_continuous(labels = label_comma())


taiwan_historical2 |> 
 # filter(縣市_區鄉鎮 == "桃園市中壢區") |>
  count(發生年度) |>

  #mutate(縣市_區鄉鎮 = fct_reorder(縣市_區鄉鎮, n, .desc = TRUE)) |> 
  ggplot() + geom_col(aes(x = 發生年度, y = n)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))



taiwan_historical2 |> 
  filter(縣市_區鄉鎮 == "桃園市中壢區") |>
  count(發生年度) |>
  
  #mutate(縣市_區鄉鎮 = fct_reorder(縣市_區鄉鎮, n, .desc = TRUE)) |> 
  ggplot() + geom_col(aes(x = 發生年度, y = n)) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
