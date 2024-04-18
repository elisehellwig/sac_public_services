# Sacramento Public Services 

This repository contains code to create maps of the public services available to
people overlayed with the locations of prominent encampments.

## Data

### Public Restroom Locations

This data comes from the [Sacramento Open Data Portal's][sodp] Parks Public
Restrooms [data layer][ppr]. This project uses the Parks Public Restrooms 
Facility and OBJECTID variables to uniquely identify each restroom. To see 
the restrooms labeled with their Facility and OBJECTID, use [this map][app].

[sodp]: https://data.cityofsacramento.org/
[ppr]: https://data.cityofsacramento.org/datasets/b9e7fa6d1d104833b3f04268d7f682dc_0/
[app]: https://www.arcgis.com/apps/instant/basic/index.html?appid=75d70d7779ed43899356d1fe07e9ace6


### Public Restroom Statuses

This data was collected by members of the Sacramento chapter of the League of
Women Voters. Members visited each bathroom and made note of whether it was 
functional or not, as well as any barriers to entry. The most up to date raw
data is stored in data/City Parks with Restrooms 040824.xlsx.