# Climate Related Traffic Safety and Accident Analysis in Taiwan 

# Overview

This project provides an in-depth epidemiological analysis of traffic safety and accident trends in Taiwan, with a particular focus on the impact of various **weather conditions**. Utilizing publicly available data, it aims to identify key risk factors, examine the spatial and temporal distribution of accidents under different weather scenarios, and highlight areas for potential intervention to improve road safety across the island.

## Background

Recent deadly traffic accidents in the Taipei area have sparked a public debate on traffic safety the country. This public debate will benefit from a proper data exploration describing the situation as it is, giving an overview of historical trends and identify risk factors and vulnerable groups. 

### Literature on relation between climate and traffic accidents:

- Gariazzo C, Bruzzone S, Finardi S, Scortichini M, Veronico L, Marinaccio A. Association between extreme ambient temperatures and general indistinct and work-related road crashes. A nationwide study in Italy. Accident Analysis & Prevention [Internet]. 2021 Apr 6;155:106110. Available from: https://www.sciencedirect.com/science/article/abs/pii/S000145752100141X
- Gu Z, Peng B, Xin Y. Higher traffic crash risk in extreme hot days? A spatiotemporal examination of risk factors and influencing features. International Journal of Disaster Risk Reduction [Internet]. 2024 Dec 1;105045. Available from: https://www.sciencedirect.com/science/article/abs/pii/S2212420924008070?via%3Dihub
- He L, Liu C, Shan X, Zhang L, Zheng L, Yu Y, et al. Impact of high temperature on road injury mortality in a changing climate, 1990–2019: A global analysis. The Science of the Total Environment [Internet]. 2022 Oct 10;857:159369. Available from: https://www.sciencedirect.com/science/article/abs/pii/S0048969722064683
  
  
## Project Structure

The project is organized into the following main components:

* **`data/`**: Contains raw and processed datasets used for the analysis.
    * **Crucially, this will include weather data alongside accident data.**
* **`scripts/`**: R scripts for data cleaning, processing, analysis, and visualization.
    * `01_data_acquisition_cleaning.R`: Scripts for downloading, cleaning, and preparing the raw traffic accident data **and merging it with relevant weather data (e.g., from weather stations, Central Weather Administration)**. This may involve spatial and temporal joins.
    * `02_exploratory_data_analysis.R`: Scripts for initial descriptive statistics and visualizations, **including accident counts and severity by various weather parameters (e.g., clear, rain, fog, strong wind)**.
    * `03_statistical_analysis.R`: Scripts for performing statistical modeling (e.g., regression analysis, time series analysis) to **quantify the association between weather conditions and accident frequency/severity**.
    * `04_mapping_visualization.R`: Scripts for generating maps and advanced visualizations of accident hotspots and trends, **potentially layering weather patterns on these maps to show correlations**.
* **`output/`**: Stores generated figures, tables, and reports.
* **`docs/`**: (Optional) Additional documentation, such as methodology notes or data dictionaries.
* **`README.md`**: This file, providing an overview of the project.

## Data Sources

The primary data for this project is sourced from:

* **Traffic Accident Data**: [**Specify your data source(s) here, e.g., Taiwan National Police Agency, Ministry of Transportation and Communications. Look for datasets that include "Weather name" or similar fields.**]
* **Weather Data**: [**Specify your data source(s) here, e.g., Central Weather Administration (CWA) of Taiwan, historical weather station data. You'll need to consider how to link weather data (e.g., hourly, daily) to specific accident events.**]

Please ensure to cite your sources appropriately within the scripts and any generated reports.

## Key Analyses Performed

* **Descriptive Epidemiology**: Examination of accident frequency, severity, and demographics of involved parties, **stratified by different weather conditions**.
* **Impact of Precipitation**: Analysis of accidents during various rainfall intensities (e.g., light rain, heavy rain, torrential rain), and their effect on accident frequency and severity.
* **Visibility Conditions**: Investigation of how reduced visibility (e.g., fog, haze, heavy rain) influences accident occurrence and severity.
* **Temperature and Humidity Effects**: Exploring the relationship between ambient temperature and humidity with accident risk, especially in Taiwan's climate (e.g., hot and humid conditions).
* **Wind Speed Analysis**: Assessing the impact of strong winds (e.g., during typhoons or strong monsoon winds) on traffic accidents.
* **Seasonal and Extreme Weather Trends**: Identification of specific periods (e.g., typhoon season, plum rain season) with higher accident rates due to prevailing weather hazards.
* **Spatial Analysis**: Identification of high-risk areas and accident clusters, **considering how these patterns change under different weather conditions**.
* **Risk Factor Identification**: Investigation of additional factors contributing to accidents (e.g., road type, vehicle type, driver behavior), **and how these interact with weather conditions**.

## Requirements

To run the R scripts in this project, you will need to have R and RStudio installed. The following R packages are essential:

* `tidyverse` (for data manipulation and visualization)
* `sf` (for spatial data handling, crucial for linking accidents to weather stations/grids)
* `ggplot2` (for advanced plotting)
* `lubridate` (for date/time operations, essential for matching accident times to weather data)
* `leaflet` or `tmap` (for interactive mapping, useful for visualizing weather-related accident hotspots)
* `knitr` and `rmarkdown` (for generating reports)
* `zoo` or `xts` (potentially for time series analysis of weather and accident data)
* [**Add any other specific packages you use, e.g., for specific statistical models (e.g., generalized linear models for count data, or models accounting for spatial correlation).**]

You can install these packages using `install.packages("package_name")` in your R console.

## Usage

1.  Clone this repository to your local machine.
2.  Open the R project file (`.Rproj`) in RStudio.
3.  Execute the scripts in the `scripts/` directory in sequential order to replicate the analysis.
    * Start with `01_data_acquisition_cleaning.R` to prepare and merge the accident and weather data.
    * Proceed through the analysis scripts to generate results and visualizations.
4.  Explore the generated figures and tables in the `output/` directory.

## Contact

For any questions or further information, please contact:

[Your Name]
[Your Email Address]

## Best data source
1. Taiwan's data portal: https://data.gov.tw/dataset/13139 (only 2025)


## Other Data sources
1. Ministry of Transportation, Road Traffic Safety Portal Site: https://168.motc.gov.tw/en/countrydeadhurt/%E8%87%BA%E5%8C%97%E5%B8%82
2. Ministry of Transportation, statistics portal: https://statis.motc.gov.tw/motc/Statistics/Display?Seq=133
   There is an english site, but it doesn't have all the same indicators
   It seems the smallest available unit is county/city.
   Here's an example query showing DUI's within the last 30 days: https://statis.motc.gov.tw/motc/Statistics/Display?Seq=122&Start=113-03-00&End=114-03-00&ShowYear=true&ShowMonth=true&ShowQuarter=false&ShowHalfYear=false&Mode=0&ColumnValues=1127_1128_1129&CodeListValues=2319_2320_2321_2322_2323_2324_2325_2326_2327_2328_2329_2330_2331_2332_2333_2334_2335_2336_2337_2338_2339_2340_2341_2342_2343
3. Road safety data dashboard: https://roadsafety.tw/Dashboard/Custom?type=30%E6%97%A5%E6%AD%BB%E4%BA%A1%E4%BA%BA%E6%95%B8       
   I hope there's a better way to do this, but it's possible to get deaths by district (區) and month-year from the dashboard
4. Hotspots map       
   There's also a map that shows accidents by year including location and cause of the accident: https://roadsafety.tw/AccLocCbi
5. School hotspots map      
   It's possible to get all the locations of accidents in a 1km radius around schools. We could theoretically use that to find all the point locations of accidents across the city. The annoying thing is that it wouldn't contain info about the cause of the accident...    
  https://roadsafety.tw/SchoolHotSpots#
6. Police statistics: https://ba.npa.gov.tw/statis/webMain.aspx?k=defjsp       
   This includes data about deaths, accidents stratified by city, year and cause.
   There is also data about tickets issued for things like speeding, dangerous driving, DUIs etc.
   Tickets are stratified by city, month and type of vehicle.
   Dui's are stratified by city, month, injuries and deaths. 
   
## Data Sources by municipality

### Taipei
- Taiwan's data portal: https://data.gov.tw/dataset/130110
  .csv data by year containing A1 and A2 accidents
  from 2012 (TW Year 101) - 2024 (TW Year 113) with at least the following fields (later years have 71 variables):
  - 發生年度 - Year of Occurrence
  - 發生月 - Month of Occurrence
  - 發生日 - Day of Occurrence
  - 發生時-Hours - Hour of Occurrence
  - 發生分 - Minute of Occurrence
  - 處理別-編號 - Handling Type - Number
  - 區序 - District Number
  - 肇事地點 - Accident Location
  - 死亡人數 - Number of Fatalities
  - 受傷人數 - Number of Injuries
  - 當事人序號 - Party Involved Number
  - 車種 - Vehicle Type
  - 性別 - Gender
  - 年齡 - Age
  - 受傷程度 - Injury Severity
  - 天候 - Weather Conditions
  - 速限-速度限制 - Speed Limit
  - 道路型態 - Road Type
  - 事故位置 - Accident Position
