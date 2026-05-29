# model_wtmp.R — Train and save water-temperature prediction model
# Predicts daily average water temp from forecasted air temp + lagged water temp + month

# Load data
dat <- read.csv("static/data/data.csv", stringsAsFactors = FALSE)
dat$datetime <- as.POSIXct(dat$datetime, format = "%Y-%m-%d %H:%M:%S")
dat$ATMP[dat$ATMP > 200] <- NA
dat$WTMP[dat$WTMP > 200] <- NA

# Daily averages
dat$date <- as.Date(dat$datetime)
daily <- aggregate(cbind(ATMP, WTMP) ~ date, data = dat, FUN = mean, na.rm = TRUE)
daily <- daily[order(daily$date), ]

# Features
daily$month <- as.numeric(format(daily$date, "%m"))
daily$yday <- as.numeric(format(daily$date, "%j"))
daily$WTMP_lag1 <- c(NA, daily$WTMP[-nrow(daily)])
daily$ATMP_lag1 <- c(NA, daily$ATMP[-nrow(daily)])

# Train model
m_wtmp <- lm(WTMP ~ ATMP + WTMP_lag1 + month, data = daily, na.action = na.omit)
cat("Model R²:", summary(m_wtmp)$r.squared, "\n")
cat("Model RMSE:", summary(m_wtmp)$sigma, "°F\n")

# Save
saveRDS(m_wtmp, "model_wtmp.rds")
cat("Saved to model_wtmp.rds\n")
