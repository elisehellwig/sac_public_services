# Read in geocoded addresses and compute the isochrones

library("httr")
library("stringr")
library("jsonlite")
library("pbapply")  
library("geojsonsf")
library("sf")

sf_to_df = function(sf_pts) {
  coord_mat = st_coordinates(sf_pts)
  df = data.frame(lat=coord_mat[,'Y'], lon=coord_mat[,'X'])
  return(df)
}

build_req_str = function(from, to, id, server, port) {
  df_from = sf_to_df(from)
  df_to = sf_to_df(to)
  json = toJSON(list("sources" = df_from, "targets" = df_to,
                     "costing" = unbox('pedestrian')))
  url_string = str_glue("{server}:{port}/sources_to_targets?json={json}&id={id}")
}

submit_req = function(request) {
  api_response = GET(request)
  response = rawToChar(api_response$content)
  isochrone = geojson_sf(response)
  isochrone = st_cast(isochrone, to="POLYGON")
  isochrone$ID =fromJSON(response)["id"]
  isochrone
}

# if using datasci.library.ucdavis.edu as the server, make sure you are 
# on the staff vpn
server = "http://datasci.library.ucdavis.edu"
port = 8002
ppr = st_read('data/Park_Restroom_Status.geojson')
names(ppr)

spts = st_read('data/sac_street_sample_points.geojson')

for (time_limit in time_limits) {
  # construct a vector of the request strings from the data
  requests = mapply(build_req_str, address_df$Latitude, address_df$Longitude, 
                    address_df$X, time_limit, server, port)
  
  # actually submit the requests to the server with valhalla
  isochrones = pblapply(requests, submit_req)
  isochrones = do.call(rbind, isochrones)
  
  # save the results
  saveRDS(isochrones, str_glue("./data/isochrones_{time_limit}_min.rds"))
}