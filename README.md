# 🩺 Vaccination Data Analysis
Hello
## 📌 Overview
This project analyzes vaccination coverage, disease incidence, and vaccine effectiveness using **Python, SQL, and Power BI**.  
The goal is to provide actionable insights into vaccination performance and public health trends.

## Steps to run the project
## create a new virtual environment
```bash
python -m vaccination python
```
## install requirements
```bash
python -m pip install -r requirements.txt
```

## run the .py file to neon
```bash
python upload_to_neon.py

```


## 🛠️ Tech Stack
- Python (Pandas, Matplotlib, SQLAlchemy)  
- SQL (PostgreSQL / MySQL)  
- Power BI (Dashboards & DAX)  

## 📂 Project Structure
vaccination-project/  
├── data_raw/ # Raw data  
├── data_clean/ # Cleaned data  
├── etl/ # Python ETL scripts  
├── sql/ # SQL schema & queries  
├── powerbi/ # Power BI reports   
├── notebooks/ # Jupyter notebooks   
└── docs/ # Documentation   



## 📊 Key Features
- Data cleaning & preprocessing with Python  
- SQL relational schema (facts & dimensions)  
- Interactive Power BI dashboards:  
  - Coverage trends  
  - Coverage vs incidence correlation  
  - Drop-off between doses & booster uptake  
  - Regional comparisons  

## 🚀 How to Run
1. Clean raw data with Python (`etl/`).  
2. Load into SQL database.  
3. Open `vaccination-dashboard.pbix` in Power BI.  

---
