# predict.R — Daily beach day prediction pipeline
# Run at 5am CT to generate today's verdict

library(jsonlite)

# ---------------------------------------------------------------------------
# 1. Load data and model
# ---------------------------------------------------------------------------
dat <- read.csv("static/data/data.csv", stringsAsFactors = FALSE)
dat$datetime <- as.POSIXct(dat$datetime, format = "%Y-%m-%d %H:%M:%S")
dat$ATMP[dat$ATMP > 200] <- NA
dat$WTMP[dat$WTMP > 200] <- NA

# Daily averages for lag feature
dat$date <- as.Date(dat$datetime)
daily <- aggregate(cbind(ATMP, WTMP) ~ date, data = dat, FUN = mean, na.rm = TRUE)
daily <- daily[order(daily$date), ]

# Yesterday's water temp (most recent complete day)
yesterday <- daily$date[nrow(daily)]
yesterday_wtmp <- daily$WTMP[nrow(daily)]

if (is.na(yesterday_wtmp)) {
  # Fallback: use last non-NA water temp
  yesterday_wtmp <- tail(na.omit(daily$WTMP), 1)
  cat("WARNING: yesterday WTMP is NA, using last available:", round(yesterday_wtmp, 1), "F\n")
} else {
  cat("Yesterday (", as.character(yesterday), "): WTMP =", round(yesterday_wtmp, 1), "F\n")
}

# ---------------------------------------------------------------------------
# 2. Fetch weather forecast
# ---------------------------------------------------------------------------
forecast_high <- NA
forecast_name <- "unknown"
tryCatch({
  pts <- fromJSON("https://api.weather.gov/points/41.85,-87.65")
  fc <- fromJSON(pts$properties$forecast)
  periods <- fc$properties$periods
  day_periods <- periods[periods$isDaytime, ]
  forecast_high <- day_periods$temperature[1]
  forecast_name <- day_periods$name[1]
  cat("Forecast (", forecast_name, "): high =", forecast_high, "F\n")
}, error = function(e) {
  cat("WARNING: NWS forecast fetch failed:", conditionMessage(e), "\n")
  cat("Falling back to yesterday's air temp as forecast proxy.\n")
  forecast_high <<- daily$ATMP[nrow(daily)]
})

# ---------------------------------------------------------------------------
# 3. Predict water temperature
# ---------------------------------------------------------------------------
if (!file.exists("model_wtmp.rds")) {
  stop("model_wtmp.rds not found. Run model_wtmp.R first.")
}
m_wtmp <- readRDS("model_wtmp.rds")

month_now <- as.numeric(format(Sys.Date(), "%m"))

pred_df <- data.frame(
  ATMP = forecast_high,
  WTMP_lag1 = yesterday_wtmp,
  month = month_now
)

predicted_wtmp <- predict(m_wtmp, newdata = pred_df)
cat("Predicted water temp:", round(predicted_wtmp, 1), "F\n")

# ---------------------------------------------------------------------------
# 4. Render verdict
# ---------------------------------------------------------------------------
air_ok <- forecast_high > 80
water_ok <- predicted_wtmp > 70
verdict <- ifelse(air_ok && water_ok, "YES", "NO")
verdict_emoji <- ifelse(air_ok && water_ok, "👍", "👎")
img_file <- ifelse(air_ok && water_ok, "thumbs-up.webp", "thumbs-down.webp")

reason <- ""
if (!air_ok && !water_ok) {
  reason <- paste0("Air temp too cool (", forecast_high, "°F, need >80°F) and water temp too cool (", round(predicted_wtmp, 1), "°F, need >70°F).")
} else if (!air_ok) {
  reason <- paste0("Air temp too cool (", forecast_high, "°F, need >80°F).")
} else if (!water_ok) {
  reason <- paste0("Water temp too cool (", round(predicted_wtmp, 1), "°F, need >70°F).")
} else {
  reason <- paste0("Air temp ", forecast_high, "°F and predicted water temp ", round(predicted_wtmp, 1), "°F both look great.")
}

# ---------------------------------------------------------------------------
# 5. Write Hugo content file
# ---------------------------------------------------------------------------
md <- paste0(
  "+++\n",
  "title = \"Is today a good day to go to the beach in Chicago?\"\n",
  "description = \"\"\n",
  "date = \"", Sys.Date(), "\"\n",
  "categories = [\"Beach Day\"]\n",
  "menu = \"main\"\n",
  "+++\n\n",
  "![", ifelse(verdict == "YES", "Thumbs Up", "Thumbs Down"), "]",
  "(/images/", img_file, ")\n\n",
  "**Forecast high:** ", forecast_high, "°F  \n",
  "**Predicted water temp:** ", round(predicted_wtmp, 1), "°F  \n\n",
  reason, "\n\n",
  "---\n\n",
  "_Updated daily at 5am CT. Predictions use NOAA buoy 45198 (Navy Pier) and NWS forecast data._\n"
)

writeLines(md, "content/post/cbd.md")
cat("Wrote content/post/cbd.md\n")
