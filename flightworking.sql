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
CREATE TABLE ROUTE (
    routeID varchar (50) not null primary key
) ;

CREATE TABLE AIRLINE (
    airlineID varchar (50) not null,
    revenue integer,
    primary key (airlineID)
) engine = innodb;

CREATE TABLE LOCATION (
    locID varchar(50),
    primary key (locID)
) engine = innodb;

CREATE TABLE AIRPLANE (
    airlineID varchar(50) not null,
    tail_num varchar(50) not null,
    seat_cap integer,
    speed integer,
    locID varchar(50),
    primary key (tail_num, airlineID),
    foreign key (airlineID) references Airline (airlineID),
    foreign key (locID) references Location (locID)
) engine = innodb;

CREATE TABLE FLIGHT (
    flight_id varchar(50) not null,
    tail_num varchar(50),
    airlineID varchar(50),
    progress integer,
    next_time time(6),
    fstatus enum('on_ground', 'in_flight'),
    routeID varchar(50) not null,
    primary key (flight_id),
    foreign key (tail_num, airlineID) references Airplane (tail_num, airlineID),
    foreign key (routeID) references Route (routeID)
) engine = innodb;

CREATE TABLE PERSON (
    personID varchar(50) not null,
    fname varchar(100),
    lname varchar(100),
    locID varchar(50) not null,
    pilotFlag boolean,
    taxID varchar(50),
    experience integer,
    tail_num varchar(50),
    airlineID varchar(50),
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
    locID varchar(50),
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

CREATE TABLE CONTAIN (
    routeID varchar(50) not null,
    legID varchar(8) not null,
    sequence integer not null,
    foreign key (routeID) references Route (routeID),
    foreign key (legID) references Leg (legID),
    primary key (sequence, legID, routeID)
) engine = innodb;


-- insert values
INSERT INTO ROUTE (routeID) VALUES
	('circle_east_coast'),
	('circle_west_coast'),
	('eastbound_north_milk_run'),
	('eastbound_north_nonstop'),
	('eastbound_south_milk_run'),
	('hub_xchg_southeast'),
	('hub_xchg_southwest'),
	('local_texas'),
	('northbound_east_coast'),
	('northbound_west_coast'),
	('southbound_midwest'),
	('westbound_north_milk_run'),
	('westbound_north_nonstop'),
	('westbound_south_nonstop');
    
INSERT INTO AIRLINE (airlineID, revenue) VALUES
	('Air_France', '25'),
	('American', '45'),
	('Delta', '46'),
	('JetBlue', '8'),
	('Lufthansa', '31'),
	('Southwest', '22'),
	('Spirit', '4'),
	('United', '40');
    
INSERT INTO LOCATION (locID) VALUES
	('plane_1'),
	('plane_11'),
	('plane_15'),
	('plane_2'),
	('plane_4'),
	('plane_7'),
	('plane_8'),
	('plane_9'),
	('port_1'),
	('port_10'),
	('port_11'),
	('port_13'),
	('port_14'),
	('port_15'),
	('port_17'),
	('port_18'),
	('port_2'),
	('port_3'),
	('port_4'),
	('port_5'),
	('port_7'),
	('port_9');
    
INSERT INTO AIRPLANE (airlineID, tail_num, seat_cap, speed, locID) VALUES
	('American', 'n330ss', '4', '200', 'plane_4'),
	('American', 'n380sd', '5', '400', null),
	('Delta', 'n106js', '4', '200', 'plane_1'),
	('Delta', 'n110jn', '5', '600', 'plane_2'),
	('Delta', 'n127js', '4', '800', null),
	('Delta', 'n156sq', '8', '100', null),
	('JetBlue', 'n161fk', '4', '200', null),
	('JetBlue', 'n337as', '5', '400', null),
	('Southwest', 'n118fm', '4', '100', 'plane_11'),
	('Southwest', 'n401fj', '4', '200', 'plane_9'),
	('Southwest', 'n653fk', '6', '400', null),
	('Southwest', 'n815pw', '3', '200', null),
	('Spirit', 'n256ap', '4', '400', 'plane_15'),
	('United', 'n451fi', '5', '400', null),
	('United', 'n517ly', '4', '400', 'plane_7'),
	('United', 'n616lt', '7', '400', null),
	('United', 'n620la', '4', '200', 'plane_8');
    
INSERT INTO FLIGHT (flight_ID, routeID, airlineID, tail_num, progress, fstatus, next_time) VALUES
	('AM_1523', 'circle_west_coast', 'American', 'n330ss', '2', 'on_ground', '14:30:00'),
	('DL_1174', 'northbound_east_coast', 'Delta', 'n106js', '0', 'on_ground', '08:00:00'),
	('DL_1243', 'westbound_north_nonstop', 'Delta', 'n110jn', '0', 'on_ground', '09:30:00'),
	('DL_3410', 'circle_east_coast', null, null, null, null, null),
	('SP_1880', 'circle_east_coast', 'Spirit', 'n256ap', '2', 'in_flight', '15:00:00'),
	('SW_1776', 'hub_xchg_southwest', 'Southwest', 'n401fj', '2', 'in_flight', '14:00:00'),
	('SW_610', 'local_texas', 'Southwest', 'n118fm', '2', 'in_flight', '11:30:00'),
	('UN_1899', 'eastbound_north_milk_run', 'United', 'n517ly', '0', 'on_ground', '09:30:00'),
	('UN_523', 'hub_xchg_southeast', 'United', 'n620la', '1', 'in_flight', '11:00:00'),
	('UN_717', 'circle_west_coast',null,null,null,null,null);
    
INSERT INTO PERSON (personID, fname, lname, locID, taxID, experience, airlineID, tail_num, miles, passengerFlag, pilotFlag) VALUES
	('p1', 'Jeanne', 'Nelson', 'plane_1', '330-12-6907', '31', 'Delta', 'n106js', null, '0', '1'),
	('p10', 'Lawrence', 'Morgan', 'plane_9', '769-60-1266', '15', 'Southwest', 'n401fj', null, '0', '1'),
	('p11', 'Sandra', 'Cruz', 'plane_9', '369-22-9505', '22', 'Southwest', 'n401fj', null, '0', '1'),
	('p12', 'Dan', 'Ball', 'plane_11', '680-92-5329', '24', 'Southwest', 'n118fm', null, '0', '1'),
	('p13', 'Bryant', 'Figueroa', 'plane_2', '513-40-4168', '24', 'Delta', 'n110jn', null, '0', '1'),
	('p14', 'Dana', 'Perry', 'plane_2', '454-71-7847', '13', 'Delta', 'n110jn', null, '0', '1'),
	('p15', 'Matt', 'Hunt', 'plane_2', '153-47-8101', '30', 'Delta', 'n110jn', null, '0', '1'),
	('p16', 'Edna', 'Brown', 'plane_15', '598-47-5172', '28', 'Spirit', 'n256ap', null, '0', '1'),
	('p17', 'Ruby', 'Burgess', 'plane_15', '865-71-6800', '36', 'Spirit', 'n256ap', null, '0', '1'),
	('p18', 'Esther', 'Pittman', 'port_2', '250-86-2784', '23', null, null, null, '0', '1'),
	('p19', 'Doug', 'Fowler', 'port_4', '386-39-7881', '2', null, null, null, '0', '1'),
	('p2', 'Roxanne', 'Byrd', 'plane_1', '842-88-1257', '9', 'Delta', 'n106js', null, '0', '1'),
	('p20', 'Thomas', 'Olson', 'port_3', '522-44-3098', '28', null, null, null, '0', '1'),
	('p21', 'Mona', 'Harrison', 'port_4', '621-34-5755', '2', null, null, '771', '1', '1'),
	('p22', 'Arlene', 'Massey', 'port_2', '177-47-9877', '3', null, null, '374', '1', '1'),
	('p23', 'Judith', 'Patrick', 'port_3', '528-64-7912', '12', null, null, '414', '1', '1'),
	('p24', 'Reginald', 'Rhodes', 'plane_1', '803-30-1789', '34', null, null, '292', '1', '1'),
	('p25', 'Vincent', 'Garcia', 'plane_1', '986-76-1587', '13', null, null, '390', '1', '1'),
	('p26', 'Cheryl', 'Moore', 'plane_4', '584-77-5105', '20', null, null, '302', '1', '1'),
	('p27', 'Michael', 'Rivera', 'plane_7', null, null, null, null, '470', '1', '0'),
	('p28', 'Luther', 'Matthews', 'plane_8', null, null, null, null, '208', '1', '0'),
	('p29', 'Moses', 'Parks', 'plane_8', null, null, null, null, '292', '1', '0'),
	('p3', 'Tanya', 'Nguyen', 'plane_4', '750-24-7616', '11', 'American', 'n330ss', null, '0', '1'),
	('p30', 'Ora', 'Steele', 'plane_9', null, null, null, null, '686', '1', '0'),
	('p31', 'Antonio', 'Flores', 'plane_9', null, null, null, null, '547', '1', '0'),
	('p32', 'Glenn', 'Ross', 'plane_11', null, null, null, null, '257', '1', '0'),
	('p33', 'Irma', 'Thomas', 'plane_11', null, null, null, null, '564', '1', '0'),
	('p34', 'Ann', 'Maldonado', 'plane_2', null, null, null, null, '211', '1', '0'),
	('p35', 'Jeffrey', 'Cruz', 'plane_2', null, null, null, null, '233', '1', '0'),
	('p36', 'Sonya', 'Price', 'plane_15', null, null, null, null, '293', '1', '0'),
	('p37', 'Tracy', 'Hale', 'plane_15', null, null, null, null, '552', '1', '0'),
	('p38', 'Albert', 'Simmons', 'port_1', null, null, null, null, '812', '1', '0'),
	('p39', 'Karen', 'Terry', 'port_9', null, null, null, null, '541', '1', '0'),
	('p4', 'Kendra', 'Jacobs', 'plane_4', '776-21-8098', '24', 'American', 'n330ss', null, '0', '1'),
	('p40', 'Glen', 'Kelley', 'plane_4', null, null, null, null, '441', '1', '0'),
	('p41', 'Brooke', 'Little', 'port_4', null, null, null, null, '875', '1', '0'),
	('p42', 'Daryl', 'Nguyen', 'port_3', null, null, null, null, '691', '1', '0'),
	('p43', 'Judy', 'Willis', 'port_1', null, null, null, null, '572', '1', '0'),
	('p44', 'Marco', 'Klein', 'port_2', null, null, null, null, '572', '1', '0'),
	('p45', 'Angelica', 'Hampton', 'port_5', null, null, null, null, '663', '1', '0'),
	('p5', 'Jeff', 'Burton', 'plane_4', '933-93-2165', '27', 'American', 'n330ss', null, '0', '1'),
	('p6', 'Randal', 'Parks', 'plane_7', '707-84-4555', '38', 'United', 'n517ly', null, '0', '1'),
	('p7', 'Sonya', 'Owens', 'plane_7', '450-25-5617', '13', 'United', 'n517ly', null, '0', '1'),
	('p8', 'Bennie', 'Palmer', 'plane_8', '701-38-2179', '12', 'United', 'n620la', null, '0', '1'),
	('p9', 'Marlene', 'Warner', 'plane_8', '936-44-6941', '13', 'United', 'n620la', null, '0', '1');
    
INSERT INTO AIRPORT (airportID, airport_name, city, state, locID) VALUES
	('ABQ', 'Albuquerque International Sunport', 'Albuquerque', 'NM', null),
	('ANC', 'Ted Stevens Anchorage International Airport', 'Anchorage', 'AK', null),
	('ATL', 'Hartsfield-Jackson Atlanta International Airport', 'Atlanta', 'GA', 'port_1'),
	('BDL', 'Bradley International Airport', 'Hartford', 'CT', null),
	('BFI', 'King County International Airport', 'Seattle', 'WA', 'port_10'),
	('BHM', 'Birmingham-Shuttlesworth International Airport', 'Birmingham', 'AL', null),
	('BNA', 'Nashville International Airport', 'Nashville', 'TN', null),
	('BOI', 'Boise Airport ', 'Boise', 'ID', null),
	('BOS', 'General Edward Lawrence Logan International Airport', 'Boston', 'MA', null),
	('BTV', 'Burlington International Airport', 'Burlington', 'VT', null),
	('BWI', 'Baltimore_Washington International Airport', 'Baltimore', 'MD', null),
	('BZN', 'Bozeman Yellowstone International Airport', 'Bozeman', 'MT', null),
	('CHS', 'Charleston International Airport', 'Charleston', 'SC', null),
	('CLE', 'Cleveland Hopkins International Airport', 'Cleveland', 'OH', null),
	('CLT', 'Charlotte Douglas International Airport', 'Charlotte', 'NC', null),
	('CRW', 'Yeager Airport', 'Charleston', 'WV', null),
	('DAL', 'Dallas Love Field', 'Dallas', 'TX', 'port_7'),
	('DCA', 'Ronald Reagan Washington National Airport', 'Washington', 'DC', 'port_9'),
	('DEN', 'Denver International Airport', 'Denver', 'CO', 'port_3'),
	('DFW', 'Dallas-Fort Worth International Airport', 'Dallas', 'TX', 'port_2'),
	('DSM', 'Des Moines International Airport', 'Des Moines', 'IA', null),
	('DTW', 'Detroit Metro Wayne County Airport', 'Detroit', 'MI', null),
	('EWR', 'Newark Liberty International Airport', 'Newark', 'NJ', null),
	('FAR', 'Hector International Airport', 'Fargo', 'ND', null),
	('FSD', 'Joe Foss Field', 'Sioux Falls', 'SD', null),
	('GSN', 'Saipan International Airport', 'Obyan Saipan Island', 'MP', null),
	('GUM', 'Antonio B_Won Pat International Airport', 'Agana Tamuning', 'GU', null),
	('HNL', 'Daniel K. Inouye International Airport', 'Honolulu Oahu', 'HI', null),
	('HOU', 'William P_Hobby Airport', 'Houston', 'TX', 'port_18'),
	('IAD', 'Washington Dulles International Airport', 'Washington', 'DC', 'port_11'),
	('IAH', 'George Bush Intercontinental Houston Airport', 'Houston', 'TX', 'port_13'),
	('ICT', 'Wichita Dwight D_Eisenhower National Airport ', 'Wichita', 'KS', null),
	('ILG', 'Wilmington Airport', 'Wilmington', 'DE', null),
	('IND', 'Indianapolis International Airport', 'Indianapolis', 'IN', null),
	('ISP', 'Long Island MacArthur Airport', 'New York Islip', 'NY', 'port_14'),
	('JAC', 'Jackson Hole Airport', 'Jackson', 'WY', null),
	('JAN', 'Jackson_Medgar Wiley Evers International Airport', 'Jackson', 'MS', null),
	('JFK', 'John F_Kennedy International Airport ', 'New York', 'NY', 'port_15'),
	('LAS', 'Harry Reid International Airport', 'Las Vegas', 'NV', null),
	('LAX', 'Los Angeles International Airport', 'Los Angeles', 'CA', 'port_5'),
	('LGA', 'LaGuardia Airport', 'New York', 'NY', null),
	('LIT', 'Bill and Hillary Clinton National Airport', 'Little Rock', 'AR', null),
	('MCO', 'Orlando International Airport', 'Orlando', 'FL', null),
	('MDW', 'Chicago Midway International Airport', 'Chicago', 'IL', null),
	('MHT', 'Manchester_Boston Regional Airport', 'Manchester', 'NH', null),
	('MKE', 'Milwaukee Mitchell International Airport', 'Milwaukee', 'WI', null),
	('MRI', 'Merrill Field', 'Anchorage', 'AK', null),
	('MSP', 'Minneapolis_St_Paul International Wold_Chamberlain Airport', 'Minneapolis Saint Paul', 'MN', null),
	('MSY', 'Louis Armstrong New Orleans International Airport', 'New Orleans', 'LA', null),
	('OKC', 'Will Rogers World Airport', 'Oklahoma City', 'OK', null),
	('OMA', 'Eppley Airfield', 'Omaha', 'NE', null),
	('ORD', 'O_Hare International Airport', 'Chicago', 'IL', 'port_4'),
	('PDX', 'Portland International Airport', 'Portland', 'OR', null),
	('PHL', 'Philadelphia International Airport', 'Philadelphia', 'PA', null),
	('PHX', 'Phoenix Sky Harbor International Airport', 'Phoenix', 'AZ', null),
	('PVD', 'Rhode Island T_F_Green International Airport', 'Providence', 'RI', null),
	('PWM', 'Portland International Jetport', 'Portland', 'ME', null),
	('SDF', 'Louisville International Airport', 'Louisville', 'KY', null),
	('SEA', 'Seattle-Tacoma International Airport', 'Seattle Tacoma', 'WA', 'port_17'),
	('SJU', 'Luis Munoz Marin International Airport', 'San Juan Carolina', 'PR', null),
	('SLC', 'Salt Lake City International Airport', 'Salt Lake City', 'UT', null),
	('STL', 'St_Louis Lambert International Airport', 'Saint Louis', 'MO', null),
	('STT', 'Cyril E_King Airport', 'Charlotte Amalie Saint Thomas', 'VI', null);
    
INSERT INTO TICKET (ticketID, cost, deplane_airport, flight_id, buyerID) VALUES
	('tkt_dl_1', '450', 'JFK', 'DL_1174', 'p24'),
	('tkt_dl_2', '225', 'JFK', 'DL_1174', 'p25'),
	('tkt_am_3', '250', 'LAX', 'AM_1523', 'p26'),
	('tkt_un_4', '175', 'DCA', 'UN_1899', 'p27'),
	('tkt_un_5', '225', 'ATL', 'UN_523', 'p28'),
	('tkt_un_6', '100', 'ORD', 'UN_523', 'p29'),
	('tkt_sw_7', '400', 'ORD', 'SW_1776', 'p30'),
	('tkt_sw_8', '175', 'ORD', 'SW_1776', 'p31'),
	('tkt_sw_9', '125', 'HOU', 'SW_610', 'p32'),
	('tkt_sw_10', '425', 'HOU', 'SW_610', 'p33'),
	('tkt_dl_11', '500', 'LAX', 'DL_1243', 'p34'),
	('tkt_dl_12', '250', 'LAX', 'DL_1243', 'p35'),
	('tkt_sp_13', '225', 'ATL', 'SP_1880', 'p36'),
	('tkt_sp_14', '150', 'DCA', 'SP_1880', 'p37'),
	('tkt_un_15', '150', 'ORD', 'UN_523', 'p38'),
	('tkt_sp_16', '475', 'ATL', 'SP_1880', 'p39'),
	('tkt_am_17', '375', 'ORD', 'AM_1523', 'p40'),
	('tkt_am_18', '275', 'LAX', 'AM_1523', 'p41');
    
INSERT INTO SEATS (ticketID, seat) VALUES
	('tkt_dl_1', '1C'),
	('tkt_dl_1', '2F'),
	('tkt_dl_2', '2D'),
	('tkt_am_3', '3B'),
	('tkt_un_4', '2B'),
	('tkt_un_5', '1A'),
	('tkt_un_6', '3B'),
	('tkt_sw_7', '3C'),
	('tkt_sw_8', '3E'),
	('tkt_sw_9', '1C'),
	('tkt_sw_10', '1D'),
	('tkt_dl_11', '1E'),
	('tkt_dl_11', '1B'),
	('tkt_dl_11', '2F'),
	('tkt_dl_12', '2A'),
	('tkt_sp_13', '1A'),
	('tkt_sp_14', '2B'),
	('tkt_un_15', '1B'),
	('tkt_sp_16', '2C'),
	('tkt_sp_16', '2E'),
	('tkt_am_17', '2B'),
	('tkt_am_18', '2A');
    
INSERT INTO LEG (legID, distance, depart_airport_ID, arrive_airport_ID) VALUES
	('leg_11', '600', 'IAD', 'ORD'),
	('leg_13', '1400', 'IAH', 'LAX'),
	('leg_14', '2400', 'ISP', 'BFI'),
	('leg_15', '800', 'JFK', 'ATL'),
	('leg_2', '600', 'ATL', 'IAH'),
	('leg_5', '1000', 'BFI', 'LAX'),
	('leg_4', '600', 'ATL', 'ORD'),
	('leg_20', '600', 'ORD', 'DCA'),
	('leg_7', '600', 'DCA', 'ATL'),
	('leg_18', '1200', 'LAX', 'DFW'),
	('leg_10', '800', 'DFW', 'ORD'),
	('leg_22', '800', 'ORD', 'LAX'),
	('leg_24', '1800', 'SEA', 'ORD'),
	('leg_8', '200', 'DCA', 'JFK'),
	('leg_23', '2400', 'SEA', 'JFK'),
	('leg_9', '800', 'DFW', 'ATL'),
	('leg_1', '600', 'ATL', 'IAD'),
	('leg_25', '600', 'ORD', 'ATL'),
	('leg_12', '200', 'IAH', 'DAL'),
	('leg_26', '800', 'LAX', 'ORD'),
	('leg_6', '200', 'DAL', 'HOU'),
	('leg_3', '800', 'ATL', 'JFK'),
	('leg_19', '1000', 'LAX', 'SEA'),
	('leg_21', '800', 'ORD', 'DFW'),
	('leg_16', '800', 'JFK', 'ORD'),
	('leg_17', '2400', 'JFK', 'SEA'),
	('leg_27', '1600', 'ATL', 'LAX');
    
INSERT INTO PROP (airlineID, tail_num, skids, props) VALUES
	('Southwest', 'n118fm', '1', '1'),
	('Southwest', 'n815pw', '0', '2'),
	('United', 'n620la', '0', '2');
    
INSERT INTO JET (airlineID, tail_num, engines) VALUES
	('American', 'n330ss', '2'),
	('American', 'n380sd', '2'),
	('Delta', 'n106js', '2'),
	('Delta', 'n110jn', '4'),
	('JetBlue', 'n161fk', '2'),
	('JetBlue', 'n337as', '2'),
	('Southwest', 'n401fj', '2'),
	('Southwest', 'n653fk', '2'),
	('Spirit', 'n256ap', '2'),
	('United', 'n451fi', '4'),
	('United', 'n517ly', '2'),
	('United', 'n616lt', '4');
    
INSERT INTO LICENSE (personID, license) VALUES
	('p1', 'jet'),
	('p10', 'jet'),
	('p11', 'jet'),
	('p11', 'prop'),
	('p12', 'prop'),
	('p13', 'jet'),
	('p14', 'jet'),
	('p15', 'jet'),
	('p15', 'prop'),
	('p15', 'testing'),
	('p16', 'jet'),
	('p17', 'prop'),
	('p17', 'jet'),
	('p18', 'jet'),
	('p19', 'jet'),
	('p2', 'jet'),
	('p2', 'prop'),
	('p20', 'jet'),
	('p21', 'prop'),
	('p21', 'jet'),
	('p22', 'jet'),
	('p23', 'jet'),
	('p24', 'jet'),
	('p24', 'prop'),
	('p24', 'testing'),
	('p25', 'jet'),
	('p26', 'jet'),
	('p3', 'jet'),
	('p4', 'jet'),
	('p4', 'prop'),
	('p5', 'jet'),
	('p6', 'jet'),
	('p6', 'prop'),
	('p7', 'jet'),
	('p8', 'prop'),
	('p9', 'jet'),
	('p9', 'prop'),
	('p9', 'testing');
    
INSERT INTO CONTAIN (routeID, legID, sequence) VALUES
	('circle_east_coast', 'leg_4', '1'),
	('circle_west_coast', 'leg_20', '2'),
	('circle_west_coast', 'leg_7', '3'),
	('circle_west_coast', 'leg_18', '1'),
	('circle_west_coast', 'leg_10', '2'),
	('circle_west_coast', 'leg_22', '3'),
	('eastbound_north_milk_run', 'leg_24', '1'),
	('eastbound_north_milk_run', 'leg_20', '2'),
	('eastbound_north_milk_run', 'leg_8', '3'),
	('eastbound_north_nonstop', 'leg_23', '1'),
	('eastbound_south_milk_run', 'leg_18', '1'),
	('eastbound_south_milk_run', 'leg_9', '2'),
	('eastbound_south_milk_run', 'leg_1', '3'),
	('hub_xchg_southeast', 'leg_25', '1'),
	('hub_xchg_southeast', 'leg_4', '2'),
	('hub_xchg_southwest', 'leg_22', '1'),
	('hub_xchg_southwest', 'leg_26', '2'),
	('local_texas', 'leg_12', '1'),
	('local_texas', 'leg_6', '2'),
	('northbound_east_coast', 'leg_3', '1'),
	('northbound_west_coast', 'leg_19', '1'),
	('southbound_midwest', 'leg_21', '1'),
	('westbound_north_milk_run', 'leg_16', '1'),
	('westbound_north_milk_run', 'leg_22', '2'),
	('westbound_north_milk_run', 'leg_19', '3'),
	('westbound_north_nonstop', 'leg_17', '1'),
	('westbound_south_nonstop', 'leg_27', '1');