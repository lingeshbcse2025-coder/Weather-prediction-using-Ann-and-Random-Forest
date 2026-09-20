# CONTEXTGPT.md — WeatherAI India, full current-state briefing

**Purpose of this file:** a single up-to-date document describing exactly what this
project is, how it's built, and where it stands right now, written so an external
reviewer (e.g. ChatGPT, or any other LLM/human) can read it cold and give useful,
grounded suggestions on functionality and UI/UX — without re-deriving the
architecture from the code or repeating decisions that were already made and
reasoned through. Last updated: **2026-09-20**, generated after the D-039 commit.

If you (the reader) are being asked to improve this app, read this whole file
first. It tells you what's real, what's intentionally faked-looking-but-isn't,
what's still incomplete, and what ground rules any suggestion has to respect.

---

## 1. What this app is

**WeatherAI India** — a rainfall-prediction web app for Indian cities. A user
picks a city and date, the app shows a next-day rain probability from a real
trained ML model (not a hardcoded rule, not an LLM guess), plus live conditions,
a 7-day forecast, historical trends, air quality, an interactive weather map, and
a conversational assistant that can answer plain-language questions about the
prediction.

**The one rule that overrides every other decision in this codebase: never
fabricate data.** Every number shown anywhere in the UI is either (a) real output
from the trained ML model, (b) a real value from a live third-party API
(Open-Meteo, Nominatim, GDACS), or (c) a real number from the training dataset
(a climatological "typical value"). When a feature can't be backed by real data —
no free API exists, no key is configured, a date is outside a forecast horizon —
the app says so honestly instead of inventing a plausible-looking number. This
pattern recurs everywhere and is called **honest degradation** throughout
`docs/DECISIONS.md`. Any suggested improvement that would fake data to make a
screen look more complete will be rejected — propose the honest version instead
(a clearly labeled "unavailable" state, a fallback to a real-but-less-precise
number, etc.).

---

## 2. Tech stack

**Backend:** Python 3.11+, FastAPI, Pydantic v2, scikit-learn, pandas, numpy,
httpx (outbound HTTP to third-party APIs), uvicorn. No database — the trained
model artifacts are files on disk (`artifacts/<version>/*.joblib` +
`metadata.json`), and the training dataset is a CSV
(`data/processed/canonical.csv`).

**Frontend:** React 19 + TypeScript, Vite 8, CSS Modules (no CSS framework,
no Tailwind). Leaflet.js for the map. `suncalc` for sun/moon calculations.
No global state library — a handful of hooks/context in `frontend/src/state/`.
No test runner configured for the frontend beyond `tsc -b` (type check) and
`oxlint` (lint); there is an `a11y` audit script
(`frontend/scripts/a11y-audit.mjs`, axe-core based).

**Tests:** `pytest` for the backend (`tests/`), covering data validation, ML
leakage checks, API endpoints, and acceptance criteria. Run with
`python -m pytest -q` from the repo root.

**No database, no auth, no user accounts, no payments.** This is a single
public-facing informational tool.

---

## 3. Repository layout

```
weatherai/                  Backend Python package
  api/                       FastAPI app: main.py (routes), schemas.py (Pydantic
                              models), service.py (prediction service +
                              UntrainedLocationError), agent.py (local NLU/chat),
                              ask.py (OpenAI-path NLU/chat), live.py (Open-Meteo
                              proxy: live weather, forecast-day, geocoding),
                              historical.py, maplayers.py, newsalerts.py,
                              stations.py, settings.py
  data/                       canonical.py (LOCATIONS registry + schema),
                              ingest.py, build.py, validate.py
  features/                   feature engineering for the ML pipeline
  ml/                         train.py, models.py, evaluate.py, ensemble.py,
                              split.py, registry.py (loads artifacts)
frontend/src/
  pages/                      HomePage, ForecastPage, CitiesPage,
                              ModelInsightsPage, HistoryPage, AboutPage
  components/                 ~25 components (map, cards, chat, form, charts)
  api/                        client.ts (typed fetch wrapper), types.ts
  state/                      activeLocation.ts, useLiveWeather.ts
  lib/                        time.ts (IST timestamp helpers)
  styles/                     design-tokens.css (spacing/color/radius scale)
artifacts/<version>/         trained model files + metadata.json + metrics.json
data/processed/canonical.csv The full training dataset (see §6)
docs/                         Spec + decision-log documents (see §8)
tests/                        pytest suite (api/, data/, ml/)
```

---

## 4. Core features (what a user can actually do)

### Home page
- A Windy.com-*style* (not a copy — own visual identity, explicitly required by
  the project owner) interactive Leaflet map: multiple independently-toggleable
  overlay layers (temperature, wind, clouds, precipitation/lightning), a
  real 24-hour timeline scrubber (1-hour steps, real forecast data per step,
  not synthetic), click-to-pin anywhere (reverse-geocodes via Nominatim),
  station markers with real readings, and screen-space label decluttering so
  city names don't overlap.
- News & alerts panel: real disaster alerts from GDACS (free, keyless);
  general news requires a `NEWS_API_KEY` (unset by default — the panel says so
  honestly rather than showing nothing or fake headlines).
- Today's recommendations (umbrella, outdoor activity, clothing, air quality) —
  threshold rules evaluated against real live/forecast numbers, not invented
  advice text.

### Forecast page
- Live current conditions, 24h hourly strip, 24h temperature chart, 7-day
  rain-probability chart, 7-day outlook list, air quality, sun/moon times —
  all real Open-Meteo data for whatever city/point is active.
- Historical trends chart (only for the ML-trained cities — built from the
  actual training data, not live data).
- **Ask WeatherAI** — a real chatbot (see §7).
- **Prediction composer** — pick a city + date:
  - **Today:** manual observation form (temp, rainfall, humidity, pressure,
    wind at 9am/3pm), with "Fill from live weather" (today's real Open-Meteo
    reading) or "Fill typical values" (climatological average from training
    data) helpers, then a "Predict" button.
  - **Future date:** collapses to just city + date + one "Predict" button
    (D-039) — fetches the real Open-Meteo forecast for that exact date and
    predicts from it directly, no manual fields. Falls back to typical
    values automatically (still one click) only if the date is beyond
    Open-Meteo's ~16-day forecast horizon, with an honest inline note when
    that fallback fires.
  - **Past date:** collapses to city + date + "Show actual weather" — fetches
    the real recorded observation for that exact day instead of running a
    probabilistic prediction against an already-known outcome (D-035).
  - The prediction result shows: verdict + probability, confidence band,
    per-model agreement (how many of the ensemble's member models agree),
    and the top real feature-importance factors that drove the number.

### Cities page
Lists every ML-trained city (currently 5; see §6 for the pending expansion to
39) with per-city stats.

### Model Insights page
Real model metrics: validation/test PR-AUC, ROC-AUC, per-location performance,
calibration table, permutation feature importance — all read directly from
`artifacts/<version>/metrics.json`, nothing summarized or rounded misleadingly.

### About page
States the real data source, real coverage (which cities, which years), and
the real methodology, including the honest caveats (gridded reanalysis data,
not station observations; five/thirty-nine cities, not nationwide).

---

## 5. API surface (FastAPI, all under `/api`)

| Endpoint | Purpose |
|---|---|
| `GET /api/health` | liveness |
| `GET /api/models`, `/api/metrics`, `/api/features` | model metadata, metrics, input schema (incl. typical values) |
| `GET /api/data/info` | dataset provenance/coverage statement |
| `POST /api/predict` | run the real trained model on given observations |
| `GET /api/weather/live` | live conditions + 24h hourly + 7-day daily, by city or lat/lon |
| `GET /api/weather/forecast-day` | real forecast for one specific future date (D-038) |
| `GET /api/geocode`, `/api/geocode/reverse` | Nominatim-backed place search |
| `GET /api/historical`, `/api/historical/day` | real training-data trends / one real recorded day |
| `GET /api/map/layers`, `/api/map/stations` | map overlay metadata, station readings |
| `GET /api/news` | GDACS alerts + optional NewsAPI headlines |
| `POST /api/ask` | the chatbot (see §7) |

Every endpoint that can fail honestly returns a real HTTP error status (422 for
bad/untrained input, 404 for "genuinely doesn't exist yet", 503 for upstream
API failure) with a real explanatory message — never a 200 with silently wrong
or fabricated data.

---

## 6. Data and ML pipeline

**Data source:** Open-Meteo's ERA5-based archive API (gridded reanalysis, not
raw IMD station observations — this distinction is stated honestly in the UI).
Free, keyless, real. `data/processed/canonical.csv` currently holds **152,343
rows across 39 cities** (the original 5 metros — Mumbai, New Delhi, Kolkata,
Chennai, Bangalore — plus 34 more Tamil Nadu cities added in a later expansion),
**2016-01-01 through 2026-09-11**.

**A prior Kaggle dataset was evaluated and explicitly rejected** (found to be
synthetic: future dates, physically impossible values, an internally
inconsistent target) — see `docs/DECISIONS.md` D-010/D-011. This is a real
audit finding, not a hypothetical; don't suggest re-adding that source.

**Models:** climatology baseline, logistic regression, random forest, MLP
(neural net), evaluated as an ensemble candidate too. Chronological train /
validation / test split (never random — this is a time series, and the
pipeline has an explicit leakage test, `tests/ml/test_leakage.py`, that fails
loudly if preprocessing was ever fit on data outside the correct slice).
Threshold selection and model choice happen on the validation slice only; the
test slice is read exactly once, at the end, for reporting.

**Current model status (as of this file's timestamp):**
- **Shipped/production (`weatherai-india-1.0.0`):** MLP, trained on the
  original 5 metro cities only. This is what `/api/predict` currently serves.
- **In progress (`weatherai-india-2.0.0`):** a retrain on the full 39-city
  dataset above, explicitly requested by the project owner and running as a
  background job at the time of this writing. Until it completes and the
  backend is restarted onto it, `/api/predict` and `/api/ask` will 422 with
  `UntrainedLocationError` for any of the 34 newer Tamil Nadu cities (this is
  correct, honest behavior, not a bug — those cities are listed for
  map/display purposes via `weatherai/data/canonical.py`'s `LOCATIONS`
  registry, which is intentionally broader than whatever set the *shipped
  model* was actually trained on; the real trained set always lives in that
  model's own `metadata.json["dataset"]["locations"]`, and the API checks
  against that, not the broader registry).
- `tests/ml/test_leakage.py::test_shipped_preprocessing_was_fitted_on_train_plus_validation_only`
  is the one known/expected failing test right now, because the shipped
  artifact (v1.0.0) predates the 39-city dataset it's being checked against.
  This will resolve itself once the v2.0.0 retrain finishes and the backend
  points at it. If you see this exact failure, it is not a new bug.

**A known, deliberately-guarded footgun:** scikit-learn's
`OneHotEncoder(handle_unknown="ignore")` silently encodes an unseen category
(e.g. an untrained city) as all-zero, which would otherwise produce a
plausible-looking but meaningless prediction with no error. This is explicitly
guarded against (`UntrainedLocationError`, checked against the *trained* set,
not the display registry) — do not suggest relaxing that check.

---

## 7. The chatbot ("Ask WeatherAI")

Fully local by default (`weatherai/api/agent.py`): a real trained TF-IDF
character-n-gram + logistic-regression intent classifier (not keyword
matching, not an LLM) picks one of: `rain_prediction`, `umbrella_or_outdoor`,
`general_conditions`, `trend`, `small_talk`, `other`. The first four run the
real grounded prediction pipeline and phrase the answer with a template that
actually matches the question shape (an umbrella question gets a direct
recommendation, not a rain-percentage paragraph reworded). `small_talk`
(greetings, thanks, farewells) and `other` (meta questions, unclear text) are
answered with honest canned replies **without ever touching city resolution or
the prediction pipeline** — this was a real bug fix (D-038): a plain "hi"
used to force-resolve the app's active map location and 422 if that location
wasn't a trained city.

If the server has `OPENAI_API_KEY` configured, an equivalent OpenAI-backed
path (`weatherai/api/ask.py`) takes over for freer-form phrasing — its system
prompt is hard-restricted to only using numbers already present in the
grounding data it's given; it is never allowed to compute or invent a
prediction itself. No key is required for the app to work; this is purely a
phrasing upgrade, same honest-degradation pattern as everything else.

The frontend renders this as a real multi-turn chat log (D-034), not a
single question-replaces-its-own-answer widget.

---

## 8. Where to find more detail / decision history

`docs/DECISIONS.md` is the authoritative, chronological decision log —
every non-obvious choice made in this project is recorded there as
Problem/Decision/Consequence, currently up to **D-039**. If you want the
full reasoning behind any behavior described in this file, that's where it
lives. Notable recent entries: D-029 (Tamil Nadu city expansion), D-030
(chatbot intent classifier + CAPE-based thunderstorm risk), D-031/D-032
(Windy-style map redesign), D-033 (click-to-pin), D-034 (chat UI), D-035
(past-date real lookup vs. future-date prediction split), D-036/D-037
(padding/UX bug fixes), D-038 (real system clock, chatbot small-talk
handling, real forecast-day fill), D-039 (future dates predict in one click).

Other docs worth knowing exist (some are historical/early-stage and not all
still 100% reflect the current UI, which has been redesigned since):
`docs/API_CONTRACT.md`, `docs/DATA_CONTRACT.md`, `docs/ML_SPECIFICATION.md`,
`docs/UI_UX_SPECIFICATION.md`, `docs/COMPONENT_SPEC.md`,
`docs/FUNCTIONALITY_AUDIT.md`. `README.md` at the repo root is also stale in
places (it still describes the original 5-city-only, "warm paper
background/AI-slope" visual identity from before the dark-theme Windy-style
redesign) — trust this file and `docs/DECISIONS.md` over `README.md` for
current UI state.

---

## 9. Design system (current, as actually shipped)

Dark theme. `frontend/src/styles/design-tokens.css` defines the spacing scale
(`--space-1` through `--space-8`: 4/8/12/16/24/32/48/64px) and color/radius/
shadow tokens used everywhere — CSS Modules per component, no inline styles,
no CSS-in-JS. Glass-panel surfaces (translucent + blur) are the dominant
card style. Custom-built form controls where the native HTML control can't be
restyled consistently (e.g. `Select.tsx`, a real listbox replacing a native
`<select>` whose open dropdown can't be reliably themed cross-browser — see
D-037).

---

## 10. Ground rules for any suggestion

If you're reviewing this project for UI/UX or functionality improvements,
please keep suggestions compatible with:

1. **No fabricated data, ever** — including no "looks-more-complete" filler,
   no fake loading-then-plausible-number, no silent fallback that hides that
   real data wasn't available.
2. **India-only scope** — see `INDIA_ONLY_DATA_POLICY.md`; do not suggest
   adding non-Indian data or reusing a non-India-trained artifact.
3. **No new paid/keyed dependency as a hard requirement** — optional
   integrations (OpenAI, a map tile provider, a news API) are fine as
   enhancements, but the app must keep working fully without any of them.
4. **Preprocessing must never be fit outside train(+validation)** — this is
   enforced by an actual test, not just a convention.
5. **The trained-city set (model) and the displayed/registry city set (map)
   are allowed to differ, and the code deliberately treats them as two
   different things** — don't suggest collapsing them into one list without
   also preserving the honest-rejection behavior for untrained cities.

Feature ideas, UI polish, new visualizations, accessibility improvements,
performance suggestions, and better copy are all welcome and don't need to
route through those five constraints — those five just describe the load-
bearing invariants that shouldn't be casually broken.
