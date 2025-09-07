# Vaccination Project 2

_Empowering Public Health Through Seamless Data Insights_

![last commit](https://img.shields.io/badge/last%20commit-today-brightgreen)
![jupyter notebook](https://img.shields.io/badge/jupyter%20notebook-95.4%25-orange)
![languages](https://img.shields.io/badge/languages-2-blue)

Built with:  
![Python](https://img.shields.io/badge/Python-blue?logo=python)  
![pandas](https://img.shields.io/badge/pandas-purple?logo=pandas)  
![SQL](https://img.shields.io/badge/SQL-orange)  
![Power%20BI](https://img.shields.io/badge/Power%20BI-yellow)  
![Markdown](https://img.shields.io/badge/Markdown-black?logo=markdown)

---

## 📌 Table of Contents
- [Overview](#overview)
- [Approach](#approach)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Workflow](#workflow)
- [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-eda)
- [Usage](#usage)


---

## 📖 Overview

**Vaccination Project 2** is a complete data pipeline project focused on analyzing global vaccination trends and their impact on disease incidence.  
The workflow integrates **Python for cleaning**, **NeonDB for database management**, and **Power BI for interactive dashboards**.  

The goal is to create a reliable, automated system that:  
- Cleans and structures vaccination data,  
- Stores and normalizes it in a relational SQL database,  
- Connects it to Power BI for **insightful, real-time dashboards**.

---

## 🛠 Approach

### 🔹 Data Cleaning (Python)
- Removed duplicates and invalid records.  
- Handled missing values via imputation/removal.  
- Normalized units (percentages, reported cases).  
- Ensured **consistent date formats** across all datasets.  

### 🔹 SQL Database Setup (NeonDB)
- Created relational tables (`vaccination`, `disease`, `antigen`, `country`, `year`).  
- Normalized schema to reduce redundancy.  
- Added **primary & foreign keys** for referential integrity.  

### 🔹 Power BI Integration
- Connected NeonDB to Power BI via SQL connector.  
- Imported all tables.  
- Enabled **scheduled refreshes** for up-to-date reports.  

### 🔹 Data Visualization (Power BI)
- Built **interactive dashboards** with slicers & filters.  
- Key Visualizations:  
  - 🌍 **Geographical Heatmaps**: Vaccination coverage & disease incidence by region.  
  - 📈 **Trend Lines & Bar Charts**: Vaccination & disease trends across years.  
  - 🔗 **Scatter Plots**: Correlation between vaccination coverage & disease incidence.  
  - 🎯 **KPI Indicators**: Track progress toward vaccination goals.  

---

## ⚙ Tech Stack
- **Python** → Data cleaning & preprocessing  
- **pandas** → Data manipulation  
- **SQL / NeonDB** → Database setup & management  
- **Power BI** → Visualization & dashboarding  

---

## 🚀 Getting Started

### Prerequisites
- Python 3.x  
- Jupyter Notebook  
- NeonDB account  
- Power BI Desktop  

### Installation
1. Clone the repo:
   ```bash
   git clone https://github.com/Pujakumari1202/Vaccination--Project-2-
   cd Vaccination--Project-2-


## create a new virtual environment
```bash
python -m vaccination python
```
2) Install dependencies:
## install requirements
```bash
python -m pip install -r requirements.txt
```

3) Run Jupyter Notebook for cleaning
````bash
jupyter notebook
```

4) Run Python script to upload to NeonDB
```bash
python upload_to_neon.py

```


🔄 Workflow 

      1. Clean raw dataset in Python.  
      2. Upload cleaned datasets to NeonDB.  
      3. Create tables & schema in SQL.  
      4. Connect Power BI to NeonDB.  
      5. Build dashboards with filters, KPIs, and visual insights.  


**📊 Exploratory Data Analysis (EDA)**

    Summarized vaccination coverage & disease incidence.  
    Visualized regional disparities with bar charts & heatmaps.  
    Conducted correlation analysis between vaccination coverage & disease reduction.  


📌 Usage

Once connected to Power BI:

      Use slicers to filter by year, country, or vaccine type.  
      Explore disease incidence vs vaccination coverage trends.  
      Monitor progress toward global vaccination goals.  
