#!/bin/bash
# daily.sh — Run the Chicago Beach Day prediction pipeline
# Add to crontab: 0 5 * * * cd /home/troy/ChicagoBeachDay && ./daily.sh

set -e

cd "$(dirname "$0")"

# 1. Update buoy data
r -e 'source("update.R")'

# 2. Run prediction (writes content/post/cbd.md)
r -e 'source("predict.R")'

# 3. Commit and push (triggers Netlify deploy)
git add content/post/cbd.md static/data/data.csv
git diff --cached --quiet || git commit -m "Daily update $(date +%Y-%m-%d)"
git push origin main

echo "Daily pipeline complete: $(date)"
