# SQL Queries for Financial Data Analysis

## Overview
This repository contains SQL scripts for analyzing financial data using Google Big query. It includes scripts for data extraction, transformation, and analysis.

## Installation
### Dependencies
- PostgreSQL 12.0 or higher

### Setup Instructions
1. Clone this repository.
2. Connect to your PostgreSQL database.
3. Run `create_tables.sql` to create necessary tables.
4. Execute `data_analysis.sql` for performing financial analysis.

## SQL Script Organization
- `create_tables.sql`: SQL script for creating database schema.
- `data_analysis.sql`: SQL queries for financial data analysis.

## Usage Examples
### Example Query
```sql
-- Retrieve total revenue by product category
SELECT category, SUM(revenue) AS total_revenue
FROM sales
GROUP BY category;
