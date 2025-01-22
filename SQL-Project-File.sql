select * from beneficiary_data;
select * from in_patient_data;
select * from out_patient_data;
select * from provider;


-- 1. Claims Analysis:
-- Retrieve the total amount reimbursed (InscClaimAmtReimbursed)
-- for inpatient claims grouped by provider.

SELECT 
    Provider,
    SUM(InscClaimAmtReimbursed) AS TotalAmountReimbursed
FROM
    in_patient_data
GROUP BY Provider
ORDER BY TotalAmountReimbursed DESC;


-- 2. Provider Insights:
-- Identify the top 5 providers with the 
-- highest number of outpatient claims.

SELECT 
    Provider, COUNT(*) AS TotalClaims
FROM
    out_patient_data
GROUP BY Provider
ORDER BY TotalClaims DESC
LIMIT 5;


-- 3. Chronic Conditions:
-- Find the number of beneficiaries with claims associated
-- with chronic conditions like diabetes (ChronicCond_Diabetes = 1).

SELECT 
    COUNT(*) AS TotalCount
FROM
    beneficiary_data
WHERE
    ChronicCond_Diabetes = 1;
    

-- 4. Gender-Based Analysis:
-- Calculate the average inpatient claim amount reimbursed 
-- (InscClaimAmtReimbursed) for each gender.

SELECT 
    b.gender,
    AVG(i.InscClaimAmtReimbursed) AS AverageReimbursed
FROM
    beneficiary_data b
        LEFT JOIN
    in_patient_data i ON b.BeneID = i.BeneID
GROUP BY b.gender;


-- 5. Beneficiary History:
-- Retrieve all claims (inpatient and outpatient) for a 
-- specific BeneID to analyze an individual beneficiary's history.

SELECT 
    BeneID, ClaimID, ClaimStartDt, ClaimEndDt, Provider, InscClaimAmtReimbursed 
FROM
    in_patient_data
WHERE
    BeneID = 'BENE21203' 
UNION SELECT 
    BeneID, ClaimID, ClaimStartDt, ClaimEndDt, Provider, InscClaimAmtReimbursed
FROM
    out_patient_data
WHERE
    BeneID = 'BENE21203';


-- 6. High-Value Claims:
-- Identify providers with claims where the admission date (AdmissionDt)
-- is in 2009 and the reimbursed amount exceeds $10,000.

SELECT 
    Provider, AdmissionDt, InscClaimAmtReimbursed
FROM
    in_patient_data
WHERE
    YEAR(AdmissionDt) = 2009
        AND InscClaimAmtReimbursed > 10000;


-- 7. Demographic Analysis:
-- Combine beneficiary demographic information with inpatient claims
-- to calculate the average deductible amount (IPAnnualDeductibleAmt) 
-- for beneficiaries aged 65+.

SELECT 
    AVG(IPAnnualDeductibleAmt) AS Avg_Deductible
FROM
    in_patient_data i
        JOIN
    beneficiary_data b ON i.BeneID = b.BeneID
WHERE
    TIMESTAMPDIFF(YEAR, b.DOB, CURDATE()) >= 65;


-- 8. Physician Involvement:
-- List all claims involving more than one physician 
-- (AttendingPhysician, OperatingPhysician, or OtherPhysician are non-null).

SELECT 
    BeneID, ClaimID, ClaimStartDt, ClaimEndDt, Provider, InscClaimAmtReimbursed,
    AttendingPhysician, OperatingPhysician, OtherPhysician
FROM
    in_patient_data
WHERE
    (AttendingPhysician IS NOT NULL AND OperatingPhysician IS NOT NULL)
    OR (AttendingPhysician IS NOT NULL AND OtherPhysician IS NOT NULL)
    OR (OperatingPhysician IS NOT NULL AND OtherPhysician IS NOT NULL)
UNION SELECT 
    BeneID, ClaimID, ClaimStartDt, ClaimEndDt, Provider, InscClaimAmtReimbursed,
    AttendingPhysician, OperatingPhysician, OtherPhysician
FROM
    out_patient_data
WHERE
    (AttendingPhysician IS NOT NULL AND OperatingPhysician IS NOT NULL)
    OR (AttendingPhysician IS NOT NULL AND OtherPhysician IS NOT NULL)
    OR (OperatingPhysician IS NOT NULL AND OtherPhysician IS NOT NULL)
        

