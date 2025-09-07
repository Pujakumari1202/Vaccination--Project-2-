CREATE TABLE IF NOT EXISTS staging_vaccination (
    year INT,
    target_number NUMERIC,
    doses TEXT,
    coverage NUMERIC,
    group_name TEXT,
    coverage_category TEXT,
    coverage_category_description TEXT,
    antigen_description TEXT,
    code TEXT,
    country_name TEXT,
    antigen TEXT
);


-- Staging: Disease Incidence / Rate
CREATE TABLE staging_disease_incidence (
    year INT,
    incidence_rate NUMERIC,
    country_name TEXT,
    group_name TEXT,
    disease_description TEXT,
    denominator NUMERIC,
    disease TEXT,
    codee TEXT
);

-- Staging: Disease Cases
CREATE TABLE staging_disease_cases (
    year INT,
    cases NUMERIC,
    country_name TEXT,
    group_name TEXT,
    disease TEXT,
    disease_description TEXT,
    code TEXT
);

-- Staging: Country Details
CREATE TABLE staging_country (
    year INT,
    iso_3_code TEXT,
    country_name TEXT,
    who_region TEXT,
    description TEXT,
    intro TEXT
);

-- Staging: Vaccine Schedule / Target Population
CREATE TABLE staging_vaccine_schedule (
    schedulerounds TEXT,
    year INT,
    who_region TEXT,
    vaccine_code TEXT,
    vaccine_description TEXT,
    targetpop NUMERIC,
    targetpop_description TEXT,
    geoarea TEXT,
    ageadministered TEXT,
    iso_3_code TEXT,
    sourcecomment TEXT,
    country_name TEXT
);

-- =========================
-- DIMENSION TABLES
-- =========================

-- Country Dimension
CREATE TABLE dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name TEXT UNIQUE NOT NULL,
    iso_3_code TEXT,
    who_region TEXT,
    description TEXT,
    intro TEXT
);

-- Disease Dimension
CREATE TABLE dim_disease (
    disease_id SERIAL PRIMARY KEY,
    disease_name TEXT UNIQUE NOT NULL,
    disease_description TEXT
);

-- Antigen Dimension
CREATE TABLE dim_antigen (
    antigen_id SERIAL PRIMARY KEY,
    antigen_name TEXT UNIQUE NOT NULL,
    antigen_description TEXT
);

-- Vaccine Dimension
CREATE TABLE dim_vaccine (
    vaccine_id SERIAL PRIMARY KEY,
    vaccine_name TEXT UNIQUE NOT NULL,
    vaccine_description TEXT
);

-- =========================
-- FACT TABLES
-- =========================

-- Vaccination Fact
CREATE TABLE fact_vaccination (
    fact_id SERIAL PRIMARY KEY,
    year INT,
    country_id INT REFERENCES dim_country(country_id),
    antigen_id INT REFERENCES dim_antigen(antigen_id),
    target_number NUMERIC,
    doses TEXT,
    coverage NUMERIC,
    group_name TEXT,
    coverage_category TEXT,
    coverage_category_description TEXT,
    code TEXT
);

-- Disease Incidence Fact
CREATE TABLE fact_disease_incidence (
    fact_id SERIAL PRIMARY KEY,
    year INT,
    country_id INT REFERENCES dim_country(country_id),
    disease_id INT REFERENCES dim_disease(disease_id),
    incidence_rate NUMERIC,
    denominator NUMERIC,
    group_name TEXT,
    codee TEXT
);

-- Disease Cases Fact
CREATE TABLE fact_disease_cases (
    fact_id SERIAL PRIMARY KEY,
    year INT,
    country_id INT REFERENCES dim_country(country_id),
    disease_id INT REFERENCES dim_disease(disease_id),
    cases NUMERIC,
    group_name TEXT,
    code TEXT
);

-- =========================
-- INSERT INTO DIMENSIONS
-- =========================

-- Country Dimension
INSERT INTO dim_country (country_name, iso_3_code, who_region, description, intro)
SELECT DISTINCT country_name, iso_3_code, who_region, description, intro
FROM staging_country;

-- Disease Dimension
INSERT INTO dim_disease (disease_name, disease_description)
SELECT DISTINCT disease, disease_description
FROM staging_disease_incidence
UNION
SELECT DISTINCT disease, disease_description
FROM staging_disease_cases;

-- Antigen Dimension
INSERT INTO dim_antigen (antigen_name, antigen_description)
SELECT DISTINCT antigen, antigen_description
FROM staging_vaccination;

-- Vaccine Dimension
INSERT INTO dim_vaccine (vaccine_name, vaccine_description)
SELECT DISTINCT vaccine_code, vaccine_description
FROM staging_vaccine_schedule;

-- =========================
-- INSERT INTO FACT TABLES
-- =========================

-- Fact Vaccination
INSERT INTO fact_vaccination (year, country_id, antigen_id, target_number, doses, coverage, group_name, coverage_category, coverage_category_description, code)
SELECT
    v.year,
    c.country_id,
    a.antigen_id,
    v.target_number,
    v.doses,
    v.coverage,
    v.group_name,
    v.coverage_category,
    v.coverage_category_description,
    v.code
FROM staging_vaccination v
JOIN dim_country c ON v.country_name = c.country_name
JOIN dim_antigen a ON v.antigen = a.antigen_name;

-- Fact Disease Incidence
INSERT INTO fact_disease_incidence (year, country_id, disease_id, incidence_rate, denominator, group_name, codee)
SELECT
    d.year,
    c.country_id,
    dis.disease_id,
    d.incidence_rate,
    d.denominator,
    d.group_name,
    d.codee
FROM staging_disease_incidence d
JOIN dim_country c ON d.country_name = c.country_name
JOIN dim_disease dis ON d.disease = dis.disease_name;

-- Fact Disease Cases
INSERT INTO fact_disease_cases (year, country_id, disease_id, cases, group_name, code)
SELECT
    d.year,
    c.country_id,
    dis.disease_id,
    d.cases,
    d.group_name,
    d.code
FROM staging_disease_cases d
JOIN dim_country c ON d.country_name = c.country_name
JOIN dim_disease dis ON d.disease = dis.disease_name;



-- Fact: Vaccine Schedule / Target Population
CREATE TABLE IF NOT EXISTS fact_vaccine_schedule (
    fact_id SERIAL PRIMARY KEY,
    year INT,
    country_id INT REFERENCES dim_country(country_id),
    vaccine_id INT REFERENCES dim_vaccine(vaccine_id),
    schedulerounds TEXT,
    targetpop NUMERIC,
    targetpop_description TEXT,
    geoarea TEXT,
    ageadministered TEXT,
    who_region TEXT,
    sourcecomment TEXT
);

-- Insert into Fact Vaccine Schedule
INSERT INTO fact_vaccine_schedule (
    year, country_id, vaccine_id, schedulerounds, targetpop, targetpop_description, geoarea, ageadministered, who_region, sourcecomment
)
SELECT
    v.year,
    c.country_id,
    vac.vaccine_id,
    v.schedulerounds,
    v.targetpop,
    v.targetpop_description,
    v.geoarea,
    v.ageadministered,
    v.who_region,
    v.sourcecomment
FROM staging_vaccine_schedule v
JOIN dim_country c ON v.country_name = c.country_name
JOIN dim_vaccine vac ON v.vaccine_code = vac.vaccine_name;




-- Index on fact_vaccination
CREATE INDEX idx_fact_vaccination_country_year ON fact_vaccination(country_id, year);

-- Index on fact_disease_incidence
CREATE INDEX idx_fact_disease_incidence_country_year ON fact_disease_incidence(country_id, year);

-- Index on fact_disease_cases
CREATE INDEX idx_fact_disease_cases_country_year ON fact_disease_cases(country_id, year);

-- Index on fact_vaccine_schedule
CREATE INDEX idx_fact_vaccine_schedule_country_year ON fact_vaccine_schedule(country_id, year);




-- Check dimension tables
SELECT * FROM dim_country LIMIT 10;
SELECT * FROM dim_disease LIMIT 10;
SELECT * FROM dim_antigen LIMIT 10;
SELECT * FROM dim_vaccine LIMIT 10;

-- Check fact tables
SELECT * FROM fact_vaccination LIMIT 10;
SELECT * FROM fact_disease_incidence LIMIT 10;
SELECT * FROM fact_disease_cases LIMIT 10;
SELECT * FROM fact_vaccine_schedule LIMIT 10;


CREATE OR REPLACE VIEW vw_vaccination_summary AS
SELECT
    f.year,
    c.country_name,
    a.antigen_name,
    f.doses,
    f.coverage,
    f.group_name
FROM fact_vaccination f
JOIN dim_country c ON f.country_id = c.country_id
JOIN dim_antigen a ON f.antigen_id = a.antigen_id;




--code to data map into Staging Tables
-- Verify
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'cleaned_df1';


INSERT INTO staging_vaccination (
    year,
    target_number,
    doses,
    coverage,
    group_name,
    coverage_category,
    coverage_category_description,
    antigen_description,
    code,
    country_name,
    antigen
)
SELECT
    "YEAR"::INT,
    "TARGET_NUMBER"::NUMERIC,
    "DOSES"::TEXT,
    "COVERAGE"::NUMERIC,
    "GROUP",  -- reserved word, but quoting works
    "COVERAGE_CATEGORY",
    "COVERAGE_CATEGORY_DESCRIPTION",
    "ANTIGEN_DESCRIPTION",
    "CODE",
    "NAME",
    "ANTIGEN"
FROM cleaned_df1;
-- How many rows loaded?
SELECT COUNT(*) FROM staging_vaccination;

-- Preview some rows
SELECT * FROM staging_vaccination LIMIT 10;



INSERT INTO staging_disease_incidence (
    year, incidence_rate, country_name, group_name,
    disease_description, denominator, disease, codee
)
SELECT
    "YEAR"::INT,
    "INCIDENCE_RATE"::NUMERIC,
    "NAME",
    "GROUP",
    "DISEASE_DESCRIPTION",
    CASE WHEN "DENOMINATOR" ~ '^[0-9]+(\.[0-9]+)?$'
         THEN "DENOMINATOR"::NUMERIC
         ELSE NULL
    END,
    "DISEASE",
    "CODE"
FROM cleaned_df2;


INSERT INTO staging_disease_cases (
    year, cases, country_name, group_name,
    disease, disease_description, code
)
SELECT
    "YEAR"::INT,
    "CASES",       -- already double precision
    "NAME",        -- country_name
    "GROUP",       -- reserved word, quoting works
    "DISEASE",
    "DISEASE_DESCRIPTION",
    "CODE"
FROM cleaned_df3;

-- Verify
SELECT COUNT(*) AS cases_rows FROM staging_disease_cases;
SELECT * FROM staging_disease_cases LIMIT 10;



INSERT INTO staging_country (
    year, iso_3_code, country_name, who_region,
    description, intro
)
SELECT
    "YEAR"::INT,
    "ISO_3_CODE",
    "COUNTRYNAME",   -- maps to country_name in staging
    "WHO_REGION",
    "DESCRIPTION",
    "INTRO"
FROM cleaned_df4;

-- Verify
SELECT COUNT(*) AS country_rows FROM staging_country;
SELECT * FROM staging_country LIMIT 10;


INSERT INTO staging_vaccine_schedule (
    schedulerounds, year, who_region, vaccine_code,
    vaccine_description, targetpop, targetpop_description,
    geoarea, ageadministered, iso_3_code, sourcecomment, country_name
)
SELECT
    "SCHEDULEROUNDS"::NUMERIC,         -- cast to numeric
    "YEAR"::INT,
    "WHO_REGION",
    "VACCINECODE",
    "VACCINE_DESCRIPTION",
    CASE WHEN "TARGETPOP" ~ '^[0-9]+(\.[0-9]+)?$'
         THEN "TARGETPOP"::NUMERIC
         ELSE NULL
    END,
    "TARGETPOP_DESCRIPTION",
    "GEOAREA",
    "AGEADMINISTERED",
    "ISO_3_CODE",
    "SOURCECOMMENT",
    "COUNTRYNAME"
FROM cleaned_df5;

-- Verify
SELECT COUNT(*) AS schedule_rows FROM staging_vaccine_schedule;
SELECT * FROM staging_vaccine_schedule LIMIT 10;


--Code to data map into Dimension Tables
-- Verify

-- Country Dimension
INSERT INTO dim_country (country_name, iso_3_code, who_region, description, intro)
SELECT DISTINCT TRIM(COUNTRYNAME), ISO_3_CODE, WHO_REGION, DESCRIPTION, INTRO
FROM staging_country
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_country (country_name, iso_3_code, who_region, description, intro)
SELECT DISTINCT TRIM(country_name), iso_3_code, who_region, description, intro
FROM staging_country
ON CONFLICT (country_name) DO NOTHING;

-- Verify
SELECT COUNT(*) FROM dim_country;
SELECT * FROM dim_country LIMIT 10;

INSERT INTO dim_disease (disease_name, disease_description)
SELECT DISTINCT disease, disease_description
FROM staging_disease_incidence
UNION
SELECT DISTINCT disease, disease_description
FROM staging_disease_cases
ON CONFLICT (disease_name) DO NOTHING;

SELECT COUNT(*) FROM dim_disease;


INSERT INTO dim_antigen (antigen_name, antigen_description)
SELECT DISTINCT antigen, antigen_description
FROM staging_vaccination
ON CONFLICT (antigen_name) DO NOTHING;

SELECT COUNT(*) FROM dim_antigen;


INSERT INTO dim_vaccine (vaccine_name, vaccine_description)
SELECT DISTINCT vaccine_code, vaccine_description
FROM staging_vaccine_schedule
ON CONFLICT (vaccine_name) DO NOTHING;

SELECT COUNT(*) FROM dim_vaccine;




-- Code to data map into Fact Tables
-- Verify



INSERT INTO fact_vaccination (
    year, country_id, antigen_id, target_number, doses,
    coverage, group_name, coverage_category, coverage_category_description, code
)
SELECT
    v.year,
    c.country_id,
    a.antigen_id,
    v.target_number,
    v.doses,
    v.coverage,
    v.group_name,
    v.coverage_category,
    v.coverage_category_description,
    v.code
FROM staging_vaccination v
JOIN dim_country c ON TRIM(v.country_name) = c.country_name
JOIN dim_antigen a ON TRIM(v.antigen) = a.antigen_name;

SELECT COUNT(*) AS vaccination_rows FROM fact_vaccination;
SELECT * FROM fact_vaccination LIMIT 10;




INSERT INTO fact_disease_incidence (
    year, country_id, disease_id, incidence_rate, denominator, group_name, codee
)
SELECT
    d.year,
    c.country_id,
    dis.disease_id,
    d.incidence_rate,
    d.denominator,
    d.group_name,
    d.codee
FROM staging_disease_incidence d
JOIN dim_country c ON TRIM(d.country_name) = c.country_name
JOIN dim_disease dis ON d.disease = dis.disease_name;

SELECT COUNT(*) AS incidence_rows FROM fact_disease_incidence;
SELECT * FROM fact_disease_incidence LIMIT 10;



INSERT INTO fact_disease_cases (
    year, country_id, disease_id, cases, group_name, code
)
SELECT
    d.year,
    c.country_id,
    dis.disease_id,
    d.cases,
    d.group_name,
    d.code
FROM staging_disease_cases d
JOIN dim_country c ON TRIM(d.country_name) = c.country_name
JOIN dim_disease dis ON d.disease = dis.disease_name;

SELECT COUNT(*) AS cases_rows FROM fact_disease_cases;
SELECT * FROM fact_disease_cases LIMIT 10;

CREATE TABLE IF NOT EXISTS fact_vaccine_schedule (
    fact_id SERIAL PRIMARY KEY,
    year INT,
    country_id INT REFERENCES dim_country(country_id),
    vaccine_id INT REFERENCES dim_vaccine(vaccine_id),
    schedulerounds NUMERIC,
    targetpop NUMERIC,
    targetpop_description TEXT,
    geoarea TEXT,
    ageadministered TEXT,
    who_region TEXT,
    sourcecomment TEXT
);

INSERT INTO fact_vaccine_schedule (
    year, country_id, vaccine_id, schedulerounds, targetpop,
    targetpop_description, geoarea, ageadministered, who_region, sourcecomment
)
SELECT
    v.year,
    c.country_id,
    vac.vaccine_id,
    v.schedulerounds::NUMERIC,   -- already numeric, safe cast
    v.targetpop::NUMERIC,       -- already numeric, safe cast
    v.targetpop_description,
    v.geoarea,
    v.ageadministered,
    v.who_region,
    v.sourcecomment
FROM staging_vaccine_schedule v
JOIN dim_country c ON TRIM(v.country_name) = c.country_name
JOIN dim_vaccine vac ON TRIM(v.vaccine_code) = vac.vaccine_name;

-- Verify
SELECT COUNT(*) AS schedule_rows FROM fact_vaccine_schedule;
SELECT * FROM fact_vaccine_schedule LIMIT 10;
