# Data Acquisition Pipeline

Local data pipeline collecting city demographics, weather forecasts, and flight arrivals from public APIs and Wikipedia, storing results in a relational MySQL database. Built as Phase 1 of a cloud migration project for Gans, a fictional e-scooter company optimising fleet deployment across European cities.

![Python](https://img.shields.io/badge/Python-3.14-blue)
![Pandas](https://img.shields.io/badge/Pandas-3.0.2-lightgrey)
![MySQL](https://img.shields.io/badge/MySQL-Database-orange)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-2.0-red)
![BeautifulSoup](https://img.shields.io/badge/BeautifulSoup4-Web%20Scraping-green)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-orange)

## Context

This project was completed as part of a data science training program. The business case: Gans needs to position e-scooters where demand will be highest, which means anticipating where people are, what the weather will be, and which cities are receiving a lot of flight arrivals with tourists.

E-scooter companies like Gans (and competitors TIER and Bird) market themselves on sustainability, but operational success comes down to something more mundane: **having scooters where users need them**. Demand is shaped by asymmetries: hilly terrain, morning commutes toward city centres, rain events, and tourists arriving from cheap flights and heading for landmarks. The data collected by this pipeline feeds directly into decisions about when and where to reposition the fleet.

## Overview

Data engineers at Gans are responsible for building the automated pipelines that turn raw external data into decision-ready information. This project covers Phase 1: constructing a fully local pipeline before migrating it to the cloud.

The pipeline answers three questions on a daily basis:

1. **Which cities are we operating in, and what are their basic demographics?**
2. **What weather conditions should we expect over the next 5 days?**
3. **Which airports are active, and what flights are arriving tomorrow?**

## Architecture

```
Wikipedia (HTML)       OpenWeatherMap API      AeroDataBox API
      │                        │                      │
      ▼                        ▼                      ▼
 cities info
 web scraping          Forecast fetch           Flight fetch
(BeautifulSoup)       (requests + JSON)      (requests + JSON)
      │                        │                      │
      └────────────────────────┴──────────────────────┘
                               │
                       pandas DataFrames
                               │
                       MySQL via SQLAlchemy
                               │
                               ▼                
    city_populations ─────── cities ─────────── airports
                               │                  │
                     city_weather_forecast     flights              
```

## Project Files

| File | Description |
|---|---|
| `1_city_data_scraping.ipynb` | Scrapes city metadata and population from Wikipedia infoboxes |
| `2_weather_data_api.ipynb` | Fetches 5-day / 3-hour forecasts from OpenWeatherMap |
| `2_weather_data_api.ipynb` | Discovers nearby airports and pulls tomorrow's arrivals from AeroDataBox |
| `database_creation.sql` | SQL file for creation of the schema and the tables cities, city_populations, city_weather_forecast, aiports and flights |
| `.env.example` | Template for required credentials and DB connection details |

## Key Features

- **Web scraping:** extracts country, coordinates, area, and population figures directly from Wikipedia infoboxes using BeautifulSoup CSS selectors — no third-party geodata API required.
- **Dual API integration:** OpenWeatherMap for weather (3-hour forecast slots, precipitation, wind) and AeroDataBox for airport discovery and flight schedules.

## Setup

**1. Clone the repo and install dependencies**
```bash
pip install -r requirements.txt
```
Or restore the full conda environment:
```bash
conda env create -f environment.yml
conda activate city-data-pipeline
```

**2. Configure credentials** by copying `example.env` to `.env` and filling in your values:
```bash
cp example.env .env
```

**3. Set up the MySQL schema** with the matching table definitions (see `schema.sql`).

**4. Run the pipeline**
```python
from cities_scraper import create_cities_population_tables
from weather_api import create_city_weather_forecast
from flights_api import create_airports_flights_tables

cities = ["Berlin", "Hamburg", "Munich"]

create_cities_population_tables(cities)   # run once, or when adding cities
create_city_weather_forecast()            # run daily
create_airports_flights_tables()          # run daily
```

## Key Learnings

**Web scraping**
- Wikipedia infoboxes are inconsistently structured across city pages. Finding the right data often required locating a neighbouring element first and navigating from there using `.find_next()` or `.find_previous()`, rather than targeting the value directly.
- Population figures were particularly difficult to extract reliably. The data appears in different row positions depending on the article, requiring a look-ahead fallback to the next table row. This part of the scraper is functional but not fully robust and would benefit from further hardening.

**API integration**
- Worked with two REST APIs simultaneously, each with different authentication patterns, response structures, and rate limits.
- Navigating deeply nested JSON responses (e.g. `arrival → scheduledTime → local`) required careful use of chained `.get()` calls with sensible defaults to avoid KeyErrors on missing fields.
- API constraints were not always obvious upfront: the AeroDataBox free tier restricts both request frequency and query window length to 12 hours, both of which required workarounds discovered through testing.

**SQL & SQLAlchemy**
- Designed a normalised schema with a foreign key chain from `flights` → `airports` → `cities`, reflecting real operational dependencies.
- Used `if_exists='delete_rows'` for idempotent city and airport loads, and `if_exists='append'` for time-series tables that accumulate daily snapshots.

## Author

**Henning** · [LinkedIn](https://www.linkedin.com/in/henning-ummethum/) · [GitHub](https://github.com/Ummethum)