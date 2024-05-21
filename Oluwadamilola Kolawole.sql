-- Create the Hospital database
CREATE DATABASE BankHospitalDB;

USE BankHospitalDB
GO

--- Address table  
CREATE TABLE Address (
    AddressID INT PRIMARY KEY IDENTITY(1,1),
    Address1 NVARCHAR(255) NOT NULL,
    Address2 NVARCHAR(255),
    City NVARCHAR(100) NOT NULL,
    Postcode NVARCHAR(20),
    Country NVARCHAR(100) NOT NULL
);

--- Patient table  
CREATE TABLE Patient (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Password VARBINARY(MAX) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    MiddleName NVARCHAR(100),
    LastName NVARCHAR(100) NOT NULL,
    AddressID INT,
    Email NVARCHAR(255) CHECK (Email LIKE '%_@__%.__%'),
    Telephone NVARCHAR(20),
    Gender NVARCHAR(10),
    DateOfBirth DATE,
    InsuranceNumber NVARCHAR(9) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    ReactivationDate DATE,
    FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);

--- Department table  
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(255) NOT NULL
);

--- Doctors table
CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100) NOT NULL,
    MiddleName NVARCHAR(100),
    LastName NVARCHAR(100) NOT NULL,
    Telephone NVARCHAR(20),
    Email AS(LOWER(SUBSTRING(FirstName, 1, 1)) + '.' + LOWER(LastName) + '@bankhospital.com'), -- Generates email address based on the first letter of the first name
    Speciality NVARCHAR(255),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

--- Doctor Availability table
CREATE TABLE DoctorAvailability (
    AvailabilityID INT PRIMARY KEY IDENTITY(1,1),
    DoctorID INT NOT NULL,
    DaysAvailable NVARCHAR(50) NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    Status NVARCHAR (25) NOT NULL,
	FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

--- Medical Record table
CREATE TABLE MedicalRecord (
    RecordID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    Diagnosis NVARCHAR(MAX),
    Allergies NVARCHAR(MAX),
    Note NVARCHAR(MAX),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

--- Appointment table
CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    AvailabilityID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    AppointmentType NVARCHAR(100),
    Status NVARCHAR(50) NOT NULL, -- Status: 'Pending','Canceled',
    Notes NVARCHAR(MAX),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (AvailabilityID) REFERENCES DoctorAvailability(AvailabilityID)
);

--- Past Appointment table
CREATE TABLE PastAppointment (
    PastAppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    AvailabilityID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    AppointmentType NVARCHAR(100),
    Status NVARCHAR(50),
    Notes NVARCHAR(MAX),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (AvailabilityID) REFERENCES DoctorAvailability(AvailabilityID)
);

--- Medicine table
CREATE TABLE Medicine (
    MedicineID INT PRIMARY KEY IDENTITY(1,1),
    MedicineName NVARCHAR(255) NOT NULL,
    Manufacturer NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX)
);

--- Prescription table
CREATE TABLE Prescription (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT NOT NULL,
	MedicineID INT NOT NULL,
    PrescriptionDate DATE NOT NULL,
    PrescriptionTime TIME NOT NULL,
    Dosage NVARCHAR(100),
    Notes NVARCHAR(MAX),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID),
    FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID)
);

--- Review table
CREATE TABLE Review (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    PastAppointmentID INT NOT NULL,
    ReviewDate DATE NOT NULL,
    ReviewTime TIME NOT NULL,
    Rating INT DEFAULT 5 CHECK (Rating >= 1 AND Rating <= 5), -- Assuming rating is on a scale of 1 to 5
    Comments NVARCHAR(MAX),
    FOREIGN KEY (PastAppointmentID) REFERENCES PastAppointment(PastAppointmentID)
);

--- Populating or inserting values into the tables
--- Address table
INSERT INTO Address (Address1, Address2, City, Postcode, Country)
VALUES
('123 Bolton Rd', NULL, 'Bolton', 'BL1 7AR', 'UK'),
('456 Deane Rd', NULL, 'Bolton', 'BL3 5AB', 'UK'),
('789 Derby St', NULL, 'Bolton', 'BL3 6HE', 'UK'),
('101 Chorley Old Rd', NULL, 'Bolton', 'BL1 3AS', 'UK'),
('789 St. Helens Rd', NULL, 'Bolton', 'BL3 3PX', 'UK'),
('456 Tonge Moor Rd', 'Apt 2B', 'Bolton', 'BL2 2HN', 'UK'),
('789 Market St', 'Suite 10', 'Bolton', 'BL4 7PH', 'UK'),
('101 Halliwell Rd', NULL, 'Bolton', 'BL1 3QG', 'UK'),
('123 Farnworth Rd', NULL, 'Bolton', 'BL4 7BB', 'UK'),
('456 Blackburn Rd', 'Floor 3', 'Bolton', 'BL1 8HF', 'UK');

Select * From Address

CREATE PROCEDURE uspAddPatient
    @Username NVARCHAR(50),
    @Password NVARCHAR(50),
    @Firstname NVARCHAR(40), 
    @MiddleName NVARCHAR(40), 
    @Lastname NVARCHAR(40), 
    @AddressID INT, 
    @Email NVARCHAR(255), 
    @Telephone NVARCHAR(20), 
    @Gender NVARCHAR(10), 
    @DateOfBirth DATE, 
    @InsuranceNumber NVARCHAR(9), 
    @StartDate DATE, 
    @EndDate DATE, 
    @ReactivationDate DATE
AS
BEGIN
    DECLARE @salt UNIQUEIDENTIFIER = NEWID()

    INSERT INTO Patient (Username, Password, FirstName, MiddleName, LastName, AddressID, Email, Telephone, Gender, DateOfBirth, InsuranceNumber, StartDate, EndDate, ReactivationDate)
    VALUES (@Username, HASHBYTES('SHA2_512', @Password + CAST(@salt AS NVARCHAR(36))), @Firstname, @MiddleName, @Lastname, @AddressID, @Email, @Telephone, @Gender, @DateOfBirth, @InsuranceNumber, @StartDate, @EndDate, @ReactivationDate);
END

--- Patient table
INSERT INTO Patient (Username, Password, FirstName, MiddleName, LastName, AddressID, Email, Telephone, Gender, DateOfBirth, InsuranceNumber, StartDate, EndDate, ReactivationDate)
VALUES
('ji-hyun_park', HASHBYTES('SHA2_512', 'kansk14125'), 'Ji-hyun', NULL, 'Park', 1, 'jihyunpark@yahoo.com', '0776789012', 'Male', '1997-05-15', 'SL345678M', '2022-01-01', NULL, NULL),
('maria_gonzalez', HASHBYTES('SHA2_512', '72827929'), 'Maria', NULL, 'Gonzalez', 2, 'maria85gonzalez@gmail.com', '0770123456', 'Female', '1985-08-20', 'UA234567W', '2021-12-01', NULL, NULL),
('hiroshi_yamamoto', HASHBYTES('SHA2_512', 'femi8962'), 'Hiroshi', 'Takahiro', 'Yamamoto', 3, 'hiroshi.yamamoto@hotmail.com', '0779012345', 'Male', '1990-03-10', 'TS789012T', '2022-02-15', NULL, NULL),
('david_brown', HASHBYTES('SHA2_512', 'najsnk789'), 'David', 'Robert', 'Brown', 4, 'davidbrown1@gmail.com', '0778901234', 'Male', '1972-09-05', 'OP456789Q', '2021-11-01', NULL, NULL),
('anna_kowalski', HASHBYTES('SHA2_512', 'father1'), 'Anna', 'Elizabeth', 'Kowalski', 5, 'anna_kowalski@gmail.com', '0774567890', 'Female', '1978-11-28', 'GH234567I', '2022-01-01', NULL, NULL),
('amy_jackson', HASHBYTES('SHA2_512', 'Amybaby67'), 'Amy', 'Louise', 'Jackson', 6, 'amy.jackson1985@gmail.com', '0777890123', 'Female', '1985-04-18', 'ME012345O', '2021-12-01', NULL, NULL),
('mark_williams', HASHBYTES('SHA2_512', 'nakaj83738'), 'Mark', 'Andrew', 'Williams', 7, 'mark.williams@gmail.com', '0771234567', 'Male', '1977-07-12', 'AQ678456C', '2022-01-01', NULL, NULL),
('lisa_chen', HASHBYTES('SHA2_512', 'Lisa789'), 'Lisa', NULL, 'Chen', 8, 'l.chen@yahoo.com', '0772345678', 'Female', '1995-01-30', 'XD654321E', '2022-02-15', NULL, NULL),
('ahmed_saeed', HASHBYTES('SHA2_512', 'njan890na'), 'Ahmed', 'Ali', 'Saeed', 9, 'ahmedsaeed95@hotmail.com', '0773456789', 'Male', '1983-06-25', 'SF987654G', '2021-11-01', NULL, NULL),
('emily_wilson', HASHBYTES('SHA2_512', '17372hn'), 'Emily', 'Anne', 'Wilson', 10, 'emilywilson79@gmail.com', '0777890123', 'Female', '1979-12-10', 'ME012345O', '2022-01-01', NULL, NULL);

Select * From Patient

--- Department table
INSERT INTO Department (DepartmentName)
VALUES
('Cardiology'),
('Pediatrics'),
('Orthopedics'),
('Gastroenterology'),
('Oncology'),
('Gynecology'),
('Dermatology'),
('Urology'),
('ENT (Ear, Nose, Throat)'),
('Internal Medicine');

Select * From Department

--- Doctor table
INSERT INTO Doctor (FirstName, MiddleName, LastName, DepartmentID, Speciality, Telephone)
VALUES 
    ('John', 'David', 'Smith', 1, 'Cardiologist', '0774567890'),
    ('Maria', 'Isabel', 'Garcia', 2, 'Podiatrist', '0777890123'),
    ('Fatima', 'Amina', 'Mohamed', 3, 'Orthopedist', '0776543210'),
    ('Elena', 'Sophia', 'Papadopoulos', 4, 'Gastroenterologist', '0775432109'),
	('Liam', 'Connor', 'McKenzie', 5, 'Oncologist', '0773219870'),
    ('Antonio', 'Fernando', 'Perez', 6, 'Gynecologist', '0773456789'),
    ('Yuki', NULL, 'Tanaka', 7, 'Dermatologist', '0776540987'),
    ('Chinedu', 'Oluwaseun', 'Okafor', 8, 'Urologist', '0779876543'),
	('Pierre', 'J', 'Dubois', 9, 'Otorhinolaryngologist', '0770123456'),
    ('Aarav', NULL, 'Patel', 10, 'Rheumatologist', '0772109876');

	Select * From Doctor

---  DoctorAvailabilty table
INSERT INTO DoctorAvailability (DoctorID, DaysAvailable, StartTime, EndTime, Status)
VALUES
    (1, 'Monday, Wednesday, Friday', '09:00:00', '17:00:00', 'Available'),
	(2, 'Tuesday, Wednesday, Thursday', '08:00:00', '16:00:00', 'Available'),
    (3, 'Monday, Tuesday, Wednesday', '10:00:00', '18:00:00', 'Available'),
    (4, 'Tuesday, Thursday, Saturday', '11:00:00', '19:00:00', 'Available'),
    (5, 'Friday, Saturday, Sunday', '08:30:00', '16:30:00', 'Available'),
    (6, 'Friday, Saturday, Sunday', '09:30:00', '17:30:00', 'Available'),
    (7, 'Wednesday, Friday, Sunday', '08:30:00', '16:30:00', 'Available'),
    (8, 'Monday, Wednesday, Friday', '10:30:00', '18:30:00', 'Available'),
    (9, 'Tuesday, Thursday, Saturday', '11:30:00', '19:30:00', 'Available'),
    (10,  'Wednesday, Thursday, Friday', '08:45:00', '16:45:00', 'Available');
 
Select * From DoctorAvailability

--- MedicalRecord table
INSERT INTO MedicalRecord (PatientID, DoctorID, Diagnosis, Allergies, Note)
VALUES
    (1, 1, 'Hypertension', 'None', 'Patient requires regular monitoring of blood pressure.'),
    (2, 2 , 'Fractured tibia', 'None', 'Referred for orthopedic consultation.'),
    (3, 3, 'Bone densitometry', 'Penicillin allergy', 'Prescribed antibiotics.'),
    (4, 4, 'Gastritis', 'None', 'Prescribed proton pump inhibitors.'),
    (5, 5, 'Breast cancer', 'None', 'Scheduled for chemotherapy.'),
    (6, 6, 'Menstrual irregularities', 'None', 'Recommended hormonal therapy.'),
    (7, 7, 'Acne vulgaris', 'None', 'Prescribed topical retinoids.'),
    (8, 8, 'Urinary tract infection', 'None', 'Prescribed antibiotics.'),
    (9, 9, 'Otitis media', 'None', 'Prescribed ear drops.'),
    (10, 10, 'Psoriatic arthritis', 'None', 'Referred for diabetic management.');

Select * From MedicalRecord

--- Appointment table
INSERT INTO Appointment (PatientID, AvailabilityID, AppointmentDate, AppointmentTime, AppointmentType, Status, Notes)
VALUES
    (1, 1, '2024-04-10', '10:00:00', 'General Checkup', 'Pending', NULL),
    (2, 2, '2024-04-11', '11:00:00', 'Orthopedic Consultation', 'Pending', NULL),
    (3, 3, '2024-04-12', '12:45:00', 'Bone Density Test', 'Pending', NULL),
    (4, 4, '2024-04-13', '13:00:00', 'Gastritis Consultation', 'Cancelled', 'Doctor unavailable'),
    (5, 5, '2024-04-14', '14:05:00', 'Chemotherapy Session', 'Pending', NULL),
    (6, 6, '2024-04-15', '15:00:00', 'Hormonal Therapy Consultation', 'Cancelled', 'Patient rescheduled'),
    (7, 7, '2024-04-16', '12:56:00:00', 'Dermatology Consultation', 'Pending', NULL),
    (8, 8, '2024-04-17', '17:00:00', 'Urinary Tract Infection Consultation', 'Cancelled', 'Patient canceled'),
    (9, 9, '2024-04-18', '15:40:00', 'Otitis Media Consultation', 'Pending', NULL),
    (10, 10, '2024-04-19', '13:10:00', 'Diabetic Management Consultation', 'Pending', NULL);

Select * From Appointment

--- PastAppointment table
INSERT INTO PastAppointment (PatientID, AvailabilityID, AppointmentDate, AppointmentTime, AppointmentType, Status, Notes)
VALUES
    (1, 1, '2024-02-18', '10:00:00', 'General Checkup', 'Completed', 'Patient requires regular monitoring of blood pressure.'),
    (1, 1, '2024-03-19', '15:32:00', 'Follow-up Checkup', 'Completed', 'Blood pressure stable.'),
	(2, 2, '2024-01-21', '11:00:00', 'Orthopedic Consultation', 'Completed', 'Referred for orthopedic consultation.'),
    (2, 2, '2024-03-18', '10:00:00', 'X-ray Examination', 'Completed', 'Fracture healing well.'),
	(4, 4, '2024-03-23', '13:00:00', 'Gastritis Consultation', 'Completed', 'Prescribed proton pump inhibitors.'),
    (6, 6, '2024-03-25', '15:00:00', 'Hormonal Therapy Consultation', 'Completed', 'Recommended hormonal therapy.'),
    (8, 8, '2024-03-27', '17:00:00', 'Urinary Tract Infection Consultation', 'Completed', 'Prescribed antibiotics.'),
    (9, 9, '2024-03-28', '18:32:00', 'Otitis Media Consultation', 'Completed', 'Prescribed ear drops.'),
    (10, 10, '2024-03-29', '12:20:00', 'Diabetic Management Consultation', 'Completed', 'Referred for diabetic management.'),
	(10, 10, '2024-03-10', '11:33:00', 'MRI Scan', 'Completed', 'No signs of active inflammation.');

Select* From PastAppointment

--- Medicine table
INSERT INTO Medicine (MedicineName, Manufacturer, Description)
VALUES
    ('Paracetamol', 'Generic Pharma', 'Analgesic and antipyretic medication commonly used to treat pain and fever.'),
    ('Amoxicillin', 'PharmaCo', 'Antibiotic medication used to treat bacterial infections such as pneumonia, bronchitis, and urinary tract infections.'),
    ('Lisinopril', 'Generic Pharma', 'Angiotensin-converting enzyme (ACE) inhibitor medication used to treat high blood pressure and heart failure.'),
    ('Atorvastatin', 'PharmaCo', 'Statins medication used to lower cholesterol levels and reduce the risk of cardiovascular diseases.'),
    ('Omeprazole', 'Generic Pharma', 'Proton pump inhibitor (PPI) medication used to reduce stomach acid production and treat conditions such as gastroesophageal reflux disease (GERD) and peptic ulcers.'),
    ('Metformin', 'PharmaCo', 'Oral antidiabetic medication used to treat type 2 diabetes mellitus.'),
    ('Ibuprofen', 'Generic Pharma', 'Nonsteroidal anti-inflammatory drug (NSAID) used to relieve pain, reduce inflammation, and lower fever.'),
    ('Ciprofloxacin', 'PharmaCo', 'Fluoroquinolone antibiotic medication used to treat a variety of bacterial infections including urinary tract infections and respiratory infections.'),
    ('Simvastatin', 'Generic Pharma', 'Statins medication used to lower cholesterol levels and reduce the risk of cardiovascular diseases.'),
    ('Albuterol', 'PharmaCo', 'Short-acting beta agonist medication used to treat asthma and chronic obstructive pulmonary disease (COPD).');

	Select * From Medicine

--- Prescription table
INSERT INTO Prescription (AppointmentID, MedicineID, PrescriptionDate, PrescriptionTime, Dosage, Notes)
VALUES
    (1, 1, '2024-03-25', '10:50', '500mg', 'Every 4-6 hours as needed, not to exceed 4000 mg in 24 hours'),
	(1, 1, '2024-03-25', '10:50', '20mg', 'Once daily.'),
	(1, 1, '2024-03-25', '10:50', '20mg', 'Once daily.'),
    (4, 4, '2024-03-28', '17:07', '500mg', 'Twice daily typically for 7-14 days.'),
	(4, 4, '2024-03-28', '17:07', '20mg', 'Once daily after breakfast.'),
 	(6, 6, '2024-03-30', '09:57', '200mg', 'Every 4-6 hours, not to exceed 1200 mg in 24 hours'),
    (8, 8, '2024-04-01', '17:00', '250mg', 'Twice daily for 3-7 days'),
	(8, 8, '2024-04-01', '17:00', '500mg', 'Once daily with meals');

 Select * From Prescription  

 --- Review table
 INSERT INTO Review (PastAppointmentID,ReviewDate, ReviewTime, Rating, Comments)
VALUES
    (1, '2024-03-25', '19:45:00', 5, 'Excellent service, highly recommended.'),
    (3, '2024-03-30', '14:00:00', 4, 'The medication prescribed has been helpful.'),
    (2, '2024-03-28', '18:00:00', 3, 'Satisfactory experience, but waiting time was a bit long.'),
    (7, '2024-03-28', '18:05:00', 5, 'Great doctor, explained everything clearly.'),
    (4, '2024-03-30', '15:08:00', 4, 'Good experience overall, would visit again.'),
    (6, '2024-04-01', '17:24:00', 3, 'Exceptional service.'),
    (9, '2024-04-01', '19:23:00', 5, 'Highly skilled doctor, solved my health issue effectively.'),
	(10, '2024-03-07', '17:24:00', 2, 'Poor service.');

Select * From Review

--- (2) The constraint to check that the appointment date is not in the past.
-- Modify Appointments table to add constraint
ALTER TABLE Appointment
ADD CONSTRAINT CheckFutureAppointmentDate
CHECK (AppointmentDate >= CAST(GETDATE() AS DATE)); 

--- To check if the constraint is applied to the Appointment table
INSERT INTO Appointment (PatientID, AvailabilityID, AppointmentDate, AppointmentTime, AppointmentType, Status, Notes)
VALUES
    (1, 1, '2024-03-10', '10:00:00', 'General Checkup', 'Pending', NULL);

--- (3) List all the patients with older than 40 and have Cancer in diagnosis.
SELECT p.FirstName,p. MiddleName, p.LastName, p.DateOfBirth, m.Diagnosis
FROM Patient p
JOIN MedicalRecord m ON p.PatientID = m.PatientID
WHERE DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) > 40
AND m.Diagnosis LIKE '%Cancer%';

--- (4)
---(a) Search for matching character strings by name of medicine
CREATE PROCEDURE SearchMedicineByName
    @MedicineName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.FirstName, p.LastName, m.MedicineName, pr.PrescriptionDate
    FROM Patient p
    JOIN Appointment a ON p.PatientID = a.PatientID
    JOIN Prescription pr ON a.AppointmentID = pr.AppointmentID
    JOIN Medicine m ON pr.MedicineID = m.MedicineID
    WHERE m.MedicineName LIKE '%' + @MedicineName + '%'
    ORDER BY pr.PrescriptionDate DESC;
END;

EXEC SearchMedicineByName @MedicineName = 'Atorvastatin';

---(b) Return a full list of diagnosis and allergies for a specific patient who has an appointment today
CREATE PROCEDURE GetPatientDiagnosisAndAllergies
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Today DATE = GETDATE();

    SELECT mr.Diagnosis, mr.Allergies
    FROM MedicalRecord mr
    JOIN Appointment a ON mr.PatientID = a.PatientID
    WHERE mr.PatientID = @PatientID
    AND CONVERT(DATE, a.AppointmentDate) = @Today;
END;

EXEC GetPatientDiagnosisAndAllergies @PatientID = 2;

---(c) Update the details of an existing doctor
    CREATE PROCEDURE UpdateDoctorDetails
    @DoctorID INT,
    @FirstName NVARCHAR(100),
    @MiddleName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Telephone NVARCHAR(20),
    @Speciality NVARCHAR(255),
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Doctor
    SET FirstName = @FirstName,
        MiddleName = @MiddleName,
        LastName = @LastName,
        Telephone = @Telephone,
        Speciality = @Speciality,
        DepartmentID = @DepartmentID
    WHERE DoctorID = @DoctorID;
END;

EXEC UpdateDoctorDetails 
    @DoctorID = 1,
    @FirstName = 'Blessing',
    @MiddleName = 'S',
    @LastName = 'Oladele',
    @Telephone = '0771234567',
    @Speciality = 'Cardiologist',
    @DepartmentID = 1;

SELECT * 
FROM Doctor
WHERE DoctorID = 1

---(d) Delete appointments with status cancelled
CREATE PROCEDURE MoveAndDeleteCancelledAppointments
AS
BEGIN
    SET NOCOUNT ON;

    -- Identify and delete associated records in the Prescription table
    DELETE FROM Prescription
    WHERE AppointmentID IN (
        SELECT AppointmentID
        FROM Appointment
        WHERE Status IN ('Cancelled', 'Completed')
    );

    -- Move cancelled appointments to PastAppointments table
    INSERT INTO PastAppointment (PatientID, AvailabilityID, AppointmentDate, AppointmentTime, AppointmentType, Status, Notes)
    SELECT PatientID, AvailabilityID, AppointmentDate, AppointmentTime, AppointmentType, Status, Notes
    FROM Appointment
    WHERE Status IN ('Cancelled', 'Completed');

    -- Delete cancelled and completed appointments from Appointment table
    DELETE FROM Appointment
    WHERE Status IN ('Cancelled', 'Completed');
END;

EXEC MoveAndDeleteCancelledAppointments;

Select * from Appointment


--- (5) View the appointment details
CREATE VIEW DoctorAppointmentDetails AS
SELECT 
    a.AppointmentID,
    a.PatientID,
    a.AvailabilityID,
    a.AppointmentDate,
    a.AppointmentTime,
    a.AppointmentType,
    a.Status,
    a.Notes AS AppointmentNotes,
    d.DoctorID,
    d.FirstName AS DoctorFirstName,
    d.MiddleName AS DoctorMiddleName,
    d.LastName AS DoctorLastName,
    d.Telephone AS DoctorTelephone,
    d.Speciality AS DoctorSpeciality,
    dept.DepartmentName AS DoctorDepartment,
    rev.ReviewID,
    rev.ReviewDate,
    rev.ReviewTime,
    rev.Rating,
    rev.Comments AS ReviewComments
FROM 
    Appointment a
JOIN 
    DoctorAvailability da ON a.AvailabilityID = da.AvailabilityID
JOIN 
    Doctor d ON da.DoctorID = d.DoctorID
JOIN 
    Department dept ON d.DepartmentID = dept.DepartmentID
LEFT JOIN 
    Review rev ON a.AppointmentID = rev.PastAppointmentID
UNION
SELECT 
    pa.PastAppointmentID,
    pa.PatientID,
    pa.AvailabilityID,
    pa.AppointmentDate,
    pa.AppointmentTime,
    pa.AppointmentType,
    pa.Status,
    pa.Notes AS AppointmentNotes,
    d.DoctorID,
    d.FirstName AS DoctorFirstName,
    d.MiddleName AS DoctorMiddleName,
    d.LastName AS DoctorLastName,
    d.Telephone AS DoctorTelephone,
    d.Speciality AS DoctorSpeciality,
    dept.DepartmentName AS DoctorDepartment,
    rev.ReviewID,
    rev.ReviewDate,
    rev.ReviewTime,
    rev.Rating,
    rev.Comments AS ReviewComments
FROM 
    PastAppointment pa
JOIN 
    DoctorAvailability da ON pa.AvailabilityID = da.AvailabilityID
JOIN 
    Doctor d ON da.DoctorID = d.DoctorID
JOIN 
    Department dept ON d.DepartmentID = dept.DepartmentID
LEFT JOIN 
    Review rev ON pa.PastAppointmentID = rev.PastAppointmentID;

SELECT 
    AppointmentDate,
    AppointmentTime,
    DoctorDepartment,
    CONCAT(DoctorFirstName, ' ', COALESCE(DoctorMiddleName + ' ', ''), DoctorLastName) AS DoctorName,
    DoctorSpeciality,
    Rating,
    ReviewComments
FROM 
    DoctorAppointmentDetails;

--- (6) Create a trigger so that the current state of an appointment can be changed to available when it is cancelled.
CREATE TRIGGER UpdateAvailabilityOnCancel
ON Appointment
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Status)
    BEGIN
        UPDATE DoctorAvailability
        SET Status = 'Available'
        FROM DoctorAvailability da
        WHERE da.AvailabilityID IN (
            SELECT a.AvailabilityID
            FROM inserted i
            JOIN Appointment a ON i.AppointmentID = a.AppointmentID
            WHERE i.Status = 'Cancelled'
            UNION
            SELECT pa.AvailabilityID
            FROM inserted i
            JOIN PastAppointment pa ON i.AppointmentID = pa.PastAppointmentID
            WHERE i.Status = 'Cancelled'
        );
    END
END;

---(7) identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’
SELECT COUNT(*) AS CompletedAppointments
FROM PastAppointment pa
INNER JOIN DoctorAvailability da ON pa.AvailabilityID = da.AvailabilityID
INNER JOIN Doctor d ON da.DoctorID = d.DoctorID
WHERE pa.Status = 'Completed' 
AND d.Speciality = 'Gastroenterologist';

