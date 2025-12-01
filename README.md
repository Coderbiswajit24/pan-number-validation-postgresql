##  pan-number-validation-postgresql
Cleaned and validated 10,000 Indian PAN numbers using PostgreSQL. Real-world data cleaning project with PL/pgSQL functions, regex validation, and production-ready views. #SQL #DataAnalyst #PostgreSQL

## 📌 **Project Overview**

Clean and validate a large dataset of Indian PAN numbers. Remove errors, standardize formats, and classify as “Valid” or “Invalid” using SQL functions and business rules.

## 🧩 **Problem Statement**

1). Validate each PAN for official format (5 letters, 4 digits, 1 letter)

2). Remove missing data, duplicates, spaces; convert to uppercase

3). No adjacent/sequential letters or digits

4). Report valid, invalid, and incomplete/missing PANs

## 🧭 **Step By Step Process**

1. Data Profiling

       Import data, check for blanks, spaces, duplicate, case issues

2. Data Cleaning

       Trim spaces, convert to uppercase, drop duplicates and missing rows

3. PAN Validation Rules

        Use regex for format: AHGVE1276F

4. Create functions for advanced checks (adjacent, sequence)

        Mark PANs as Valid or Invalid

4. Output Results

       Categorize every PAN

5. Generate summary stats (count valid, invalid, missing)

## 🚀 **How To Run This Project**
1. Requirements :-

       PostgreSQL (PgAdmin 4 Tool) Database

2. Setup ( Create Tables): -
 
        CREATE TABLE dump_unclean_pan_numbers (pan_raw_text TEXT);
        CREATE TABLE pan_numbers (pan_raw_text TEXT);
3. Upload your CSV file :

        Import your PAN numbers CSV into dump_unclean_pan_numbers table using your database tool (PgAdmin 4 Tool).
        a). Using psql from your local machine (most common)
   
        \copy dump_unclean_pan_numbers (pan_raw_text)
         FROM '/full/path/to/PAN Number Validation Dataset.csv'
        WITH (FORMAT csv, HEADER true);
        b). Using server-side COPY (file must be on the DB server):
   
        COPY dump_unclean_pan_numbers (pan_raw_text)
        FROM '/full/path/to/PAN Number Validation Dataset.csv'
        DELIMITER ','
        CSV HEADER;

        Replace /full/path/to/PAN Number Validation Dataset.csv with the actual path of your CSV file.
   
4. Copy data to the working table

        INSERT INTO pan_numbers (pan_raw_text)
        SELECT pan_raw_text FROM dump_unclean_pan_numbers;

## 📁 **File Structure**

          ├── README.md
          ├── Pan Number Cleaning & Validation SQL Query File.sql
          ├── PAN Number Validation Dataset.csv
          ├── screenshots/
          ├── LICENSE
          └── .gitignore
          
## 🎥 **Video Presentation** 

  A walkthrough video showing code, cleaning, validation, and final reporting will be shared here soon.
  
## 🙏 **Acknowledgment**

  The PAN number data cleaning and validation project is inspired by and adapted from the comprehensive tutorial by the techTFQ YouTube channel. The step-by-step    SQL techniques for cleaning, validating, and categorizing PAN numbers, including user-defined functions for complex checks, were learned from the video titled     "PAN Card Validation in SQL | Real World Data Cleaning & Validation Project" https://youtu.be/J1vlhH5LFY8?si=VQwnso3AwytRA1vt 
  This resource greatly helped in understanding practical data engineering challenges and solutions for real-world datasets.
  
  Special thanks to techTFQ [Thoufiq Mohammed](https://www.linkedin.com/in/thoufiq-mohammed/) for sharing this detailed, hands-on project that bridges theoretical knowledge with applied SQL programming for data analysts.

 ## 🌐 Connect With Me

- LinkedIn: [BISWAJIT SASMAL](https://www.linkedin.com/in/biswajitsasmal/)
- Email: biswajitsasmal.data@gmail.com

## 🎉 THANK YOU FOR VISITING! 🎉

Your time means a lot.  
If this project helped you, consider giving it a ⭐ and sharing it!
## 🙏 Thank You

![Thank You](https://www.icegif.com/wp-content/uploads/2023/06/icegif-454.gif)


