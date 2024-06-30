# Read in geocoded addresses and compute the isochrones

library("httr")
library("stringr")
library("jsonlite")
library("sf")
library("data.table")
library('scales')

source('R/functions.R')
source('R/point_dist_functions.R')


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

#time is in seconds, assumes 19 minute mile
msgs = mapply(submit_save_request, fns_to_do$request, fns_to_do$fn)

percent_done(request_df, data_path)
