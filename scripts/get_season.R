get_season <- function(dates) {
  mmdd <- 100 * lubridate::month(dates) + lubridate::day(dates)
  cuts <- cut(
    mmdd,
    breaks = c(0, 319, 620, 921, 1220, 1231),
    labels = c("Winter", "Spring", "Summer", "Fall", "Winter")
  )
  return(as.character(cuts))
}