                                 ------------------------------------------------------------
								 -- PAN Number Data Cleaning & Validation Using PostgreSQL -- 
								 ------------------------------------------------------------
/*
 * PAN Number Data Cleaning & Validation in PostgreSQL
 * Purpose: Clean, deduplicate, and validate Indian PAN numbers
 * 
 * Business Rules:
 * 1. PAN must be 10 characters: 5 letters + 4 digits + 1 letter
 * 2. First 5 letters: no adjacent same characters (e.g., AABCD invalid)
 * 3. First 5 letters: no full sequential pattern (e.g., ABCDE invalid)
 * 4. Next 4 digits: no adjacent same digits (e.g., 1123 invalid)
 * 5. Next 4 digits: no full sequential pattern (e.g., 1234 invalid)
 * 
 * Tables:
 * - dump_unclean_pan_numbers: raw dump (source)
 * - pan_numbers: Staging table 
 * - vw_valid_invalid_pans: view for Valid/Invalid categorization
 * 
 * Author: BISWAJIT SASMAL
 * Date: 2025‑12‑01
 */


-- Creating a dump table Which Contain All the Unclean Pan Numbers.
create table dump_unclean_pan_numbers
(
 pan_raw_text text
);

select * from dump_unclean_pan_numbers; 
                                           ------------------------------------
                                           -- Data Cleaning and Preprocessing --
								           -------------------------------------
create table pan_numbers
(
 pan_raw_text  text
);

insert into pan_numbers(pan_raw_text)
select * from dump_unclean_pan_numbers;

-- Task 1:- Identify and handle missing data
select
     *
from pan_numbers
where pan_raw_text is null or pan_raw_text = '' or pan_raw_text = ' ';

-- Another Query Solution to Indentify Null or Missing Records:-
select
     *
from pan_numbers
where trim(coalesce(pan_raw_text , '')) = '';

-- Task 2:- Indentify Duplicates Records in Pan Numbers.
select
     upper(trim(pan_raw_text)) as duplicates_pan_number,
	 count(*) as total_count
from pan_numbers
where trim(coalesce(pan_raw_text , '')) <> ''
group by upper(trim(pan_raw_text))
having count(*) > 1 ;

-- Task 3: Identify PAN records with leading/trailing spaces
SELECT 
    *
FROM pan_numbers
WHERE COALESCE(pan_raw_text, '') <> TRIM(COALESCE(pan_raw_text, ''));

-- Task 4: Identify incorrect letter case PAN records
SELECT 
     *
FROM pan_numbers
WHERE  TRIM(COALESCE(pan_raw_text, '')) <> UPPER(TRIM(COALESCE(pan_raw_text, '')))
  AND  TRIM(COALESCE(pan_raw_text, '')) <> '';
                                           -------------------------------------------
                                           -- PAN Number Format /Pattern Validation --
										   -------------------------------------------

-- Function To check that First Five Alphabet Adjacent Characters Cannot be Same 

CREATE OR REPLACE FUNCTION fn_check_adjacent_character(pan_str text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    i int;
BEGIN
    -- Ensure string length is exactly 5
    IF length(pan_str) <> 5 THEN
        RAISE EXCEPTION 'Input must be exactly 5 characters long';
    END IF;

    -- Loop through adjacent characters
    FOR i IN 1..4 
	LOOP
        IF substring(pan_str, i, 1) = substring(pan_str, i+1, 1) THEN
            RETURN true;  -- Found adjacent characters are same
        END IF;
    END LOOP;

    RETURN false;  -- No adjacent characters are the same
END;
$$;
	 
-- Function to Check First All Five Alphabet Charcaters are not formming a sequencial characters.

CREATE OR REPLACE FUNCTION fn_check_sequential_character(pan_str text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    i int;
BEGIN
    -- Ensure string length is exactly 5
    IF length(pan_str) <> 5 THEN
        RAISE EXCEPTION 'Input must be exactly 5 characters long';
    END IF;

    -- Loop through adjacent character
	-- Check if all adjacent characters are sequential (ASCII difference = 1)
	FOR i IN 1..4 
	LOOP
        IF ascii(substring(pan_str, i+1 , 1)) - ascii(substring(pan_str, i , 1)) != 1 THEN
            RETURN false;  -- Not Forming a Full Sequence
        END IF;
    END LOOP;

    RETURN true;  -- Forming a sequencetial characters
END;
$$;

-- Function To check that Next Four Numeric Adjacent Characters Cannot be Same.

CREATE OR REPLACE FUNCTION fn_check_numeric_adjacent_character(pan_str text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    i int;
BEGIN
    -- Ensure string length is exactly 4
    IF length(pan_str) <> 4 THEN
        RAISE EXCEPTION 'Input must be exactly 4 characters long';
    END IF;

    -- Loop through adjacent characters
    FOR i IN 1..3 
	LOOP
        IF substring(pan_str, i, 1) = substring(pan_str, i+1, 1) THEN
            RETURN true;  -- Found adjacent characters are same
        END IF;
    END LOOP;

    RETURN false;  -- No adjacent characters are the same
END;
$$;

-- Function to Check Next Four Numeric Charcaters are not formming a sequencial characters.

CREATE OR REPLACE FUNCTION fn_check_numeric_sequential_character(pan_str text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    i int;
BEGIN
    -- Ensure string length is exactly 4
    IF length(pan_str) <> 4 THEN
        RAISE EXCEPTION 'Input must be exactly 4 characters long';
    END IF;

    -- Loop through adjacent character
	-- Check if all numeric adjacent characters are sequential (ASCII difference = 1)
	FOR i IN 1..3 
	LOOP
        IF ascii(substring(pan_str, i+1 , 1)) - ascii(substring(pan_str, i , 1)) != 1 THEN
            RETURN false;  -- Not Forming a Full Sequence
        END IF;
    END LOOP;

    RETURN true;  -- Forming a sequencetial characters
END;
$$;
-- Regular Expression to Validate the pattern of PAN Numbers.
SELECT 
     *
FROM pan_numbers
WHERE UPPER(TRIM(COALESCE(pan_raw_text, ''))) ~ '^[A-Z]{5}[0-9]{4}[A-Z]$';
                                        
                                         ------------------------------------------    
                                         -- Valid and Invaild Pan Categorization --
										 ------------------------------------------

CREATE VIEW vw_valid_invalid_pans AS
WITH cleaned_pan_cte AS (
    -- Step 1: Clean PAN numbers
    -- Trim spaces, convert to uppercase, remove blanks, and ensure uniqueness
    SELECT DISTINCT UPPER(TRIM(pan_raw_text)) AS cleaned_pan_numbers
    FROM pan_numbers
    WHERE COALESCE(TRIM(pan_raw_text), '') <> ''
),
valid_pan_cte AS (
    -- Step 2: Apply validation rules
    -- a) First 5 chars: no adjacent or sequential letters
    -- b) Next 4 chars: no adjacent or sequential digits
    -- c) Regex check: PAN must match pattern AHGVE1276F
    SELECT *
    FROM cleaned_pan_cte
    WHERE fn_check_adjacent_character(LEFT(cleaned_pan_numbers, 5)) = FALSE
      AND fn_check_sequential_character(LEFT(cleaned_pan_numbers, 5)) = FALSE
      AND fn_check_numeric_adjacent_character(SUBSTRING(cleaned_pan_numbers, 6, 4)) = FALSE
      AND fn_check_numeric_sequential_character(SUBSTRING(cleaned_pan_numbers, 6, 4)) = FALSE
      AND cleaned_pan_numbers ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
)
-- Step 3: Final output
-- Join cleaned PANs with valid PANs to mark status
SELECT
    cpc.cleaned_pan_numbers,
    CASE
        WHEN vpc.cleaned_pan_numbers IS NOT NULL THEN 'Valid Pan'
        ELSE 'Invalid Pan'
    END AS status
FROM cleaned_pan_cte AS cpc
LEFT JOIN valid_pan_cte AS vpc
    ON cpc.cleaned_pan_numbers = vpc.cleaned_pan_numbers;

                                                           --------------------
                                                           -- Summary Report -- 
											               --------------------

-- Purpose:
-- Summarize PAN number processing results:
--   1. Total PANs processed (from pan_numbers table)
--   2. Count of valid PANs (from vw_valid_invalid_pans view)
--   3. Count of invalid PANs (from vw_valid_invalid_pans view)
--   4. Count of incomplete PANs (derived as difference)

WITH summary_cte AS (
    SELECT
        -- Total PANs processed across the system
        (SELECT COUNT(*) FROM pan_numbers) AS total_processed_pan_numbers,

        -- Count of PANs marked as 'Valid Pan'
        COUNT(*) FILTER (WHERE status = 'Valid Pan') AS total_valid_pan_numbers,

        -- Count of PANs marked as 'Invalid Pan'
        COUNT(*) FILTER (WHERE status = 'Invalid Pan') AS total_invalid_pan_numbers
    FROM vw_valid_invalid_pans
)
SELECT
    *,
    -- Incomplete PANs = total processed - (valid + invalid)
    (total_processed_pan_numbers 
     - total_valid_pan_numbers 
     - total_invalid_pan_numbers) AS total_incomplete_pan_numbers
FROM summary_cte;

COMMENT ON TABLE pan_numbers IS 'Staging table for Pan Numbers Cleaning and Validating';

COMMENT ON VIEW vw_valid_invalid_pans IS 'View that categorizes PAN numbers as Valid Pan / Invalid Pan based on format and business rules.';

COMMENT ON COLUMN vw_valid_invalid_pans.cleaned_pan_numbers IS 'Cleaned PAN (UPPER + TRIM)';

COMMENT ON COLUMN vw_valid_invalid_pans.status IS 'Valid Pan / Invalid Pan';


COMMENT ON FUNCTION fn_check_adjacent_character(text) IS 'Returns TRUE if any two adjacent characters in the input string are the same (used for first 5 letters of PAN).';

COMMENT ON FUNCTION fn_check_sequential_character(text) IS 'Returns TRUE if all adjacent characters in the input string form a strict sequence (e.g., ABCDE).';

COMMENT ON FUNCTION fn_check_numeric_adjacent_character(text) IS 'Returns TRUE if any two adjacent characters in the input string are the same (used for 4 digits of PAN).';

COMMENT ON FUNCTION fn_check_numeric_sequential_character(text) IS 'Returns TRUE if all adjacent characters in the input string form a strict sequence (e.g., 1234).';

