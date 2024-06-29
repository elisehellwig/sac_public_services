library(openxlsx)
library(sf)


locs = st_read(dsn = 'data/Public_Park_Amenities.geojson',
               layer = 'Public_Park_Amenities')


amenities = table(locs$Amenity) |> data.frame()
names(amenities) = c('Amenity', 'Count')
write.csv(amenities, 'data/amenities.csv', row.names = FALSE)

df_locs = locs[which(locs$Amenity=='Drinking Fountain'), ]
