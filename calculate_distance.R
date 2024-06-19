# Read in geocoded addresses and compute the isochrones

library("httr")
library("stringr")
library("jsonlite")
library("pbapply")  
library("sf")
library("data.table")

source('functions.R')


submit_req = function(request) {
  api_response = GET(request)
  
  stop_for_status(api_response)
  
  from_to_list = fromJSON(rawToChar(api_response$content))
  
  dist_mat = from_to_list$sources_to_targets |> rbindlist()
  
  dist_mat$departure = from_to_list$id
  
  return(dist_mat)
  
}

# if using datasci.library.ucdavis.edu as the server, make sure you are 
# on the staff vpn (not the library vpn)
server = "http://datasci.library.ucdavis.edu"
port = 8002

ppr = st_read('data/Park_Restroom_Status.geojson')
pts_list = readRDS('data/sac_street_sample_points_list.RDS')


request = build_req_str(test_pts, ppr, server, port, '12:00')
system.time(mat <- submit_req(request))

requests = sapply(pts_list, build_req_str, ppr, server, port, '12:00')

log_fn = paste0('data/log_', Sys.time(), '.txt')
sink()
dist_mats = pblapply(requests, submit_req) |> rbindlist()

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