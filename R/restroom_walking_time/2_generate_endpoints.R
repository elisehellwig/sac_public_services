library(osmdata)
library(sf)

source('R/functions.R')

fn = 'data/sac_street_sample_points.geojson'

#requires internet
feats = available_features()

highway_tags = available_tags('highway')
#write.csv(highway_tags, 'data/highway_tags.csv', row.names = FALSE)
walking_tags = read.csv('data/walking_tags.csv')$Value

sac_merc = st_read('data/city_boundary.geojson')
sac = st_transform(sac_merc, st_crs(4326))
sac_bbox = st_bbox(sac)


sac_paths = opq(sac_bbox) |>
  add_osm_feature(key='highway', value=walking_tags) |>
  osmdata_sf()

line_vars = c('osm_id', 'name', 'highway', 'geometry')
walking_ll = sac_paths$osm_lines[,line_vars]

walking = st_transform(walking_ll, st_crs(3310))

set.seed(29383)
multipts = st_line_sample(walking, density = 0.2)

multipts_full = multipts[!st_is_empty(multipts), ]

pts_set = st_cast(st_sfc(multipts_full), "POINT")

pts = st_sf(to_index=1:length(pts_set)-1, geometry=pts_set)

pts_ll = st_transform(pts, 4326)

write_sf(pts_ll, fn)

#chunk up data

nchunk = ceiling(nrow(pts_ll)/35)

pts_list = lapply(1:nchunk, function(i) {
  start = (i-1)*35+1
  end = if (i == nchunk) nrow(pts_ll) else i*35
  pts_ll[start:end, ]
})

sapply(pts_list, nrow) |> unique()

saveRDS(pts_list, 'data/sac_street_sample_points_list.RDS')



