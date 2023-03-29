-- CS4400: Introduction to Database Systems: Monday, January 30, 2023
-- Flight Management Course Project Database TEMPLATE (v1.0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

drop database if exists flight_management;
create database if not exists flight_management;
use flight_management;

-- Define the database structures and enter the denormalized data
CREATE TABLE route (
    routeID varchar (50) not null primary key
) ;

CREATE TABLE AIRLINE (
    airlineID varchar (50) not null,
    primary key (airlineID),
    revenue integer
) engine = innodb;

CREATE TABLE LOCATION (
    locID varchar(50),
    primary key (locID)
) engine = innodb;

CREATE TABLE AIRPLANE (
    tail_num varchar(50) not null,
    airlineID varchar(50) not null,
    speed integer,
    seat_cap integer,
    locID varchar(50) not null,
    primary key (tail_num, airlineID),
    foreign key (airlineID) references Airline (airlineID),
    foreign key (locID) references Location (locID)
) engine = innodb;

CREATE TABLE FLIGHT (
    flight_id varchar(50) not null,
    tail_num varchar(50) not null,
    airlineID varchar(50) not null,
    progress integer,
    next_time time(6),
    fstatus enum('on_ground', 'in_flight'),
    rID varchar(50) not null,
    primary key (flight_id),
    foreign key (tail_num, airlineID) references Airplane (tail_num, airlineID),
    foreign key (rID) references Route (routeID)
) engine = innodb;

CREATE TABLE PERSON (
    personID varchar(50) not null,
    fname varchar(100),
    lname varchar(100),
    locID varchar(50) not null,
    pilotFlag boolean,
    taxID varchar(50),
    experience integer,
    tail_num varchar(50) not null,
    airlineID varchar(50) not null,
    passengerFlag boolean,
    miles integer,
    primary key (personID),
    foreign key (tail_num, airlineID) references Airplane (tail_num, airlineID),
    foreign key (locID) references Location (locID)
) engine = innodb;

CREATE TABLE AIRPORT (
    airportID char(3) not null,
    airport_name char(100),
    city char(100),
    state char(2),
    locID varchar(50) not null,
    primary key (airportID),
    foreign key (locID) references Location (locID)
) engine = innodb;


CREATE TABLE TICKET (
    ticketID varchar(50) not null,
    cost integer,
    deplane_airport char(3) not null,
    flight_id varchar(50) not null,
    buyerID varchar(50) not null,
    primary key (ticketID),
    foreign key (deplane_airport) references Airport (airportID),
    foreign key (flight_ID) references Flight (flight_ID),
    foreign key (buyerID) references Person (personID)
) engine = innodb;

CREATE TABLE SEATS (
    ticketID varchar(50) not null,
    seat varchar(50),
    foreign key (ticketID) references Ticket (ticketID),
    primary key(ticketID, seat)
) engine = innodb;

CREATE TABLE LEG (
    legID varchar(8) not null,
    distance integer,
    arrive_airport_ID char(3) not null,
    depart_airport_ID char(3) not null,
    primary key (legID),
    foreign key (arrive_airport_ID) references Airport (airportID),
    foreign key (depart_airport_ID) references Airport (airportID)
) engine = innodb;

CREATE TABLE PROP (
    tail_num varchar(50) not null,
    airlineID varchar(50) not null,
    props integer,
    skids integer,
    foreign key (tail_num, airlineID) references Airplane (tail_num, airlineID),
    primary key (tail_num, airlineID)
) engine = innodb;

CREATE TABLE JET (
    tail_num varchar(50) not null,
    airlineID varchar(50) not null,
    engines integer,
    foreign key (tail_num, airlineID) references Airplane (tail_num, airlineID),
    primary key (tail_num, airlineID)
) engine = innodb;

CREATE TABLE LICENSE (
    personID varchar(50) not null,
    license enum('jet', 'prop', 'testing'),
    foreign key (personID) references Person (personID),
    primary key (personID, license)
) engine = innodb;

CREATE TABLE CONTAINS (
    routeID varchar(50) not null,
    legID varchar(8) not null,
    sequence integer not null,
    foreign key (routeID) references Route (routeID),
    foreign key (legID) references Leg (legID),
    primary key (sequence, legID, routeID)
) engine = innodb;
