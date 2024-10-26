
# Analytics Engineer Case Study at Superside

This repository contains the codebase for processing and cleaning datasets for a take-home assignment as part of the Analytics Engineer role application at Superside.

## Project Overview
This project leverages `duckdb` to store and manage data and utilizes `dbt` (Data Build Tool) to streamline data transformation and testing. Follow the instructions below to set up, clean, and document the data pipeline.

## Getting Started

### 1. Import Data
First, load the source data into the database by running the following command:

```python
python import_data.py
```

### 2. Run Cleaning Pipelines
Navigate to the `dbt_project` directory and use `dbt` to seed and build the data models:

```bash
cd dbt_project
dbt seed
dbt build
```

### 3. Run Tests
Execute the tests to validate the data models:

```bash
dbt test
```

### 4. Generate and Serve Documentation
To generate and view detailed documentation for each model, use:

```bash
dbt docs generate
dbt docs serve
```

This will start a server to interactively browse the project documentation, including data lineage, model descriptions, and dependencies.
