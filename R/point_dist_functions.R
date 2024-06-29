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