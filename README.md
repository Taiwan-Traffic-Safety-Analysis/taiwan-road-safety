# Climate Related Traffic Safety and Accident Analysis in Taiwan 

# Overview

This project provides an in-depth epidemiological analysis of traffic safety and accident trends in Taiwan, with a particular focus on the impact of various **weather conditions**. Utilizing publicly available data, it aims to identify key risk factors, examine the spatial and temporal distribution of accidents under different weather scenarios, and highlight areas for potential intervention to improve road safety across the island.

## Background

Recent deadly traffic accidents in the Taipei area have sparked a public debate on traffic safety the country. This public debate will benefit from a proper data exploration describing the situation as it is, giving an overview of historical trends and identify risk factors and vulnerable groups. 

### Literature on relation between climate and traffic accidents*:

- Gariazzo C, Bruzzone S, Finardi S, Scortichini M, Veronico L, Marinaccio A. Association between extreme ambient temperatures and general indistinct and work-related road crashes. A nationwide study in Italy. Accident Analysis & Prevention [Internet]. 2021 Apr 6;155:106110. Available from: https://www.sciencedirect.com/science/article/abs/pii/S000145752100141X
- Gu Z, Peng B, Xin Y. Higher traffic crash risk in extreme hot days? A spatiotemporal examination of risk factors and influencing features. International Journal of Disaster Risk Reduction [Internet]. 2024 Dec 1;105045. Available from: https://www.sciencedirect.com/science/article/abs/pii/S2212420924008070?via%3Dihub
- He L, Liu C, Shan X, Zhang L, Zheng L, Yu Y, et al. Impact of high temperature on road injury mortality in a changing climate, 1990–2019: A global analysis. The Science of the Total Environment [Internet]. 2022 Oct 10;857:159369. Available from: https://www.sciencedirect.com/science/article/abs/pii/S0048969722064683

*currently all focusing on heat* 
  
  
## Project Structure

The project is organized into the following main components:

* **`data/`**: Contains raw and processed datasets used for the analysis.
    * **Crucially, this will include weather data alongside accident data.**
* **`R/`**: R scripts for data cleaning, processing, analysis, and visualization.
    * `1-import.R`, `2-load.R` and `3-Translations.R`: Scripts for downloading, cleaning, and preparing the raw traffic accident data **and merging it with relevant weather data (obtained with `OpenMeteo`)**. This may involve spatial and temporal joins.
* **`output/`**: Stores generated figures, tables, and reports.
    * [`1-exploratory_data_analysis.md`](Output/1-exploratory_data_analysis.md): Scripts for initial descriptive statistics and visualizations, **including accident counts and severity by various weather parameters (e.g., clear, rain, fog, strong wind)**.
    * `2-statistical_analysis.md`: Scripts for performing statistical modeling (e.g., regression analysis, time series analysis) to **quantify the association between weather conditions and accident frequency/severity**.
    * `3mapping_visualization.md`: Scripts for generating maps and advanced visualizations of accident hotspots and trends, **potentially layering weather patterns on these maps to show correlations**.
* **`README.md`**: This file, providing an overview of the project.

## Data Sources

- **Taiwan's open data portal**: https://data.gov.tw/dataset/130110
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

- **Openmeteo package**:
Pisel T. openmeteo: Retrieve Weather Data from the Open-Meteo API [Internet]. R package version 0.2.4. 2023. Available from: https://CRAN.R-project.org/package=openmeteo. The following variables are downloaded with the package:
  - Daily variables:
    - weather_code
    - temperature_2m_mean
    - temperature_2m_max
    - temperature_2m_min
    - apparent_temperature_mean
    - apparent_temperature_max
    - apparent_temperature_min
    - sunrise
    - sunset
    - daylight_duration
    - sunshine_duration
    - precipitation_sum
    - precipitation_hours
    - wind_speed_10m_max
    - wind_gusts_10m_max
    - wind_direction_10m_dominant
  - Hourly variables:
    - temperature_2m
    - precipitation
    - windspeed_10m
    - cloudcover
    - apparent_temperature
    - weather_code
    - wind_direction_10m
    - wind_gusts_10m


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
* `data.table` (for fast handling of large datasets, including import and export of .csv files)
* [**Add any other specific packages you use, e.g., for specific statistical models (e.g., generalized linear models for count data, or models accounting for spatial correlation).**]

You can install these packages using `install.packages("package_name")` in your R console.

## Usage

1.  Clone/fork this repository to your local machine.
3.  Execute the scripts in the `R/` directory in sequential order to replicate the data handling.
4.  Explore the generated markdown reports in the `output/` directory.

## Contact

For any questions or further information, please contact:

*Erik de Jong*
[Contact through LinkedIn](https://www.linkedin.com/in/erikpieterdejong/)


