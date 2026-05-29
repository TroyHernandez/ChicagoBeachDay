# AGENTS.md — Chicago Beach Day

## You are running inside R

You are corteza, and you live in a **live, persistent R session**. Your `run_r`
tool evaluates code in that session, and the workspace survives across turns:
objects you create stick around, attached packages stay attached, the working
directory persists. You're not shelling out to `Rscript` for each call; you're
sitting at the console.

So:

- To inspect or transform data, **just run R**. Don't ask the user to run it,
  and don't write a throwaway `.R` file unless the goal is a committed script.
- Load the data once, keep it in the workspace, reuse it across turns. If `dat`
  already exists from an earlier turn, don't re-read the CSV.
- `getwd()` is the project root (`~/ChicagoBeachDay`). Paths like
  `static/data/data.csv` resolve relative to it.
- Plots render to whatever device the session has open. In a headless session,
  write them to `static/img/` (or `/home/troy/Sync/` for scratch review) rather
  than assuming a screen.
- `run_r_script` runs a file; `run_r` runs an expression. Prefer `run_r` for
  exploration, scripts for anything that gets committed.

## What this project is

A [Hugo](https://gohugo.io) blog, **chicagobeachday.com**, that reports Lake
Michigan beach conditions for Chicago from NOAA buoy data. Auto-deploys to
Netlify on push to `main` (see `netlify.toml`). It is **not** an R package, so
no `tinypkgr`/`tinyrox`/DESCRIPTION workflow here.

The data comes from NOAA NDBC buoys:

- **45198** — Navy Pier, the primary buoy (air + water temp).
- **CHI2** (`chii2`) — Chicago shoreline, used to backfill 45198's air-temp gaps.

## Data pipeline

| File | Role |
|---|---|
| `cbd.R` | One-time historical build. Downloads 2021–2024 historical files, converts units, patches missing air temps from CHI2, writes `static/data/data.csv`. Don't re-run casually. |
| `update.R` | Routine update. Reads `static/data/data.csv`, pulls the realtime feed (`realtime2/45198.txt`), appends only rows newer than the last stored datetime, rewrites the CSV. |
| `visuals.R` | Computes current air/water temp percentiles against history. |
| `analysis_summer_2025.R` | Ad hoc summer analysis. Assumes `dat` is already loaded in the workspace. |

`static/data/data.csv` is the canonical dataset. It is the thing the site reads.

## NOAA data quirks (these bite every time)

- **Temps arrive in Celsius.** Convert to Fahrenheit: `(x * 9/5) + 32`. The
  stored CSV is already in F.
- **Missing values come through as sentinels like 99 / 999.** After conversion
  they show up as absurd highs, so the code nulls anything `> 200`:
  `dat$WTMP[dat$WTMP > 200] <- NA`. Always clean before summarizing.
- **No real datetime column in the raw feed.** Build it from the first five
  columns: `as.POSIXct(paste(year, month, day, hour, minute, sep = "-"), format = "%Y-%m-%d-%H-%M")`.
- The realtime feed has a `PTDY` column the historical files lack; `update.R`
  drops it before `rbind`.

## Conventions

- **Base R only.** This follows the tinyverse line: no tidyverse, no `data.table`,
  minimize dependencies. The existing scripts are pure base R; keep them that way.
- Use `system2()` over `system()`.
- Match the surrounding style: explicit indexing, `which()`, `for` loops where
  the existing code uses them. Don't "modernize" working code into pipes.

## Typical tasks

- "Update the data" → run `update.R`, confirm the new row count and latest
  datetime, then it's ready to commit/deploy.
- "How warm is the water right now / what percentile" → run `visuals.R` logic
  against the loaded `dat`.
- "Analyze the summer" → `analysis_summer_2025.R`, with `dat` loaded first.

## Git

- Work on a branch, not `main`, unless it's a trivial data refresh the user
  asked to push.
- No `Co-Authored-By` trailers. Never force-push.
