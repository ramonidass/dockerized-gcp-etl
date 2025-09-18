# Field Service Management (FSM) Cloud Data Pipeline

## Project Overview

This project implements a **cloud-native data infrastructure** for a Field Service Management (FSM) system,
designed to support efficient **allocation of skilled engineers** for repairs and maintenance tasks across a telecommunications network.

---

## Key Features

- **Automated Ingestion**: New files are picked up hourly via GCS and ingested automatically.
- **Schema Validation**: Each record is validated using **Pydantic** to ensure data quality before ingestion.
- **Containerized ETL**: A Dockerized Python application processes the data and loads it into BigQuery.
- **SQL-Based Access**: Data is available to analysts through **Google BigQuery** for SQL queries.
- **Infrastructure-as-Code**: All infrastructure is managed with **Terraform**, including GCS, Cloud Run, BigQuery, etc.
- **Idempotent & Fault-Tolerant**: The system avoids duplicates and handles partial failures.

---

## Architecture

```
Cloud Storage (GCS)
│
▼ (New file uploaded every hour)

Cloud Function Trigger (Event-based)
│
▼ (Calls HTTP endpoint with file info)

Cloud Run (Python Docker App: ETL pipeline)
│
▼
BigQuery (Structured, queryable data layer)
```

## Setup Instructions


