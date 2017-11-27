/*
Created by: Sigurður Orri Hjaltason (and Kristinn)
Creation year:2017
*/

drop database if exists 0405993209_ProgressTracker_V1;
use 0405993209_ProgressTracker_V1;

select sum(Courses.courseCredits) 
from TrackCourses
inner join table Courses on TrackCourses.courseNumber = Courses.courseNumber
GROUP BY TrackCourses.trackID

/*dæmi 1*/
drop PROCEDURE if exists CourseList;
DELIMITER ☺
CREATE PROCEDURE CourseList()
begin
	select courseName from Courses
	order by courseName asc;
end ☺
DELIMITER ;

call CourseList();

/*dæmi 2*/
drop PROCEDURE if exists SingleCourse;
DELIMITER ☺
CREATE PROCEDURE SingleCourse(in SelectedCoursNumber char(10))
begin
	select * from Courses
    where courseNumber = SelectedCoursNumber;
end ☺
DELIMITER ;

call SingleCourse('GSF2A3U');

/*dæmi 3*/
drop PROCEDURE if exists NewCourse;
DELIMITER ☺
CREATE PROCEDURE NewCourse(in courseNumber char(10), in courseName varchar(75), in courseCredits tinyint(4), out number_of_inserted_rows int)
begin
	insert into Courses
    values (courseNumber, courseName, courseCredits);
end ☺
DELIMITER ;

call NewCourse('Testing123', 'testing_coursename', 1);

/*dæmi 4*/


/*dæmi 5*/
drop PROCEDURE if exists DeleteCourse;
DELIMITER ☺
CREATE PROCEDURE DeleteCourse(in SelectedCoursNumber char(10))
begin
	if (select * from TrackCourses where courseNumber = SelectedCoursNumber)=0
    then
		select 2;
    end if;
end ☺
DELIMITER ;
commit;
call DeleteCourse('GSF2A3U');
rollback;


/*dæmi 6*/
drop function if exists  NumberOfCourses;
DELIMITER ☺
create function NumberOfCourses()
returns int
begin
	declare fjöldi int;
    set fjöldi = (select count(*) from Courses);
	return fjöldi;
end;☺

select NumberOfCourses()

/*dæmi 7*/
drop function if exists  TotalTRackCredits;
DELIMITER ☺
create function TotalTRackCredits(Selected_ID int)
returns int
begin
	declare fjöldi int;
    
    set fjöldi = (select sum(Courses.courseCredits) from Courses
	inner join TrackCourses on Courses.courseNumber = TrackCourses.courseNumber
	inner join Tracks on TrackCourses.trackID = Tracks.trackID
	where Tracks.trackID = Selected_ID);
    
	return fjöldi;
end;☺
DELIMITER ;

select TotalTRackCredits(1);

/*dæmi 8*/
drop function if exists  HighestCredits;
DELIMITER ☺
create function HighestCredits()
returns int
begin
	declare fjöldi int;
    
    set fjöldi = (select max(Courses.courseCredits) from Courses);
    
	return fjöldi;
end;☺
DELIMITER ;

select HighestCredits();


/*dæmi 9*/
#Fall sem skilar toppfjölda námsbrauta(tracks) sem tilheyra námsbrautum(Divisions)


/*dæmi 10*/
CREATE TEMPORARY TABLE IF NOT EXISTS 
  temp_table
AS (
select Courses.courseNumber as 'x' from Courses
	inner join Restrictors on Courses.courseNumber = Restrictors.courseNumber
);

insert into temp_table 
(select Courses.courseNumber as 'x' from Courses
	inner join Restrictors on Courses.courseNumber = Restrictors.restrictorID);

select CONCAT ( x,' : ',count(x)) from temp_table
group by x;








/*Skilaverkefni 2*/
/*dæmi 1*/
drop table if exists Student;
create table Student
(
	s_id int primary key auto_increment,
    s_fn varchar(100),
    s_ln varchar(100),
	s_email varchar(120),
    trackID int,
    foreign key (trackID) references Tracks(trackID)
);
drop PROCEDURE if exists SkraNemanda;
DELIMITER ☺
CREATE PROCEDURE SkraNemanda(in firstName varchar(100), in lastName varchar(100), in email varchar(120), in Track varchar(75))
begin
	set @TrackID = (select trackID from Tracks where trackName = Track);
	insert into Student(s_fn,s_ln,S_email,trackID)
    values 
    (firstName,lastName, email,@TrackID);
end ☺
DELIMITER ;
call SkraNemanda ("siggi","orri","askurinnminn@gmail.com","Tölvubraut TBR16 - stúdentsbraut");
select * from Student;

drop table if exists CourseSemester;
drop table if exists Semester;
create table Semester
(
	id int auto_increment,
	semNumber tinyint,
	scedualed date,
	s_id int,
    constraint restrictor_PK primary key (id),
    constraint restrictor_unq unique (semNumber,s_id),
    FOREIGN KEY (s_id) REFERENCES student(s_id)

);
drop table if exists CourseSemester;
create table CourseSemester
(
	semesterID int,
    courseNumber char(10),
    grade double default null,
    foreign key (semesterID) references Semester(id),
    foreign key (courseNumber) references Courses(courseNumber)
);

/*dæmi 2*/
drop trigger if exists InsertDenial;
DELIMITER ☺
create trigger InsertDenial before insert on Restrictors 
for each row
begin
    if( new.courseNumber = new.RestrictorID) then
		set new.courseNumber=null;
        signal sqlstate '45000' set message_text = 'TriggerError: courseNumber and RestrictorID can not be the same';
    end if;
end ☺
DELIMITER ;
insert into Restrictors values('GSF2B3U','GSF2B3U',1);

/*dæmi 3*/
drop trigger if exists UpdateDenial;
DELIMITER ☺
create trigger UpdateDenial before update on Restrictors 
for each row
begin
    if( new.courseNumber = new.RestrictorID) then
		set new.courseNumber=null;
        signal sqlstate '45000' set message_text = 'TriggerError: courseNumber and RestrictorID can not be the same';
    end if;
end ☺
DELIMITER ;
update Restrictors
set courseNumber = 'GSF2B3U' where RestrictorID = 'GSF2B3U';


/*dæmi 4*/
drop PROCEDURE if exists einingarHeild;
DELIMITER ☺
CREATE PROCEDURE einingarHeild(in person int)
begin
	select sum(Courses.courseCredits) from Student
    Left join Semester on Semester.s_id = Student.s_id
    Left join CourseSemester on CourseSemester.semesterID = Semester.id
    Left join Courses on CourseSemester.courseNumber = Courses.courseNumber
    where CourseSemester.grade >=5 and Student.s_id=person;
end ☺
DELIMITER ;
commit;
call einingarHeild(1);
rollback;

/*dæmi 5*/
drop procedure if exists AddMandtoryCourses;
DELIMITER ☺
CREATE PROCEDURE AddMandtoryCourses( in student_identity int)
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE C_name CHAR(10);
	DECLARE recomendedSemester tinyint unsigned;
    
	declare CourseNameCursor cursor for 
		select Courses.courseName from Courses
		inner join TrackCourses on TrackCourses.courseNumber = Courses.courseNumber
		inner join Tracks on Tracks.trackID = TrackCourses.trackID
		where TrackCourses.trackID = (select Student.trackID from Student where s_id = student_identity) and TrackCourses.mandatory = 1;
        
	declare SemesterCursor cursor for 
		select TrackCourses.semester from Courses
		inner join TrackCourses on TrackCourses.courseNumber = Courses.courseNumber
		inner join Tracks on Tracks.trackID = TrackCourses.trackID
		where TrackCourses.trackID = (select Student.trackID from Student where s_id = student_identity) and TrackCourses.mandatory = 1;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    open CourseNameCursor;
    open SemesterCursor;
    
    read_loop: LOOP
		fetch CourseNameCursor into C_name;
        fetch SemesterCursor into recomendedSemester;
        if done then
			leave read_loop;
        end if;
        #my work here
		#step 1: call addCourse
        select addCourse(student_identity);
        #step 2: profit
        #end my work
	end loop;
    
    close CourseNameCursor;
    close SemesterCursor;
END ☺
DELIMITER ;
call AddMandtoryCourses(1);

DELIMITER ☺
create function addCourse(nemandi int, course char(10), semesterNumber tinyint)
returns tinyint
begin
	set @timed = semesterNumber;
	#check if it's not compleated
    if (select not exists(	select Student.s_id from Student															#does not matter what I return (I'm just checking if it returns anything
							inner join Semester on Semester.s_id = Student.s_id
							inner join CourseSemester on CourseSemester.semesterID = Semester.id
							inner join Courses on CourseSemester.courseNumber = Courses.courseNumber
							where CourseSemester.grade >=5 and Student.s_id=nemandi and CourseSemester.courseName = course
                            ))
	then
    #check if there is a constraint for this course
		if (select exists(select * from Restrictors where courseNumber = course))
        then
			#a course needs to be added
            #add the course it self(in the returned semester value)
			select 2+2;
		else
			#check what semester the course needs to be set
			select 2+2;
        end if;
    end if;
    return @timed;
end☺
DELIMITER ;

/*Verkefni 3*/
/*dæmi 1*/
drop PROCEDURE if exists SemesterInfo;#concat
DELIMITER ☺
CREATE PROCEDURE SemesterInfo()
begin
	drop table if exists jsonTable;
	create TEMPORARY table jsonTable (jdoc JSON);
    INSERT INTO jsonTable VALUES('{"Semester": {"Nemendur":{}}}');
end ☺
DELIMITER ;
call SemesterInfo();
rollback;
set @j = 4;
SELECT JSON_OBJECT('id',  @j, 'name', 'carrot');
SHOW VARIABLES LIKE "%version%";