# WeatherAI India — production image.
# Multi-stage: build the frontend, install the backend, run both in a single
# container behind a tiny reverse proxy (nginx) so the browser only ever talks
# to one origin. Development does NOT use this file (see docker-compose.yml
# and docs/DEPLOYMENT_SPEC.md); dev runs Vite's dev server + `uvicorn --reload`
# directly on the host.

# ---- Stage 1: frontend build --------------------------------------------------
FROM node:22-slim AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm install
COPY frontend/ ./
# Same-origin in production: nginx proxies /api to the backend container, so
# the frontend calls relative /api/* paths (VITE_API_BASE_URL left empty).
RUN npm run build

# ---- Stage 2: backend runtime -------------------------------------------------
FROM python:3.12-slim AS backend
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY weatherai/ ./weatherai/
COPY pyproject.toml ./
RUN pip install --no-cache-dir --no-deps -e .
# Data and trained artifacts are produced by the pipeline, not baked from a
# stale image layer; mount or copy them in at build/deploy time.
COPY data/processed/ ./data/processed/
COPY artifacts/ ./artifacts/

EXPOSE 8000
CMD ["uvicorn", "weatherai.api.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]

# ---- Stage 3: nginx serving the built frontend + proxying /api ---------------
FROM nginx:1.27-alpine AS frontend
COPY --from=frontend-build /app/frontend/dist /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
