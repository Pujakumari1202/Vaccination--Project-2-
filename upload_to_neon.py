import os
import pandas as pd
from sqlalchemy import create_engine

# Your Neon connection string
DATABASE_URL = "postgresql://neondb_owner:npg_cnO9Iwy1TCSE@ep-dawn-field-ad6sc9t3-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require"

# Create SQLAlchemy engine
engine = create_engine(DATABASE_URL)

# Path to cleaned data folder
folder_path = r"C:\Users\PUJA KUMARI\Desktop\Vaccination (Project-2)\cleaned_data"

# Loop through all CSV files in the folder
for file in os.listdir(folder_path):
    if file.endswith(".csv"):
        file_path = os.path.join(folder_path, file)
        
        # Read CSV into DataFrame
        df = pd.read_csv(file_path)
        
        # Create table name from file name (remove extension)
        table_name = os.path.splitext(file)[0]
        
        print(f"Uploading {file} → {table_name} table in Neon...")
        
        # Upload to Neon (replace if exists)
        df.to_sql(table_name, engine, if_exists="replace", index=False)
        
        print(f"✅ Uploaded: {table_name}")

print("🎉 All CSV files uploaded to Neon successfully!")
