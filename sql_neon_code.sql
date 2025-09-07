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


