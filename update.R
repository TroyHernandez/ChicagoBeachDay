# update.R

# Load the data
dat <- read.csv("static/data/data.csv")

# read in realtime data from https://www.ndbc.noaa.gov/data/realtime2/45198.txt
dat_realtime <- read.table("https://www.ndbc.noaa.gov/data/realtime2/45198.txt",
                           col.names = c("year", "month", "day", "hour", "minute",
                                         "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                         "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                         "PTDY", "TIDE"))
# create datetime column
dat_realtime$datetime <- as.POSIXct(paste(dat_realtime$year, dat_realtime$month,
                                          dat_realtime$day, dat_realtime$hour,
                                          dat_realtime$minute, sep = "-"),
                                    format = "%Y-%m-%d-%H-%M")
# convert celsius to fahrenheit
dat_realtime$ATMP <- (dat_realtime$ATMP * 9/5) + 32
dat_realtime$WTMP <- (dat_realtime$WTMP * 9/5) + 32
# Find the rows where the air temperature is greater than 200 degrees and make it null
bad.inds <- which(dat_realtime$ATMP > 200)
if(length(bad.inds) > 0) {
  dat_realtime$ATMP[bad.inds] <- NA
}
# Find the rows where the water temperature is greater than 200 degrees and make it null
bad.inds <- which(dat_realtime$WTMP > 200)
if(length(bad.inds) > 0) {
  dat_realtime$WTMP[bad.inds] <- NA
}

#Find last date in the historical data
last_date <- max(dat$datetime)
# Find first date in the realtime data after that
first_date <- min(dat_realtime$datetime[dat_realtime$datetime > last_date])
# take all data from the first date in the realtime data
dat_new <- dat_realtime[dat_realtime$datetime >= first_date, ]
# Order dat_new by datetiem
dat_new <- dat_new[order(dat_new$datetime), ]
# Remove PTDY var from dat_new
dat_new <- dat_new[, -which(names(dat_new) == "PTDY")]

# append to the historical data
dat <- rbind(dat, dat_new)
# Save the data
write.csv(dat, "static/data/data.csv", row.names = FALSE)
