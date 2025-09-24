*/-- Create Table and Load Data
CREATE TABLE credit_risk (
    person_age INT,
    person_income DECIMAL(12,2),
    person_home_ownership VARCHAR(50),
    person_emp_length VARCHAR(20),
    loan_intent VARCHAR(100),
    loan_grade CHAR(1),
    loan_amnt DECIMAL(12,2),
    loan_int_rate DECIMAL(5,2),
    loan_status INT, -- 0 = non-default, 1 = default
    loan_percent_income DECIMAL(5,2),
    cb_person_default_on_file CHAR(1),
    cb_person_cred_hist_length INT
);

-- Load Data from CSV*
COPY credit_risk
FROM 'C:\\Users\\ADMIN\\Desktop\\credit_risk.csv'
DELIMITER ','
CSV HEADER;


/*Data Cleaning*/

-- View first few rows


select * from credit_risk limit 20;

--look for null values
SELECT
    SUM(CASE WHEN person_age IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN person_income IS NULL THEN 1 ELSE 0 END) AS null_income,
    SUM(CASE WHEN person_home_ownership IS NULL THEN 1 ELSE 0 END) AS null_home_ownership,
    SUM(CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END) AS null_emp_length,
    SUM(CASE WHEN loan_intent IS NULL THEN 1 ELSE 0 END) AS null_intent,
    SUM(CASE WHEN loan_grade IS NULL THEN 1 ELSE 0 END) AS null_grade,
    SUM(CASE WHEN loan_amnt IS NULL THEN 1 ELSE 0 END) AS null_amount,
    SUM(CASE WHEN loan_int_rate IS NULL THEN 1 ELSE 0 END) AS null_rate,
    SUM(CASE WHEN loan_status IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN loan_percent_income IS NULL THEN 1 ELSE 0 END) AS null_pct_income,
    SUM(CASE WHEN cb_person_default_on_file IS NULL THEN 1 ELSE 0 END) AS null_default_flag,
    SUM(CASE WHEN cb_person_cred_hist_length IS NULL THEN 1 ELSE 0 END) AS null_cred_len
FROM credit_risk;

--Count Duplicate BY KEY COLUMNS

select 
    person_age,
    person_income,
    loan_amnt,
    loan_status,
    count(*) as duplicate_count
from credit_risk
group by 
    person_age,
    person_income,
    loan_amnt,
    loan_status
having count(*)>1;

--Remove Duplicates
DELETE FROM credit_risk a
USING credit_risk b
WHERE a.ctid < b.ctid
  AND a.person_age = b.person_age
  AND a.person_income = b.person_income
  AND a.loan_amnt = b.loan_amnt
  AND a.loan_status = b.loan_status;

-- Checking Negative Or Zero Values 
select * from credit_risk
where person_age<=0
    or person_income<=0
    or loan_amnt<=0
    or loan_percent_income<=0;



/*Data Exploration*/

--summary statistics
select 
    min(person_age) as min_age,
    max(person_age) as max_age,
    round(avg(person_age)) as avg_age,
    min(person_income) as min_income,
    max(person_income) as max_income,
    avg(person_income) as avg_income,
    min(loan_amnt) as min_loan_amount,
    max(loan_amnt) as max_loan_amount,
    avg(loan_amnt) as avg_loan_amount
from credit_risk;

--Distribution of Loan Status
select loan_status,
    count(*) as total_loans,
    round(100.0*count(*) / sum(count(*)) over (),2) as pct_share
from credit_risk
group by loan_status;


--Loan Amount By grade

select loan_grade,
    count(*) as total_loans,
    round(avg(loan_amnt)) as avg_loan_amount,
    round(avg(loan_int_rate)) as avg_interest_rate
from credit_risk
group by loan_grade
order by loan_grade;

--Average Income vs Default STATUS

select 
    loan_status,
    round(avg(person_income)) as avg_income,
    round(avg(loan_amnt)) as AVG_loan_amount
from credit_risk
group by loan_status;

--Average Loan Amount by Intent
SELECT
    loan_intent,
    round(ROUND(AVG(loan_amnt),2)) AS avg_amount,
    ROUND(AVG(loan_int_rate),2) AS avg_interest
FROM credit_risk
GROUP BY loan_intent
ORDER BY avg_amount DESC;


--Default Rate By Age Band
with age_band as (
   select * ,
   case 
        when person_age < 25 then 'under 25'
        when person_age between 25 and 35 then '25-35'
        when person_age between 36 and 45 then '35-45'
        when person_age between 46 and 60 then '45-60'
        else 'Above 60'
    end as age_group 
from credit_risk
)
select 
    age_group,
    count(*) as applications,
    sum(case when loan_status = 1 then 1 else 0 end ) as defaults,
    round(100.0*sum(case when loan_status = 1 then 1 else 0 end ) /count(*),2) as default_rate
from age_band 
group by age_group
order by default_rate desc;


--Income Vs Loan Amount
SELECT 
    round(avg(person_income),2) as avg_income,
    round(avg(loan_amnt),2) as avg_loan,
    round(avg(loan_percent_income),2) as avg_loan_pct_income
    from credit_risk;

--Home Ownnership Impact on Default
SELECT
    person_home_ownership,
    count(*) as total,
    round(100.0*sum(case when loan_status=1 then 1 else 0 end ) / count(*),2) as default_rate
from credit_risk
group by person_home_ownership
order by default_rate desc;

--Credit History Lenght vs Default
select 
    round(avg(cb_person_cred_hist_length)) as avg_cred_length,
    round(avg(loan_status),3) as avg_default_flag
from credit_risk;

--Default Rate Vy Income Band
with income_band as (
   select * ,
   case 
        when person_income < 10000 then 'Low'
        when person_income between 10001 and 20000 then 'Medium'
        when person_income between 20001 and 30000 then 'High'
        else 'Very High'
    end as  income_group 
from credit_risk
)
select 
    income_group,
    count(*) as applications,
    sum(case when loan_status = 1 then 1 else 0 end ) as defaults,
    round(100.0*sum(case when loan_status = 1 then 1 else 0 end ) /count(*),2) as default_rate
from income_band 
group by income_group
order by default_rate desc;

--Top 10 Highest Loans & thier status
select person_age,person_income, loan_amnt,loan_status
from credit_risk
order by loan_amnt desc limit 19;

