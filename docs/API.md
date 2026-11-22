# BatteryLife AI API Reference

This document provides endpoint documentation for both the **Backend Gateway** (port 4000) and the **AI Engine** (port 8000).

---

## 1. Backend Gateway Endpoints (`http://localhost:4000`)

### Authentication
* `POST /auth/register`
  - Registers a new user account.
  - Body: `{ email, password, name? }`
  - Response: `{ token, user }`
* `POST /auth/login`
  - Authenticates user credentials.
  - Body: `{ email, password }`
  - Response: `{ token, user }`

### Datasets
* `POST /datasets/upload`
  - Uploads a raw battery data file (`.mat`, `.xls`, `.xlsx`).
  - Multipart form-data: `file`
  - Response: `{ datasetId, originalName, size, path }`
* `GET /datasets/uploaded`
  - Lists previously uploaded datasets with metadata.

### Model & Training
* `POST /model/train`
  - Initiates an LSTM-VAE model training session.
  - Body: `{ data_root, window_size, hidden_dim, latent_dim, epochs, batch_size, scaler }`
  - Response: `{ experimentId, training: { model_path, train_metrics, test_metrics } }`
* `GET /model/progress`
  - Retrieves real-time training progress (current epoch, loss, recon, kl).
* `POST /model/generate`
  - Generates synthetic degradation sequences from the latent distribution.
  - Body: `{ num_samples, temp_condition? }`
* `POST /model/detect`
  - Runs anomaly scoring against input sequences.
  - Body: `{ data_root?, threshold? }`
* `POST /model/latent`
  - Computes PCA or t-SNE dimensionality reduction for latent vectors.
  - Body: `{ method: "pca" | "tsne" }`
* `POST /model/interpolate`
  - Interpolates latent trajectories between degradation stages.
* `POST /model/drift`
  - Computes latent distribution drift across successive cycles.

### Analysis & Reports
* `POST /analysis/run`
  - Executes comprehensive battery health analysis.
* `GET /analysis/report/:id`
  - Retrieves a specific battery diagnostic and SOH report.
* `GET /analysis/compare`
  - Compares metrics across multiple experiments.

---

## 2. AI Service Endpoints (`http://localhost:8000`)

| Method | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/healthz` | AI service health check. |
| `POST` | `/train` | Runs the ETL and trains the LSTM-VAE neural model. |
| `GET` | `/training-progress` | Polls current training progress and epoch metrics. |
| `POST` | `/generate` | Generates synthetic sequence trajectories from latent priors. |
| `POST` | `/detect` | Computes reconstruction error and latent distance anomalies. |
| `POST` | `/latent` | Performs PCA/t-SNE dimensionality reduction on latent representations. |
| `POST` | `/interpolate` | Generates latent interpolation sequences between stages. |
| `POST` | `/drift` | Measures Wasserstein / Euclidean drift in latent embeddings. |
| `POST` | `/trajectory` | Computes simulated degradation trajectories over time. |
| `POST` | `/health` | Generates battery health score, remaining cycles, and risk classification. |
