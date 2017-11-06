use 0405993209_ProgressTracker_V2;

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
create table Students
(
	id int(100) primary key auto_increment,
    st_name varchar(100) not null,
    SelectedTrack int(11)
);
drop PROCEDURE if exists SkraNemanda;
DELIMITER ☺
CREATE PROCEDURE SkraNemanda(in student_name varchar(100), in Track int(11))
begin
	insert into Students(st_name,SelectedTrack)
    values 
    (student_name,Track);
end ☺
DELIMITER ;
call SkraNemanda ();

/*dæmi 2*/
DELIMITER ☺
create trigger UpdateDenial after insert on Restrictors 
for each row
begin
    if exists ( select * from Restrictors where Restrictors.courseNumber = Restrictors.restrictorID)
        rollback transaction
        raiserror ('some message', 16, 1)
    end if;
end ☺
DELIMITER ;