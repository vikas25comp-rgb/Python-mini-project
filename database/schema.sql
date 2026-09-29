-- MahaDBT Scholarship Application and Status Tracker
-- PostgreSQL Database Schema

-- Drop tables if they already exist to allow clean re-runs
DROP TABLE IF EXISTS status_history CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS applications CASCADE;
DROP TABLE IF EXISTS schemes CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS admins CASCADE;

-- 1. Admins Table
CREATE TABLE admins (
    admin_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'Scrutiny Officer'
);

-- 2. Students Table
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    mobile VARCHAR(15) NOT NULL,
    course VARCHAR(100) NOT NULL,
    year VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- 3. Schemes Table
CREATE TABLE schemes (
    scheme_id SERIAL PRIMARY KEY,
    scheme_name VARCHAR(200) NOT NULL,
    department VARCHAR(200) NOT NULL,
    eligibility TEXT NOT NULL,
    description TEXT NOT NULL
);

-- 4. Applications Table
CREATE TABLE applications (
    application_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    scheme_id INT NOT NULL REFERENCES schemes(scheme_id) ON DELETE CASCADE,
    academic_year VARCHAR(20) NOT NULL,
    application_date DATE NOT NULL DEFAULT CURRENT_DATE,
    current_status VARCHAR(50) NOT NULL DEFAULT 'Submitted'
);

-- 5. Documents Table
CREATE TABLE documents (
    document_id SERIAL PRIMARY KEY,
    application_id INT NOT NULL REFERENCES applications(application_id) ON DELETE CASCADE,
    document_name VARCHAR(150) NOT NULL,
    document_status VARCHAR(50) NOT NULL DEFAULT 'Uploaded'
);

-- 6. Status History Table
CREATE TABLE status_history (
    status_id SERIAL PRIMARY KEY,
    application_id INT NOT NULL REFERENCES applications(application_id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL,
    remarks TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
