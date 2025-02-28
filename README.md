
# Optimizing Data for Analytics: A SQL Data Warehouse & Pipeline Using Medallion Architecture

This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to Analytics-Ready Insights. Here's a sneak peak of the raw data!
![Data](docs/Data_Integration.png)

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

![Data Flow](docs/Data_Flow.png)

---
## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.


#### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

## 📜 SQL Scripts

Stored procedures and schema definitions for each layer:

- **Bronze Layer**: `bronze_ddl.sql`, `proc_load_bronze.sql`
- **Silver Layer**: `silver_ddl.sql`, `proc_load_silver.sql`
- **Gold Layer**: `gold_products.sql`, `gold_sales.sql`, `gold_customers.sql`

![Data Model](docs/Data_Model.png)
