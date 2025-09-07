## Code to drop tables in Neon DB and upload again

import os
import pandas as pd
from sqlalchemy import create_engine, inspect, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

# Create engine
engine = create_engine(DATABASE_URL)

# Path to cleaned data
folder_path = r"C:\Users\PUJA KUMARI\Desktop\Vaccination (Project-2)\cleaned_data"

uploaded_tables = []

with engine.connect() as conn:
    for file in os.listdir(folder_path):
        if file.endswith(".csv"):
            file_path = os.path.join(folder_path, file)
            table_name = os.path.splitext(file)[0].lower()

            # Drop table if it exists
            conn.execute(text(f"DROP TABLE IF EXISTS {table_name};"))
            print(f"🗑️ Dropped old table: {table_name}")

            # Read cleaned CSV
            df = pd.read_csv(file_path)

            # Upload again
            print(f"⏳ Uploading {file} → {table_name} table...")
            df.to_sql(table_name, engine, if_exists="replace", index=False)
            uploaded_tables.append(table_name)
            print(f"✅ Uploaded: {table_name} ({len(df)} rows)")

print("\n🎉 All datasets dropped (if existed) and uploaded again successfully!")
