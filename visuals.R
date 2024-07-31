# visuals.R

# Load the data
dat <- read.csv("static/data/data.csv")

# Determine percentile for current water temperature
percentile <- round(quantile(dat$WTMP, probs = seq(0, 1, 0.01), na.rm = TRUE), 2)
temp.pct <- names(percentile)[which(dat$WTMP[nrow(dat)] >= percentile)]
temp.pct[length(temp.pct)]


# Determine percentile for current air temperature
air.percentile <- round(quantile(dat$ATMP, probs = seq(0, 1, 0.01), na.rm = TRUE), 2)
air.temp.pct <- names(air.percentile)[which(dat$ATMP[nrow(dat)] >= air.percentile)]
air.temp.pct[length(air.temp.pct)]
