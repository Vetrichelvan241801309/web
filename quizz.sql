--------------------------------------------------
-- Department Table
--------------------------------------------------
CREATE TABLE department (
    
    dept_id NUMBER  PRIMARY KEY,
    dept_name VARCHAR2(100) UNIQUE NOT NULL
);
CREATE SEQUENCE dept_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--------------------------------------------------
-- Class Table
--------------------------------------------------
CREATE TABLE class (
    class_id NUMBER PRIMARY KEY,
    class_name VARCHAR2(100) NOT NULL,
    dept_id NUMBER NOT NULL,
    CONSTRAINT fk_class_dept FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);
CREATE SEQUENCE class_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--------------------------------------------------
-- User Table (common for all logins)
--------------------------------------------------
CREATE TABLE app_user (
    user_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) UNIQUE NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    password_hash VARCHAR2(255) NOT NULL,
    role VARCHAR2(20) CHECK (role IN ('student','teacher','admin')) NOT NULL
);
CREATE SEQUENCE quser_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--------------------------------------------------
-- Teacher Table (extra teacher info)
--------------------------------------------------
CREATE TABLE teacher (
    teacher_id NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL UNIQUE,
    name VARCHAR2(100) NOT NULL,
    CONSTRAINT fk_teacher_user FOREIGN KEY (user_id) REFERENCES app_user(user_id)
);
CREATE SEQUENCE teacher_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--------------------------------------------------
-- Student Table (extra student info)
--------------------------------------------------
CREATE TABLE student (
    student_id NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL UNIQUE,
    name VARCHAR2(100) NOT NULL,
    class_id NUMBER NOT NULL,
    dept_id NUMBER NOT NULL,
    CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES app_user(user_id),
    CONSTRAINT fk_student_class FOREIGN KEY (class_id) REFERENCES class(class_id),
    CONSTRAINT fk_student_dept FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);
CREATE SEQUENCE student_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--------------------------------------------------
-- Quiz Table
--------------------------------------------------
CREATE TABLE quiz (
    quiz_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    subject VARCHAR2(100) NOT NULL,
    class_id NUMBER NOT NULL,
    dept_id NUMBER NOT NULL,
    mark_per_question NUMBER DEFAULT 1 NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration_minutes NUMBER NOT NULL,
    created_by NUMBER NOT NULL,
    CONSTRAINT fk_quiz_class FOREIGN KEY (class_id) REFERENCES class(class_id),
    CONSTRAINT fk_quiz_dept FOREIGN KEY (dept_id) REFERENCES department(dept_id),
    CONSTRAINT fk_quiz_teacher FOREIGN KEY (created_by) REFERENCES teacher(teacher_id)
);
CREATE SEQUENCE quiz_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--------------------------------------------------
-- Quiz Questions Table
--------------------------------------------------
CREATE TABLE quiz_question (
    question_id NUMBER PRIMARY KEY,
    quiz_id NUMBER NOT NULL,
    question CLOB NOT NULL,
    op1 VARCHAR2(255) NOT NULL,
    op2 VARCHAR2(255) NOT NULL,
    op3 VARCHAR2(255) NOT NULL,
    op4 VARCHAR2(255) NOT NULL,
    correct_answer VARCHAR2(5) CHECK (correct_answer IN ('op1','op2','op3','op4')) NOT NULL,
    mark NUMBER DEFAULT 1 NOT NULL,
    CONSTRAINT fk_question_quiz FOREIGN KEY (quiz_id) REFERENCES quiz(quiz_id)
);
CREATE SEQUENCE question_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--------------------------------------------------
-- Quiz Result Summary Table
--------------------------------------------------
CREATE TABLE result (
    result_id NUMBER PRIMARY KEY,
    quiz_id NUMBER NOT NULL,
    student_id NUMBER NOT NULL,
    total_score NUMBER DEFAULT 0,
    CONSTRAINT fk_result_quiz FOREIGN KEY (quiz_id) REFERENCES quiz(quiz_id),
    CONSTRAINT fk_result_student FOREIGN KEY (student_id) REFERENCES student(student_id)
);
CREATE SEQUENCE result_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--------------------------------------------------
-- Quiz Result Answers Table
--------------------------------------------------
CREATE TABLE result_answer (
    result_answer_id NUMBER PRIMARY KEY,
    result_id NUMBER NOT NULL,
    question_id NUMBER NOT NULL,
    student_answer VARCHAR2(5) CHECK (student_answer IN ('op1','op2','op3','op4')) NOT NULL,
    mark_obtained NUMBER NOT NULL,
    CONSTRAINT fk_answer_result FOREIGN KEY (result_id) REFERENCES result(result_id),
    CONSTRAINT fk_answer_question FOREIGN KEY (question_id) REFERENCES quiz_question(question_id)
);
CREATE SEQUENCE result_answer_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

SELECT * FROM department;
SELECT * FROM class;
SELECT * FROM app_user;
SELECT * FROM teacher;
SELECT * FROM student;
SELECT * FROM quiz;
SELECT * FROM quiz_question;
SELECT * FROM result;
SELECT * FROM result_answer;

TRUNCATE TABLE result_answer;
TRUNCATE TABLE result;
TRUNCATE TABLE quiz_question;
TRUNCATE TABLE quiz;
TRUNCATE TABLE student;
TRUNCATE TABLE teacher;
TRUNCATE TABLE app_user;
TRUNCATE TABLE class;
TRUNCATE TABLE department;

DROP SEQUENCE dept_id_seq;
DROP SEQUENCE class_id_seq;
DROP SEQUENCE quser_id_seq;
DROP SEQUENCE teacher_id_seq;
DROP SEQUENCE student_id_seq;
DROP SEQUENCE quiz_id_seq;
DROP SEQUENCE question_id_seq;
DROP SEQUENCE result_id_seq;
DROP SEQUENCE result_answer_id_seq;

-- Drop child tables first
DROP TABLE result_answer CASCADE CONSTRAINTS;
DROP TABLE result CASCADE CONSTRAINTS;
DROP TABLE quiz_question CASCADE CONSTRAINTS;
DROP TABLE quiz CASCADE CONSTRAINTS;
DROP TABLE student CASCADE CONSTRAINTS;
DROP TABLE teacher CASCADE CONSTRAINTS;
DROP TABLE app_user CASCADE CONSTRAINTS;
DROP TABLE class CASCADE CONSTRAINTS;
DROP TABLE department CASCADE CONSTRAINTS;

-- ============================================
-- 1. Departments
-- ============================================
INSERT INTO department (dept_id, dept_name) VALUES (dept_id_seq.NEXTVAL, 'AIDS');
INSERT INTO department (dept_id, dept_name) VALUES (dept_id_seq.NEXTVAL, 'AIML');
INSERT INTO department (dept_id, dept_name) VALUES (dept_id_seq.NEXTVAL, 'IT');
INSERT INTO department (dept_id, dept_name) VALUES (dept_id_seq.NEXTVAL, 'CSC');
INSERT INTO department (dept_id, dept_name) VALUES (dept_id_seq.NEXTVAL, 'ECE');
INSERT INTO department (dept_id, dept_name) VALUES (dept_id_seq.NEXTVAL, 'EEE');

-- ============================================
-- 2. Classes
-- ============================================
INSERT INTO class (class_id, class_name, dept_id) VALUES (class_id_seq.NEXTVAL, 'AIDS-A', 1);
INSERT INTO class (class_id, class_name, dept_id) VALUES (class_id_seq.NEXTVAL, 'AIML-A', 2);
INSERT INTO class (class_id, class_name, dept_id) VALUES (class_id_seq.NEXTVAL, 'IT-A', 3);
INSERT INTO class (class_id, class_name, dept_id) VALUES (class_id_seq.NEXTVAL, 'CSC-A', 4);
INSERT INTO class (class_id, class_name, dept_id) VALUES (class_id_seq.NEXTVAL, 'ECE-A', 5);
INSERT INTO class (class_id, class_name, dept_id) VALUES (class_id_seq.NEXTVAL, 'EEE-A', 6);

-- ============================================
-- 3. App Users
-- ============================================
-- Admin
INSERT INTO app_user (user_id, username, email, password_hash, role) 
VALUES (quser_id_seq.NEXTVAL, 'admin1', 'admin1@example.com', 'hashed_pw_admin', 'admin');

-- Teachers
INSERT INTO app_user (user_id, username, email, password_hash, role) 
VALUES (quser_id_seq.NEXTVAL, 't_raj', 'raj.teacher@example.com', 'hashed_pw_t1', 'teacher');
INSERT INTO app_user (user_id, username, email, password_hash, role) 
VALUES (quser_id_seq.NEXTVAL, 't_meena', 'meena.teacher@example.com', 'hashed_pw_t2', 'teacher');

-- Students
INSERT INTO app_user (user_id, username, email, password_hash, role) 
VALUES (quser_id_seq.NEXTVAL, 's_arun', 'arun.student@example.com', 'hashed_pw_s1', 'student');
INSERT INTO app_user (user_id, username, email, password_hash, role) 
VALUES (quser_id_seq.NEXTVAL, 's_kavya', 'kavya.student@example.com', 'hashed_pw_s2', 'student');
INSERT INTO app_user (user_id, username, email, password_hash, role) 
VALUES (quser_id_seq.NEXTVAL, 's_manoj', 'manoj.student@example.com', 'hashed_pw_s3', 'student');

-- ============================================
-- 4. Teachers
-- ============================================
INSERT INTO teacher (teacher_id, user_id, name) VALUES (teacher_id_seq.NEXTVAL, 2, 'Prof. Raj Kumar');
INSERT INTO teacher (teacher_id, user_id, name) VALUES (teacher_id_seq.NEXTVAL, 3, 'Prof. Meena Sharma');

-- ============================================
-- 5. Students
-- ============================================
INSERT INTO student (student_id, user_id, name, class_id, dept_id) 
VALUES (student_id_seq.NEXTVAL, 4, 'Arun Patel', 1, 1);
INSERT INTO student (student_id, user_id, name, class_id, dept_id) 
VALUES (student_id_seq.NEXTVAL, 5, 'Kavya Reddy', 2, 2);
INSERT INTO student (student_id, user_id, name, class_id, dept_id) 
VALUES (student_id_seq.NEXTVAL, 6, 'Manoj Singh', 4, 4);

-- ============================================
-- 6. Quizzes
-- ============================================
INSERT INTO quiz (quiz_id, name, subject, class_id, dept_id, mark_per_question, start_date, end_date, duration_minutes, created_by)
VALUES (quiz_id_seq.NEXTVAL, 'AIDS Midterm', 'AIDS Basics', 1, 1, 1, TO_DATE('2025-10-01','YYYY-MM-DD'), TO_DATE('2025-10-01','YYYY-MM-DD'), 60, 1);

INSERT INTO quiz (quiz_id, name, subject, class_id, dept_id, mark_per_question, start_date, end_date, duration_minutes, created_by)
VALUES (quiz_id_seq.NEXTVAL, 'AIML Quiz', 'Machine Learning Intro', 2, 2, 1, TO_DATE('2025-10-02','YYYY-MM-DD'), TO_DATE('2025-10-02','YYYY-MM-DD'), 45, 2);

INSERT INTO quiz (quiz_id, name, subject, class_id, dept_id, mark_per_question, start_date, end_date, duration_minutes, created_by)
VALUES (quiz_id_seq.NEXTVAL, 'CSC Quiz', 'C Programming', 4, 4, 1, TO_DATE('2025-10-03','YYYY-MM-DD'), TO_DATE('2025-10-03','YYYY-MM-DD'), 60, 1);

-- ============================================
-- 7. Quiz Questions
-- ============================================
INSERT INTO quiz_question (question_id, quiz_id, question, op1, op2, op3, op4, correct_answer, mark)
VALUES (question_id_seq.NEXTVAL, 1, 'What is AIDS?', 'Virus', 'Bacteria', 'Fungus', 'Protozoa', 'op1', 1);

INSERT INTO quiz_question (question_id, quiz_id, question, op1, op2, op3, op4, correct_answer, mark)
VALUES (question_id_seq.NEXTVAL, 2, 'Which algorithm is used in ML?', 'Linear Regression', 'DFS', 'Stack', 'Queue', 'op1', 1);

INSERT INTO quiz_question (question_id, quiz_id, question, op1, op2, op3, op4, correct_answer, mark)
VALUES (question_id_seq.NEXTVAL, 3, 'Which keyword declares a variable in C?', 'var', 'int', 'let', 'const', 'op2', 1);

-- ============================================
-- 8. Quiz Results
-- ============================================INSERT INTO result (result_id, quiz_id, student_id, total_score)
INSERT INTO result (result_id, quiz_id, student_id, total_score) VALUES (result_id_seq.NEXTVAL, 1, 1, 1);
INSERT INTO result (result_id, quiz_id, student_id, total_score) VALUES (result_id_seq.NEXTVAL, 2, 2, 1);
INSERT INTO result (result_id, quiz_id, student_id, total_score) VALUES (result_id_seq.NEXTVAL, 3, 3, 1);


-- ============================================
-- 9. Result Answers
-- ============================================
INSERT INTO result_answer (result_answer_id, result_id, question_id, student_answer, mark_obtained) 
VALUES (result_answer_id_seq.NEXTVAL, 1, 1, 'op1', 1);

INSERT INTO result_answer (result_answer_id, result_id, question_id, student_answer, mark_obtained) 
VALUES (result_answer_id_seq.NEXTVAL, 2, 2, 'op1', 1);

INSERT INTO result_answer (result_answer_id, result_id, question_id, student_answer, mark_obtained) 
VALUES (result_answer_id_seq.NEXTVAL, 3, 3, 'op2', 1);


SELECT student_id, name FROM student;

select * from app_user;
commit;