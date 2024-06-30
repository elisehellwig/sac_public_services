library('data.table')
library('sf')
library('stringr')

source('R/point_dist_functions.R')

pts = st_read('data/sac_street_sample_points.geojson')
city = st_read('data/city_boundary.geojson')
ppr = st_read('data/Park_Restroom_Status.geojson')


city = st_transform(city, 4326) |> st_make_valid()


data_path = 'data/dist'

time_int = 1200

fns = list.files(data_path, full.names = TRUE)

#takes a little over 2 minutes
system.time(dist_df <- lapply(fns, read_in_dist) |> rbindlist())

min_df = dist_df[,.SD[which.min(time)], by=.(from_index, departure)]

min_df[, mins:=time/60]

min_pts = merge(pts, min_df, by='from_index')

city_pts = st_intersection(min_pts[,c('mins', 'geometry')], city)

plot(city_pts[,c('mins', 'geometry')], pch='.')

st_write(min_pts, 'data/minimum_time_points.geojson')