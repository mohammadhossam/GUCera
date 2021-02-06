CREATE PROCEDURE studentRegister @first_name varchar(20),
                                 @last_name varchar(20),
                                 @password varchar(20),
                                 @email varchar(50),
                                 @gender bit,
                                 @address varchar(10)
AS
    INSERT INTO Users
    VALUES (@first_name, @last_name, @password, @email, @gender, @address)
    DECLARE @id int
    SELECT @id = MAX(id)
    FROM Users
    INSERT INTO Student (id)
    VALUES (@id)

GO
CREATE PROCEDURE InstructorRegister @first_name varchar(20),
                                    @last_name varchar(20),
                                    @password varchar(20),
                                    @email varchar(50),
                                    @gender bit,
                                    @address varchar(10)
AS
    INSERT INTO Users
    VALUES (@first_name, @last_name, @password, @email, @gender, @address)

    DECLARE @id int

    SELECT @id = MAX(id)
    FROM Users

    INSERT INTO Instructor (id)
    VALUES (@id)


GO

CREATE PROCEDURE userLogin @ID int,
                           @password varchar(20),
                           @Success bit output,
                           @Type int output
AS
    DECLARE @rightPass varchar(20)
    DECLARE @isInstructor int -- 0
    DECLARE @isAdmin int -- 1
    DECLARE @isStudent int -- 2

    SELECT @rightPass = password
    FROM Users
    WHERE Users.id = @ID

    IF @rightPass IS NOT NULL AND @rightPass = @password
        SET @Success = 1
    ELSE
        SET @Success = 0

    SELECT @isAdmin = Admin.id
    FROM Admin
    WHERE @ID = Admin.id

    SELECT @isStudent = Student.id
    FROM Student
    WHERE @ID = Student.id

    SELECT @isInstructor = Instructor.id
    FROM Instructor
    WHERE @ID = Instructor.id

    IF @Success = 1
        BEGIN
            IF @isAdmin IS NOT NULL
                SET @Type = 1
            ELSE
                BEGIN
                    IF @isStudent IS NOT NULL
                        SET @Type = 2
                    ELSE
                        SET @Type = 0
                END
        END

GO

CREATE PROCEDURE addMobile @ID int,
                           @mobile_number varchar(20)
AS
    INSERT INTO UserMobileNumber
    VALUES (@ID, @mobile_number)

GO

CREATE PROCEDURE AdminListInstr
AS
    SELECT U.firstName, U.lastName
    FROM Instructor Instr inner join Users U on Instr.id = U.id

GO

CREATE PROCEDURE AdminViewInstructorProfile @instrId int
AS
    SELECT U.firstName, U.lastName, U.gender, U.email, U.address, Instr.rating
    FROM Instructor Instr inner join Users U on U.id = Instr.id
    WHERE Instr.id = @instrId

GO

CREATE PROCEDURE AdminViewAllCourses
AS
    SELECT C.name, C.creditHours, C.price, C.content, C.accepted
    FROM Course C

GO

CREATE PROCEDURE AdminViewNonAcceptedCourses
AS
    SELECT C.name, C.creditHours, C.price, C.content
    FROM Course C
    WHERE C.accepted is null OR C.accepted = 0

GO

CREATE PROCEDURE AdminViewCourseDetails @courseId int
AS
    SELECT C.name, C.creditHours, C.price, C.content, C.accepted
    FROM Course C
    WHERE C.id = @courseId

GO

CREATE PROCEDURE AdminAcceptRejectCourse @adminId int,
                                         @courseId int
AS

    UPDATE Course
    SET accepted = 1, adminId  = @adminId
    where id = @courseId

GO

CREATE PROCEDURE AdminCreatePromocode @code varchar(6),
                                      @issueDate datetime,
                                      @expiryDate datetime,
                                      @discount decimal(4, 2),
                                      @adminId int
AS
    INSERT INTO Promocode VALUES (@code, @issueDate, @expiryDate, @discount, @adminId)

GO

CREATE PROC AdminListAllStudents
AS
    SELECT U.firstName, U.lastName
    FROM Student S inner join Users U on S.id = U.id

GO

CREATE PROC AdminViewStudentProfile @sid INT
AS
    SELECT U.firstName, U.lastName, U.gender, U.email, U.address, S.gpa
    FROM Student S inner join Users U on S.id = U.id
    WHERE S.id = @sid
GO

CREATE PROC AdminIssuePromocodeToStudent @sid INT,
                                         @pid VARCHAR(6)
AS
    INSERT INTO StudentHasPromocode
    VALUES (@sid, @pid)
GO

CREATE PROC InstAddCourse @creditHours INT,
                          @name VARCHAR(10),
                          @price DECIMAL(6, 2),
                          @instructorId INT
AS
    INSERT INTO Course (creditHours, name, price, instructorId)
    VALUES (@creditHours, @name, @price, @instructorId)
    DECLARE @lastCourseId INT

    SELECT @lastCourseId = MAX(id)
    FROM Course
    INSERT INTO InstructorTeachCourse
    Values (@instructorId, @lastCourseId)

GO

CREATE PROC UpdateCourseContent @instrId INT,
                                @courseId INT,
                                @content VARCHAR(20)
AS
    IF EXISTS(
        SELECT *
        FROM InstructorTeachCourse
        WHERE cid = @courseId AND instId = @instrId
    )
    BEGIN
        UPDATE Course
        SET content=@content
        WHERE id = @courseId
    END
GO

CREATE PROC UpdateCourseDescription @instrId INT,
                                    @courseId INT,
                                    @courseDescription VARCHAR(200)
AS

    IF EXISTS(
        SELECT *
        FROM InstructorTeachCourse
        WHERE instId = @instrId AND cid = @courseId
    )
    BEGIN
        UPDATE Course
        SET courseDescription = @courseDescription
        WHERE id = @courseId
    END
GO

CREATE PROC AddAnotherInstructorToCourse @insid INT,
                                         @cid INT,
                                         @adderIns INT
AS
    IF EXISTS(
        SELECT ITC.instId
        FROM InstructorTeachCourse ITC
        WHERE @adderIns = ITC.instId and @cid = ITC.cid
    )
    BEGIN
        INSERT INTO InstructorTeachCourse VALUES (@insid, @cid)
    END


GO

CREATE PROC InstructorViewAcceptedCoursesByAdmin @instrId INT
AS
    SELECT C.id, C.name, C.creditHours
    FROM Course C
    WHERE C.instructorId = @instrId and C.accepted = 1

GO

CREATE PROC DefineCoursePrerequisites @cid INT,
                                      @prerequisiteId INT
AS
    INSERT INTO CoursePrerequisiteCourse VALUES (@cid, @prerequisiteId)

GO

CREATE PROC DefineAssignmentOfCourseOfCertianType @instId INT,
                                                  @cid INT,
                                                  @number INT,
                                                  @type VARCHAR(10),
                                                  @fullGrade INT,
                                                  @weight DECIMAL(4, 1),
                                                  @deadline DATETIME,
                                                  @content VARCHAR(200)
AS

    IF EXISTS(
        SELECT ITC.cid, ITC.instId
        FROM InstructorTeachCourse ITC inner join Course C on C.id = ITC.cid
        WHERE ITC.cid = @cid and ITC.instId = @instId and C.accepted = 1
    )
    BEGIN
        INSERT INTO Assignment VALUES (@cid, @number, @type, @fullGrade, @weight, @deadline, @content)
    END

GO

CREATE PROC updateInstructorRate @insid INT
AS
    DECLARE @Rate DECIMAL(3, 2)

    SELECT @Rate = AVG(rate)
    FROM StudentRateInstructor
    WHERE instId = @insid

    IF @Rate is not null
        UPDATE Instructor
        SET rating = @Rate
        WHERE id = @insid



GO

CREATE PROC ViewInstructorProfile @instrId INT
AS
    EXEC updateInstructorRate @instrId

    SELECT U.firstName, U.lastName, U.gender, U.email, U.address, I.rating, UMN.mobile_number
    FROM Instructor I
         inner join Users U on I.id = U.id
         left outer join UserMobileNumber UMN on U.id = UMN.id
    WHERE I.id = @instrId

GO
--4(h)
CREATE PROCEDURE InstructorViewAssignmentsStudents
   @instrId int, @cid int
AS
    IF EXISTS
    (
        SELECT *
        FROM InstructorTeachCourse
        WHERE cid = @cid AND instId = @instrId
    )
    BEGIN
    SELECT sid, cid, assignmentNumber,assignmentType
    FROM StudentTakeAssignment
    WHERE cid = @cid
    END
GO
--4(i)
CREATE PROCEDURE InstructorgradeAssignmentOfAStudent
    @instrId int,@sid int,@cid int,@assignmentNumber int,@type varchar(10),@grade decimal(5,2)
AS
    IF EXISTS(
        SELECT *
        FROM InstructorTeachCourse
        WHERE cid = @cid AND instId = @instrId
    )
    BEGIN
        UPDATE StudentTakeAssignment
        SET grade=@grade
        WHERE sid=@sid AND cid=@cid AND assignmentNumber=@assignmentNumber AND assignmentType=@type
    END

GO
--4(j)
CREATE PROCEDURE ViewFeedbacksAddedByStudentsOnMyCourse @instrId int, @cid int
AS

    IF EXISTS(
        SELECT *
        FROM InstructorTeachCourse
        WHERE instId = @instrId AND cid = @cid
    )
    BEGIN
        SELECT number, comment, numberOfLikes
        FROM Feedback F
        WHERE cid = @cid
    END
GO

--4(K)
CREATE PROCEDURE calculateFinalGrade @cid int, @sid int, @insId int
AS
    DECLARE @finalGrade decimal(5,2)
    IF EXISTS(SELECT *
              FROM StudentTakeCourse STC
              WHERE (STC.sid = @sid AND STC.cid = @cid)
    )AND EXISTS(
            SELECT *
            FROM InstructorTeachCourse ITC
            WHERE (ITC.instId=@insId AND ITC.cid=@cid)
    )
    BEGIN
    SELECT @finalGrade = SUM((STA.grade/A.fullGrade) * CalculationTable.individualWeight)
    FROM StudentTakeAssignment STA
        inner join Assignment A on A.cid = STA.cid and A.number = STA.assignmentNumber and A.type = STA.assignmentType
        inner join (
            SELECT cid , type, (MAX(weight) / COUNT(*)) as individualWeight
            FROM Assignment
            GROUP BY cid , type
        )CalculationTable on A.cid = CalculationTable.cid AND A.type = CalculationTable.type
        WHERE STA.cid = @cid AND STA.sid = @sid
    END
    UPDATE StudentTakeCourse
    SET grade = @finalGrade
    WHERE cid = @cid AND sid = @sid
GO


CREATE PROCEDURE InstructorIssueCertificateToStudent @cid int, @sid int, @insId int, @issueDate datetime
AS
    EXECUTE calculateFinalGrade @cid , @sid , @insId
    IF EXISTS(
        SELECT *
        FROM StudentTakeCourse
        WHERE cid = @cid AND sid = @sid AND grade >= 50
    )
    BEGIN
            INSERT INTO StudentCertifyCourse values (@sid, @cid, @issueDate)
    END

GO

--5(a)
CREATE PROCEDURE viewMyProfile @id int
AS
    SELECT *
    FROM Student
         INNER JOIN Users U on Student.id = U.id
    WHERE Student.id = @id
GO

--5(b)
CREATE PROCEDURE editMyProfile @id int, @firstName varchar(10), @lastName varchar(10), @password varchar(10),
                               @gender binary,
                               @email varchar(10), @address varchar(10)
AS
    IF @firstName IS NOT NULL
        UPDATE Users
        SET firstName=@firstName
        WHERE id = @id
    IF @lastName IS NOT NULL
        UPDATE Users
        SET lastName=@lastName
        WHERE id = @id
    IF @password IS NOT NULL
        UPDATE Users
        SET password=@password
        WHERE id = @id
    IF @gender IS NOT NULL
        UPDATE Users
        SET gender = @gender
        WHERE id = @id
    IF @email IS NOT NULL
        UPDATE Users
        SET email=@email
        WHERE id = @id
    IF @address IS NOT NULL
        UPDATE Users
        SET address=@address
        WHERE id = @id

GO
--5(c)
CREATE PROCEDURE availableCourses
AS
    SELECT name
    FROM Course
    WHERE accepted = 1

GO
--5(d)

CREATE PROCEDURE courseInformation @id int
AS
SELECT creditHours, name, courseDescription, price, U.firstName, U.lastName
FROM Course C
         INNER JOIN InstructorTeachCourse I on (C.id = I.cid)
         INNER JOIN Users U ON U.id = I.instId
         WHERE C.id = @id AND C.accepted = 1
GO
--5(e)

CREATE PROCEDURE enrollInCourse @sid INT, @cid INT, @instr int
AS
    IF NOT EXISTS(
        (
            SELECT prerequisiteId
            FROM CoursePrerequisiteCourse
            WHERE cid = @cid
        )
        EXCEPT
        (
            SELECT cid
            FROM StudentCertifyCourse
            WHERE sid = @sid
        )
    )AND NOT EXISTS(
            SELECT *
            FROM StudentTakeCourse
            WHERE sid = @sid AND cid = @cid
        )
    BEGIN
        INSERT INTO StudentTakeCourse(sid, cid, instId) VALUES (@sid, @cid, @instr)
    END
GO
--5(f)

CREATE PROCEDURE addCreditCard @sid int, @number varchar(15), @cardHolderName varchar(16), @expiryDate datetime,
                               @cvv varchar(3)
AS
    INSERT INTO CreditCard
    VALUES (@number, @cardHolderName, @expiryDate, @cvv)
    INSERT INTO StudentAddCreditCard
    VALUES (@sid, @number)

GO

CREATE PROCEDURE viewPromocode @sid INT
AS
SELECT P.*
FROM Promocode P
         INNER JOIN StudentHasPromocode SHP on P.code = SHP.code
WHERE SHP.sid = @sid

GO

CREATE PROCEDURE payCourse @cid INT, @sid INT
AS
    EXECUTE viewPromocode @sid
    if exists(
        select *
        from StudentAddCreditCard
        where sid = @sid
        )
    UPDATE StudentTakeCourse
    SET payedfor = 1
    WHERE sid = @sid AND cid = @cid
GO

CREATE PROCEDURE enrollInCourseViewContent @id INT, @cid INT
AS
    SELECT C.id, C.creditHours, C.name, C.courseDescription, C.price, C.content
    FROM StudentTakeCourse S
         INNER JOIN Course C on C.id = S.cid
    WHERE S.sid = @id AND C.id = @cid


GO

CREATE PROCEDURE viewAssign @courseId INT, @Sid INT
AS
    SELECT A.cid, A.number, A.type, A.fullGrade, A.weight, A.deadline, A.content
    FROM StudentTakeCourse STC
         INNER JOIN Assignment A on STC.cid = A.cid
    WHERE STC.sid = @Sid AND STC.cid = @courseId

GO

CREATE PROCEDURE submitAssign @assignType VARCHAR(10), @assignnumber INT, @sid INT, @cid INT
AS
    IF EXISTS(
        SELECT *
        FROM StudentTakeCourse
        WHERE cid = @cid AND sid = @sid
    )
    BEGIN
            INSERT INTO StudentTakeAssignment (sid, cid, assignmentNumber, assignmentType)
            VALUES (@sid, @cid, @assignnumber, @assignType)
    END

GO

CREATE PROCEDURE viewAssignGrades @assignnumber INT, @assignType VARCHAR(10), @cid INT, @sid INT,
                                  @assignGrade INT OUTPUT
AS
    SELECT @assignGrade = STA.grade
    FROM StudentTakeAssignment STA
    WHERE sid = @sid AND cid = @cid AND STA.assignmentNumber = @assignnumber AND assignmentType = @assignType
GO

CREATE PROCEDURE viewFinalGrade @cid INT, @sid INT, @finalgrade DECIMAL(10, 2) OUTPUT
AS
    SELECT @finalgrade = STC.grade
    FROM StudentTakeCourse STC
    WHERE cid = @cid AND sid = @sid

GO

CREATE PROCEDURE addFeedback @comment VARCHAR(100), @cid INT, @sid INT
AS
    IF EXISTS(
        SELECT *
        FROM StudentTakeCourse
        WHERE sid = @sid AND cid = @cid
        )
    BEGIN
        INSERT INTO Feedback (cid, comment, sid)
        VALUES (@cid, @comment, @sid)
    END
GO

CREATE PROCEDURE rateInstructor @rate DECIMAL(2, 1), @sid INT, @insid INT
AS
    IF EXISTS(
            SELECT *
            FROM StudentTakeCourse STA INNER JOIN InstructorTeachCourse ITC on STA.cid = ITC.cid
            WHERE sid = @sid AND ITC.instId = @insid
        )
        BEGIN
            INSERT INTO StudentRateInstructor (sid, instId, rate)
            VALUES (@sid, @insid, @rate)
        END
GO

CREATE PROCEDURE viewCertificate @cid INT, @sid INT
AS
    SELECT *
    FROM StudentCertifyCourse
    WHERE sid = @sid AND cid = @cid
GO

