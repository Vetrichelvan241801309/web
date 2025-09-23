from flask import *

app = Flask(__name__)

from flask import Flask, render_template, request, redirect, url_for, session
import oracledb

app = Flask(__name__)
app.secret_key = "your_secret_key_here"   # required for session

def connectdb():
    try:
        return oracledb.connect(
            user="system",
            password="vetri",
            dsn="localhost:1521/XEPDB1"
        )
    except Exception as e:
        print("Error connecting to DB:", e)
        return None

@app.route("/", methods=["GET", "POST"])
@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")

        try:
            connection = connectdb()
            if connection is None:
                return "Database connection failed", 500

            cursor = connection.cursor()

            # Check user
            cursor.execute(
                "SELECT * FROM app_user WHERE username=:1 AND password_hash=:2",
                (username, password)
            )
            user = cursor.fetchone()
            print("User fetched:", user)

            if user and user[4].lower() == "teacher":
                cursor.execute("SELECT * FROM teacher WHERE user_id=:1", (user[0],))
                teacher = cursor.fetchone()
                print("Teacher fetched:", teacher)

                if teacher:
                    session["teacher_id"] = teacher[0]
                    session["teacher_name"] = teacher[2]
                    session["user_id"]=user[0]
                    session["username"] = user[1]
                    session["email"] = user[2]
                    session["password"] = user[3]

                    return redirect(url_for("teacher_dashboard"))

            # If login fails
            return render_template("login.html", error="Invalid username or password")

        except Exception as e:
            print("Login error:", e)
            return render_template("login.html", error="Something went wrong")

        finally:
            if connection:
                connection.close()

    return render_template("login.html",error="")

@app.route("/signup", methods=["POST","GET"])
def signup():
    fullname = request.form.get("fullname")
    email = request.form.get("email")
    username = request.form.get("username")
    password = request.form.get("password")

    if fullname and email and username and password:
        return render_template("login.html")

    return render_template("signup.html")

@app.route('/dashboard', methods=["POST","GET"])
def teacher_dashboard():
    quizzes = [
        {
            'title': 'Math Quiz - Algebra',
            'created': '2025-09-15',
            'questions': 10,
            'status': 'Active'
        },
        {
            'title': 'Science Quiz - Biology',
            'created': '2025-09-10',
            'questions': 15,
            'status': 'Closed'
        },
        {
            'title': 'History Quiz - WW2',
            'created': '2025-08-25',
            'questions': 8,
            'status': 'Active'
        }
    ]
    return render_template('teacherhomepage.html', quizzes=quizzes)

@app.route("/editprofile", methods=["GET", "POST"])
def editprofile():
    if "teacher_id" not in session:
        return redirect(url_for("login"))  
    if request.method == "POST":
        teacher_name = request.form.get("teacherName") or session["name"]
        teacher_username = request.form.get("username") or session["username"]
        teacher_email = request.form.get("email") or session["email"]
        teacher_password = request.form.get("password") or session["password"]

        try:
            connection=connectdb()
            cursor=connection.cursor()

            cursor.execute("UPDATE app_user SET username=:1, email=:2, password_hash=:3 WHERE user_id=:4",(teacher_username.strip(),teacher_email.strip(),teacher_password.strip(),session["user_id"]))
            cursor.execute("UPDATE teacher SET name=:1 WHERE user_id=:2",(teacher_name.strip(),session["user_id"]))

            connection.commit()

            session["username"] = teacher_username
            session["email"] = teacher_email
            session["password"] = teacher_password
            session["name"] = teacher_name

            return redirect(url_for('teacher_dashboard'))

        except Exception as e:
            print(e)
    return render_template("editprofile.html", teacher=session)

@app.route("/changepassword", methods=["POST","GET"])
def changepassword():
    return render_template('changepassword.html')

@app.route("/logout")
def logout():
    return redirect(url_for('login'))

@app.route("/addstudent")
def addstudent():
    return render_template('addstudent.html')

students = [
    {
        'student_id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'class_name': 'CS101',
        'department': 'CSC',
        'username': 'john123',
        'password': 'johnpass'
    },
    {
        'student_id': 2,
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'class_name': 'ECE102',
        'department': 'ECE',
        'username': 'jane456',
        'password': 'janepass'
    }
]

@app.route('/viewstudents',methods=["POST","GET"])
def viewstudents():
    return render_template('viewstudents.html', students=students)

@app.route('/editstudent/<int:student_id>')
def editstudent(student_id,methods=["POST","GET"]):
    # find student by ID
    student = next((s for s in students if s['student_id'] == student_id), None)
    if not student:
        return "Student not found", 404

    return render_template('editstudent.html', student=student)


# -------------------- UPDATE PROFILE --------------------
@app.route('/update-profile', methods=['POST'])
def update_profile():
    student_id = int(request.form['teacherId'])
    student = next((s for s in students if s['student_id'] == student_id), None)

    if student:
        student['name'] = request.form['teacherName']
        student['username'] = request.form['username']
        student['email'] = request.form['email']
        student['password'] = request.form['password']

    return redirect(url_for('viewstudents'))

if __name__ == "__main__":
    app.run(debug=True)
