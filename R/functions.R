write_sf = function(x, fn, overwrite=TRUE) {
  if (file.exists(fn) | overwrite) file.remove(fn)
  
  st_write(x, fn)
}

sf_to_df = function(sf_pts) {
  coord_mat = st_coordinates(sf_pts)
  df = data.frame(lat=coord_mat[,'Y'], lon=coord_mat[,'X'])
  
  return(df)
}

build_req_str = function(from, to, server, port, departure=NA,
                         date='2023-07-01') {
  df_from = sf_to_df(from)
  df_to = sf_to_df(to)
  
  if (nrow(from)>nrow(to) & !is.na(departure)) {
    stop('You cannot set a departure time if there are more sources than targets.')
  }
  
  datetime = data.frame(type=1, value=paste0(date, "T", departure))
  
  json = toJSON(list("sources" = df_from,
                     "targets" = df_to,
                     "date_time" = datetime,
                     "costing" = unbox('pedestrian') ))
  
  if (is.na(departure)) id = '00:00' else id = departure
  
  url_string = str_glue("{server}:{port}/sources_to_targets?json={json}&id={id}")
}
