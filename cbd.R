# library(blogdown)
# install_hugo()
# new_site(theme = "ribice/kiss")


dat <- read.table("https://www.ndbc.noaa.gov/data/realtime2/45198.txt",
                  col.names = c("year", "month", "day", "hour", "minute",
                                "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                "PTDY", "TIDE"))

# convert celsius to fahrenheit
dat$ATMP <- (dat$ATMP * 9/5) + 32
dat$WTMP <- (dat$WTMP * 9/5) + 32
# create datetime column
dat$datetime <- as.POSIXct(paste(dat$year, dat$month, dat$day, dat$hour, dat$minute, sep = "-"), format = "%Y-%m-%d-%H-%M")

# Downloading historical data
# https://www.ndbc.noaa.gov/view_text_file.php?filename=45198h2021.txt.gz&dir=data/historical/stdmet/

dat2021 <- read.table("https://www.ndbc.noaa.gov/view_text_file.php?filename=45198h2021.txt.gz&dir=data/historical/stdmet/",
                      col.names = c("year", "month", "day", "hour", "minute",
                                    "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                    "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                    "TIDE"))
dat2022 <- read.table("https://www.ndbc.noaa.gov/view_text_file.php?filename=45198h2022.txt.gz&dir=data/historical/stdmet/",
                      col.names = c("year", "month", "day", "hour", "minute",
                                    "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                    "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                    "TIDE"))
dat2023 <- read.table("https://www.ndbc.noaa.gov/view_text_file.php?filename=45198h2023.txt.gz&dir=data/historical/stdmet/",
                      col.names = c("year", "month", "day", "hour", "minute",
                                    "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                    "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                    "TIDE"))
dat2024May <- read.table("https://www.ndbc.noaa.gov/view_text_file.php?filename=4519852024.txt.gz&dir=data/stdmet/May/",
                      col.names = c("year", "month", "day", "hour", "minute",
                                    "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                    "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                    "TIDE"))

dat2024June <- read.table("https://www.ndbc.noaa.gov/data/stdmet/Jun/45198.txt",
                         col.names = c("year", "month", "day", "hour", "minute",
                                       "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                       "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                       "TIDE"))

dat_hist <- rbind(dat2021, dat2022, dat2023, dat2024May, dat2024June)

# convert celsius to fahrenheit
dat_hist$ATMP <- (dat_hist$ATMP * 9/5) + 32
dat_hist$WTMP <- (dat_hist$WTMP * 9/5) + 32
# create datetime column
dat_hist$datetime <- as.POSIXct(paste(dat_hist$year, dat_hist$month,
                                      dat_hist$day, dat_hist$hour,
                                      dat_hist$minute, sep = "-"),
                                format = "%Y-%m-%d-%H-%M")
# Find the rows where the water temperature is greater than 200 degrees and make it null
dat_hist$WTMP[which(dat_hist$WTMP > 200)] <- NA

# Find the rows where the air temperature is greater than 200 degrees and make it null
dat_hist$ATMP[which(dat_hist$ATMP > 200)] <- NA

plot(dat_hist$datetime, dat_hist$WTMP, type = "l", xlab = "Date",
     ylab = "Temperature (F)",
     main = "Historical Water Temperature at Buoy 45198 (Navy Pier)", col = "blue")


plot(dat_hist$datetime, dat_hist$ATMP, type = "l", xlab = "Date",
     ylab = "Temperature (F)",
     main = "Historical Air Temperature at Buoy 45198 (Navy Pier)", col = "blue")

#####################################################################
# Pull 2023 data for CHI2
# https://www.ndbc.noaa.gov/view_text_file.php?filename=chii2h2023.txt.gz&dir=data/historical/stdmet/
# col names <- YY  MM DD hh mm WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP  DEWP  VIS  TIDE
datCHI2_2023 <- read.table("https://www.ndbc.noaa.gov/view_text_file.php?filename=chii2h2023.txt.gz&dir=data/historical/stdmet/",
                           col.names = c("year", "month", "day", "hour", "minute",
                                         "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                         "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                         "TIDE"))
# create datetime column
datCHI2_2023$datetime <- as.POSIXct(paste(datCHI2_2023$year, datCHI2_2023$month,
                                          datCHI2_2023$day, datCHI2_2023$hour,
                                          datCHI2_2023$minute, sep = "-"),
                                    format = "%Y-%m-%d-%H-%M")
# convert celsius to fahrenheit
datCHI2_2023$ATMP <- (datCHI2_2023$ATMP * 9/5) + 32

# Find the rows where the air temperature is greater than 200 degrees and make it null
datCHI2_2023$ATMP[which(datCHI2_2023$ATMP > 200)] <- NA

plot(datCHI2_2023$datetime, datCHI2_2023$ATMP, type = "l", xlab = "Date",
     ylab = "Temperature (F)",
     main = "Historical Air Temperature at Buoy CHI2 (Chicago)", col = "blue")


################################################################################
# Compare 2022 CHI2 and 45198
datCHI2_2022 <- read.table("https://www.ndbc.noaa.gov/view_text_file.php?filename=chii2h2022.txt.gz&dir=data/historical/stdmet/",
                           col.names = c("year", "month", "day", "hour", "minute",
                                         "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                         "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                         "TIDE"))
# create datetime column
datCHI2_2022$datetime <- as.POSIXct(paste(datCHI2_2022$year, datCHI2_2022$month,
                                          datCHI2_2022$day, datCHI2_2022$hour,
                                          datCHI2_2022$minute, sep = "-"),
                                    format = "%Y-%m-%d-%H-%M")
# convert celsius to fahrenheit
datCHI2_2022$ATMP <- (datCHI2_2022$ATMP * 9/5) + 32
# Find the rows where the air temperature is greater than 200 degrees and make it null
datCHI2_2022$ATMP[which(datCHI2_2022$ATMP > 200)] <- NA

plot(datCHI2_2022$datetime, datCHI2_2022$ATMP, type = "l", xlab = "Date",
     ylab = "Temperature (F)",
     main = "Historical Air Temperature at Buoy CHI2 (Chicago)", col = "blue")

# Compare 2022 CHI2 and 45198
dat_comp <- merge(datCHI2_2022, dat_hist, by = "datetime", all = TRUE)
# Select only 2022 data
dat_comp_2022 <- dat_comp[!(is.na(dat_comp$ATMP.y) | is.na(dat_comp$ATMP.x)),]
plot(dat_comp_2022$ATMP.y, dat_comp_2022$ATMP.x, xlab = "Chicago Air Temp (F)",
     ylab = "Navy Pier Air Temp (F)",
     main = "Comparison of Air Temperature at Buoy CHI2 (Chicago) and 45198 (Navy Pier)",
     col = "blue")
head(dat_comp_2022[, c("ATMP.y", "ATMP.x")])
# Looks good

##################################################################################
# Replace missing dat_hist$ATMP with datCHI2_2022$ATMP
# Find missing values in dat_hist$ATMP in 2022
inds <- which(is.na(dat_hist$ATMP) & dat_hist$year == 2022)
# Get datetime for those inds and find the corresponding values in datCHI2_2022$ATMP
for(i in 1:length(inds)){
  ind <- inds[i]
  datetime <- dat_hist$datetime[ind]
  val <- datCHI2_2022$ATMP[which(datCHI2_2022$datetime == datetime)]
  if(length(val) == 0){
    next
  } else {
    dat_hist$ATMP[ind] <- val
  }
}

# Replace missing dat_hist$ATMP with datCHI2$ATMP
# Find missing values in dat_hist$ATMP in 2023
inds <- which(is.na(dat_hist$ATMP) & dat_hist$year == 2023)
# Get datetime for those inds and find the corresponding values in datCHI2$ATMP
for(i in 1:length(inds)){
  ind <- inds[i]
  datetime <- dat_hist$datetime[ind]
  val <- datCHI2_2023$ATMP[which(datCHI2_2023$datetime == datetime)]
  if(length(val) == 0){
    next
  } else {
    dat_hist$ATMP[ind] <- val
  }
}

# plot the historical air temperature with the replaced values
plot(dat_hist$datetime, dat_hist$ATMP, type = "l", xlab = "Date",
     ylab = "Temperature (F)",
     main = "Historical Air Temperature at Buoy 45198 (Navy Pier)", col = "blue")

# Plot water vs air temp
plot(dat_hist$ATMP, dat_hist$WTMP, xlab = "Air Temp (F)", ylab = "Water Temp (F)",
     main = "Historical Air vs Water Temperature at Buoy 45198 (Navy Pier)", col = "blue")
smoothScatter(dat_hist$ATMP, dat_hist$WTMP, xlab = "Air Temp (F)", ylab = "Water Temp (F)",
              main = "Historical Air vs Water Temperature at Buoy 45198 (Navy Pier)")

write.csv(dat_hist, "static/data/historical_data_202406.csv", row.names = FALSE)
write.csv(dat_hist, "static/data/data.csv", row.names = FALSE)
