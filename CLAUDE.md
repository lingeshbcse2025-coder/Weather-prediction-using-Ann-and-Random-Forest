# CLAUDE.md — WeatherAI India
## Master autonomous-build contract

You are the implementation agent for **WeatherAI India**.
Build a complete, real, testable application. Do not produce a visual-only mockup.

### Operating principle
Correctness > speed > feature count.

Do not blindly obey an assumption when the actual data/code disproves it.
Do not silently invent missing requirements.
When a contradiction is found:
1. stop the affected phase,
2. explain the conflict,
3. choose the defensible resolution,
4. record it in `docs/DECISIONS.md`,
5. continue only when the contract is coherent.

Never fabricate:
- data
- model scores
- predictions
- confidence
- dataset coverage
- screenshots
- API responses
- feature importance
- user history

---

# A. AUTHORITATIVE PROJECT IDENTITY

Name: **WeatherAI India**

Primary purpose:
> Predict next-day rainfall from Indian weather observations and explain the result through a calm AI-chat interface.

Geographic scope:
> **INDIA ONLY**

Forbidden:
- Australia data
- weatherAUS.csv
- Rain in Australia dataset
- Australian stations/cities
- mixed India + Australia training data
- old Australia-trained artifacts reused as India production models

The old weatherAUS experiment may be mentioned only as superseded historical context in migration notes. It must never participate in the active India training/inference pipeline.

---

# B. BUILD PHASES — DO NOT SKIP

Execute in this order:

1. INSPECT
2. DATA ACQUISITION
3. DATA VALIDATION
4. CANONICAL SCHEMA FREEZE
5. ML PIPELINE
6. TRAINING
7. EVALUATION
8. ARTIFACT REGISTRY
9. FASTAPI
10. FRONTEND
11. INTEGRATION
12. TESTING
13. UI/UX REVIEW
14. FINAL AUDIT

After each phase:
- run the relevant tests,
- update documentation,
- report what was verified versus assumed.

---

# C. DATA SOURCE

Approved source:
`kalashnikov1405/rain-forecasting-in-india`

Source URL:
https://www.kaggle.com/datasets/kalashnikov1405/rain-forecasting-in-india

The source was described in prior research as early-2025 Indian multi-city data.
That does NOT prove full-year 2025 or nationwide coverage.

Therefore:
- inspect the downloaded data,
- measure actual date range,
- measure actual location coverage,
- measure row count,
- verify target,
- verify country/geographic fields if available,
- document limitations.

Do not call it "all India" or "full-year 2025" unless the file proves it.

Do not download unrelated datasets merely to fill gaps.

---

# D. CANONICAL DATA PIPELINE

Raw data:
`data/raw/`

Processed data:
`data/processed/`

Raw files are immutable.

Required sequence:
source → raw → schema inspection → canonical mapping → validation → processed data.

Canonical schema is NOT assumed in advance.

Create:
`data/processed/schema_report.json`

It must contain:
- source files
- row count
- columns
- date range
- locations
- target labels
- target balance
- missingness
- duplicates
- numeric ranges
- categorical values where useful
- schema mapping

If a required field does not exist, fail with a clear schema error.

---

# E. PRIMARY ML TASK

Binary classification:

`RainTomorrow ∈ {Yes, No}`

Do not silently turn this into:
- temperature regression
- rainfall amount regression
- multi-output forecasting

Those can be future extensions.

Required models:
1. Decision Tree
2. ANN/MLP
3. Random Forest
4. Validation-selected probability ensemble

The ensemble is a model-combination layer, not a claim that it must outperform every individual model.

---

# F. FEATURE ENGINEERING

Only create features justified by the actual dataset.

Potential categories:
- current weather measurements
- humidity
- pressure
- temperature
- rainfall
- wind
- rain-today indicator
- temporal/cyclic date features
- location/city

For lag/rolling features:
- sort chronologically first,
- group by location if location exists,
- shift before rolling where required,
- never use future observations.

Never create a feature that contains information from tomorrow's target.

---

# G. SPLITTING + VALIDATION

Final evaluation:
- chronological holdout
- test observations must occur later than training observations

Model selection:
- TimeSeriesSplit or rolling-origin validation where compatible

Never randomly shuffle the final temporal test.

Preprocessing:
- imputer
- encoder
- scaler
- feature selector

must be fitted inside training folds only.

Never fit preprocessing on validation/test.

---

# H. CLASS IMBALANCE

Start with class weighting.

SMOTE is optional and experimental.
If tested:
- apply only within training folds,
- never validation/test,
- compare against baseline.

Do not assume SMOTE improves the model.

---

# I. HYPERPARAMETER TUNING

Use controlled, reproducible search.

Decision Tree:
- max_depth
- min_samples_split
- min_samples_leaf
- class_weight

Random Forest:
- n_estimators
- max_depth
- min_samples_split
- min_samples_leaf
- max_features
- class_weight

ANN/MLP:
- hidden layer sizes
- activation where appropriate
- learning rate
- alpha/L2
- batch size
- early stopping
- max iterations

Keep search bounded so training remains practical on a normal student laptop.

Record all selected parameters.

---

# J. THRESHOLD + ENSEMBLE

Default 0.50 is NOT sacred.

Use validation data to select a threshold according to the declared project objective.
For a rainfall-warning application, F1 and recall should be considered explicitly,
but the selected objective must be documented.

Ensemble:
`P = w_DT*P_DT + w_ANN*P_ANN + w_RF*P_RF`

Weights must be selected using validation data.
Do not manually choose impressive-looking weights.

Final test is used only once for final reporting.

---

# K. METRICS

Required:
- Accuracy
- Precision
- Recall
- F1
- ROC-AUC
- PR-AUC
- confusion matrix

Recommended:
- Brier score
- calibration curve
- per-city metrics
- threshold curve

Reports must include:
- validation results
- final test results
- model comparison
- ensemble result
- split dates
- class distribution

Never compare metrics from different datasets as if they were the same experiment.

---

# L. EXPLAINABILITY

Use held-out permutation importance where supported.

UI language must say:
- "important signals"
- "features associated with the model output"
- "model-supported factors"

Do NOT say:
- "humidity caused rain"
- "the AI knows"
- "this proves rain will happen"

The model provides a probabilistic prediction, not causality.

---

# M. ARTIFACTS

Store in:
`api_model/ml_pipeline/artifacts/`

At minimum:
- one reproducible pipeline artifact per model
- ensemble configuration
- feature schema
- model metadata
- metrics

Recommended:
- `.joblib` for sklearn pipelines
- `.keras` for a genuine Keras neural network if Keras is used

Never load a model artifact created from Australia/weatherAUS data.

Each artifact must identify:
- dataset fingerprint
- model version
- training timestamp
- feature schema version
- code/version metadata
- metrics

---

# N. FASTAPI

Base:
`/api`

Endpoints:
- GET `/api/health`
- GET `/api/models`
- GET `/api/metrics`
- GET `/api/features`
- GET `/api/data/info`
- POST `/api/predict`

Routes stay thin.

Prediction service:
- loads artifacts once,
- validates input,
- performs preprocessing,
- returns model outputs,
- generates explanation data.

Prediction response must include:
- prediction
- probability
- confidence_band
- model_outputs
- ensemble_probability
- model_agreement
- top_factors
- model_version
- timestamp

No invented fallback weather values.

Use Pydantic validation.
Configure CORS with environment variables.
OpenAPI docs must work.

---

# O. FRONTEND PRODUCT

Stack:
React + Vite.

**Superseded 2026-09-17 (docs/DECISIONS.md D-017):** the section below
described the original AI-chat direction. The user then supplied an explicit
build brief and reference UI (`design inspo/ui ux.png`) asking for a
dashboard-style "weather intelligence platform," including the specific
things this section originally banned (glassmorphism, a dashboard IA). Per
the precedent in D-013 (an explicit user/build instruction overrides
`CLAUDE.md` where the two conflict), the dashboard direction shipped. This
section is kept, struck through in spirit, for history; §P and §Q below are
rewritten to describe what is actually shipped now.

~~The UI is an AI-chat interaction model, NOT a generic dashboard.~~ It is now
a dashboard: top navigation, a live map, hourly/daily forecast, charts, and a
prediction panel. The ML-facing rules elsewhere in this file (§E-§L: real
models, real metrics, no fabricated predictions/explanations) are unaffected
-- only the surrounding product shell moved.

## Product personality (current)

Target:
- dark, cinematic "weather intelligence platform"
- premium, restrained -- not a generic AI-SaaS template
- one accent color (blue), reserved for interactive/active state
- restrained glassmorphism (blur + hairline border on panels), not applied
  indiscriminately to every element

Still avoid (unchanged from the original direction):
- excessive/glowing gradients beyond the one accent
- robot/brain illustrations
- fake terminal decorations
- meaningless sparkles
- generic AI marketing copy
- decoration that isn't real data (every chart, gauge, and map layer must be
  backed by a real source -- see §Q)

If decoration can be removed without reducing understanding, remove it.

---

# P. UI STRUCTURE

**Superseded 2026-09-17 (D-017).** Current structure:

Desktop:
Sticky top nav (logo, Home / Forecast / Cities / Insights / About, one
location search, history icon)
→ page content, no persistent left sidebar.

Home: a left info column (current weather, recommendations, news/alerts) next
to a live map. Forecast: hourly strip, temperature and rain-probability
charts, 7-day outlook, then the prediction panel (composer + result -- this
IS the old "conversation," just not styled as chat bubbles: one result panel,
not a scrolling thread; prior predictions live on the History page, reachable
from the top nav's history icon rather than a sidebar tab). Cities: live
snapshot cards for the 5 trained cities. Insights / About: unchanged content,
restyled.

The result panel keeps the same information hierarchy as before: user's
input → assistant forecast → explanation → model agreement → composer for
the next prediction.

Mobile:
- collapsible nav (hamburger → full-width menu)
- stacked content, map/sidebar reflow to a single column
- no horizontal overflow

---

# Q. AI SLOPE

**Removed 2026-09-17 (D-017).** The user's build brief explicitly said "No AI
Slope." The `AISlope` component, its CSS, and its references in the
frontend, tests, and a11y audit were deleted. There is no replacement visual
metaphor -- the map, charts, and forecast panels carry the product identity
instead.

# Q2. MAP AND LIVE DATA (added 2026-09-17, D-018/D-019)

The Home page map and sidebar are real, not decorative:

- Basemap: CARTO `dark_all` tiles (free, keyless, attribution required).
- Precipitation radar: RainViewer's public API (free, keyless), real
  timestamped frames, real timeline scrubber and play/pause.
- Lightning and thunderstorm-path layers: **not implemented.** No free/keyless
  source was found. Their toggle buttons render visibly `disabled` with the
  reason in a `title` attribute, per this file's own "never fabricate ...
  API responses" rule -- they are not hidden, and they are not faked.
- Current conditions, hourly/daily forecast, AQI: Open-Meteo's forecast and
  air-quality APIs, proxied server-side through `weatherai/api/live.py`
  (10-minute cache). Display-only: never auto-submitted to `/api/predict`.
- Place search: Nominatim (OpenStreetMap), proxied server-side, rate-limited
  to ~1 request/second per its usage policy.

See `docs/API_CONTRACT.md` (`GET /api/weather/live`, `GET /api/geocode`) and
`docs/DECISIONS.md` D-018/D-019 for the full reasoning.

---

# R. FORECAST RESPONSE

The assistant result hierarchy:

1. Verdict
2. Probability
3. Uncertainty
4. Model agreement
5. Important model-supported signals
6. Technical details on demand

Example copy pattern:

"Rain is likely tomorrow."

"72% probability"

"3 of 3 models lean toward rain."

"Important signals: humidity, pressure, recent rainfall."

Do not imply certainty.

---

# S. INPUT UX

The weather input form must be generated from the actual trained feature schema.

Do not hard-code weatherAUS fields.

Group inputs:
- location/date
- temperature
- rainfall
- humidity
- pressure
- wind
- advanced observations

Only show fields required by the trained model.
Advanced fields can use progressive disclosure.

---

# T. HISTORY

Do not add a database just to look sophisticated.

Default:
- local browser history is acceptable for MVP.

If persistence is required later:
- add backend storage deliberately,
- document why,
- add migration/tests.

History should show:
- date/time
- location
- prediction
- probability
- model version

---

# U. ACCESSIBILITY

Required:
- semantic HTML
- keyboard navigation
- visible focus
- sufficient contrast
- color is not the only signal
- reduced motion
- usable at 390px width

---

# V. TESTING

Backend:
- schema tests
- preprocessing leakage test
- chronological split test
- model artifact loading test
- `/health`
- invalid `/predict`
- valid `/predict`
- unavailable-model behavior

Frontend:
- production build
- API error state
- loading state
- responsive layout
- prediction rendering

Integration:
- real frontend → API → model prediction

Acceptance test:
A clean environment can execute the complete documented workflow.

---

# W. DEPLOYMENT

Development and production are different.

Development:
- Vite dev server
- Uvicorn reload

Production:
- build frontend
- serve static assets through a proper production web server/container
- run FastAPI without reload

Docker configuration must not pretend the dev setup is production.

---

# X. FINAL AUDIT

Before declaring complete, verify:

[ ] India-only data
[ ] no Australia/weatherAUS training
[ ] source coverage verified
[ ] schema frozen
[ ] no leakage
[ ] chronological test
[ ] three models trained
[ ] ensemble validated
[ ] threshold validated
[ ] artifacts saved
[ ] API contract passes
[ ] frontend build passes
[ ] real prediction works
[ ] explanation works
[ ] AI slope implemented
[ ] no AI-slop visual patterns
[ ] mobile works
[ ] tests pass
[ ] README is accurate
[ ] limitations documented

Do not declare "perfect".
Declare "complete" only when acceptance criteria are actually verified.
