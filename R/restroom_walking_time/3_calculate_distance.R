# Read in geocoded addresses and compute the isochrones

library("httr")
library("stringr")
library("jsonlite")
library("sf")
library("data.table")
library('scales')

source('R/functions.R')


submit_save_request = function(request, fn=NA) {
  api_response = GET(request)
  
  stop_for_status(api_response)
  
  Sys.sleep(1)
  
  from_to_list = fromJSON(rawToChar(api_response$content))
  
  dist_mat = from_to_list$sources_to_targets |> rbindlist()
  
  dist_mat$departure = from_to_list$id
  
  if (is.na(fn)) {
    return(dist_mat)
  } else {
    fwrite(dist_mat, fn)
    print(fn)
  }
  
}

create_fns = function(base_name, n, ext, fixed_width=TRUE) {
  
  ids = 1:n
  
  if (fixed_width) {
    
    ndig = log10(n) |> ceiling()
    ids = formatC(ids, digits=ndig, flag='0')
  }
  
  fns = paste0(base_name, '_', ids, '.', ext)
  
  return(fns)
  
}

percent_done = function(df, data_path) {
 
  done_fns = list.files(data_path, pattern='csv$')
  
  pct_num = length(done_fns)/nrow(df)
  
  pct_str = label_percent(accuracy=0.01)(pct_num)
  
  return(pct_str)
  
   
}


# if using datasci.library.ucdavis.edu as the server, make sure you are 
# on the staff vpn (not the library vpn)
server = "http://datasci.library.ucdavis.edu"
port = 8002
depart_time = '12:00'
data_path = 'data/dist'

ppr = st_read('data/Park_Restroom_Status.geojson')
pts_list = readRDS('data/sac_street_sample_points_list.RDS')

requests = sapply(pts_list, build_req_str, ppr, server, port, depart_time)

depart_hrs = gsub('[^0-9]', '', depart_time)
base_path = file.path(data_path, paste0('distance_matrix', depart_hrs))

dist_fns = create_fns(base_path, length(pts_list), 'csv')

request_df = data.table(fn=dist_fns, request=requests)

done_fns = file.path(data_path, list.files(data_path, pattern='csv$'))

fns_to_do = request_df[!fn %in% done_fns]

msgs = mapply(submit_save_request, fns_to_do$request, fns_to_do$fn)

percent_done(request_df, data_path)
