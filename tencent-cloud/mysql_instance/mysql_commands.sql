CREATE TABLE PatientData (
    date DATE,
    patient_id VARCHAR(10),
    gender VARCHAR(10),
    coverage INT CHECK (coverage BETWEEN 10 AND 300),
    purity_sample INT CHECK (purity_sample BETWEEN 10 AND 100),
    cancer_status VARCHAR(10),
    directory_sample VARCHAR(255),
    fileapikey VARCHAR(255),
    PRIMARY KEY ( patient_id),
    FOREIGN KEY ( patient_id) REFERENCES userdataiot(date, patient_id)
);

-- Insert values into table
INSERT INTO patientdata (date, patient_id, gender, coverage ,purity_sample, cancer_status, directory_sample, fileapikey) 
VALUES ('2023-7-04', "P001", 'XY', 60 ,80, 'normal','https:test-url-pj1b', 'fileapikey1b');
INSERT INTO patientdata (date, patient_id, gender, coverage ,purity_sample, cancer_status, directory_sample, fileapikey) 
VALUES ('2023-7-04', "P001", 'XY', 150 ,75, 'tumor','https:test-url-pj1', 'fileapikey1t');
INSERT INTO patientdata (date, patient_id, gender, coverage ,purity_sample, cancer_status, directory_sample, fileapikey) 
VALUES ('2023-6-04', "P002", 'XX', 100 ,92, 'normal','https:test-url-pj2b', 'fileapikey2b');
INSERT INTO patientdata (date, patient_id, gender, coverage ,purity_sample, cancer_status, directory_sample, fileapikey) 
VALUES ('2023-6-04', "P002", 'XX', 40 ,60, 'tumor', 'https:test-url-pj2', 'fileapikey2t');
INSERT INTO patientdata (date, patient_id, gender, coverage ,purity_sample, cancer_status, directory_sample, fileapikey) 
VALUES ('2023-5-04', "P003", 'XY', 170 ,73, 'normal', 'https:test-url-pj3b', 'fileapikey3b');
INSERT INTO patientdata (date, patient_id, gender, coverage ,purity_sample, cancer_status, directory_sample, fileapikey) 
VALUES ('2023-5-04', "P003", 'XY', 140 ,75, 'tumor', 'https:test-url-pj3', 'fileapikey3t');
INSERT INTO patientdata (date, patient_id, gender, coverage ,purity_sample, cancer_status, directory_sample, fileapikey) 
VALUES ('2023-4-04', "P004", 'XX', 30 ,77, 'normal', 'https:test-url-pj4b', 'fileapikey4b');
INSERT INTO patientdata (date, patient_id, gender, coverage ,purity_sample, cancer_status, directory_sample, fileapikey) 
VALUES ('2023-4-04', "P004", 'XX', 70 ,66, 'tumor', 'https:test-url-pj4', 'fileapikey4t');

-- Create HealthPassport Table
CREATE TABLE HealthPassport ( 
    date DATE, 
    patient_id VARCHAR(255), 
    gender VARCHAR(10), 
    country VARCHAR(10), 
    doctor_appointed VARCHAR(50),
    nhi VARCHAR(10),
    blood_type VARCHAR(10),
    allergies VARCHAR(10),
    vaccines VARCHAR(10),
    directory_sample VARCHAR(255) );

INSERT INTO healthpassport (date, patient_id, gender, country, doctor_appointed, nhi, blood_type, allergies, vaccines, directory_sample) 
VALUES ('2023-7-04', 'p1', 'XY', 'AND' 'dr.name1', 222, 'A',1, 3,'https:test-url-pj1b');
INSERT INTO healthpassport (date, patient_id, gender, country, doctor_appointed, nhi, blood_type, allergies, vaccines, directory_sample) 
VALUES ('2023-7-04', 'p2', 'XX', 'MRD' 'dr.name2', 123, "B",2, 2,'https:test-url-pj2b');
INSERT INTO healthpassport (date, patient_id, gender, country, doctor_appointed, nhi, blood_type, allergies, vaccines, directory_sample) 
VALUES ('2023-7-04', 'p3', 'XY', 'GDR' 'dr.name2', 312, "AB",3, 1,'https:test-url-pj3b');
INSERT INTO healthpassport (date, patient_id, gender, country, doctor_appointed, nhi, blood_type, allergies, vaccines, directory_sample) 
VALUES ('2023-7-04', 'p4', 'XY', 'RHN' 'dr.name2', 312, "O",3, 3,'https:test-url-pj4b');


CREATE TABLE userdataiot (
    date DATE,
    patient_id VARCHAR(10), 
    steps_walked INT,
    healthrate INT,
    calories INT,
    bmi INT,
    distance INT,
    sleep INT,
    city VARCHAR(50),
    PRIMARY KEY (patient_id),
    FOREIGN KEY (city) REFERENCES smartcity(city)
);

CREATE TABLE smartcity(
    date DATE,
    city VARCHAR(50) PRIMARY KEY,
    temperature INT,
    airquality INT CHECK (airquality BETWEEN 0 AND 100),
    uvexposure INT,
    humidity INT CHECK (humidity BETWEEN 0 AND 100));

-- Populate smartcity table
INSERT INTO smartcity (date, city, temperature, airquality, uvexposure, humidity)
VALUES 
    ('2023-11-22', 'SmartCity1', 25, 80, 5, 60),
    ('2023-11-22', 'SmartCity2', 28, 70, 7, 55),
    ('2023-11-22', 'SmartCity3', 22, 75, 6, 65);

-- Populate userdataiot table
INSERT INTO userdataiot (date, patient_id, steps_walked, healthrate, calories, bmi, distance, sleep, city)
VALUES 
    ('2023-11-22', 'P001', 8000, 75, 500, 25, 10, 7, 'SmartCity1'),
    ('2023-11-22', 'P002', 10000, 80, 600, 22, 15, 8, 'SmartCity2'),
    ('2023-11-22', 'P003', 12000, 85, 700, 20, 18, 7, 'SmartCity3'),
    ('2023-11-22', 'P004', 9000, 78, 550, 23, 12, 6, 'SmartCity1'),
    ('2023-11-22', 'P005', 11000, 82, 650, 21, 17, 8, 'SmartCity2'),
    ('2023-11-22', 'P006', 9500, 77, 520, 24, 11, 7, 'SmartCity3'),
    ('2023-11-22', 'P007', 10500, 81, 580, 22, 16, 8, 'SmartCity1'),
    ('2023-11-22', 'P008', 8800, 76, 480, 26, 9, 6, 'SmartCity2'),
    ('2023-11-22', 'P009', 11500, 83, 670, 20, 20, 7, 'SmartCity3'),
    ('2023-11-22', 'P010', 9200, 79, 530, 23, 13, 6, 'SmartCity1');
