## -------------------------------------------------- ##
#                  Housekeeping -----
## -------------------------------------------------- ##
# Purpose:
# This script executes the entire scraping and post creation workflow

# Load packages
library(rvest)
library(tidyverse)
library(chromote)
library(lubridate)

# Load function to scrape data and images
source(file.path("scripts", "scrape.R"))
# Load function to create post
source(file.path("scripts", "create_post.R"))

## -------------------------------------------------- ##
#                  Execution -----
## -------------------------------------------------- ##

# Set item URL
my_url <- "https://www.tokyokawaiilife.jp/fs/lizlisaadmin/all-bottoms/153-5108-0"
# Set item name in English
my_en_name <- "Double Ribbon Belt Skirt-Pants"

# Scrape data and images
scrape(url = my_url, en_name = my_en_name)

# Set item ID
my_id <- "153-5108-0"

# Create post
create_post(id = my_id)
