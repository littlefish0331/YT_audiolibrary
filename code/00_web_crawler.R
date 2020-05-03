rm(list = ls()); gc()
setwd("D:/project_big/YT_audiolibrary/")
library(dplyr)
library(data.table)
library(jsonlite)
library(filesstrings)

listcheck <- function(x){
  if(length(x)==0) return("")
  else return(x %>% gsub(",", " ", .))
}  

has_more <- "TRUE"
# query_s <- "music"
query_s <- "soundeffects"
query_mr <- 100
query_si <- 0
query_url <- paste0("https://www.youtube.com/audioswap_ajax?action_get_tracks=1&dl=true&s=",
                    query_s, "&mr=", query_mr, "&si=", query_si)
cmd <- paste0('start chrome "', query_url, '"')
download_path <- "C:/Users/littlefish/Downloads/audioswap_ajax.json"
move_to <- "./data/"
file_path <- paste0(move_to, "audioswap_ajax.json")
col_order <- c("vid", "artist", "album", "title", "len", 
               "display_genre", "display_mood", "display_category", "genre", "mood", "category",
               "instruments", "artist_url", "artist_channel_url", 
               "license_type", "downloadable", "download_url", 
               "favorite", "popularity_percentile",
               "is_new_track", "track_url", 
               "streamid", "reference_vid", "fp_ref_id", "waveform_url") #音樂和音效的欄位都是一樣的XD

res_tmp <- list()
i <- 1
if (file.exists(download_path)) file.remove(download_path)
while (has_more=="TRUE") {
  # ---
  shell(cmd = cmd)
  
  # ---
  while (!file.exists(download_path)) Sys.sleep(1)
  file.move(files = download_path, destinations = move_to, overwrite = T)
  
  # ---
  while (!file.exists(file_path)) Sys.sleep(0.5)
  response = fromJSON(txt = file_path)
  tmp01 <- response$tracks %>% setDT()
  tmp01$instruments <- tmp01$instruments %>% lapply(., listcheck)
  res_tmp[[i]] <- tmp01[, col_order, with = F]
  
  # ---
  file.remove(file_path)
  query_si <- 0+100*i
  i <- i+1
  query_url <- paste0("https://www.youtube.com/audioswap_ajax?action_get_tracks=1&dl=true&s=",
                      query_s, "&mr=", query_mr, "&si=", query_si)
  cmd <- paste0('start chrome "', query_url, '"')
  has_more <- response$has_more
  Sys.sleep(5)
}

# ---
res <- res_tmp %>% rbindlist()
# res %>% fwrite(., "./data/music.csv", row.names = F)
res %>% fwrite(., "./data/soundeffects.csv", row.names = F)
