-- MahaDBT Scholarship Application and Status Tracker
-- Sample Seed Data

-- 1. Insert Sample Admins
INSERT INTO admins (admin_id, username, email, password, role) VALUES
(1, 'admin', 'admin@mahadbt.gov.in', 'admin123', 'Head Scrutiny Officer'),
(2, 'clerk_pune', 'clerk.pune@mahadbt.gov.in', 'admin123', 'College Verification Clerk');

SELECT setval('admins_admin_id_seq', (SELECT MAX(admin_id) FROM admins));

-- 2. Insert Sample Students
INSERT INTO students (student_id, name, email, password, mobile, course, year, category) VALUES
(1, 'Rahul Sharma', 'rahul.sharma@example.com', 'student123', '9876543210', 'B.Tech Computer Engineering', 'Third Year', 'OBC'),
(2, 'Priya Patil', 'priya.patil@example.com', 'student123', '9823456789', 'B.E. Information Technology', 'Second Year', 'Open'),
(3, 'Amit Kamble', 'amit.kamble@example.com', 'student123', '9123456780', 'B.Tech Mechanical Engineering', 'Final Year', 'SC'),
(4, 'Sneha Deshmukh', 'sneha.deshmukh@example.com', 'student123', '9345678901', 'B.Pharmacy', 'First Year', 'EBC'),
(5, 'Rohan Jadhav', 'rohan.jadhav@example.com', 'student123', '9456789012', 'B.Sc Computer Science', 'Second Year', 'ST');

-- Reset student sequence so new insertions continue after 5
SELECT setval('students_student_id_seq', (SELECT MAX(student_id) FROM students));

-- 3. Insert Scholarship Schemes
INSERT INTO schemes (scheme_id, scheme_name, department, eligibility, description) VALUES
(1, 'Rajarshi Chhatrapati Shahu Maharaj Shikshan Shulkh Shishyavrutti Yojna (EBC)', 
    'Directorate of Higher Education (DHE)', 
    'Family annual income must be up to Rs. 8 Lakhs. Student admitted through CAP / Government merit round in Maharashtra.', 
    'Provides 50% tuition and examination fee waiver for students from Economically Backward Classes enrolled in approved degree courses.'),

(2, 'Government of India Post-Matric Scholarship for SC Students', 
    'Social Justice and Special Assistance Department', 
    'Student must belong to Scheduled Caste (SC) category. Family income less than or equal to Rs. 2,50,000 per annum.', 
    'Provides complete fee exemption (Tuition, Exam, Library fees) and a monthly maintenance allowance to eligible SC students.'),

(3, 'Dr. Panjabrao Deshmukh Hostel Maintenance Allowance (Vastigruh Nirvah Bhatta)', 
    'Directorate of Technical Education (DTE)', 
    'Children of registered Alpabhudharak (marginal landholder) farmers staying in registered hostels with family income up to Rs. 8 Lakhs.', 
    'Financial allowance up to Rs. 30,000 per annum for hostel accommodation, food, and mess expenses in metro and non-metro areas.');

SELECT setval('schemes_scheme_id_seq', (SELECT MAX(scheme_id) FROM schemes));

-- 4. Insert Applications
INSERT INTO applications (application_id, student_id, scheme_id, academic_year, application_date, current_status) VALUES
(101, 1, 1, '2024-2025', '2024-08-10', 'Approved'),
(102, 2, 1, '2024-2025', '2024-08-18', 'Under Scrutiny'),
(103, 3, 2, '2024-2025', '2024-09-01', 'Documents Pending'),
(104, 4, 3, '2024-2025', '2024-09-15', 'Submitted'),
(105, 5, 2, '2024-2025', '2024-07-25', 'Rejected');

SELECT setval('applications_application_id_seq', (SELECT MAX(application_id) FROM applications));

-- 5. Insert Documents
INSERT INTO documents (document_id, application_id, document_name, document_status) VALUES
-- Documents for Application 101
(1, 101, 'Domicile Certificate', 'Verified'),
(2, 101, 'Income Certificate (Tehsildar)', 'Verified'),
(3, 101, 'CAP Allotment Letter', 'Verified'),
(4, 101, 'Previous Year Marksheet', 'Verified'),

-- Documents for Application 102
(5, 102, 'Domicile Certificate', 'Verified'),
(6, 102, 'Income Certificate (Tehsildar)', 'Under Verification'),
(7, 102, 'College Admission Fee Receipt', 'Verified'),

-- Documents for Application 103
(8, 103, 'Caste Certificate (SC)', 'Verified'),
(9, 103, 'Caste Validity Certificate', 'Pending Re-upload'),
(10, 103, 'Income Certificate', 'Verified'),

-- Documents for Application 104
(11, 104, 'Hostel Allotment & Fee Receipt', 'Uploaded'),
(12, 104, 'Alpabhudharak Farmer Certificate / 7-12 Extract', 'Uploaded'),
(13, 104, 'Ration Card', 'Uploaded'),

-- Documents for Application 105
(14, 105, 'Caste Certificate', 'Verified'),
(15, 105, 'Income Certificate (ITR)', 'Rejected (Exceeds Limit)');

SELECT setval('documents_document_id_seq', (SELECT MAX(document_id) FROM documents));

-- 6. Insert Status History
INSERT INTO status_history (status_id, application_id, status, remarks, updated_at) VALUES
-- History for App 101 (Approved)
(1, 101, 'Submitted', 'Application submitted successfully with all required documents.', '2024-08-10 10:30:00'),
(2, 101, 'Under Scrutiny', 'Desk officer scrutinized CAP details and marksheets.', '2024-08-14 14:15:00'),
(3, 101, 'Documents Pending', 'Annual income certificate required verification from issuing authority.', '2024-08-20 11:00:00'),
(4, 101, 'Approved', 'Verification completed successfully. Scholarship grant approved for disbursement.', '2024-08-28 16:45:00'),

-- History for App 102 (Under Scrutiny)
(5, 102, 'Submitted', 'Fresh scholarship application submitted online.', '2024-08-18 11:20:00'),
(6, 102, 'Under Scrutiny', 'Application forwarded to College Principal and DHE desk for scrutiny.', '2024-08-22 09:30:00'),

-- History for App 103 (Documents Pending)
(7, 103, 'Submitted', 'Application submitted with caste and academic certificates.', '2024-09-01 15:45:00'),
(8, 103, 'Under Scrutiny', 'Initial verification done by Social Welfare clerk.', '2024-09-05 12:10:00'),
(9, 103, 'Documents Pending', 'Caste Validity document is unclear/blurred. Please re-upload a clear copy.', '2024-09-08 14:00:00'),

-- History for App 104 (Submitted)
(10, 104, 'Submitted', 'Hostel maintenance allowance application submitted with land documents.', '2024-09-15 16:00:00'),

-- History for App 105 (Rejected)
(11, 105, 'Submitted', 'Post-matric scholarship application registered.', '2024-07-25 09:15:00'),
(12, 105, 'Under Scrutiny', 'Verifying income criteria against tax documents.', '2024-07-29 13:40:00'),
(13, 105, 'Rejected', 'Application rejected. Family annual income exceeds prescribed limit for this scheme.', '2024-08-02 17:10:00');

SELECT setval('status_history_status_id_seq', (SELECT MAX(status_id) FROM status_history));
