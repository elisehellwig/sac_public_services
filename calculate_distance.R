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
spts = st_read('data/sac_street_sample_points.geojson')

##testing
n = 5

test_ppr = ppr[1:(n+1), ]
test_pts = spts[sample(1:nrow(spts), n), ]

request = build_req_str(test_pts, test_ppr, server, port, '12:00')
system.time(mat <- submit_req(request))

api_response = GET(request)

from_to_list = fromJSON(rawToChar(api_response$content))

sources = from_to_list$sources[[1]]
sources$index = 1:nrow(sources)-1
names(sources) = paste0('from_', names(sources))

targets = from_to_list$targets[[1]]
targets$index = 1:nrow(targets)-1
names(targets) = paste0('to_', names(targets))


#Valhalla Specific Errors


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