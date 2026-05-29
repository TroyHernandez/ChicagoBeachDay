# forecast.R — Fetch today's forecasted high temperature from NOAA NWS API
# Returns the first daytime period's temperature (°F)

library(jsonlite)

# Chicago gridpoint (Navy Pier area)
POINTS_URL <- "https://api.weather.gov/points/41.85,-87.65"

pts <- fromJSON(POINTS_URL)
forecast_url <- pts$properties$forecast

fc <- fromJSON(forecast_url)
periods <- fc$properties$periods

# Find first daytime period = today's high
# (periods are ordered chronologically; daytime = high temp)
day_periods <- periods[periods$isDaytime, ]
today_high <- day_periods$temperature[1]
today_name <- day_periods$name[1]

cat("Forecast period:", today_name, "\n")
cat("Predicted high:", today_high, "°F\n")

# Return as numeric for downstream use
invisible(today_high)
