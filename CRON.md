# Cron Setup — Chicago Beach Day

The `daily.sh` script runs the full pipeline at 5am CT every morning.

## Install

```bash
# Edit your crontab
crontab -e

# Add this line for 5:00 AM Central Time daily:
0 5 * * * cd /home/troy/ChicagoBeachDay && ./daily.sh >> /home/troy/ChicagoBeachDay/daily.log 2>&1
```

## What it does

1. **update.R** — Pulls latest NOAA buoy data, appends to `static/data/data.csv`
2. **predict.R** — Fetches NWS forecast, predicts water temp, writes verdict to `content/post/cbd.md`
3. **Git commit & push** — Commits changes and pushes to `main`, triggering Netlify auto-deploy

## Manual test

```bash
cd /home/troy/ChicagoBeachDay
./daily.sh
```

## Log file

Output goes to `daily.log` in the project root for troubleshooting.
