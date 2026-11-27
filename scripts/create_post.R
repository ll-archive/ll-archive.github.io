## -------------------------------------------------- ##
#                  Housekeeping -----
## -------------------------------------------------- ##
# Purpose:
# This function programmatically creates a new post

## -------------------------------------------------- ##
#                    Function -----
## -------------------------------------------------- ##

create_post <- function(id){
  
  # -------------------- Create post --------------------
  
  # Read in item CSV
  item_df <- read.csv(file.path("posts", id, paste0("info_", id, ".csv")))

  # Pick out specific pieces of info
  en_name <- item_df$value[2]
  jp_name <- item_df$value[3]
  category <- item_df$value[4]
  season <- item_df$value[5]
  
  # List paths to stock images
  item_imgs <- list.files(file.path("posts", id), pattern = ".jpg")
  
  # Build the qmd file
  qmd_content <- sprintf('---
title: "%s"
date: last-modified
description: "%s"
categories: [%s, %s]
---

![](%s){width=48%%} ![](%s){width=48%%}
![](%s){width=48%%} ![](%s){width=48%%}

```{r}
#| echo: false
#| warning: false
library(DT)
library(tidyverse)
item_df <- read.csv(file.path(paste0("info_", "%s", ".csv")))
DT::datatable(item_df, options = list(pageLength = 15))
```

', en_name, jp_name, category, season,
   item_imgs[1], item_imgs[2], item_imgs[3], item_imgs[4], id)
  
  # Write to a .qmd file
  writeLines(qmd_content, con = file.path("posts", id, "index.qmd"))
  
}