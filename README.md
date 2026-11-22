# BatteryLife AI

[![CI](https://github.com/nitin-code6/BatteryLife-AI/actions/workflows/ci.yml/badge.svg)](https://github.com/nitin-code6/BatteryLife-AI/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.0%2B-EE4C2C.svg)](https://pytorch.org/)
[![Next.js](https://img.shields.io/badge/Next.js-15-black.svg)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.7-3178C6.svg)](https://www.typescriptlang.org/)

**BatteryLife AI** is an intelligent, production-style platform for electric vehicle (EV) lithium-ion battery lifecycle modeling, synthetic degradation simulation, and predictive health prognostics.

By applying an **LSTM Variational Autoencoder (LSTM-VAE)** to high-dimensional battery cycle telemetry, BatteryLife AI performs unsupervised degradation representation learning, detects abnormal cell behavior, simulates realistic degradation trajectories, and estimates State of Health (SOH) and Remaining Useful Life (RUL).

---

## Key Capabilities

* 🔋 **Battery Cycle Ingestion (ETL)**: Automatically parses NASA (`.mat`) and CALCE (`.xlsx`, `.xls`) test files, extracts voltage, current, temperature, and capacity, and handles missing capacity values via numerical integration ($Q = \int |I|\,dt$).
* 🧠 **LSTM-VAE Neural Modeling**: Encodes multi-dimensional time series into a continuous latent space representing physical aging states.
* 📈 **Synthetic Degradation Generation**: Generates synthetic degradation trajectories and interpolates between health stages with temperature conditioning.
* 🚨 **Multi-Metric Anomaly Detection**: Identifies failing and degraded battery cells using a hybrid score combining reconstruction mean squared error with latent Mahalanobis/Euclidean distance.
* 📊 **Latent Space & Drift Analysis**: Explores aging dynamics using PCA and t-SNE dimensionality reduction, tracking distribution drift across operational cycles.
* 📋 **Health Reports & Risk Stratification**: Produces diagnostic health reports with SOH estimation, remaining cycle life, risk categorization, and preventive maintenance actions.

---

## System Architecture

```text
BatteryLife AI Architecture
┌────────────────────────────────────────────────────────┐
│               Frontend (Next.js 15 + React 19)         │
│  - Training Monitor   - Latent Space Visualizer        │
│  - Data Explorer      - Battery Health Diagnostic Card │
│  - Anomaly Inspector  - Scenario Simulator             │
└──────────────────────────┬─────────────────────────────┘
                           │ REST (HTTP/JSON)
┌──────────────────────────▼─────────────────────────────┐
│           Backend Gateway (Express + TypeScript)       │
│  - JWT Authentication     - Experiment Tracking        │
│  - Dataset Ingestion      - Model Registry             │
│  - Persistence Layer: MongoDB                          │
└──────────────────────────┬─────────────────────────────┘
                           │ Internal REST Proxy
┌──────────────────────────▼─────────────────────────────┐
│             AI Engine (FastAPI + PyTorch)              │
│  - Automated ETL & Sliding Window Pipeline             │
│  - LSTM-VAE Encoder / Reparameterization / Decoder     │
│  - Anomaly Scoring (Reconstruction + Latent Drift)     │
│  - Health Prognostics & Maintenance Recommendations    │
└────────────────────────────────────────────────────────┘
```

Detailed architectural diagrams and data flows are documented in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Repository Structure

```text
BatteryLife-AI/
├── ai-service/                # Deep learning service (FastAPI + PyTorch)
│   ├── app/                   # Core application logic
│   │   ├── config.py          # Service settings and artifact paths
│   │   ├── etl.py             # Telemetry parsing, integration, and windowing
│   │   ├── model.py           # LSTM-VAE neural architecture & loss
│   │   ├── trainer.py         # Model training loop & progress state
│   │   ├── insights.py        # SOH, RUL, and health diagnostic engine
│   │   ├── schemas.py         # Pydantic request/response schemas
│   │   └── main.py            # FastAPI application endpoints
│   ├── requirements.txt       # Python dependencies
│   └── .env.example           # AI service environment template
├── backend/                   # Backend API Gateway (Express + TypeScript)
│   ├── src/                   # Source files
│   │   ├── config.ts          # Environment variables & DB settings
│   │   ├── middleware/        # JWT authentication middleware
│   │   ├── models/            # Mongoose schemas (User, Dataset, Model, etc.)
│   │   ├── routes/            # REST API route handlers
│   │   ├── services/          # HTTP client for AI engine integration
│   │   └── index.ts           # Application bootstrap and server entry
│   ├── package.json           # Node.js dependencies
│   └── .env.example           # Backend environment template
├── frontend/                  # Modern web dashboard (Next.js 15)
│   ├── app/                   # Next.js App Router pages
│   │   ├── dashboard/         # Main analytics overview
│   │   ├── data-explorer/     # Telemetry exploration interface
│   │   ├── generative-analysis/# Latent space & trajectory explorer
│   │   ├── anomaly-detection/ # Anomaly inspection interface
│   │   ├── battery-report/    # Comprehensive diagnostic report view
│   │   ├── scenario-simulator/# What-if scenario simulation
│   │   └── experiment-comparison/# Experiment tracking and comparison
│   ├── components/            # Reusable UI components & charts
│   ├── package.json           # Frontend dependencies
│   └── .env.example           # Frontend environment template
├── docs/                      # Technical documentation
│   ├── ARCHITECTURE.md        # Comprehensive system design
│   ├── API.md                 # REST API reference
│   └── DATASETS.md            # Battery datasets and ETL processing guide
├── .github/workflows/         # Continuous integration workflows
│   └── ci.yml                 # TypeScript compilation and CI checks
└── scripts/                   # Local run and helper scripts
```

---

## Quickstart & Local Setup

### Option A: Run with Docker Compose (Recommended - Single Command)

Ensure [Docker](https://www.docker.com/) is installed and running, then start the entire multi-service stack with a single command:

```bash
docker-compose up --build
```

This will automatically spin up:
1. `batterylife-mongo` (MongoDB 7 database on port `27017`)
2. `batterylife-ai-service` (FastAPI + PyTorch engine on port `8000`)
3. `batterylife-backend` (Express Gateway on port `4000`)
4. `batterylife-frontend` (Next.js 15 UI on port `3000`)

To run in detached/background mode:
```bash
docker-compose up -d --build
```

To view logs or stop services:
```bash
docker-compose logs -f
docker-compose down
```

---

### Option B: Manual Local Setup (Without Docker)

#### Prerequisites
* **Node.js** (v20+ recommended) and **npm**
* **Python** (v3.10+ recommended)
* **MongoDB** instance running locally on `mongodb://localhost:27017`

### 1. Clone the Repository
```bash
git clone https://github.com/nitin-code6/BatteryLife-AI.git
cd BatteryLife-AI
```

### 2. Environment Setup
Copy the example environment configurations:
```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
cp ai-service/.env.example ai-service/.env
```

### 3. Install Dependencies
```bash
# Root and Node services
npm install
npm run install:all

# AI service Python dependencies (in your active virtual environment)
pip install -r ai-service/requirements.txt
```

### 4. Run the Platform
You can run all services concurrently using:
```bash
npm run dev:all
```

Or start each service independently in separate terminal sessions:

* **AI Service (Port 8000)**:
  ```bash
  npm run ai:dev
  ```
* **Backend API Gateway (Port 4000)**:
  ```bash
  npm run backend:dev
  ```
* **Frontend Web Dashboard (Port 3000)**:
  ```bash
  npm run frontend:dev
  ```

### Service Access URLs
* **Frontend Dashboard**: [http://localhost:3000](http://localhost:3000)
* **Backend Gateway**: [http://localhost:4000](http://localhost:4000)
* **AI Service Docs**: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## API Summary

Refer to [docs/API.md](docs/API.md) for full endpoint specifications.

* `POST /train` — Ingests battery datasets, creates sliding sequences, and trains the LSTM-VAE.
* `POST /generate` — Generates synthetic battery degradation sequences from latent space.
* `POST /detect` — Computes reconstruction and latent distance anomaly scores.
* `POST /latent` — Projections using PCA and t-SNE for degradation stage visualization.
* `POST /interpolate` — Simulates smooth transitions across progressive battery degradation stages.
* `POST /health` — Generates State of Health (SOH), cycle prognosis, and maintenance recommendations.

---

## Documentation
* [Architecture Guide](docs/ARCHITECTURE.md)
* [API Reference](docs/API.md)
* [Dataset & ETL Specifications](docs/DATASETS.md)
* [LSTM-VAE Error Validations](LSTM_VAE_ERROR_FIXES.md)

---

## License
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
