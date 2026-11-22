# BatteryLife AI Dataset Specifications & ETL Guide

## 1. Supported Battery Telemetry Formats

BatteryLife AI is engineered to ingest standard experimental lithium-ion battery cycling datasets from research institutions such as **NASA Ames Prognostics Center of Excellence** and the **Center for Advanced Life Cycle Engineering (CALCE)** at the University of Maryland.

| Format | Extensions | Primary Sources | Typical Attributes |
| :--- | :--- | :--- | :--- |
| **MATLAB Structures** | `.mat` | NASA Battery Data Set (B0005, B0006, etc.) | Nested cycle structs containing Voltage_measured, Current_measured, Temperature_measured, Capacity, Time |
| **Excel Spreadsheets** | `.xlsx`, `.xls` | CALCE (A123, INR18650, CS2 cells) | Tabular test records containing Step_Index, Cycle_Index, Current(A), Voltage(V), Cell_Temperature(C) |

---

## 2. Telemetry Processing & Feature Extraction

### Feature Columns
The standard tensor representation consists of sequences across 4 core features:
1. `voltage`: Terminal voltage in Volts ($V$).
2. `current`: Operating charge/discharge current in Amperes ($A$).
3. `temperature`: Surface or ambient temperature in degrees Celsius ($^\circ\text{C}$).
4. `capacity`: Cell capacity in Ampere-hours ($\text{Ah}$).

### Numerical Integration for Missing Capacity
When direct capacity measurements are absent from telemetry files, the ETL pipeline computes cumulative charge throughput via numerical integration:
$$Q(t) = \frac{1}{3600} \int_0^t |I(\tau)|\, d\tau$$
where $dt$ defaults to 1.0 second if step time is not explicitly logged.

---

## 3. Degradation Stage Parsing & Splits

The ETL processor scans file paths and headers for standard degradation indicators:
* `OCV0`, `OCV10`, `OCV20`, `OCV30`, `OCV40`, `OCV50`
* `DST-N*`, `FUDS-N*`, `US06-FUDS-N*`

### Standard Partitioning:
* **Training Stages**: Stages `0`, `10`, `20` (fresh and early-life cycles).
* **Evaluation / Test Stages**: Stages `30`, `40`, `50` (aged, knee-point, and end-of-life cycles).
* **Fallback**: If stage tags are not detected, a chronological time-series split (70% train / 30% test) is automatically applied.

---

## 4. Sliding Window Sequence Generation

To train sequential deep learning models (such as LSTM-VAE):
* Telemetry series are chunked into overlapping windows of length $L = 50$ timesteps.
* Features are normalized using either `minmax` scaling to $[0, 1]$ or `zscore` standard scaling.
* The resulting tensor shape fed to the neural network is $(N, L, D)$, where $N$ is batch size, $L=50$ is sequence length, and $D=4$ is the feature dimension.
