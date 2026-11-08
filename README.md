```markdown
# AWS Iceberg & dbt Data Lakehouse Pipeline

[![Python 3.12](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)
[![Apache Spark](https://img.shields.io/badge/PySpark-3.5.0-orange.svg)](https://spark.apache.org/)
[![Apache Iceberg](https://img.shields.io/badge/Apache_Iceberg-1.4.3-blue.svg)](https://iceberg.apache.org/)
[![dbt](https://img.shields.io/badge/dbt-Athena_Community-FF694B.svg)](https://www.getdbt.com/)
[![AWS](https://img.shields.io/badge/AWS-S3_%7C_Glue_%7C_Athena-232F3E.svg)](https://aws.amazon.com/)

## 📖 Project Overview
This repository contains an end-to-end modern data engineering pipeline implementing a strict **Medallion Architecture**[cite: 4]. Designed to demonstrate scalable data processing for an enterprise data lakehouse, the pipeline extracts highly nested and unstructured multiline JSON from Amazon S3, standardizes it via PySpark into Apache Iceberg tables registered in AWS Glue, and transforms the data using dbt (data build tool) running on Amazon Athena[cite: 4, 6]. 

The project showcases solutions to common real-world data engineering bottlenecks, including handling OutOfMemory (OOM) errors from unsplittable file formats, normalizing nested arrays into 1-to-many bridge tables to prevent Cartesian products, and enforcing strict data contracts at the storage layer[cite: 4].

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

```

### Tech Stack

* **Data Processing:** PySpark 3.5.0 (Dockerized environment to manage exact Hadoop-AWS dependencies).


* **Storage & Table Format:** Amazon S3 & Apache Iceberg (ACID compliance, snapshot history, and time-travel querying).


* **Metastore:** AWS Glue Data Catalog.


* **Transformations & Data Quality:** dbt (Data Build Tool) via the `dbt-athena-community` adapter.


* **Compute Engine:** Amazon Athena (Serverless distributed SQL).


* **CI/CD Orchestration:** GitHub Actions (Automating PySpark jobs and `dbt build` sequences).



## 📂 Repository Structure

```text
├── us_recipes/                  # dbt project directory
│   ├── models/
│   │   ├── sources.yml          # External data contract pointing to AWS Glue Bronze/Silver tables
│   │   ├── schema.yml           # Data quality tests (unique, not_null) and documentation
│   │   ├── silver/              # ELT models for cleansing and surrogate key generation
│   │   └── gold/                # Aggregated mart models (e.g., cuisine statistics)
│   ├── dbt_project.yml          # Core dbt configuration and materialization rules
│   └── profiles.yml             # Athena connection settings and S3 staging paths
├── pyspark_ingestion/           # Python scripts for PySpark extraction and flattening
│   ├── 01_s3_to_dataframe.py    # Custom RDD-based JSON parsing logic to bypass OOM
│   ├── 02_flatten_normalize.py  # Struct flattening and array explosion logic
│   └── 03_write_to_iceberg.py   # Spark 3 V2 writeTo() API to register tables in AWS Glue
└── .github/workflows/           # GitHub Actions CI/CD pipeline configuration

```

## 🧠 Key Engineering Challenges Solved

**1. Bypassing PySpark OOM Crashes on Complex JSON**

* *Problem:* A 13MB JSON file crashed an 8GB PySpark JVM because it was structured as a single massive dictionary with dynamic numeric keys (e.g., `"0": {...}, "1": {...}`), forcing Spark's default reader to build an unmanageable syntax tree.


* *Solution:* Bypassed the native `spark.read.json()` method. Used PySpark RDDs (`wholeTextFiles`) and Python's native `json` library to extract the text, strip the dynamic keys, and parallelize the clean records back into a scalable DataFrame.



**2. Enforcing Relational Normalization on Nested Arrays**

* *Problem:* The raw JSON contained nested `nutrients` structs and multi-item `ingredients` and `instructions` arrays. Expanding them natively creates a massive Cartesian product that ruins downstream BI aggregations.


* *Solution:* Used PySpark's `.drop()` and `explode()` functions to split the data into a core Fact table and dedicated 1-to-many bridge tables directly in the Silver layer, writing them independently to Iceberg.



**3. AWS Glue Catalog Integration via V2 API**

* *Problem:* V1 Iceberg `.save()` commands threw `TABLE_OR_VIEW_NOT_FOUND` exceptions when trying to dynamically create tables in AWS Glue.


* *Solution:* Transitioned to the Spark 3 V2 API (`writeTo("glue_catalog.database.table").using("iceberg").createOrReplace()`), which natively handles both the creation of the Glue metastore schema and the physical Parquet data write in one atomic transaction.



**4. Separation of Compute and Storage via dbt + Athena**

* *Problem:* dbt cannot interact directly with Iceberg files in S3.


* *Solution:* Configured the `dbt-athena-community` adapter. Athena acts as the serverless compute layer, reading the Glue catalog and writing query results to a dedicated S3 staging bucket (`s3_staging_dir`), while dbt materializes the final Gold analytical models back into the Iceberg warehouse (`s3_data_dir`).



## 🚀 Getting Started

1. **Clone the Repository**
```bash
git clone [https://github.com/YashShukla17/aws-iceberg-dbt-lakehouse.git](https://github.com/YashShukla17/aws-iceberg-dbt-lakehouse.git)
cd aws-iceberg-dbt-lakehouse

```


2. **Configure AWS Credentials**
Ensure your `~/.aws/credentials` file is configured with an IAM user that has access to S3 and AWS Glue.


3. **Execute the PySpark Ingestion**
Run the scripts in `pyspark_ingestion/` to extract the raw S3 JSON, normalize it, and register the Bronze and Silver tables in AWS Glue.
4. **Run dbt Transformations**
Navigate to the dbt project folder and run the pipeline:
```bash
cd us_recipes
dbt deps --profiles-dir .
dbt build --profiles-dir .

```



```

```
