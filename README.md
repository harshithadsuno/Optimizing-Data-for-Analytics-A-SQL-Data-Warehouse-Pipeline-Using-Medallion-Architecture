# Data Warehouse Project: CPG Sales Analytics using Medallion Architecture

This project implements a full-stack data warehousing pipeline using the **Medallion Architecture** (Bronze → Silver → Gold) to transform and model raw CPG (Consumer Packaged Goods) datasets into an analytics-ready format. The pipeline was built using SQL scripts to ingest, clean, integrate, and organize data across multiple business entities.

---

## 📊 Architecture Overview

### 🔁 Data Flow
![Data Flow](Data_Flow.png)

### 🔗 Data Integration Design
![Data Integration](Data_Integration.png)

### 🧱 Dimensional Data Model
![Data Model](Data_Model.png)

---

## 🗂️ Layered Structure

### 🔸 Bronze Layer – Raw Ingestion
Files:
- `bronze.crm_cust_info.csv`
- `bronze.crm_sales_details.csv`
- `bronze.crm_prd_info.csv`
- `bronze.erp_loc_a101.csv`
- `bronze.erp_cust_az12.csv`
- `bronze.erp_px_cat_g1v2.csv`

### 🔹 Silver Layer – Cleaned & Standardized
Files:
- `silver.crm_cust_info.csv`
- `silver.crm_sales_details.csv`
- `silver.crm_prd_info.csv`
- `silver.erp_loc_a101.csv`
- `silver.erp_cust_az12.csv`
- `silver.erp_px_cat_g1v2.csv`

### 🏅 Gold Layer – Analytics-Ready
Files:
- `gold.dim_customers.csv`
- `gold.dim_products.csv`
- `gold.fact_sales.csv`
- `gold.report_customers.csv`
- `gold.report_products.csv`

---

## ⚙️ How to Run

1. Run `init_database.sql` to initialize the schema.
2. Execute DDL scripts for each layer:
   - `bronze_ddl.sql`
   - `silver_ddl.sql`
3. Load data using procedures:
   - `proc_load_bronze.sql`
   - `proc_load_silver.sql`
4. Execute gold layer transformations:
   - `gold_cust.sql`
   - `gold_products.sql`
   - `gold_sles.sql`

---

## ✅ Outcomes

- Clean dimensional model for sales analysis
- Unified customer and product entities across systems
- Ready-to-analyze fact and report tables
- Foundation for advanced analytics (used in a follow-up project)

---

## 🧠 Skills Demonstrated

- SQL DDL & DML Scripting
- ETL Architecture (Medallion)
- Data Cleaning & Transformation
- Relational Modeling & Star Schema Design
- Procedural SQL (Stored Procedures)
- End-to-End Data Warehousing Workflow

---

> 🚀 This project sets the stage for advanced analytics built on top of a solid data foundation. Follow-up analysis available in the [Advanced SQL Analytics Project](#).

