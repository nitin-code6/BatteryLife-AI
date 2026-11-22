# BatteryLife AI System Architecture

## 1. High-Level Architecture Overview

BatteryLife AI employs a decoupled, production-style multi-service architecture designed for industrial EV battery diagnostics, simulation, and predictive maintenance.

```mermaid
flowchart TD
    subgraph UI ["Client Layer (Next.js 15 + React 19)"]
        Dashboard["Analytics Dashboard"]
        Explorer["Data Explorer"]
        Generative["Generative & Latent Explorer"]
        Anomaly["Anomaly Detection Panel"]
        Report["Battery Health Reports"]
        Simulator["Scenario Simulator"]
    end

    subgraph BackendGateway ["API Gateway & Orchestrator (Express + TypeScript)"]
        AuthMiddleware["JWT Authentication"]
        DatasetRouter["Dataset Ingestion Router"]
        ModelRouter["Model Orchestration Router"]
        AnalysisRouter["Analysis & Reporting Router"]
        DB[(MongoDB Persistence)]
    end

    subgraph AIService ["Deep Learning Engine (FastAPI + PyTorch)"]
        ETLPipeline["ETL & Signal Processor"]
        VAE["LSTM-VAE Neural Engine"]
        AnomalyEngine["Reconstruction + Latent Scoring"]
        HealthEngine["SOH & RUL Prognostics"]
        Artifacts["Model Registry & Scalers"]
    end

    subgraph DataSources ["Battery Telemetry Sources"]
        NASA["NASA Battery Prognostics (.mat)"]
        CALCE["CALCE Battery Aging (.xlsx, .xls)"]
    end

    DataSources --> DatasetRouter
    UI <--> |REST JSON / CORS| BackendGateway
    BackendGateway <--> |Mongoose ODM| DB
    BackendGateway <--> |Internal REST Proxy| AIService
    DatasetRouter --> |Forward Raw Files| ETLPipeline
    ETLPipeline --> VAE
    VAE --> AnomalyEngine
    VAE --> HealthEngine
    VAE --> Artifacts
```

---

## 2. Component Breakdown

### 2.1 AI Engine (`ai-service`)
* **Framework**: FastAPI (Python 3.10+) with PyTorch, NumPy, SciPy, and Scikit-learn.
* **ETL Pipeline**:
  - Ingests `.mat` (MATLAB) files and `.xlsx`/`.xls` (Excel spreadsheets).
  - Automatically identifies telemetry features: `voltage`, `current`, `temperature`, `capacity`.
  - Computes cumulative charge throughput via numerical integration ($Q = \frac{1}{3600}\int |I| dt$) if capacity measurements are absent.
  - Groups cycles by degradation stages (default: training on stages `0, 10, 20`; evaluation on `30, 40, 50`).
  - Generates sliding time windows of length $L=50$.
* **LSTM-VAE Neural Network**:
  - **Encoder**: LSTM network projecting sequence inputs into mean ($\mu$) and log-variance ($\log\sigma^2$) parameters.
  - **Reparameterization Trick**: $z = \mu + \epsilon \odot \sigma$ where $\epsilon \sim \mathcal{N}(0, I)$.
  - **Decoder**: LSTM network reconstructing sequence data from the latent vector $z$.
* **Diagnostic & Anomaly Scoring**:
  - Reconstruction Mean Squared Error: $\|x - \hat{x}\|_2^2$
  - Latent Mahalanobis / Euclidean distance: $\|\mu\|_2$
  - Combined anomaly scoring for early fault warning.

### 2.2 Backend Gateway (`backend`)
* **Framework**: Node.js, Express, TypeScript, Mongoose.
* **Responsibilities**:
  - User authentication and role-based access control via JWT.
  - Dataset metadata storage and file persistence.
  - Experiment tracking (`experiments` collection in MongoDB).
  - Model registry (`models` collection in MongoDB) tracking model versions and evaluation metrics.
  - Long-polling proxy to the AI Service for model training and simulation requests.

### 2.3 Frontend Dashboard (`frontend`)
* **Framework**: Next.js 15 (App Router), React 19, Tailwind CSS.
* **Capabilities**:
  - **Live Training Progress**: Real-time visualization of training epochs, loss convergence, and validation stats.
  - **Data Explorer**: Visual inspection of voltage, current, and temperature time-series curves.
  - **Generative Analysis**: Interactive PCA and t-SNE 2D/3D projections of the latent battery space.
  - **Scenario Simulation**: Temperature-conditioned degradation simulation under various thermal environments.
  - **Health Reports**: Comprehensive diagnostic reports indicating State of Health (SOH), estimated remaining cycles, risk stratification, and preventive maintenance actions.
