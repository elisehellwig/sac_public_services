library(sf)
library(terra)
library(data.table)


ppr = st_read(dsn='data/Parks_Public_Restrooms.geojson',
              layer='Parks_Public_Restrooms')

calls = st_read('data/SalesForce311.gpkg', layer="SalesForce311")

camp = vect('data/test_encampments.kml') |> st_as_sf()

camp$camp_id = substr(camp$Name, 11, 12)
camp$Description = NULL

st_write(camp, 'data/test_encampments.geojson')

#pp_names = st_drop_geometry(ppr)["Facility"]

#write.csv(pp_names, 'data/public_park_names.csv', row.names = FALSE)
set.seed(838)
closed = sample(ppr$OBJECTID, floor(nrow(ppr)*0.4))

ppr$Status = ifelse(ppr$OBJECTID %in% closed, 'Closed', 'Open') |>
  factor(levels=c('Open', 'Closed'))

ppr_stat = ppr['Status']

st_write(ppr, 'data/test_restrooms.geojson')

