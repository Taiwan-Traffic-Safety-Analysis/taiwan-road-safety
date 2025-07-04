# taiwan-road-safety
An in-depth look at traffic safety and an analysis of traffic accidents in Taiwan    

## Best data source
1. Taiwan's data portal:


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
