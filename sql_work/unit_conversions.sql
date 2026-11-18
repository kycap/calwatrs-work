
USE role WB_STAFF_ACROLE;
USE role swrcb_internal_test_wr_supply_and_demand_r_acrole;

USE DATABASE SWRCB_INTERNAL_TEST; 

-- Create queries that check and, if necessary, convert units

USE DATABASE SWRCB_INTERNAL_PROD;

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'WR_CALWATRS_FLATFILES'
AND TABLE_NAME = 'ANNUAL_REPORTS';


SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'WR_CALWATRS_FLATFILES'
AND TABLE_NAME = 'ANNUAL_REPORTS'
AND COLUMN_NAME ILIKE '%UNI%'
ORDER BY COLUMN_NAME asc;
-- above looks for columns that contain "Units" in the header name

SELECT 
    AR_JANDIVERSIONVOLUME AS jan_div_volume,
    AR_MONTHLYDIVERSIONUNIT AS div_unit,
    CASE 
        -- put all column text in UPPER case to avoid things falling through cracks/differences in how data entered into field
        -- IN creates a list that the query checks
        -- if already acre-feet, no change
        WHEN UPPER(AR_MONTHLYDIVERSIONUNIT) IN ('ACRE-FEET', 'AF', 'ACRE FEET')
        THEN AR_JANDIVERSIONVOLUME
        -- if it's in gallons
        WHEN UPPER(AR_MONTHLYDIVERSIONUNIT) IN ('GALLONS', 'GAL')
        THEN AR_JANDIVERSIONVOLUME / 325851.0 -- add .0 so it does not round to whole number
        -- if it's in cubic feet
        WHEN UPPER(AR_MONTHLYDIVERSIONUNIT) IN ('CUBIC FEET', 'CU FT')
        THEN AR_JANDIVERSIONVOLUME / 43560.0 
        -- if it's something else, blank, or null
        ELSE NULL
    END AS volume_in_acre_feet
FROM ANNUAL_REPORTS;

SELECT AR_MONTHLYDIVERSIONUNIT,
    COUNT(*) AS frequency
FROM ANNUAL_REPORTS
GROUP BY AR_MONTHLYDIVERSIONUNIT
ORDER BY frequency DESC;
-- above looks through the AR_MONTHLYDIVERSIONUNIT column to see what the entries are
-- then, know what conversions to make to put any unit into Acre-Feet