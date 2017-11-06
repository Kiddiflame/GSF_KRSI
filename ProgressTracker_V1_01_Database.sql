drop database if exists ProgressTracker_V1;

create database ProgressTracker_V1
	default character set utf8
	default collate utf8_general_ci;

set default_storage_engine = innodb;
set sql_mode = 'STRICT_ALL_TABLES';

use ProgressTracker_V1;

-- School information
create table Schools
(
	schoolID int auto_increment,
    schoolName varchar(75),
    constraint school_PK primary key(schoolID)
);

-- Divisions belonging to certain scool(s)
create table Divisions
(
	divisionID int auto_increment,
    divisionName varchar(75) not null,
    schoolID int not null,
    constraint division_PK primary key(divisionID),
    constraint division_school_FK foreign key(schoolID) references Schools(schoolID)
);

-- Each division has at least one track
create table Tracks
(
	trackID int auto_increment,
    trackName varchar(75),
    validFrom date,
    divisionID int not null,
    constraint track_PK primary key(trackID),
    constraint track_division_FK foreign key(divisionID) references Divisions(divisionID)
);

-- All the courses in the database
create table Courses 
(
  courseNumber char(10),
  courseName varchar(75) not null,
  courseCredits tinyint(4) default 3,
  constraint course_PK primary key(courseNumber),
  constraint name_unique unique(courseName)
);

-- A course may or may not have restrictors applied to them
create table Restrictors 
(
  courseNumber char(10) not null,
  restrictorID char(10) not null,
  restrictorType char(1) default '1',
  constraint restrictor_PK primary key (courseNumber,restrictorID),
  constraint course_course_FK foreign key (courseNumber) references Courses (courseNumber),
  constraint restrictor_course_FK foreign key (courseNumber) references Courses (courseNumber)
);

-- Courses belonging to a certain track. A track can belong to more then one track(N:M)
create table TrackCourses
(
	trackID int not null,
    courseNumber char(10) not null,
    semester tinyint unsigned null,
    mandatory tinyint unsigned,
    constraint trackcourse_PK primary key(trackID,courseNumber),
    constraint track_course_tracks_FK foreign key(trackID) references Tracks(trackID),
    constraint track_course_courses_FK foreign key(courseNumber) references Courses(courseNumber)
);