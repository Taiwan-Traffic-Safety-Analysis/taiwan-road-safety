


taiwan_historical <- taiwan_historical |>
  
  # remove stuff from schema files
  filter(is.na(name),
         is.na(schema),
         is.na(description),
         is.na(title)) |>
  
  select(-name,
         -schema,
         -description,
         -title) |> 
  
  
  
  # filter out stupid metadata rows
  filter(is.na(發生年度) |	!str_detect(發生年度, "事故類別：|資料提供日期："),
         is.na(發生時間) | !str_detect(發生時間, "事故類別：|資料提供日期："))


old_format <- taiwan_historical |> 
  dplyr::filter(!is.na(車種)) |> 
  
  # remove completely na columns
  select(where(~ !all(is.na(.)))) |> 
  
  mutate(
    # fix year       
    發生年度 = as.character(as.numeric(str_extract(發生時間, ".*(?=年)")) + 1911), 
    
    # month
    發生月份 = str_extract(發生時間, "(?<=年).*(?=月)"),

    
    # day
    發生日 = str_extract(發生時間, "(?<=月).*(?=日)"),
    
    
    # Hour
    發生小時 = str_squish(str_extract(發生時間, "(?<=日).*(?=時)")),
    
    # minute
    發生分鐘 = str_extract(發生時間, "(?<=時).*(?=分)"),
    
    # second
    發生分秒 = str_extract(發生時間, "(?<=分).*(?=秒)"),
    
    # If seconds are blank default to zero
    發生分秒 = ifelse(is.na(發生分秒),
                  "00",
                  發生分秒),
    
    
    # create columns that exist in new_format 
    # so that we can fix them together after left join
    發生日期 = paste0(發生年度, "-", 發生月份, "-", 發生日)
    
    
    )  |>
  
  # separate the per accident rows into per party rows
  mutate(row_id = row_number()) %>%  
  
  # seperate all the parties at the semicolon
  tidyr::separate_rows(車種, sep = ";") %>%
  
  # create a party number value
  group_by(row_id) %>%
  mutate(當事者順位 = row_number()) %>%  
  
  # remove the extra row_id value
  ungroup() %>%
  select(-row_id) 


old_format_subset |> tidyr::separate_rows(車種, sep = ";") |> View()


new_format <- taiwan_historical |> 
  dplyr::filter(is.na(車種)) |> 
  
  mutate(
    # day
    發生日 = str_sub(發生日期, -2, -1), 
    
    # combine date pieces into one coherent measurement
    發生日期 = paste0(發生年度, "-", 發生月份, "-", 發生日),
    
    # Fix (some of the time values) time so that there are leading zeros
    發生時間 = ifelse(nchar(發生時間) == 6,
                  發生時間, 
                  ifelse(nchar(發生時間) == 5,
                         paste0("0", 發生時間),
                         發生時間)
                  )
  )




taiwan_historical2 <- taiwan_historical  |> 
  
  
  # start creating new columns 
  
  # extract cities and districts
  mutate(縣市 = str_extract(發生地點, ".*?(縣|市)"),
         區鄉鎮 = str_extract(發生地點, "(?<=縣|市).*?(區|鄉|鎮|市|村)"),
         縣市_區鄉鎮 = paste0(縣市, 區鄉鎮)
         
         
         
         
  ) 




