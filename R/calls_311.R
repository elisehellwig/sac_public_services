#current - https://data.cityofsacramento.org/datasets/5b9a9448663f41b1898643b6d91201c4_0

library(sf)
library(terra)
library(data.table)

current_fn = 'data/sac311_current.gpkg'

st_layers(current_fn)

system.time(calls_sf <- st_read(current_fn, layer='SalesForce311'))
system.time(calls_t <- vect(current_fn, layer='SalesForce311'))

calls <- fread('data/sac311_current.csv', fill=TRUE, header=FALSE)

calls_names = calls[1, ] |> unlist(use.names = FALSE) 
calls_names = gsub(' ', '', calls_names)

calls = calls[V1!='OBJECTID']
setnames(calls, names(calls), calls_names)

grps = table(calls$CategoryName) |> data.table()
