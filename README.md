# WeatherAI India

Next-day rainfall prediction for five Indian cities (Mumbai, New Delhi,
Kolkata, Chennai, Bangalore), served through a calm, editorial-styled AI-chat
interface. Built end to end: real data, real models, real API, real frontend
— no mocked responses, no fabricated metrics.

**Scope: India only.** See `INDIA_ONLY_DATA_POLICY.md`.

## What's actually here

| Layer | Status |
|---|---|
| Data | 19,505 rows, 5 cities, 2016-01-01 → 2026-09-05, Open-Meteo ERA5 reanalysis |
| Models | Climatology, Logistic Regression, Decision Tree, Random Forest, MLP — chronologically split, validation-selected |
| Production model | MLP, threshold 0.46 (ensemble evaluated, not shipped — see `docs/ML_SPECIFICATION.md`) |
| API | FastAPI, 6 endpoints, real inference, Pydantic validation |
| Frontend | React + TypeScript + Vite, schema-driven form, AI slope, browser-local history |
| Tests | 45 passing (`python -m pytest`) |
| Docker | Built and run in this environment — see `docs/DEPLOYMENT_SPEC.md` |

A prior Kaggle source (`kalashnikov1405/rain-forecasting-in-india`) was
inspected and found to be synthetic (future dates, physically impossible
temperatures, an internally inconsistent target). It was rejected and replaced
with real reanalysis data. The full reasoning is in `docs/DECISIONS.md`
(D-010, D-011) and `docs/INITIAL_AUDIT.md`.

## Data truth

Coverage is **five cities, not nationwide**, and the source is **gridded ERA5
reanalysis, not IMD station observations** — stated in `/api/data/info` and
the frontend's About page, not just in this file. See `docs/DATA_CONTRACT.md`
for the measured numbers.

## Run it

### Development

```bash
# 1. Get the data (only needed once; cached under data/raw/open_meteo/)
python -m weatherai.data.ingest

# 2. Build the canonical dataset (validates; fails loudly if the data is bad)
python -m weatherai.data.build

# 3. Train (climatology + 4 models, chronological split, ~1 minute on a laptop CPU)
python -m weatherai.ml.train

# 4. Backend
pip install -e .
uvicorn weatherai.api.main:app --reload --port 8000

# 5. Frontend (separate terminal)
cd frontend
npm install
npm run dev   # http://localhost:5173, proxies /api to :8000
```

### Production (Docker — built and run in this environment)

```bash
docker compose up -d --build
curl http://127.0.0.1:8080/api/health
# frontend + API both served through nginx on :8080 (same-origin, no CORS needed)
```

### Tests

```bash
python -m pytest          # 45 tests: data validation, leakage, ML pipeline, API, acceptance
cd frontend && npm run build   # production build (also exercised by the acceptance test)
```

## Build order followed

1. `docs/INITIAL_AUDIT.md` — repository inspection, what was reused vs. replaced.
2. Data acquisition, validation, canonical schema (`docs/DATA_CONTRACT.md`).
3. ML pipeline, training, evaluation (`docs/ML_SPECIFICATION.md`).
4. FastAPI (`docs/API_CONTRACT.md`).
5. React + Vite frontend (`docs/UI_UX_SPECIFICATION.md`, `docs/COMPONENT_SPEC.md`).
6. Integration, tests (`docs/TEST_PLAN.md`).
7. Docker, docs, final audit (`docs/FINAL_AUDIT.md`).

## UI philosophy

AI-chat interaction with a mature editorial/scientific visual language: warm
paper background, restrained typography, no purple-blue AI gradients, no
glassmorphism, no glowing blobs. The AI slope — a restrained diagonal
SVG/CSS motif meaning *observations → reasoning → forecast* — is the
signature visual identity, not a decision boundary.

## Do not

- add Australia data or reuse an Australia-trained artifact (enforced at the
  data and artifact layer — see `INDIA_ONLY_DATA_POLICY.md`),
- fabricate metrics, predictions, or coverage claims,
- hard-code frontend fields independent of the trained feature schema,
- fit preprocessing on validation or test data,
- claim "complete" without evidence — see `docs/FINAL_AUDIT.md` for what was
  actually verified versus not verified in this environment.
