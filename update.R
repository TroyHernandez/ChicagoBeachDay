# update.R — Append realtime buoy data to historical CSV

# Load the data
dat <- read.csv("static/data/data.csv", stringsAsFactors = FALSE)
# Reconstruct datetime from components (robust against format changes)
dat$datetime <- as.POSIXct(paste(dat$year, dat$month, dat$day, dat$hour, dat$minute, sep = "-"),
                           format = "%Y-%m-%d-%H-%M")

# Read realtime data — "MM" and "999" are NOAA missing-value sentinels
url <- "https://www.ndbc.noaa.gov/data/realtime2/45198.txt"
dat_realtime <- read.table(url, header = FALSE, skip = 2,
                           na.strings = c("MM", "999"),
                           col.names = c("year", "month", "day", "hour", "minute",
                                         "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                                         "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS",
                                         "PTDY", "TIDE"))

# Force temperature columns to numeric (read.table may coerce to character)
dat_realtime$ATMP <- as.numeric(dat_realtime$ATMP)
dat_realtime$WTMP <- as.numeric(dat_realtime$WTMP)

# Create datetime column from components
dat_realtime$datetime <- as.POSIXct(paste(dat_realtime$year, dat_realtime$month,
                                          dat_realtime$day, dat_realtime$hour,
                                          dat_realtime$minute, sep = "-"),
                                    format = "%Y-%m-%d-%H-%M")

# Convert Celsius to Fahrenheit
dat_realtime$ATMP <- (dat_realtime$ATMP * 9/5) + 32
dat_realtime$WTMP <- (dat_realtime$WTMP * 9/5) + 32

# Null absurd values (sentinels that survived as numeric)
bad.inds <- which(dat_realtime$ATMP > 200)
if (length(bad.inds) > 0) dat_realtime$ATMP[bad.inds] <- NA
bad.inds <- which(dat_realtime$WTMP > 200)
if (length(bad.inds) > 0) dat_realtime$WTMP[bad.inds] <- NA

# Find new rows after the last stored datetime
last_date <- max(dat$datetime, na.rm = TRUE)
new_rows <- dat_realtime$datetime > last_date

if (!any(new_rows)) {
  cat("No new data. Last:", as.character(last_date), "\n")
} else {
  dat_new <- dat_realtime[new_rows, ]
  dat_new <- dat_new[order(dat_new$datetime), ]

  # Drop PTDY (not in historical schema)
  dat_new$PTDY <- NULL

  # Ensure column order matches before rbind by selecting explicit columns
  keep_cols <- c("year", "month", "day", "hour", "minute",
                 "WDIR", "WSPD", "GST", "WVHT", "DPD", "APD",
                 "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS", "TIDE", "datetime")
  dat_new <- dat_new[, keep_cols]
  dat <- dat[, keep_cols]

  # Append
  dat <- rbind(dat, dat_new)

  # Capture latest datetime before converting to character
  latest_dt <- max(dat$datetime, na.rm = TRUE)

  # Write back with datetime as character string (avoid Unix epoch in CSV)
  dat$datetime <- format(dat$datetime, "%Y-%m-%d %H:%M:%S")
  write.csv(dat, "static/data/data.csv", row.names = FALSE)

  cat("Updated data.csv:", nrow(dat), "rows, latest", as.character(latest_dt), "\n")
}
