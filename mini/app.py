import os
from flask import Flask, render_template, request, redirect, url_for, session, flash
from dotenv import load_dotenv
import database

# Load environment variables
load_dotenv()

app = Flask(__name__)
# Secret key for session management
app.secret_key = os.getenv('SECRET_KEY', 'mahadbt_college_demo_secret_2026')

# ==========================================
# PUBLIC & STUDENT ROUTES
# ==========================================

@app.route('/')
def index():
    """
    Landing Page: Overview of the MahaDBT Portal and available scholarship schemes.
    """
    schemes = []
    error = None
    try:
        schemes = database.get_all_schemes()
    except Exception as e:
        error = f"Database connection note: {e}"
    
    return render_template('index.html', schemes=schemes, db_error=error)


@app.route('/login', methods=['GET', 'POST'])
def login():
    """
    Student Login:
    - Checks credentials against PostgreSQL 'students' table.
    - If valid, redirects to /dashboard.
    - If invalid, shows 'Invalid email or password'.
    """
    error = None
    if request.method == 'POST':
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '').strip()

        if not email or not password:
            error = "Please enter both email and password."
        else:
            try:
                student = database.authenticate_student(email, password)
                if student:
                    # Save student details in session
                    session['student_id'] = student['student_id']
                    session['student_name'] = student['name']
                    session['student_email'] = student['email']
                    return redirect(url_for('dashboard'))
                else:
                    error = "Invalid email or password"
            except Exception as e:
                error = f"Database error: {e}"

    return render_template('login.html', error=error)


@app.route('/logout')
def logout():
    """
    Logs out the student and clears student session.
    """
    session.pop('student_id', None)
    session.pop('student_name', None)
    session.pop('student_email', None)
    flash("You have been logged out successfully.", "info")
    return redirect(url_for('login'))


@app.route('/dashboard')
def dashboard():
    """
    Student Dashboard:
    - Displays student details (Name, Course, Year, Category).
    - Lists applications submitted by this student with status badges.
    """
    student_id = session.get('student_id')
    if not student_id:
        flash("Please log in to access your dashboard.", "warning")
        return redirect(url_for('login'))

    try:
        student = database.get_student_by_id(student_id)
        if not student:
            session.pop('student_id', None)
            flash("Student profile not found. Please log in again.", "danger")
            return redirect(url_for('login'))

        applications = database.get_student_applications(student_id)
        return render_template('dashboard.html', student=student, applications=applications)
    except Exception as e:
        flash(f"Error loading dashboard: {e}", "danger")
        return render_template('dashboard.html', student=None, applications=[])


@app.route('/track', methods=['GET', 'POST'])
def track():
    """
    Track Application:
    - Search by Application ID (via form submission or ?app_id= query param).
    - Displays application info, submitted documents, remarks, and visual status timeline.
    """
    app_id = request.args.get('app_id') or request.form.get('application_id')
    application = None
    documents = []
    history = []
    error = None

    if app_id:
        try:
            app_id_int = int(str(app_id).strip())
            application = database.get_application_details(app_id_int)
            if application:
                documents = database.get_application_documents(app_id_int)
                history = database.get_application_history(app_id_int)
            else:
                error = f"No application found with Application ID #{app_id_int}."
        except ValueError:
            error = "Please enter a valid numeric Application ID."
        except Exception as e:
            error = f"Error retrieving tracking info: {e}"

    return render_template('track.html', 
                           application=application, 
                           documents=documents, 
                           history=history, 
                           searched_id=app_id, 
                           error=error)


@app.route('/application', methods=['GET', 'POST'])
def application():
    """
    Apply for Scholarship:
    - Displays application form.
    - Submits new application, document records, and initial 'Submitted' history.
    """
    success_message = None
    error = None
    schemes = []

    try:
        schemes = database.get_all_schemes()
    except Exception as e:
        error = f"Error loading scholarship schemes: {e}"

    # Prefill student ID if logged in
    logged_in_student_id = session.get('student_id')

    if request.method == 'POST':
        student_id = request.form.get('student_id', '').strip()
        scheme_id = request.form.get('scheme_id', '').strip()
        academic_year = request.form.get('academic_year', '').strip()
        document_name = request.form.get('document_name', '').strip()

        # Simple validation
        if not student_id or not scheme_id or not academic_year or not document_name:
            error = "All fields are required. Please fill in all information."
        else:
            try:
                student_id_int = int(student_id)
                scheme_id_int = int(scheme_id)

                # Verify student exists
                student = database.get_student_by_id(student_id_int)
                if not student:
                    error = f"Student with ID #{student_id_int} does not exist in the database. Please verify your Student ID."
                else:
                    new_app_id = database.create_application(
                        student_id=student_id_int,
                        scheme_id=scheme_id_int,
                        academic_year=academic_year,
                        document_name=document_name
                    )
                    success_message = f"Application submitted successfully! Your Application ID is #{new_app_id}. Keep this ID to track your status."
            except ValueError:
                error = "Student ID and Scholarship Scheme must be valid numbers."
            except Exception as e:
                error = f"Failed to submit application: {e}"

    return render_template('application.html', 
                           schemes=schemes, 
                           logged_in_student_id=logged_in_student_id, 
                           success_message=success_message, 
                           error=error)


# ==========================================
# ADMIN AUTHENTICATION & PORTAL ROUTES
# ==========================================

@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    """
    Admin Login:
    - Verifies credentials against PostgreSQL 'admins' table.
    - If valid, saves admin session and redirects to /admin.
    - If invalid, displays error.
    """
    error = None
    if request.method == 'POST':
        login_id = request.form.get('login_id', '').strip()
        password = request.form.get('password', '').strip()

        if not login_id or not password:
            error = "Please enter both admin username/email and password."
        else:
            try:
                admin_user = database.authenticate_admin(login_id, password)
                if admin_user:
                    session['admin_id'] = admin_user['admin_id']
                    session['admin_name'] = admin_user['username']
                    session['admin_role'] = admin_user['role']
                    flash(f"Welcome, {admin_user['username']} ({admin_user['role']})!", "success")
                    return redirect(url_for('admin'))
                else:
                    error = "Invalid admin username/email or password."
            except Exception as e:
                error = f"Database error: {e}"

    return render_template('admin_login.html', error=error)


@app.route('/admin/logout')
def admin_logout():
    """
    Logs out admin user and redirects to admin login.
    """
    session.pop('admin_id', None)
    session.pop('admin_name', None)
    session.pop('admin_role', None)
    flash("You have been logged out of the admin portal.", "info")
    return redirect(url_for('admin_login'))


@app.route('/admin', methods=['GET', 'POST'])
def admin():
    """
    Admin Dashboard (Protected Route):
    - Requires active admin session.
    - Lists all applications.
    - Allows admin to update application status and enter remarks.
    """
    # Route Protection: Redirect to admin login if not authenticated
    if not session.get('admin_id'):
        flash("Please log in to access the admin scrutiny portal.", "warning")
        return redirect(url_for('admin_login'))

    success_message = None
    error = None

    if request.method == 'POST':
        app_id = request.form.get('application_id', '').strip()
        new_status = request.form.get('new_status', '').strip()
        remarks = request.form.get('remarks', '').strip()

        if not app_id or not new_status:
            error = "Application ID and Status are required."
        else:
            valid_statuses = ['Submitted', 'Under Scrutiny', 'Documents Pending', 'Approved', 'Rejected']
            if new_status not in valid_statuses:
                error = f"Invalid status. Must be one of: {', '.join(valid_statuses)}"
            else:
                try:
                    admin_role = session.get('admin_role', 'Scrutiny Officer')
                    formatted_remark = f"[{admin_role}] {remarks}" if remarks else f"[{admin_role}] Status updated to {new_status}"
                    database.update_application_status(int(app_id), new_status, formatted_remark)
                    success_message = f"Application #{app_id} status updated to '{new_status}' successfully."
                except Exception as e:
                    error = f"Failed to update status: {e}"

    applications = []
    try:
        applications = database.get_all_applications_for_admin()
    except Exception as e:
        error = f"Error fetching applications: {e}"

    return render_template('admin.html', 
                           applications=applications, 
                           success_message=success_message, 
                           error=error)


if __name__ == '__main__':
    # Runs local Flask development server
    print("Starting MahaDBT Scholarship Tracker Flask App...")
    print("Access portal at: http://127.0.0.1:5000")
    app.run(debug=True, host='127.0.0.1', port=5000)
