SET GLOBAL local_infile = 1;
 --- Create DATABASE
 CREATE DATABASE IF NOT EXISTS health_care;
 USE health_care;
 
 --- show imported table
 SELECT * FROM data_set;
 
--- Check Missing Values and Remove Spaces
SELECT
    SUM(Patient_ID IS NULL OR TRIM(Patient_ID) = '') AS missing_Patient_ID,
    SUM(Survey_Date IS NULL OR TRIM(Survey_Date) = '') AS missing_Survey_Date,
    SUM(Gender IS NULL OR TRIM(Gender) = '') AS missing_Gender,
    SUM(Age IS NULL OR TRIM(Age) = '') AS missing_Age,
    SUM(Department IS NULL OR TRIM(Department) = '') AS missing_Department,
    SUM(Admission_Type IS NULL OR TRIM(Admission_Type) = '') AS missing_Admission_Type,
    SUM(Length_of_Stay_Days IS NULL OR TRIM(Length_of_Stay_Days) = '') AS missing_Length_of_Stay_Days,
    SUM(Appointment_Delay_Minutes IS NULL OR TRIM(Appointment_Delay_Minutes) = '') AS missing_Appointment_Delay_Minutes,
    SUM(Doctor_Workload_Patients_Per_Doctor_Day IS NULL OR TRIM(Doctor_Workload_Patients_Per_Doctor_Day) = '') AS missing_Doctor_Workload_Patients_Per_Doctor_Day,
    SUM(Doctor_Rating IS NULL OR TRIM(Doctor_Rating) = '') AS missing_Doctor_Rating,
    SUM(Cleanliness_Rating IS NULL OR TRIM(Cleanliness_Rating) = '') AS missing_Cleanliness_Rating,
    SUM(Staff_Rating IS NULL OR TRIM(Staff_Rating) = '') AS missing_Staff_Rating,
    SUM(NPS_Score IS NULL OR TRIM(NPS_Score) = '') AS missing_NPS_Score,
    SUM(Feedback_Category IS NULL OR TRIM(Feedback_Category) = '') AS missing_Feedback_Category,
    SUM(Feedback_Text IS NULL OR TRIM(Feedback_Text) = '') AS missing_Feedback_Text,
    SUM(Complaint_Count IS NULL OR TRIM(Complaint_Count) = '') AS missing_Complaint_Count,
    SUM(Hospital_Branch IS NULL OR TRIM(Hospital_Branch) = '') AS missing_Hospital_Branch,
    SUM(Insurance_Type IS NULL OR TRIM(Insurance_Type) = '') AS missing_Insurance_Type,
    SUM(Visit_Channel IS NULL OR TRIM(Visit_Channel) = '') AS missing_Visit_Channel,
    SUM(Visit_Outcome IS NULL OR TRIM(Visit_Outcome) = '') AS missing_Visit_Outcome,
    SUM(service_type IS NULL OR TRIM(service_type) = '') AS missing_service_type,
    SUM(service_completed IS NULL OR TRIM(service_completed) = '') AS missing_service_completed,
    SUM(cancelation_reason IS NULL OR TRIM(cancelation_reason) = '') AS missing_cancelation_reason,
    SUM(equipment_used IS NULL OR TRIM(equipment_used) = '') AS missing_equipment_used,
    SUM(equipment_availability IS NULL OR TRIM(equipment_availability) = '') AS missing_equipment_availability,
    SUM(system_downtime_minutes IS NULL OR TRIM(system_downtime_minutes) = '') AS missing_system_downtime_minutes,
    SUM(staff_on_duty IS NULL OR TRIM(staff_on_duty) = '') AS missing_staff_on_duty,
    SUM(bed_occupancy_rate IS NULL OR TRIM(bed_occupancy_rate) = '') AS missing_bed_occupancy_rate,
    SUM(queue_length IS NULL OR TRIM(queue_length) = '') AS missing_queue_length, 
    SUM(doctor_rating_avg IS NULL OR TRIM(doctor_rating_avg) = '') AS missing_doctor_rating_avg,
    SUM(patient_segment IS NULL OR TRIM(patient_segment) = '') AS missing_patient_segment,
    SUM(profit_per_patient IS NULL OR TRIM(profit_per_patient) = '') AS missing_profit_per_patient,
    SUM(lifetime_value_patient IS NULL OR TRIM(lifetime_value_patient) = '') AS missing_lifetime_value_patient 
FROM `data_set`; 

--- Check duplicate by patient_ID
SELECT Patient_ID, COUNT(*) as count_patient_ID
FROM data_set
WHERE Patient_ID IS NOT NULL
GROUP BY Patient_ID
HAVING COUNT(*) > 1;

--- inconsistency view
SELECT Gender, COUNT(*) AS Count_Gender 
FROM data_set
Group BY Gender
ORDER BY Count_Gender DESC;
SELECT Department, COUNT(*) AS Count_Department
FROM data_set
Group BY Department
ORDER BY Count_Department DESC;
SELECT Admission_Type, COUNT(*) AS Count_Admission_Type
FROM data_set
Group BY Admission_Type
ORDER BY Count_Admission_Type DESC;
SELECT Feedback_Category, COUNT(*) AS Count_Feedback_Category
FROM data_set
Group BY Feedback_Category
ORDER BY Count_Feedback_Category DESC;
SELECT Hospital_Branch, COUNT(*) AS Count_Hospital_Branch
FROM data_set
Group BY Hospital_Branch
ORDER BY Count_Hospital_Branch DESC;
SELECT Visit_Channel, COUNT(*) AS Count_Visit_Channel
FROM data_set
Group BY Visit_Channel
ORDER BY Count_Visit_Channel DESC;
SELECT Service_Shift, COUNT(*) AS Count_Service_Shift
FROM data_set
Group BY Service_Shift
ORDER BY Count_Service_Shift DESC;
SELECT Visit_Outcome, COUNT(*) AS Count_Visit_Outcome
FROM data_set
Group BY Visit_Outcome
ORDER BY Count_Visit_Outcome DESC;
SELECT service_type, COUNT(*) AS Count_service_type
FROM data_set
Group BY service_type
ORDER BY Count_service_type DESC;
SELECT equipment_availability, COUNT(*) AS Count_equipment_availability
FROM data_set
Group BY equipment_availability
ORDER BY Count_equipment_availability DESC;
SELECT patient_segment, COUNT(*) AS Count_patient_segment
FROM data_set
Group BY patient_segment
ORDER BY Count_patient_segment DESC;

--- Clean Text Standard case
-- Disable safe updates for this session
SET SQL_SAFE_UPDATES = 0;
UPDATE `data_set`
SET `Gender` = 'Female'
WHERE TRIM(`Gender`) = 'female';
UPDATE `data_set`
SET `Department` = CASE 
    WHEN TRIM(`Department`) = 'cardiology' THEN 'Cardiology'
    WHEN TRIM(`Department`) = 'emergency' THEN 'Emergency'
    ELSE TRIM(`Department`) 
END;
UPDATE `data_set`
SET `Hospital_Branch` = CASE 
    WHEN TRIM(`Hospital_Branch`) = 'central' THEN 'Central'
    WHEN TRIM(`Hospital_Branch`) = 'south' THEN 'South'
    ELSE TRIM(`Hospital_Branch`) 
END;
UPDATE `data_set`
SET `Service_Shift` = CASE 
    WHEN TRIM(`Service_Shift`) = 'evining' THEN 'Evining'
    ELSE TRIM(`Service_Shift`)
END;

--- Correct Data format
ALTER TABLE `data_set`
MODIFY COLUMN `Survey_Date` DATE;
DESCRIBE `data_set`;
--- Remove duplicate Values based on patient ID
USE `health_care`;

CREATE TABLE `data_set_temp` AS
SELECT * FROM (
    SELECT *, 
		 ROW_NUMBER() OVER (PARTITION BY `Patient_ID` ORDER BY `Survey_Date` DESC) as row_num
    FROM `data_set`
) as ranked_table
WHERE row_num = 1;
ALTER TABLE `data_set_temp` DROP COLUMN row_num;
DROP TABLE `data_set`;
ALTER TABLE `data_set_temp` RENAME TO `data_set`;
SELECT Patient_ID, COUNT(*) as count_patient_ID
FROM data_set
WHERE Patient_ID IS NOT NULL
GROUP BY Patient_ID
HAVING COUNT(*) > 1;

--- Stat for Numerical data type
DESCRIBE `data_set`;

SELECT 
    COUNT(`age`) AS age_Count, MIN(`age`) AS age_Min, MAX(`age`) AS age_Max, ROUND(AVG(`age`), 2) AS age_Avg, ROUND(STDDEV(`age`), 2) AS age_StdDev,
    
    COUNT(`Length_of_Stay_Days`) AS Length_of_Stay_Count, MIN(`Length_of_Stay_Days`) AS Length_of_Stay_Min, MAX(`Length_of_Stay_Days`) AS Length_of_Stay_Max, ROUND(AVG(`Length_of_Stay_Days`), 2) AS Length_of_Stay_Avg, ROUND(STDDEV(`Length_of_Stay_Days`), 2) AS Length_of_Stay_StdDev,
    
    COUNT(`Appointment_Delay_Minutes`) AS Delay_Minutes_Count, MIN(`Appointment_Delay_Minutes`) AS Delay_Minutes_Min, MAX(`Appointment_Delay_Minutes`) AS Delay_Minutes_Max, ROUND(AVG(`Appointment_Delay_Minutes`), 2) AS Delay_Minutes_Avg, ROUND(STDDEV(`Appointment_Delay_Minutes`), 2) AS Delay_Minutes_StdDev,
    
    COUNT(`Doctor_Workload_Patients_Per_Doctor_Day`) AS Workload_Count, MIN(`Doctor_Workload_Patients_Per_Doctor_Day`) AS Workload_Min, MAX(`Doctor_Workload_Patients_Per_Doctor_Day`) AS Workload_Max, ROUND(AVG(`Doctor_Workload_Patients_Per_Doctor_Day`), 2) AS Workload_Avg, ROUND(STDDEV(`Doctor_Workload_Patients_Per_Doctor_Day`), 2) AS Workload_StdDev,
    
    COUNT(`Doctor_Rating`) AS Doctor_Rating_Count, MIN(`Doctor_Rating`) AS Doctor_Rating_Min, MAX(`Doctor_Rating`) AS Doctor_Rating_Max, ROUND(AVG(`Doctor_Rating`), 2) AS Doctor_Rating_Avg, ROUND(STDDEV(`Doctor_Rating`), 2) AS Doctor_Rating_StdDev,
    
    COUNT(`Cleanliness_Rating`) AS Cleanliness_Count, MIN(`Cleanliness_Rating`) AS Cleanliness_Min, MAX(`Cleanliness_Rating`) AS Cleanliness_Max, ROUND(AVG(`Cleanliness_Rating`), 2) AS Cleanliness_Avg, ROUND(STDDEV(`Cleanliness_Rating`), 2) AS Cleanliness_StdDev,
    
    COUNT(`Staff_Rating`) AS Staff_Rating_Count, MIN(`Staff_Rating`) AS Staff_Rating_Min, MAX(`Staff_Rating`) AS Staff_Rating_Max, ROUND(AVG(`Staff_Rating`), 2) AS Staff_Rating_Avg, ROUND(STDDEV(`Staff_Rating`), 2) AS Staff_Rating_StdDev,
    
    COUNT(`NPS_Score`) AS NPS_Count, MIN(`NPS_Score`) AS NPS_Min, MAX(`NPS_Score`) AS NPS_Max, ROUND(AVG(`NPS_Score`), 2) AS NPS_Avg, ROUND(STDDEV(`NPS_Score`), 2) AS NPS_StdDev,
    
    COUNT(`Complaint_Count`) AS Complaint_Count, MIN(`Complaint_Count`) AS Complaint_Min, MAX(`Complaint_Count`) AS Complaint_Max, ROUND(AVG(`Complaint_Count`), 2) AS Complaint_Avg, ROUND(STDDEV(`Complaint_Count`), 2) AS Complaint_StdDev,
    
    COUNT(`system_downtime_minutes`) AS Downtime_Count, MIN(`system_downtime_minutes`) AS Downtime_Min, MAX(`system_downtime_minutes`) AS Downtime_Max, ROUND(AVG(`system_downtime_minutes`), 2) AS Downtime_Avg, ROUND(STDDEV(`system_downtime_minutes`), 2) AS Downtime_StdDev,
    
    COUNT(`staff_on_duty`) AS Staff_Duty_Count, MIN(`staff_on_duty`) AS Staff_Duty_Min, MAX(`staff_on_duty`) AS Staff_Duty_Max, ROUND(AVG(`staff_on_duty`), 2) AS Staff_Duty_Avg, ROUND(STDDEV(`staff_on_duty`), 2) AS Staff_Duty_StdDev,
    
    COUNT(`bed_occupancy_rate`) AS Bed_Occupancy_Count, MIN(`bed_occupancy_rate`) AS Bed_Occupancy_Min, MAX(`bed_occupancy_rate`) AS Bed_Occupancy_Max, ROUND(AVG(`bed_occupancy_rate`), 2) AS Bed_Occupancy_Avg, ROUND(STDDEV(`bed_occupancy_rate`), 2) AS Bed_Occupancy_StdDev,
    
    COUNT(`queue_length`) AS Queue_Count, MIN(`queue_length`) AS Queue_Min, MAX(`queue_length`) AS Queue_Max, ROUND(AVG(`queue_length`), 2) AS Queue_Avg, ROUND(STDDEV(`queue_length`), 2) AS Queue_StdDev,
    
    COUNT(`doctor_rating_avg`) AS Doc_Rating_Avg_Count, MIN(`doctor_rating_avg`) AS Doc_Rating_Avg_Min, MAX(`doctor_rating_avg`) AS Doc_Rating_Avg_Max, ROUND(AVG(`doctor_rating_avg`), 2) AS Doc_Rating_Avg_Actual, ROUND(STDDEV(`doctor_rating_avg`), 2) AS Doc_Rating_Avg_StdDev,
    
    COUNT(`profit_per_patient`) AS Profit_Count, MIN(`profit_per_patient`) AS Profit_Min, MAX(`profit_per_patient`) AS Profit_Max, ROUND(AVG(`profit_per_patient`), 2) AS Profit_Avg, ROUND(STDDEV(`profit_per_patient`), 2) AS Profit_StdDev,
    
    COUNT(`lifetime_value_patient`) AS LTV_Count, MIN(`lifetime_value_patient`) AS LTV_Min, MAX(`lifetime_value_patient`) AS LTV_Max, ROUND(AVG(`lifetime_value_patient`), 2) AS LTV_Avg, ROUND(STDDEV(`lifetime_value_patient`), 2) AS LTV_StdDev;
UPDATE `data_set`
SET `Feedback_Category` = 'Unspecified'
WHERE `Feedback_Category` IS NULL 
   OR `Feedback_Category` = '' 
   OR TRIM(`Feedback_Category`) = '';
SELECT COUNT(*) AS Missing_Count
FROM `data_set`
WHERE `Feedback_Category` IS NULL OR `Feedback_Category` = '';
UPDATE `data_set`
SET `Feedback_Text` = 'Unspecified'
WHERE `Feedback_Text` IS NULL OR `Feedback_Text` = '';  
SELECT COUNT(*) AS Missing_Count
FROM `data_set`
WHERE `Feedback_Text` IS NULL OR `Feedback_Text` = '';
UPDATE `data_set`
SET `Hospital_Branch` = 'Unspecified'
WHERE `Hospital_Branch` IS NULL OR `Hospital_Branch` = '';
UPDATE `data_set`
SET `Insurance_Type` = 'Unspecified'
WHERE `Insurance_Type` IS NULL OR `Insurance_Type` = '';
UPDATE `data_set`
SET `Visit_Channel` = 'Unspecified'
WHERE `Visit_Channel` IS NULL 
   OR `Visit_Channel` = '' 
   OR TRIM(`Visit_Channel`) = '';
   SELECT `Patient_ID`, `Visit_Channel`
FROM `data_set`
WHERE `Visit_Channel` = 'Unspecified';
UPDATE `data_set`
SET `cancelation_reason` = 'Visit completed'
WHERE `service_completed` = 'Yes' 
  AND (`cancelation_reason` IS NULL OR `cancelation_reason` = '');
  
--- Create Dim_Patient table
CREATE TABLE IF NOT EXISTS `Dim_Patient` (
    `Patient_ID` VARCHAR(50) NOT NULL,
    `Gender` VARCHAR(20) NULL,
    `Age` INT NULL,
    `patient_segment` VARCHAR(50) NULL,
    `profit_per_patient` DECIMAL(15, 4) NULL,
    `lifetime_value_patient` DECIMAL(15, 4) NULL,
    PRIMARY KEY (`Patient_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `Dim_Patient` (
    `Patient_ID`, 
    `Gender`, 
    `Age`, 
    `patient_segment`, 
    `profit_per_patient`, 
    `lifetime_value_patient`
)
SELECT DISTINCT 
    `Patient_ID`, 
    `Gender`, 
    `Age`, 
    `patient_segment`, 
    `profit_per_patient`, 
    `lifetime_value_patient`
FROM `data_set`; 
SELECT * FROM `Dim_Patient` LIMIT 10;

--- Create Dim_Hospital table
CREATE TABLE IF NOT EXISTS `Dim_Hospital` (
    `Branch_Key` INT NOT NULL AUTO_INCREMENT, 
    `Hospital_Branch` VARCHAR(100) NOT NULL,  
    PRIMARY KEY (`Branch_Key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `Dim_Hospital` (`Hospital_Branch`)
SELECT DISTINCT `Hospital_Branch`
FROM `data_set`
WHERE `Hospital_Branch` IS NOT NULL;
SELECT * FROM `Dim_Hospital`;

--- Create Dim_Department table

CREATE TABLE `Dim_Department` (
    `Department_Key` INT NOT NULL AUTO_INCREMENT, 
    `Department` VARCHAR(100) NOT NULL,  
    PRIMARY KEY (`Department_Key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `Dim_Department` (`Department`) 
SELECT DISTINCT `Department` 
FROM `data_set` 
WHERE `Department` IS NOT NULL;
SELECT * FROM `Dim_Department`;

--- Create Dim_Date table
CREATE TABLE IF NOT EXISTS `Dim_Date` (
    `Date_Key` INT NOT NULL AUTO_INCREMENT,
    `Survey_Date` DATE NOT NULL,
    `Year` INT NOT NULL,
    `Quarter` INT NOT NULL,
    `Month_Number` INT NOT NULL,
    `Month_Name` VARCHAR(20) NOT NULL,
    `Day_Of_Month` INT NOT NULL,
    `Day_Name` VARCHAR(20) NOT NULL,
    PRIMARY KEY (`Date_Key`),
    UNIQUE KEY (`Survey_Date`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `Dim_Date` (
    `Survey_Date`, 
    `Year`, 
    `Quarter`, 
    `Month_Number`, 
    `Month_Name`, 
    `Day_Of_Month`, 
    `Day_Name`
)
SELECT DISTINCT 
    `Survey_Date`,  
    YEAR(`Survey_Date`),
    QUARTER(`Survey_Date`),
    MONTH(`Survey_Date`),
    MONTHNAME(`Survey_Date`),
    DAY(`Survey_Date`),
    DAYNAME(`Survey_Date`)
FROM `data_set`
WHERE `Survey_Date` IS NOT NULL; 
SELECT * FROM `Dim_Date` LIMIT 10;

--- Create Dim_service
CREATE TABLE IF NOT EXISTS `Dim_Service` (
    `Service_Key` INT NOT NULL AUTO_INCREMENT,
    `service_type` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`Service_Key`),
    UNIQUE KEY (`service_type`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `Dim_Service` (`service_type`)
SELECT DISTINCT `service_type`
FROM `data_set`
WHERE `service_type` IS NOT NULL AND TRIM(`service_type`) != '';
SELECT * FROM `Dim_Service`;

--- Create Dim_Visit table
CREATE TABLE IF NOT EXISTS `Dim_Visit` (
    `Visit_Key` INT NOT NULL AUTO_INCREMENT,
    `Visit_Channel` VARCHAR(100) NULL,
    `Feedback_Category` VARCHAR(100) NULL,
    `Insurance_Type` VARCHAR(100) NULL,
    `Service_Shift` VARCHAR(50) NULL,
    `Visit_Outcome` VARCHAR(100) NULL,
    `service_completed` VARCHAR(50) NULL,
    `cancelation_reason` VARCHAR(100) NULL,
    `equipment_used` VARCHAR(100) NULL,
    `equipment_availability` VARCHAR(50) NULL,
    PRIMARY KEY (`Visit_Key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `Dim_Visit` (
    `Visit_Channel`,
    `Feedback_Category`,
    `Insurance_Type`,
    `Service_Shift`,
    `Visit_Outcome`,
    `service_completed`,
    `cancelation_reason`,
    `equipment_used`,
    `equipment_availability`
)
SELECT DISTINCT 
    `Visit_Channel`,
    `Feedback_Category`,
    `Insurance_Type`,
    `Service_Shift`,
    `Visit_Outcome`,
    `service_completed`,
    `cancelation_reason`,
    `equipment_used`,
    `equipment_availability`
FROM `data_set`;
SELECT * FROM `Dim_Visit` LIMIT 10;
DESCRIBE `data_set`;

--- Create Fact_Table
CREATE TABLE IF NOT EXISTS `Fact_Healthcare` (

    Fact_ID INT NOT NULL AUTO_INCREMENT,

    -- Foreign Keys
    Patient_ID VARCHAR(50) NOT NULL,
    Branch_Key INT NOT NULL,
    Department_Key INT NOT NULL,
    Date_Key INT NOT NULL,
    Service_Key INT NOT NULL,
    Visit_Key INT NOT NULL,

    -- Measures
    Length_of_Stay_Days INT,
    Appointment_Delay_Minutes INT,
    Doctor_Workload_Patients_Per_Doctor_Day INT,
    Doctor_Rating DECIMAL(5,2),
    Cleanliness_Rating DECIMAL(5,2),
    Staff_Rating DECIMAL(5,2),
    NPS_Score INT,
    Complaint_Count INT,
    system_downtime_minutes INT,
    staff_on_duty INT,
    bed_occupancy_rate DECIMAL(5,2),
    queue_length INT,
    doctor_rating_avg DECIMAL(5,2),
    profit_per_patient DECIMAL(15,4),
    lifetime_value_patient DECIMAL(15,4),

    PRIMARY KEY (Fact_ID),

    -- Foreign Key Constraints
    CONSTRAINT fk_patient
        FOREIGN KEY (Patient_ID)
        REFERENCES Dim_Patient(Patient_ID),

    CONSTRAINT fk_branch
        FOREIGN KEY (Branch_Key)
        REFERENCES Dim_Hospital(Branch_Key),

    CONSTRAINT fk_department
        FOREIGN KEY (Department_Key)
        REFERENCES Dim_Department(Department_Key),

    CONSTRAINT fk_date
        FOREIGN KEY (Date_Key)
        REFERENCES Dim_Date(Date_Key),

    CONSTRAINT fk_service
        FOREIGN KEY (Service_Key)
        REFERENCES Dim_Service(Service_Key),

    CONSTRAINT fk_visit
        FOREIGN KEY (Visit_Key)
        REFERENCES Dim_Visit(Visit_Key)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO Fact_Healthcare (

    Patient_ID,
    Branch_Key,
    Department_Key,
    Date_Key,
    Service_Key,
    Visit_Key,

    Length_of_Stay_Days,
    Appointment_Delay_Minutes,
    Doctor_Workload_Patients_Per_Doctor_Day,
    Doctor_Rating,
    Cleanliness_Rating,
    Staff_Rating,
    NPS_Score,
    Complaint_Count,
    system_downtime_minutes,
    staff_on_duty,
    bed_occupancy_rate,
    queue_length,
    doctor_rating_avg,
    profit_per_patient,
    lifetime_value_patient
)

SELECT

    ds.Patient_ID,
    dh.Branch_Key,
    dd.Department_Key,
    dt.Date_Key,
    dsrv.Service_Key,
    dv.Visit_Key,

    ds.Length_of_Stay_Days,
    ds.Appointment_Delay_Minutes,
    ds.Doctor_Workload_Patients_Per_Doctor_Day,
    ds.Doctor_Rating,
    ds.Cleanliness_Rating,
    ds.Staff_Rating,
    ds.NPS_Score,
    ds.Complaint_Count,
    ds.system_downtime_minutes,
    ds.staff_on_duty,
    ds.bed_occupancy_rate,
    ds.queue_length,
    ds.doctor_rating_avg,
    ds.profit_per_patient,
    ds.lifetime_value_patient

FROM data_set ds

JOIN Dim_Hospital dh
    ON ds.Hospital_Branch = dh.Hospital_Branch

JOIN Dim_Department dd
    ON ds.Department = dd.Department

JOIN Dim_Date dt
    ON ds.Survey_Date = dt.Survey_Date

JOIN Dim_Service dsrv
    ON ds.service_type = dsrv.service_type

JOIN Dim_Visit dv
    ON ds.Visit_Channel = dv.Visit_Channel
   AND ds.Feedback_Category = dv.Feedback_Category
   AND ds.Insurance_Type = dv.Insurance_Type
   AND ds.Service_Shift = dv.Service_Shift
   AND ds.Visit_Outcome = dv.Visit_Outcome
   AND ds.service_completed = dv.service_completed
   AND ds.cancelation_reason = dv.cancelation_reason
   AND ds.equipment_used = dv.equipment_used
   AND ds.equipment_availability = dv.equipment_availability;




