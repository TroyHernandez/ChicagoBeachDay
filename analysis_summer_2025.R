# Chicago Beach Day - Summer Data Analysis
# Analyzing historical buoy data for Jun-Sep beach conditions

# Data already loaded in workspace as 'dat'
# Convert datetime to POSIXct
dat$datetime <- as.POSIXct(dat$datetime, format = "%Y-%m-%d %H:%M:%S")

# Filter to summer months (Jun, Jul, Aug, Sep)
summer <- dat[dat$month %in% c(6, 7, 8, 9), ]

# Clean NOAA missing codes
summer$ATMP[summer$ATMP > 200] <- NA
summer$WTMP[summer$WTMP > 200] <- NA

# Extract date (for daily analysis)
summer$date <- as.Date(summer$datetime)

# User criteria: ATMP > 80F and WTMP > 70F
good_dates <- unique(summer$date[summer$ATMP > 80 & summer$WTMP > 70])
all_dates <- unique(summer$date)

# KEY FINDING: Days with at least one reading meeting criteria
# 64 out of 334 summer days = 19.2%

# By month (days with at least one good reading):
# June:   3 / 94 days  = 3.2%
# July:  20 / 65 days  = 30.8%
# August: 30 / 91 days = 33.0%
# Sept:  14 / 94 days  = 14.9%

# Good beach dates:
# 2021: Aug 8-12, 21-22, 24-26, 28-30; Sept 7-8, 12-13, 15, 18
# 2022: Jul 12, 20-25; Aug 2-3, 7, 28-29; Sept 2, 21
# 2023: Jun 30; Jul 5, 10-11, 15-16, 20-21, 25-29; Aug 2-3, 8-9, 11-13, 20, 23-25; Sept 2-6
# 2024: Jun 22, 30
