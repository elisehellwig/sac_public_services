library(sf)
library(data.table)
library(openxlsx)

source('R/functions.R')

ppr = st_read(dsn='data/Parks_Public_Restrooms.geojson',
              layer='Parks_Public_Restrooms')

status = read.xlsx('data/City Parks with Restrooms 040824.xlsx')
names(status)[2] = "OBJECTID"
setDT(status)

status = status[grepl('Yes', Toilets) | grepl('Yes', Open)]

status[, Is_Open:=grepl('Yes', Open, ignore.case = TRUE)]
status[, Status:=ifelse(Is_Open, 'Open', 'Closed')]

final_status = status[, .(OBJECTID, Neighborhood, Is_Open, Status, Notes)]

ppr_status = merge(ppr, final_status, by='OBJECTID')

ppr_ll = st_transform(ppr_status, 4326)

ppr_ll = ppr_ll[order(ppr_ll$OBJECTID), ]
ppr_ll$to_index = 1:nrow(ppr_ll)-1

write_sf(ppr_ll, 'data/Park_Restroom_Status.geojson')
