# WeatherAI India — Cinematic Product-Demo Prompt (corrected for the real UI)

This is a corrected version of the original walkthrough prompt. The only change is
to **Sequence 01/02**: the original script opened on an invented "landing page"
with a hero section and a "Get Started" button. **That page does not exist.**
WeatherAI India is a single-page app (`frontend/src/App.tsx`) that opens directly
into the Home view — no marketing splash screen, no CTA button, no separate
"entering the app" transition. Everything else below (03–08) has been checked
against the live product and the screenshots in `chatgp ui ux refernce/` and is
accurate to what's actually on screen.

Reference material to hand to whatever tool/editor produces the actual video:
- `chatgp ui ux refernce/` — 14 full-page screenshots of every view
- `CONTEXTGPT.md` — full product/feature description
- `C:\Users\Lingesh\Videos\Screen Recordings\Screen Recording 2026-09-20 150607.mp4` — your reference recording

---

Create a cinematic product-demo walkthrough of my EXISTING web application, "WeatherAI India".

CRITICAL: The supplied website, screenshots, screen recording and reference video are the SOURCE OF TRUTH. Reproduce the existing interface and visual language as closely as possible. Do NOT redesign, replace, simplify, or invent another UI. This is a presentation of an existing product.

GOAL:
Make WeatherAI India feel like a serious, polished weather-intelligence platform rather than a generic student dashboard. Improve the presentation through camera movement, pacing, transitions and visual emphasis — NOT by changing the product.

VISUAL DIRECTION:
Dark cinematic navy/blue interface, refined translucent glass-panel surfaces, crisp hairline borders, subtle shadows, restrained blue accents, clean modern typography and scientific weather-visualization aesthetics. Professional, controlled and minimal. Avoid excessive gradients, neon, glowing AI effects, robots, brains, generic SaaS illustrations, or artificial "AI" imagery.

VIDEO:
16:9, 1080p, approximately 60–90 seconds. Realistic browser/product-demo presentation. Smooth cursor movement, deliberate clicks, natural scrolling, subtle camera push-ins and clean transitions. No chaotic motion. Keep important UI visible long enough to understand.

SEQUENCE:

01 — HOME / OPENING
Open directly on the real WeatherAI India Home view — top nav (WeatherAI India brand mark, Home/Forecast/Cities/Insights/About links, location search field top-right), the current-location card (city name, live date/time, temperature, condition, humidity/wind/pressure/UV), Today's Recommendations card, and the large interactive map filling the right side, with News & Alerts below the recommendations. Let it breathe for a moment — this is the platform's real front door, not a marketing splash.

02 — SEARCH / SELECT CHENNAI
Use the existing top-right location search field. Type "Chennai" and select it from the real results. Show the Home view updating to Chennai's live conditions and the map recentering — this is the natural "entry" moment, not a separate landing-page transition.

03 — HOME / WEATHER INTELLIGENCE (MAP)
With Chennai active, reveal the map's real layer-toggle buttons (temperature, wind, clouds, precipitation/lightning — small icon buttons above the map) and the 24-hour timeline scrubber along the bottom of the map (1-hour steps, a play button, real hour/temperature labels). Demonstrate ONE real interaction: either toggle a layer on, or drag/step the timeline forward and show the map's shaded overlay and station markers updating.

04 — FORECAST
Navigate via the top nav to the existing Forecast page. Show, in order: the hourly strip (Now, 4pm, 5pm... with icons/temps/rain %), the "Temperature, next 24 hours" line chart and "Rain probability, next 7 days" bar chart side by side, then the Weather details / Air quality (US AQI + PM2.5/PM10/ozone/NO2) / Sun & Moon (sunrise, sunset, day length, moon phase) card row, and the 7-day outlook list.

05 — ML PREDICTION (the centerpiece)
Still on the Forecast page, scroll to "Predict tomorrow's rainfall". Show the real prediction composer: City and Date fields, then — for a future date — the collapsed single "Predict" button (no manual fields to fill; it runs on the real Open-Meteo forecast for that date). Click Predict. Emphasize the result panel: the verdict chip ("Rain" / "No rain" + probability %), the confidence bar (Low/Medium/High, with the "how close to the decision threshold" framing), "Model agreement" (X of 4 models agree, shown as dots), and the "Important signals" list (each real feature — e.g. rainfall today, humidity at 3pm — with its bar and "raises/lowers probability" label). This is the conceptual centerpiece: linger here longer than any other screen.

06 — CITIES
Navigate to the existing Cities page. Show the real grid of Indian city cards (name, state, live icon/temp/condition — currently Mumbai, New Delhi, Kolkata, Chennai, Bangalore plus a large set of Tamil Nadu cities). Click a different city card; show it becoming the active location.

07 — MODEL INSIGHTS
Navigate to the existing Insights page. Show real evidence in sequence: the Chronological split table (train/validation/test date ranges and rain-tomorrow rates), the Model comparison (validation) table (climatology / logistic regression / decision tree / random forest / MLP with PR-AUC, ROC-AUC, F1), the Final test results stat grid for the production model, the Per-city test performance table, and the Calibration (test set) table (predicted-bin vs. observed rate). Present this as the receipts behind the prediction shown in step 05.

08 — HISTORY → HOME
Briefly show the existing History page (clock icon, top-right of the nav): a short list of past predictions with city, timestamp, model version and verdict. Then return to the Home view.

ENDING:
End on the real WeatherAI India Home screen with the map and current conditions visible. Subtle cinematic pull-back. Finish on the WeatherAI India wordmark in the top nav.

ABSOLUTE RULES:
• Never invent UI elements, pages, buttons or functionality — there is no landing page and no "Get Started" button; do not add one.
• Never fabricate weather values, predictions, charts, metrics or city data — use only what actually appears in the screen recording/screenshots.
• Never replace the existing design with a generic AI dashboard.
• Never add ChatGPT-style interfaces beyond the real "Ask WeatherAI" box if it's shown — don't invent a different chat UI.
• Never add robots, brains, AI holograms or meaningless futuristic graphics.
• Do not distort maps, charts or numerical information.
• Do not create fake readable text.
• Preserve the existing navigation and product structure (Home / Forecast / Cities / Insights / About in the top nav, History behind the clock icon).
• If a detail cannot be reproduced accurately, keep it visually neutral rather than inventing it.
• The result must feel like a REAL product walkthrough of WeatherAI India.

EMOTIONAL ARC:
Discover → Explore → Predict → Understand → Trust.

The viewer should finish understanding that WeatherAI India combines real weather data, an actual trained ML rainfall-prediction system, interactive visualization and model transparency.
