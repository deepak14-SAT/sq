/*
------------------------------------------------------------
 Project: Patients Management Database 
 Author : Deepak P
------------------------------------------------------------
*/

-- ==========================================================
-- 1. DATABASE SETUP
-- ==========================================================

use first_project_hospital;

-- ==========================================================
-- 2.Schema Design
-- ==========================================================

-- Insert Patient table

create table patient(
patient_id int primary key auto_increment,
patient_name text,
D_O_B date,
gender enum("male","female") default "male",
contact int,
address text,
medical_history enum("yes","no")

);

-- Insert doctor table

create table doctor(
doctor_id int primary key auto_increment,
doctor_name text,
specialization text,
email text,
contact_no int 
);

-- Insert appointment table

create table appointment(
app_id int primary key auto_increment,
patient_id int,
doctor_id int,
app_date date,
app_time time,
app_status enum("completed","pending","withdrawn") default "pending",
foreign key (patient_id) references patient(patient_id),
foreign key (doctor_id) references doctor(doctor_id)
);

-- Insert billings table

create table billings(
bill_id int primary key auto_increment,
patient_id int,
doctor_id int,
bill_date date,
amount float,
bill_status enum("paid","not_paid","insurance_claimed") default "not_paid",
foreign key (patient_id) references patient(patient_id),
foreign key (doctor_id) references doctor(doctor_id)
);

-- ==========================================================
-- 3.Insert datas
-- ==========================================================

-- Insert values into patient table

insert into patient(patient_name,D_O_B,gender,contact,address,medical_history) values ("Joe","2025-1-1","male","987657890","73 rd cross,Bangalore","yes"),("biden","2025-1-1","male","834628284","123,london,england","no"),("trump","2025-1-9","male","24685268","whilte house,washington","yes"),("haley","2025-2-3","female","79878568","modern family S3, California", "no"),("alex","2025-2-3","female","7929292","modern family s3, California","yes"),("mullai","2025-4-4","female","23785487","ullunthurpettai , chennai","no");
select * from patient;

-- Insert values into doctor table

insert into doctor(doctor_name,specialization,email,contact_no) values ("albert","cardio","albert@123","987788878"),("einstein","physio","ein@123","754758658"),("maaran","gyno","verti@123","555555"),("vasoolraja","therapist","mbbs@123","764674888");
select * from doctor;

-- Insert values into Appointment table

insert into appointment(patient_id,doctor_id,app_date,app_time,app_status) values(1, 1, '2024-10-20', '10:00:00', 'completed'),
(2, 2, '2024-10-21', '11:30:00', 'pending'),
(3, 1, '2024-10-22', '09:00:00', 'Completed'),
(4, 3, '2024-10-23', '12:00:00', 'pending'),
(5, 4, '2024-10-24', '14:00:00', 'withdrawn'),
(6, 4, '2024-10-24', '14:00:00', 'withdrawn');
select * from appointment;

-- Insert values into Billing table

insert into billings(patient_id,doctor_id,bill_date,amount,bill_status) values (1, 1, '2024-10-20', 200.00, 'Paid'),
(2, 2, '2024-10-21', 150.00,"not_paid"),
(3, 1, '2024-10-22', 300.00, 'Paid'),
(4, 3, '2024-10-23', 250.00, 'not_paid'),
(5, 4, '2024-10-24', 400.00, "insurance_claimed"),
(6, 4, '2024-10-24', 400.00, "insurance_claimed");
select * from billings;

-- ==========================================================
-- 4.Insert queries
-- ==========================================================

-- Patient demographics by gender
SELECT gender, COUNT(*) AS total_patients
FROM patient
GROUP BY gender;

-- Doctor workload (appointments handled by each doctor)
SELECT d.doctor_name, d.specialization, COUNT(a.app_id) AS total_appointments
FROM doctor d
LEFT JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name, d.specialization
ORDER BY total_appointments DESC;

-- Revenue contribution by doctor
SELECT d.doctor_name, SUM(b.amount) AS total_revenue
FROM billings b
JOIN doctor d ON b.doctor_id = d.doctor_id
WHERE b.bill_status = 'paid'
GROUP BY d.doctor_id, d.doctor_name
ORDER BY total_revenue DESC;

-- Billing status overview
SELECT bill_status, COUNT(*) AS total_bills, SUM(amount) AS total_amount
FROM billings
GROUP BY bill_status;

-- Frequent patients (with more than 1 visit)
SELECT p.patient_name, COUNT(a.app_id) AS total_visits
FROM patient p
JOIN appointment a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name
HAVING COUNT(a.app_id) > 1
ORDER BY total_visits DESC;

-- Appointment trends by date
SELECT app_date, COUNT(*) AS appointments_count
FROM appointment
GROUP BY app_date
ORDER BY app_date;

 -- Patients with unpaid or insurance bills
SELECT p.patient_name, b.amount, b.bill_status, b.bill_date
FROM patient p
JOIN billings b ON p.patient_id = b.patient_id
WHERE b.bill_status <> 'paid';

 -- Patients with medical history = 'yes'
SELECT patient_name, D_O_B, gender, medical_history
FROM patient
WHERE medical_history = 'yes';

 -- Patients with appointments but no billing record
SELECT p.patient_name, a.app_date, d.doctor_name
FROM patient p
JOIN appointment a ON p.patient_id = a.patient_id
LEFT JOIN billings b ON p.patient_id = b.patient_id AND a.doctor_id = b.doctor_id
JOIN doctor d ON a.doctor_id = d.doctor_id
WHERE b.bill_id IS NULL;

 -- Doctor revenue vs number of appointments
SELECT d.doctor_name, COUNT(a.app_id) AS total_appointments, SUM(b.amount) AS total_revenue
FROM doctor d
LEFT JOIN appointment a ON d.doctor_id = a.doctor_id
LEFT JOIN billings b ON a.patient_id = b.patient_id AND a.doctor_id = b.doctor_id
GROUP BY d.doctor_id, d.doctor_name
ORDER BY total_revenue DESC;

 -- Specializations with most patients
SELECT d.specialization, COUNT(DISTINCT a.patient_id) AS unique_patients
FROM doctor d
JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.specialization
ORDER BY unique_patients DESC;

 -- Appointment status breakdown
SELECT app_status, COUNT(*) AS total_appointments
FROM appointment
GROUP BY app_status;

 -- Double-booked patients (two appointments same day)
SELECT p.patient_name, a.app_date, COUNT(*) AS same_day_appointments
FROM appointment a
JOIN patient p ON a.patient_id = p.patient_id
GROUP BY p.patient_id, p.patient_name, a.app_date
HAVING COUNT(*) > 1;

 -- Daily revenue
SELECT bill_date, SUM(amount) AS daily_revenue
FROM billings
WHERE bill_status = 'paid'
GROUP BY bill_date
ORDER BY bill_date;

 -- Patients contributing most revenue
SELECT p.patient_name, SUM(b.amount) AS total_spent
FROM billings b
JOIN patient p ON b.patient_id = p.patient_id
WHERE b.bill_status = 'paid'
GROUP BY p.patient_id, p.patient_name
ORDER BY total_spent DESC
LIMIT 5;




