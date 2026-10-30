# Analyseunterstützung

This repository provides example scripts for researchers working with data from Data Integration Centers (DICs).

## Repository structure

- **`example_data/`**: CSV files containing test data generated from FHIR test resources and processed using the same pipeline as real data at the DICs.
- **`preprocessing/R/`**: R scripts for common data preprocessing tasks.
- **`preprocessing/Python/`**: Python scripts for common data preprocessing tasks.

The preprocessing scripts demonstrate typical steps such as removing unnecessary rows and columns, handling duplicate records, and joining datasets.

The example data can be used to test and adapt the scripts before applying them to real DIC data.