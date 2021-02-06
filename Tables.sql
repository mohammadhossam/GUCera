--CREATE DATABASE GUCera

CREATE TABLE Users
(
    id        INT IDENTITY,
    firstName VARCHAR(20),
    lastName  VARCHAR(20),
    password  VARCHAR(20),
    email     VARCHAR(50),
    gender    BIT,
    address   VARCHAR(10),
    CONSTRAINT PK_Users PRIMARY KEY (id)
);

CREATE TABLE UserMobileNumber
(
    id           INT,
    mobile_number VARCHAR(20),
    CONSTRAINT PK_UserMobileNumber PRIMARY KEY (id, mobile_number),
    CONSTRAINT FK_UserMobileNumber_Student FOREIGN KEY (id) REFERENCES Users On DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Instructor
(
    id     INT,
    rating DECIMAL(3, 2) DEFAULT 0,
    CONSTRAINT PK_Instructor PRIMARY KEY (id),
    CONSTRAINT FK_Instructor_Users Foreign KEY (id) REFERENCES Users ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Student
(
    id  INT,
    gpa DECIMAL(3, 2) DEFAULT 0,
    CONSTRAINT PK_Student PRIMARY KEY (id),
    CONSTRAINT FK_Student_Users FOREIGN KEY (id) REFERENCES Users ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Admin
(
    id INT,
    CONSTRAINT PK_Admin PRIMARY KEY (id),
    CONSTRAINT FK_Admin_Users FOREIGN KEY (id) REFERENCES Users ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Course
(
    id                INT IDENTITY,
    creditHours       INT,
    name              VARCHAR(10),
    courseDescription VARCHAR(200),
    price             DECIMAL(6, 2),
    content           varchar(20),
    adminId           INT,
    instructorId      INT,
    accepted          BIT,
    CONSTRAINT PK_Course PRIMARY KEY (id),
    CONSTRAINT FK_Course_ADMIN FOREIGN KEY (adminId) REFERENCES Admin ON DELETE SET NULL ON UPDATE CASCADE ,
    CONSTRAINT FK_Course_INSTRUCTOR FOREIGN KEY (instructorId) REFERENCES Instructor ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE TABLE Assignment
(
    cid       INT,
    number    INT,
    type      VARCHAR(10),
    fullGrade INT,
    weight    DECIMAL(4, 1),
    deadline  DATETIME,
    content   VARCHAR(200),
    CONSTRAINT PK_Assignment PRIMARY KEY (cid, number, type),
    CONSTRAINT FK_Assignment_Course FOREIGN KEY (cid) REFERENCES Course ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Feedback
(
    cid           INT,
    number        INT IDENTITY,
    comment       VARCHAR(100),
    numberOfLikes INT DEFAULT 0,
    sid           INT,
    CONSTRAINT PK PRIMARY KEY (cid, number),
    CONSTRAINT FK_Feedback_COURSE FOREIGN KEY (cid) REFERENCES Course ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Feedback_STUDENT FOREIGN KEY (sid) REFERENCES Student ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Promocode
(
    code       VARCHAR(6),
    issueDate  DATETIME,
    expiryDate DATETIME,
    discount   DECIMAL(4, 2),
    adminID    INT,
    CONSTRAINT PK_Promocode PRIMARY KEY (code),
    CONSTRAINT FK_Promocode_Admin FOREIGN KEY (adminID) REFERENCES Admin ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE StudentHasPromocode
(
    sid  INT,
    code VARCHAR(6),
    CONSTRAINT PK_StudentHasPromocode PRIMARY KEY (sid, code),
    CONSTRAINT FK_StudentHasPromocode_STUDENT FOREIGN KEY (sid) REFERENCES Student ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_StudentHasPromocode_PROMOCODE FOREIGN KEY (code) REFERENCES Promocode ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CreditCard
(
    number         VARCHAR(15),
    cardHolderName VARCHAR(16),
    expiryDate     DATETIME,
    CVV            VARCHAR(3),
    CONSTRAINT PK_CreditCard PRIMARY KEY (number)
);

CREATE TABLE StudentAddCreditCard
(
    sid              INT,
    creditCardNumber VARCHAR(15),
    CONSTRAINT PK_StudentAddCreditCard PRIMARY KEY (sid, creditCardNumber),
    CONSTRAINT FK_StudentAddCreditCard_Student FOREIGN KEY (sid) REFERENCES Student ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_StudentAddCreditCard_CreditCard FOREIGN KEY (creditCardNumber) REFERENCES CreditCard ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE StudentTakeCourse
(
    sid      INT,
    cid      INT,
    instId   INT,
    payedfor BIT,
    grade    decimal(5,2) default  0,
    CONSTRAINT PK_StudentTakeCourse PRIMARY KEY (sid, cid, instId),
    CONSTRAINT FK_StudentTakeCourse_Student FOREIGN KEY (sid) REFERENCES Student ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_StudentTakeCourse_Course FOREIGN KEY (cid) REFERENCES Course ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_StudentTakeCourse_Instructor FOREIGN KEY (instId) REFERENCES Instructor ON DELETE NO ACTION ON UPDATE NO ACTION

);



CREATE TABLE StudentTakeAssignment
(
    sid              INT,
    cid              INT,
    assignmentNumber INT,
    assignmentType   VARCHAR(10),
    grade            DECIMAL(5, 2) DEFAULT 0,
    CONSTRAINT PK_StudentTakeAssignment PRIMARY KEY (sid, cid, assignmentNumber, assignmentType),
    CONSTRAINT FK_StudentTakeAssignment_Student FOREIGN KEY (sid) REFERENCES Student ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_StudentTakeAssignment_Assignment FOREIGN KEY (cid, assignmentNumber, assignmentType) REFERENCES Assignment ON DELETE NO ACTION ON UPDATE NO ACTION

);

CREATE TABLE StudentRateInstructor
(
    sid    INT,
    instId INT,
    rate   DECIMAL(2, 1),
    CONSTRAINT PK_StudentRateInstructor PRIMARY KEY (sid, instId),
    CONSTRAINT FK_StudentRateInstructor_Student FOREIGN KEY (sid) REFERENCES Student ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_StudentRateInstructor_Instructor FOREIGN KEY (instId) REFERENCES Instructor ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE StudentCertifyCourse
(
    sid       INT,
    cid       INT,
    issueDate datetime,
    CONSTRAINT PK_StudentCertifyCourse PRIMARY KEY (sid, cid),
    CONSTRAINT FK_StudentCertifyCourse_Student FOREIGN KEY (sid) REFERENCES Student ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_StudentCertifyCourse_Course FOREIGN KEY (cid) REFERENCES Course ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CoursePrerequisiteCourse
(
    cid            INT,
    prerequisiteId INT,
    CONSTRAINT PK_CoursePrerequisiteCourse PRIMARY KEY (cid, prerequisiteId),
    CONSTRAINT FK_CoursePrerequisiteCourse_Course1 FOREIGN KEY (cid) REFERENCES Course ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_CoursePrerequisiteCourse_Course2 FOREIGN KEY (prerequisiteId) REFERENCES Course ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE InstructorTeachCourse
(
    instId INT,
    cid    INT,
    CONSTRAINT PK_InstructorTeachCourse PRIMARY KEY (instId, cid),
    CONSTRAINT FK_InstructorTeachCourse_Instructor FOREIGN KEY (instId) REFERENCES Instructor ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_InstructorTeachCourse_Course FOREIGN KEY (cid) REFERENCES Course ON DELETE CASCADE ON UPDATE CASCADE
);