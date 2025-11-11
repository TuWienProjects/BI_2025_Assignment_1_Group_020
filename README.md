# 🌍 Air Quality Monitoring Data Warehouse

### A Business Intelligence Case Study — Designed and Implemented

---

## 📘 Overview

This project presents a complete **end-to-end Business Intelligence (BI) and Data Warehousing solution** designed for an **International Air Quality Monitoring Agency**.
The goal was to transform large-scale sensor and maintenance data from an operational system (OLTP) into a **decision-support data mart** using dimensional modeling and a robust SQL-based ETL pipeline.

The result is a **fully functional, validated Star Schema** that enables environmental, operational, and campaign-based insights across multiple geographies and time periods.

---

## 🧭 Business Context

The agency monitors air quality across **36 cities in 20 countries**, collecting:

* Sensor readings for pollutants (e.g., PM10, NO₂)
* Weather and environmental metrics
* Service and technician performance records
* Campaign-based initiatives (e.g., “Clean Air 2023”)

Challenges included:

* Integrating heterogeneous data sources
* Capturing historical technician role changes
* Linking environmental metrics with campaign activities
* Enabling reliable analytics and trend visualization

The proposed BI solution delivers actionable intelligence to:

* Policy and environmental analysts
* Operations managers and engineering leads
* Public-sector decision-makers

---

## 🎯 Objectives

1. Design a **dimensional data model** for environmental and operational analysis.
2. Develop a **SQL-first ETL pipeline** transforming data from OLTP to OLAP.
3. Integrate campaign-level business context for cross-domain insights.
4. Ensure **referential integrity**, **historical tracking**, and **auditability**.
5. Deliver a clear, analytical data mart ready for reporting and visualization tools.

---

## 🏗️ Architecture Overview

The solution follows a **modular three-tier architecture**:

| Layer                                    | Description                                                         |
| ---------------------------------------- | ------------------------------------------------------------------- |
| **Staging Area (stg_020)**               | Receives and harmonizes raw CSV data from the operational snapshot. |
| **Data Warehouse (dwh_020)**             | Implements a star schema optimized for analytical queries.          |
| **Orchestration Layer (Python/Jupyter)** | Coordinates ETL execution, validation, and provenance tracking.     |

All transformations are SQL-driven and executed directly on the PostgreSQL engine via Python’s SQLAlchemy interface.

---

## ⚙️ Technical Stack

| Component                     | Description                                     |
| ----------------------------- | ----------------------------------------------- |
| **Database Server**           | PostgreSQL 17.6 (64-bit)                        |
| **SQL IDE**                   | DBeaver Community Edition                       |
| **Orchestration Environment** | Python 3 (Anaconda, Jupyter Lab)                |
| **ETL Framework**             | SQL-first approach using SQLAlchemy             |
| **Schema Type**               | Star Schema (ROLAP)                             |
| **Validation & Provenance**   | SQL integrity checks + PROV-O (JSON-LD) lineage |

---

## 🧩 Data Model

### **1. Fact Tables**

| Table          | Description                                                  | Key Measures                                                                           | Business Focus                                    |
| -------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------- | ------------------------------------------------- |
| **ft_reading** | Captures daily pollutant readings from sensors across cities | `recorded_value`, `data_volume_mb`, `data_quality_score`, `exceedance_flag`            | Air quality and data reliability analysis         |
| **ft_service** | Records technician maintenance and operational costs         | `service_cost_eur`, `duration_minutes`, `service_quality_score`, `underqualified_flag` | Operational efficiency and technician performance |

### **2. Dimension Tables**

| Dimension                    | Key Attributes                 | Purpose                                          |
| ---------------------------- | ------------------------------ | ------------------------------------------------ |
| **dim_timeday**              | Year → Month → Day             | Temporal analytics for all facts                 |
| **dim_device_geo**           | Country → City → Device        | Shared conformed geography dimension             |
| **dim_parameter**            | Group → Family → Parameter     | Environmental parameter hierarchy                |
| **dim_servicetype**          | Category → Type → Subtype      | Classification of maintenance activities         |
| **dim_technician_role_scd2** | Role → Category → Level        | Tracks technician career progression (SCD2)      |
| **dim_readingmode**          | Mode name, start/end validity  | Reading configuration and versioning             |
| **dim_campaign**             | Campaign → Sponsor → Objective | Synthetic dimension linking business initiatives |
| **dim_alertstatus**          | Alert level, threshold         | Lookup for alert-based analysis                  |

Each dimension and fact table includes:

* **Surrogate primary keys**
* **Audit column:** `etl_load_timestamp` for load traceability

---

## 🧠 Business Logic & Analytical Scope

### Key Analytical Capabilities:

* **Environmental Trends:** Evaluate pollutant behavior (PM10, NO₂) by city, campaign, or time.
* **Operational Efficiency:** Track maintenance costs, duration, and service quality.
* **Compliance Insights:** Detect underqualified technician assignments using SCD2 logic.
* **Campaign Performance:** Compare public vs. private campaigns on data quality and uptime.

### Example Business Questions:

1. Which campaigns achieved the highest average air quality improvement per region?
2. How do data quality scores vary between different reading modes?
3. Which devices required the most maintenance during critical campaigns?
4. Do technician experience levels correlate with service efficiency?

---

## 🧮 Star Schema Diagram

The final data mart (schema: `dwh_020`) is centered on two fact tables (`ft_reading`, `ft_service`) surrounded by eight interconnected dimensions.
The diagram `AirQ_ERD_dwh_020.png` visualizes all PK/FK relationships and hierarchies.

---

## 🔄 ETL Pipeline

### Workflow Overview

1. **Extract:** Load all raw OLTP snapshot CSVs and synthetic campaign data into `stg_020`.
2. **Transform:** Clean, join, and enrich data using SQL transformations and SCD2 logic.
3. **Load:** Populate dimension tables first, followed by fact tables, ensuring referential consistency.
4. **Validate:** Run structured post-ETL SQL checks (counts, integrity, domains, measures).
5. **Trace:** Generate lightweight provenance records using the PROV-O model (JSON-LD).

### Validation Results

| Check Type              | Result | Outcome                                |
| ----------------------- | ------ | -------------------------------------- |
| Row counts & integrity  | ✅      | 1:1 match between staging and DWH      |
| Attribute consistency   | ✅      | All key mappings correct               |
| Referential integrity   | ✅      | No orphaned fact entries               |
| SCD2 logic              | ✅      | Correct versioning of technician roles |
| Data range & domains    | ✅      | Measures within expected bounds        |
| Null handling           | ✅      | No missing mandatory fields            |
| Synthetic table linkage | ✅      | Campaign data successfully integrated  |

---

## 🧾 Data Provenance & Audit

The ETL notebook generates a machine-readable provenance record (`prov_airq_dwh_020.jsonld`) that documents:

* Source data (staging tables, synthetic inputs)
* ETL scripts executed
* Output entities (facts, dimensions)
* Agents and software used (PostgreSQL, Jupyter)
* Execution timestamp and row counts

This ensures full **traceability and reproducibility** of the analytical pipeline.

---

## 📊 Results & Insights

The final data warehouse enables:

* Fast OLAP-style aggregation and drill-down by **time, geography, campaign, and parameter**.
* Cross-domain analytics linking **environmental data with operational performance**.
* Historical tracking of technician roles for compliance and workforce analytics.
* Extensible schema design ready for future campaigns and parameters.

---

## 💡 Key Achievements

* **End-to-end BI pipeline** using open-source technologies
* **Fully normalized OLTP → Star Schema OLAP transformation**
* **Historical tracking (SCD Type 2)** implemented at dimension level
* **Validated and reproducible ETL process** with documented lineage
* **Business-ready analytical model** supporting campaign, service, and environmental KPIs

---

## 🚀 Future Enhancements

* Integration of **real-time sensor ingestion** via APIs
* Implementation of **Power BI / Tableau dashboards** for visualization
* Expansion of campaign analytics with **predictive modeling**
* Migration to **cloud-based DWH (e.g., Snowflake or BigQuery)** for scalability

---

## 👨‍💻 Project Team

| Name                      | Role                     | Focus Area                                                             |
| ------------------------- | ------------------------ | ---------------------------------------------------------------------- |
| **Muhammad Sajid Bashir** | Data Warehouse Architect | Dimensional modeling, ETL orchestration, reading fact analysis         |
| **Eman Shahin**           | Data Engineer            | Service fact design, validation framework, technician dimension (SCD2) |

---

## 📦 Repository Layout

```
AirQ-DataWarehouse/
│
├── data/          # Synthetic campaign and linkage tables
├── ddl/           # SQL DDL scripts for all schemas
├── etl/           # SQL-first ETL transformations
├── post/          # Validation and integrity checks
├── prov/          # Provenance records (JSON-LD)
├── sqldump/       # Final OLAP database export
├── AirQ_Part1_020.ipynb    # Orchestrator notebook (Python + SQL)
├── AirQ_ERD_dwh_020.png    # Schema diagram
└── Report_Part1_Group_020.pdf  # Project summary document
```

---

## 🏁 Conclusion

This project demonstrates how **data warehousing and business intelligence** principles can transform complex operational data into **actionable insights** for environmental agencies.

Through **robust dimensional modeling, reproducible ETL workflows, and validated analytics**, the Air Quality Monitoring Data Warehouse delivers a scalable, transparent, and data-driven foundation for strategic decision-making.

---

Would you like me to **format this as a ready-to-publish `README.md` file** (with Markdown syntax, line spacing, and heading consistency optimized for GitHub display)? It’ll be ready to copy-paste directly into your repository or LinkedIn “featured project” section.
