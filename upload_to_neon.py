import os
import pandas as pd
from sqlalchemy import create_engine, inspect
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get Neon DB URL from .env
DATABASE_URL = os.getenv("DATABASE_URL")

# Create SQLAlchemy engine
engine = create_engine(DATABASE_URL)
inspector = inspect(engine)

# Path to cleaned data folder
folder_path = r"C:\Users\PUJA KUMARI\Desktop\Vaccination (Project-2)\cleaned_data"

uploaded_tables = []

# Loop through all CSV files in the folder
for file in os.listdir(folder_path):
    if file.endswith(".csv"):
        file_path = os.path.join(folder_path, file)
        table_name = os.path.splitext(file)[0].lower()  # remove .csv and lowercase

        # Check if table already exists in Neon DB
        if table_name in inspector.get_table_names():
            print(f"✅ Already uploaded: {table_name}")
        else:
            # Read CSV into DataFrame
            df = pd.read_csv(file_path)

            print(f"⏳ Uploading {file} → {table_name} table in Neon...")
            df.to_sql(table_name, engine, if_exists="replace", index=False)

            uploaded_tables.append(table_name)
            print(f"✅ Uploaded: {table_name} ({len(df)} rows)")

print("\n🎉 All datasets are uploaded successfully to Neon DB!")
