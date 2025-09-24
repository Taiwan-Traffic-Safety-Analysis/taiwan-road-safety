

# Taipei City Traffic Data - Open Data Portal - 2012-2024 ------------------
# import .ttl (rdf DCAT lib) file
url <- "https://data.gov.tw/api/front/dataset/dcat.download?nid=130110"
rdf <- rdf_parse(url, format = "turtle")

# obtain the yearly .csv file links form the rdf file
query <- "PREFIX dcat: <http://www.w3.org/ns/dcat#>
                SELECT ?s ?downloadURL WHERE {
                ?s dcat:downloadURL ?downloadURL .
                }" #using SPARQL to read triples (data structure of RDF) containing Subjects, Predicates and Objects for each triple

urls <- rdf %>% rdf_query(query) %>% select(downloadURL) %>% pull #select urls add to string

# download all csv data at ones and deal with strange "Big5" encoding (not natively supported in fread)

# create function to properly import Big5 encoded csv 
read_Big5_csv <- function(url) {
  raw_lines <- readLines(url, encoding = "bytes", warn = FALSE)
  utf8_lines <- iconv(raw_lines, from = "Big5", to = "UTF-8")
  df <- fread(text = utf8_lines)
}

#load all csvs and combine into list
taipei_accidents_list <- lapply(urls, read_Big5_csv)

# Combine all years into one data.table, filling missing columns if needed
taipei_accidents_df <- rbindlist(taipei_accidents_list, fill = TRUE)

# translations
name_map_taipei <- c(
  "發生年度" = "year",
  "發生月" = "month",
  "發生日" = "day",
  "發生時-Hours" = "hour",
  "發生分" = "minute",
  "處理別-編號" = "handling_type",
  "區序" = "district_code",
  "肇事地點" = "location",
  "死亡人數" = "deaths",
  "受傷人數" = "injuries",
  "當事人序號" = "party_id",
  "車種" = "vehicle_type",
  "性別" = "gender",
  "年齡" = "age",
  "受傷程度" = "injury_severity",
  "天候" = "weather",
  "速限-速度限制" = "speed_limit",
  "道路型態" = "road_type",
  "事故位置" = "accident_location",
  "座標-X" = "coord_x",
  "座標-Y" = "coord_y",
  "2-30日死亡人數" = "deaths_2to30days",
  "光線" = "lighting",
  "道路類別" = "road_category",
  "路面狀況1" = "road_condition_1",
  "路面狀況2" = "road_condition_2",
  "路面狀況3" = "road_condition_3",
  "道路障礙1" = "road_obstacle_1",
  "道路障礙2" = "road_obstacle_2",
  "號誌1" = "signal_1",
  "號誌2" = "signal_2",
  "車道劃分-分向" = "lane_dir",
  "車道劃分-分道1" = "lane_1",
  "車道劃分-分道2" = "lane_2",
  "車道劃分-分道3" = "lane_3",
  "事故類型及型態" = "accident_type",
  "主要傷處" = "main_injury_part",
  "保護裝置" = "protective_device",
  "行動電話" = "mobile_phone",
  "車輛用途" = "vehicle_use",
  "當事者行動狀態" = "party_movement",
  "駕駛資格情形" = "driving_qualification",
  "駕駛執照種類" = "license_type",
  "飲酒情形" = "alcohol_use",
  "車輛撞擊部位1" = "impact_point_1",
  "車輛撞擊部位2" = "impact_point_2",
  "肇因碼-個別" = "cause_code_individual",
  "肇因碼-主要" = "cause_code_main",
  "個人肇逃否" = "hit_and_run",
  "職業" = "occupation",
  "旅次目的" = "trip_purpose",
  "道路照明設備" = "road_lighting",
  "4天候" = "weather_4",
  "5光線" = "lighting_5",
  "6道路類別" = "road_category_6",
  "7速限-速度限制" = "speed_limit_7",
  "8道路型態" = "road_type_8",
  "9事故位置" = "accident_location_9",
  "10路面狀況1" = "road_condition1_10",
  "10路面狀況2" = "road_condition2_10",
  "10路面狀況3" = "road_condition3_10",
  "11道路障礙1" = "road_obstacle1_11",
  "11道路障礙2" = "road_obstacle2_11",
  "12號誌1" = "signal1_12",
  "12號誌2" = "signal2_12",
  "13車道劃分-分向" = "lane_dir_13",
  "14車道劃分-分道1" = "lane1_14",
  "14車道劃分-分道2" = "lane2_14",
  "14車道劃分-分道3" = "lane3_14",
  "15事故類型及型態" = "accident_type_15",
  "安全帽" = "helmet"
)
name_map_taipei <- setNames(names(name_map_taipei), name_map_taipei)

# translate columns
taipei_accidents_df <- taipei_accidents_df %>% 
  rename(!!!name_map_taipei)
test2 <- taipei_accidents_df %>% filter(year==104)
# save dataframe as .csv

fwrite(taipei_accidents_df, "data/Taipei Accidents (2012-2024).csv")