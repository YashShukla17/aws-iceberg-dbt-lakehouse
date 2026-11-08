# AWS Iceberg & dbt Data Lakehouse Pipeline

[![Python 3.12](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)
[![Apache Spark](https://img.shields.io/badge/PySpark-3.5.0-orange.svg)](https://spark.apache.org/)
[![Apache Iceberg](https://img.shields.io/badge/Apache_Iceberg-1.4.3-blue.svg)](https://iceberg.apache.org/)
[![dbt](https://img.shields.io/badge/dbt-Athena_Community-FF694B.svg)](https://www.getdbt.com/)
[![AWS](https://img.shields.io/badge/AWS-S3_%7C_Glue_%7C_Athena-232F3E.svg)](https://aws.amazon.com/)

## 📖 Project Overview
This repository contains an end-to-end modern data engineering pipeline implementing a strict **Medallion Architecture**. Designed to demonstrate scalable data processing for an enterprise data lakehouse, the pipeline extracts highly nested and unstructured multiline JSON from Amazon S3, standardizes it via PySpark into Apache Iceberg tables registered in AWS Glue, and transforms the data using dbt (data build tool) running on Amazon Athena. 

The project showcases solutions to common real-world data engineering bottlenecks, including handling OutOfMemory (OOM) errors from unsplittable file formats, normalizing nested arrays into 1-to-many bridge tables to prevent Cartesian products, and enforcing strict data contracts at the storage layer.

## 🏗️ Architecture & Workflow

```text
[Raw Data] --> [Ingestion & Flattening] --> [Storage Catalog] --> [Transformation & Analytics]

Amazon S3 (Messy JSON)
       │
       ▼
   PySpark (RDD -> DataFrame)
       │   ├─ Resolves OOM limits via custom Python JSON parsing
       │   └─ Flattens structs & explodes arrays
       ▼
Apache Iceberg + AWS Glue (Bronze & Silver Layers)
       │   ├─ V2 API: writeTo().using("iceberg").createOrReplace()
       │   └─ Separated Fact & 1-to-Many Bridge Tables
       ▼
Amazon Athena (Serverless Query Engine)
       │
       ▼
      dbt (us_recipes folder)
           ├─ Enforces unique/not_null tests via schema.yml
           ├─ Generates MD5 surrogate keys
           └─ Builds aggregated Gold / Mart models
