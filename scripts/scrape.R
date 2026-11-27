## -------------------------------------------------- ##
#                  Housekeeping -----
## -------------------------------------------------- ##
# Purpose:
# This function scrapes from tokyokawaiilife.jp given an item URL

# Load function to get the season
source(file.path("scripts", "get_season.R"))

## -------------------------------------------------- ##
#                    Function -----
## -------------------------------------------------- ##

scrape <- function(url, en_name){
  
  # -------------------- Extract HTML --------------------

  # Start a headless Chrome session
  b <- ChromoteSession$new()
  
  # Navigate to URL and wait for page to load
  b$Page$navigate(url)
  b$Page$loadEventFired()
  
  # Wait for page to finish rendering
  Sys.sleep(3)
  
  # Extract the rendered DOM
  html_raw <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value
  
  # Parse the HTML
  page <- rvest::read_html(html_raw)
  
  # Close the browser session
  b$close()
  
  # -------------------- Compile data --------------------
  
  # Grab item metadata
  item_info <- page %>%
    rvest::html_elements('script[type="text/javascript"]') %>%
    rvest::html_text2() %>%
    stringr::str_subset("setItemData")
  
  # Grab item description
  item_jp_description <- page %>%
    rvest::html_elements('p[class="description_text"]') %>%
    rvest::html_text2()
  
  # If no description is provided, put placeholder text
  if (length(item_jp_description) == 0){
    item_jp_description <- "No description provided"
  }
  
  # Grab tables
  item_tables <- page %>%
    rvest::html_table()
  # Pick out the measurement table
  item_jp_measure <- item_tables[[4]]
  
  # Pick out specific pieces of info
  id <- stringr::str_extract(item_info, "(?<=code:')[^']+")
  jp_name <- stringr::str_extract(item_info, "(?<=name:')[^']+")
  category <- stringr::str_to_title(stringr::str_extract(item_info, "(?<=category:')[^']+"))
  price <- stringr::str_extract(item_info, "(?<=price_before_tax:')[^']+")
  release_date <- stringr::str_extract(item_info, "(?<=release_date:')[^']+") %>%
    stringr::str_extract("[:digit:]{4}-[:digit:]{2}-[:digit:]{2}")
  season <- paste0(get_season(release_date), " ", stringr::str_sub(release_date, 1, 4))
  
  # Compile item dataframe
  item_df <- data.frame(id = id,
                        en_name = en_name,
                        jp_name = jp_name,
                        category = category,
                        season = season,
                        price = price,
                        jp_desc = item_jp_description,
                        jp_material = item_jp_measure[[2]][1],
                        jp_size = item_jp_measure[[2]][2],
                        jp_color = item_jp_measure[[2]][4],
                        jp_size_label = item_jp_measure[[2]][5]) %>%
    dplyr::mutate(across(everything(), as.character)) %>%
    tidyr::pivot_longer(cols = everything(), names_to = "detail", values_to = "value")
  
  # Create item folder
  dir.create(file.path("posts", id))
  # Export
  write_csv(item_df, file.path("posts", id, paste0("info_", id, ".csv")))
  
  # -------------------- Download images --------------------
  
  # Grab list of URLs for available stock images
  images_orig <- page %>%
    rvest::html_elements('img') %>%
    rvest::html_attr("src") %>%
    stringr::str_subset("storage")
  
  images_to_download <- list()
  
  # Edit URLs so they point to the large version
  for (i in seq_along(images_orig)){
    if (stringr::str_detect(images_orig[i], "ds.jpg")){
      images_to_download[[i]] <- stringr::str_replace(images_orig[i], pattern = "ds.jpg", replacement = "dl.jpg")
    } else {
      images_to_download[[i]] <- images_orig[i]
    }
  }
  
  # Download the first 4 images
  for (i in 1:4) {
    download.file(images_to_download[[i]],
                  destfile = file.path("posts", id, basename(images_to_download[[i]])),
                  mode = "wb")
  }
}