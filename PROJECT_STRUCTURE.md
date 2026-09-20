# WeatherAI India Structure

```text
WeatherAI India/
├── weatherai/                    # installable Python package (pip install -e .)
│   ├── config.py                 # filesystem layout, constants
│   ├── features.py                # leakage-safe feature engineering + schema doc
│   ├── data/
│   │   ├── canonical.py           # frozen canonical schema, locations, rain threshold
│   │   ├── validate.py            # deterministic validation (blocker/warning checks)
│   │   ├── ingest.py               # CLI: download raw Open-Meteo cache
│   │   ├── build.py                # CLI: raw -> canonical CSV + schema/validation reports
│   │   └── sources/
│   │       ├── open_meteo.py       # production source (ERA5 reanalysis)
│   │       └── kaggle_rain_forecasting.py  # rejected source adapter (evidence only)
│   ├── ml/
│   │   ├── split.py                # chronological train/val/test split
│   │   ├── models.py               # pipelines + bounded hyperparameter search spaces
│   │   ├── evaluate.py             # metrics, threshold selection, ensemble weighting
│   │   ├── ensemble.py             # weighted probability ensemble estimator
│   │   ├── train.py                # CLI: train, select, evaluate, save artifacts
│   │   └── registry.py             # load artifacts once, refuse non-India artifacts
│   └── api/
│       ├── schemas.py              # Pydantic request/response models (the API contract)
│       ├── service.py              # prediction logic (routes stay thin)
│       ├── settings.py             # environment-driven configuration
│       └── main.py                 # FastAPI app
├── frontend/                     # React + TypeScript + Vite
│   └── src/{api,components,pages,state,styles}/
├── data/
│   ├── raw/
│   │   ├── open_meteo/             # immutable per-city-year cache + MANIFEST.json
│   │   └── kaggle_rain_forecasting/  # rejected source, kept as evidence (PROFILE.md)
│   └── processed/                  # canonical.csv, schema_report.json, validation_report.*
├── artifacts/                    # versioned model artifacts (weatherai-india-<version>/)
├── scripts/
│   └── profile_kaggle_source.py    # reproduces the rejection evidence
├── docs/                         # specifications, decisions, audits
├── skills/                       # runbooks
├── tests/                        # pytest: data, ml, api, acceptance
├── Dockerfile, docker-compose.yml, deploy/nginx.conf
├── pyproject.toml, requirements.txt
├── CLAUDE.md, README.md
└── project_manifest.json
```

India-only data policy applies to the entire active training/inference
pipeline — see `INDIA_ONLY_DATA_POLICY.md`.
