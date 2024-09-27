CREATE DATABASE POLICE;
USE POLICE;

-- Departments Table
CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) UNIQUE
);
select * from departments;

-- Officers Table
CREATE TABLE Officers (
    officer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    position VARCHAR(50),
    badge_number VARCHAR(20) UNIQUE,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Addresses Table
CREATE TABLE Addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    officer_id INT,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    FOREIGN KEY (officer_id) REFERENCES Officers(officer_id)
);
select * from addresses;
-- Case Types Table
CREATE TABLE CaseTypes (
    case_type_id INT PRIMARY KEY AUTO_INCREMENT,
    case_type_name VARCHAR(100) UNIQUE
);

-- Cases Table
CREATE TABLE Cases (
    case_id INT PRIMARY KEY AUTO_INCREMENT,
    case_name VARCHAR(100),
    description TEXT,
    status VARCHAR(50),
    case_type_id INT,
    assigned_officer_id INT,
    FOREIGN KEY (case_type_id) REFERENCES CaseTypes(case_type_id),
    FOREIGN KEY (assigned_officer_id) REFERENCES Officers(officer_id)
);

-- Intermediate table for Many-to-Many relationship between Officers and Cases
CREATE TABLE OfficerCases (
    officer_id INT,
    case_id INT,
    PRIMARY KEY (officer_id, case_id),
    FOREIGN KEY (officer_id) REFERENCES Officers(officer_id),
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);
select * from officercases;
-- Criminals Table
CREATE TABLE Criminals (
    criminal_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    description TEXT,
    wanted_status BOOLEAN,
    case_id INT,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);

-- Incident Reports Table
CREATE TABLE IncidentReports (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    case_id INT,
    report_date DATE,
    details TEXT,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);
select * from incidentreports;
-- Case Status Log Table
CREATE TABLE CaseStatusLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    case_id INT,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);
select * from casestatuslog;

-- Inserting into Departments table
INSERT INTO Departments (department_name) 
VALUES 
    ('Homicide'),
    ('Narcotics'),
    ('Traffic'),
    ('Fraud');

-- Inserting into Officers table
INSERT INTO Officers (name, position, badge_number, department_id) 
VALUES 
    ('John Doe', 'Detective', '1234', 1),
    ('Alice Johnson', 'Sergeant', '5678', 1),
    ('Bob Smith', 'Officer', '91011', 1),
    ('Emily Brown', 'Detective', '121314', 2),
    ('David Jones', 'Captain', '151617', 3),
    ('Sarah Wilson', 'Lieutenant', '181920', 4);
    
    -- Inserting into Addresses table
INSERT INTO Addresses (address_id, officer_id, address, city, state, zip_code) 
VALUES 
    (1, 1, '123 Main St', 'Springfield', 'IL', '62701'),
    (2, 2, '456 Elm St', 'Springfield', 'IL', '62702'),
    (3, 3, '789 Oak St', 'Springfield', 'IL', '62703'),
    (4, 4, '101 Maple St', 'Chicago', 'IL', '60601'),
    (5, 5, '202 Pine St', 'Chicago', 'IL', '60602'),
    (6, 6, '303 Cedar St', 'Peoria', 'IL', '61602');


-- Inserting into CaseTypes table
INSERT INTO CaseTypes (case_type_name) 
VALUES 
    ('Homicide'),
    ('Drug Trafficking'),
    ('Robbery'),
    ('Identity Theft'),
    ('Assault'),
    ('Burglary');

-- Inserting into Cases table
INSERT INTO Cases (case_name, description, status, case_type_id, assigned_officer_id) 
VALUES  
    ('Murder Investigation', 'Investigation of a homicide case', 'Open', 1, 1), 
    ('Drug Trafficking', 'Investigation of drug trafficking network', 'Open', 2, 4),
    ('Bank Robbery', 'Investigation of a bank robbery case', 'Closed', 3, 5),
    ('Identity Theft', 'Investigation of identity theft cases', 'Open', 4, 6),
    ('Assault', 'Investigation of an assault case', 'Open', 5, 3),
    ('Burglary', 'Investigation of a burglary case', 'Open', 6, 2);

-- Assigning officers to cases in the OfficerCases table
INSERT INTO OfficerCases (officer_id, case_id) 
VALUES 
    (1, 1), 
    (4, 2),
    (5, 3),
    (6, 4),
    (3, 5),
    (2, 6);

-- Inserting into Criminals table
INSERT INTO Criminals (name, description, wanted_status, case_id) 
VALUES 
    ('Jack the Ripper', 'Serial killer known for his gruesome murders', true, 1),
    ('Pablo Escobar','Infamous drug lord', true, 2),
    ('Al Capone', 'Notorious gangster', true, 3),
    ('Bonnie and Clyde', 'Famous criminals who robbed banks and killed people', true, 3),
    ('Ted Bundy', 'Serial killer who murdered numerous young women', true, 1),
    ('Charles Manson', 'Cult leader and mastermind behind several murders', true, 1);

-- Inserting into IncidentReports table
INSERT INTO IncidentReports (case_id, report_date, details) 
VALUES 
    (1, '2023-01-01', 'Initial report on the murder case.'),
    (2, '2023-02-15', 'Surveillance of drug trafficking activities.'),
    (3, '2023-03-10', 'Detailed account of the bank robbery.'),
    (4, '2023-04-05', 'Collected evidence of identity theft.'),
    (5, '2023-05-20', 'Witness statement on the assault.'),
    (6, '2023-06-25', 'Crime scene report for the burglary.');

-- Trigger to log status changes in Cases table
DELIMITER //

CREATE TRIGGER log_case_status_change 
AFTER UPDATE ON Cases
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO CaseStatusLog (case_id, old_status, new_status) 
        VALUES (NEW.case_id, OLD.status, NEW.status);
    END IF;
END //

DELIMITER ;

-- Reassign cases when an officer is removed:
CALL ReassignCases(1);

-- Count the number of wanted criminals:
SELECT CountCriminalsByWantedStatus(TRUE) AS wanted_criminals_count;

-- List all officers
SELECT * FROM Officers;

-- List all cases
SELECT * FROM Cases;

-- List all criminals
SELECT * FROM Criminals;

-- Retrieve details of a specific case along with assigned officer's details
SELECT c.case_name, c.description, c.status, o.name AS assigned_officer
FROM Cases c
INNER JOIN Officers o ON c.assigned_officer_id = o.officer_id
WHERE c.case_id = 2;

-- List all open cases
SELECT * FROM Cases WHERE status = 'Open';

-- List all officers working in the Homicide department
SELECT * FROM Officers WHERE department_id = (SELECT department_id FROM Departments WHERE department_name = 'Homicide');

-- List all wanted criminals
SELECT * FROM Criminals WHERE wanted_status = true;

-- Retrieve the count of criminals by wanted status
SELECT CountCriminalsByWantedStatus(true) AS wanted_criminals_count;

-- List all incident reports for a specific case
SELECT * FROM IncidentReports WHERE case_id = 1;

-- Log entries when updating case status:
UPDATE Cases SET status = 'Closed' WHERE case_id = 1;
-- Retrieve case status logs
SELECT * FROM CaseStatusLog WHERE case_id = 1;

select assigned_officer_id, count (case_id) as number_of_cases from cases group by assigned_officer_id;
