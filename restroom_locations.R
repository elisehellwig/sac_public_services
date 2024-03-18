library(sf)
library(terra)

ppr = st_read(dsn='data/Parks_Public_Restrooms.geojson',
              layer='Parks_Public_Restrooms')

camp = vect('data/test_encampments.kml') |> st_as_sf()

camp$camp_id = substr(camp$Name, 11, 12)

?st#pp_names = st_drop_geometry(ppr)["Facility"]

#write.csv(pp_names, 'data/public_park_names.csv', row.names = FALSE)
set.seed(838)
closed = sample(ppr$OBJECTID, floor(nrow(ppr)*0.4))

ppr$Status = ifelse(ppr$OBJECTID %in% closed, 'Closed', 'Open') |>
  factor(levels=c('Open', 'Closed'))

ppr_stat = ppr['Status']
