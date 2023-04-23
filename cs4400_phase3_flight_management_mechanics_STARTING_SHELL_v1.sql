-- CS4400: Introduction to Database Systems: Wednesday, March 8, 2023
-- Flight Management Course Project Mechanics (v1.0) STARTING SHELL
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

use flight_management;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a database-wide unique location if
it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	if ip_airlineID is null then leave sp_main; end if;
    if ip_airlineID not in (select airlineID from airline) then leave sp_main; end if;
    if ip_tail_num in (select tail_num from airplane) then leave sp_main; end if;
    if ip_seat_capacity = 0 or ip_speed = 0 then leave sp_main; end if;
    if ip_plane_type = 'prop' and ip_jet_engines is not null then leave sp_main; end if;
	if ip_plane_type = 'jet' and ip_propellers is not null then leave sp_main; end if;
	
    if ip_plane_type = 'prop' or ip_plane_type = 'jet' then 
        insert into airplane values(ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, 
    ip_propellers, ip_jet_engines);
    end if;

end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a database-wide unique location if it will be used to support
airplane takeoffs and landings.  An airport may have a longer, more descriptive
name.  An airport must also have a city and state designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state char(2), in ip_locationID varchar(50))
sp_main: begin
	if ip_airportID in (select airportID from airport) then leave sp_main; end if;
	if ip_locationID not in (select locationID from location) then leave sp_main; end if;
    #if ip_airport_name not in (select airlineID from airline) then leave sp_main; end if;
    if ip_city is null then leave sp_main; end if;
    if ip_state is null then leave sp_main; end if;
	insert into airport values(ip_airportID, ip_airport_name, ip_city, ip_state, ip_locationID);
end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person may have a first and last name as well.

Also, a person can hold a pilot role, a passenger role, or both roles.  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  Also,
a pilot might be assigned to a specific airplane as part of the flight crew.  As a
passenger, a person will have some amount of frequent flyer miles. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_flying_airline varchar(50), in ip_flying_tail varchar(50),
    in ip_miles integer)
sp_main: begin
	if ip_personID in (select personID from person) then leave sp_main; end if;
    if ip_locationID not in (select locationID from location) then leave sp_main; end if;
    
    insert into person values (ip_personID, ip_first_name, ip_last_name, ip_locationId);

    if ip_taxID is not null and ip_taxID not in (select taxID from pilot) then 
    insert into pilot values (ip_personID, ip_taxID, ip_experience, ip_flying_airline, ip_flying_tail);
    end if;
    
	if ip_miles > 0 then 
    insert into passenger values (ip_personID, ip_miles);
    end if;
end //
delimiter ;

-- [4] grant_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new pilot license.  The license must reference
a valid pilot, and must be a new/unique type of license for that pilot. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_pilot_license;
delimiter //
create procedure grant_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	if ip_personID not in (select personID from person) then leave sp_main; end if;
    if ip_license in (select license from pilot_licenses where personID = ip_personID) then leave sp_main; end if;
    
    insert into pilot_licenses values (ip_personID, ip_license);

end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  Once
an airplane has been assigned, we must also track where the airplane is along
the route, whether it is in flight or on the ground, and when the next action -
takeoff or landing - will occur. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_airplane_status varchar(100), in ip_next_time time)
sp_main: begin
	if ip_routeID not in (select routeID from route) then leave sp_main; end if;
    if ip_support_airline is not null and ip_support_airline not in (select airlineID from airline) then leave sp_main; end if;
    if ip_flightID in (select flightID from flight) then leave sp_main; end if;
    if ip_support_tail is not null and ip_support_tail not in (select tail_num from airplane) then leave sp_main; end if;
    
    insert into flight values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 
		ip_airplane_status, ip_next_time);
end //
delimiter ;

-- [6] purchase_ticket_and_seat()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ticket.  The cost of the flight is optional
since it might have been a gift, purchased with frequent flyer miles, etc.  Each
flight must be tied to a valid person for a valid flight.  Also, we will make the
(hopefully simplifying) assumption that the departure airport for the ticket will
be the airport at which the traveler is currently located.  The ticket must also
explicitly list the destination airport, which can be an airport before the final
airport on the route.  Finally, the seat must be unoccupied. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ticket_and_seat;
delimiter //
create procedure purchase_ticket_and_seat (in ip_ticketID varchar(50), in ip_cost integer,
	in ip_carrier varchar(50), in ip_customer varchar(50), in ip_deplane_at char(3),
    in ip_seat_number varchar(50))
sp_main: begin
	if ip_customer not in (select personId from person) and ip_carrier not in (select flightID from flight) then
    leave sp_main; end if;
    if ip_deplane_at is null then leave sp_main; end if;
	if ip_deplane_at not in (select arrival from leg where legID = (select legID from route_path 
		where routeID = (select routeID from flight where flightID = ip_carrier))) then leave sp_main; end if;
    if ip_seat_number in (select seat_number from ticket_seats where ip_ticketID = ticketID) then leave sp_main; end if;
    
    insert into ticket values (ip_ticketID, ip_cost, ip_carrier, ip_customer, ip_deplane_at);
    insert into ticket_seats values (ip_ticketID, ip_seat_number);
    end //
delimiter ;

-- [7] add_update_leg()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new leg as specified.  However, if a leg from
the departure airport to the arrival airport already exists, then don't create a
new leg - instead, update the existence of the current leg while keeping the existing
identifier.  Also, all legs must be symmetric.  If a leg in the opposite direction
exists, then update the distance to ensure that it is equivalent.   */
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (in ip_legID varchar(50), in ip_distance integer,
    in ip_departure char(3), in ip_arrival char(3))
sp_main: begin
    if ip_legID in (select legID from leg) then leave sp_main; end if;
    if ip_departure in (select departure from leg) and ip_arrival in (select arrival from leg where departure = ip_departure) then
        update leg 
        set distance = ip_distance 
        where leg.departure = ip_departure and leg.arrival = ip_arrival;
    else 
        insert into leg values (ip_legID, ip_distance, ip_departure, ip_arrival);
    end if;
    
    if ip_departure in (select arrival from leg) and ip_arrival in (select departure from leg where arrival = ip_departure) then
        update leg 
        set distance = ip_distance 
        where leg.arrival = ip_departure and leg.departure = ip_arrival;
    end if;
end //
delimiter ;

-- [8] start_route()
-- -----------------------------------------------------------------------------
/* This stored procedure creates the first leg of a new route.  Routes in our
system must be created in the sequential order of the legs.  The first leg of
the route can be any valid leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin
    if ip_legID not in (select legID from leg) then leave sp_main; end if;
    if ip_routeID in (select routeID from route_path) then leave sp_main; end if;
    if ip_legID in (select legID from leg) and ip_routeID in (select routeID from route) then
        insert into route_path values (ip_routeID, ip_legID, 1);
    end if;
    if ip_legID in (select legID from leg) and ip_routeID not in (select routeID from route) then
        insert into route values (ip_routeID);
        insert into route_path values (ip_routeID, ip_legID, 1);
    end if;
end //
delimiter ;

-- [9] extend_route()
-- -----------------------------------------------------------------------------
/* This stored procedure adds another leg to the end of an existing route.  Routes
in our system must be created in the sequential order of the legs, and the route
must be contiguous: the departure airport of this leg must be the same as the
arrival airport of the previous leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists extend_route;
delimiter //
create procedure extend_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin
    if ip_routeID not in (select routeID from route) then leave sp_main; end if;
    if ip_legID not in (select legID from leg) then leave sp_main; end if;
    set @maxVal = (select max(sequence) from route_path where routeID = ip_routeID);
    set @lastLegID = (select legID from route_path where sequence = @maxVal and routeID = ip_routeID);
    set @lastArrivalAirport = (select arrival from leg where legID = @lastLegID);
    set @departAirport = (select departure from leg where legID = ip_legID);
    if @lastArrivalAirport = @departAirport then 
        insert into route_path values (ip_routeID, ip_legID, @maxVal + 1);
    end if;
end //
delimiter ;

-- [10] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
	if ip_flightID not in (select flightID from flight) then leave sp_main; end if;
    if (select airplane_status from flight where flightID = ip_flightID) = 'on_ground' then leave sp_main; end if;
	if (select support_airline from flight where flightID = ip_flightID) is null then leave sp_main; end if;
	update flight set airplane_status = 'on_ground', next_time = date_add(next_time, interval 1 hour) where flightID = ip_flightID;
    
    set @flightlocation = (select locationID from airplane where airlineID = (select support_airline from flight where flightID = ip_flightID)
	and tail_num = (select support_tail from flight where flightID = ip_flightID));
    
    update pilot set experience = experience + 1 where personId in 
	(select personID from person where locationID = @flightlocation);
    
	update passenger set miles = miles + (select distance from leg where legID in (select legID from route_path where routeID in (select routeID from flight where flightID = ip_flightID) and sequence in (select progress from flight where flightID = ip_flightID))) 
	where personID in (select personID from person where locationID = @flightlocation);
end //
delimiter ;

-- [11] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
	#interpreted as if theres a pilot shortage stay 'on_ground' and only increment next_time by 30 minutes instead of full time
	if ip_flightID not in (select flightID from flight) then leave sp_main; end if;
    if (select airplane_status from flight where flightID = ip_flightID) = 'in_flight' then leave sp_main; end if;
    set @planetype = (select plane_type from airplane join flight on airlineID = support_airline and tail_num = support_tail where flightID = ip_flightID);
    set @numpilots = (select count(*) from pilot, flight where flying_airline = support_airline and flying_tail = support_tail);
    if @planetype = 'jet' and @numpilots < 2 then 
		update flight set next_time = date_add(next_time, interval 30 minute) where flightID = ip_flightID;
        leave sp_main; end if;
	if @planetype = 'prop' and @numpilots < 1 then
		update flight set next_time = date_add(next_time, interval 30 minute) where flightID = ip_flightID;
        leave sp_main; end if;
        
	update flight set airplane_status = 'in_flight', progress = progress + 1 where flightID = ip_flightID;
	set @dist = (select distance from leg where legID in (select legID from route_path where routeID in (select routeID from flight where flightID = ip_flightID) and sequence in (select progress from flight where flightID = ip_flightID)));
    set @tinc = @dist / (select speed from airplane join flight on airlineID = support_airline and tail_num = support_tail where flightID = ip_flightID);
    update flight set next_time = date_add(next_time, interval @tinc hour) where flightID = ip_flightID;
end //
delimiter ;

-- [12] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the airport and hold a valid ticket
for the flight. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
	if ip_flightID not in (select flightID from flight) then leave sp_main; end if;
    if (select airplane_status from flight where flightID = ip_flightID) = 'in_flight' then leave sp_main; end if;
	set @arriveair = (select arrival from leg where legID in (select legID from route_path where routeID in (select routeID from flight where flightID = ip_flightID) and sequence in (select progress from flight where flightID = ip_flightID)));
	set @portloc = (select locationID from airport where airportID = @arriveair);
    set @planeloc = (select locationID from airplane join flight on airlineID = support_airline and tail_num = support_tail where flightID = ip_flightID);
    update person set locationID = @planeloc where locationID = @portloc and personID in (select customer from ticket where carrier = ip_flightID);
end //
delimiter ;

-- [13] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
	if ip_flightID not in (select flightID from flight) then leave sp_main; end if;
    if (select airplane_status from flight where flightID = ip_flightID) = 'in_flight' then leave sp_main; end if;
	set @planeloc = (select locationID from airplane join flight on airlineID = support_airline and tail_num = support_tail where flightID = ip_flightID);
    set @departair = (select arrival from leg where legID in (select legID from route_path where routeID in (select routeID from flight where flightID = ip_flightID) and sequence in (select progress from flight where flightID = ip_flightID)));
	set @portloc = (select locationID from airport where airportID = @departair);
    update person set locationID = @portloc where locationID = @planeloc and @departair = (select deplane_at from ticket where customer = personID);
end //
delimiter ;

-- [14] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
airplane.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin
    if ip_flightID not in (select flightID from flight) then leave sp_main; end if;
    if ip_personID not in (select personID from pilot) then leave sp_main; end if;
    if (select airplane_status from flight where flightID = ip_flightID) = 'in_flight' then leave sp_main; end if;
    set @departair = (select arrival from leg where legID in (select legID from route_path where routeID in (select routeID from flight where flightID = ip_flightID) and sequence in (select progress from flight where flightID = ip_flightID)));
    set @portloc = (select locationID from airport where airportID = @departair);
    set @planeloc = (select locationID from airplane join flight on airlineID = support_airline and tail_num = support_tail where flightID = ip_flightID);
    set @ptype = (select plane_type from airplane join flight on airlineID = support_airline and tail_num = support_tail where flightID = ip_flightID);
    if @ptype in (select license from pilot_licenses where personID = ip_personID) and (select flying_airline from pilot where personID = ip_personID) is null then
        update person set locationID = @planeloc where personID = ip_personID;
        update pilot set flying_airline = (select support_airline from flight where flightID = ip_flightID),
        flying_tail = (select support_tail from flight where flightID = ip_flightID) where personID = ip_personID;
    end if;
end //
delimiter ;

-- [15] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin
	if ip_flightID not in (select flightID from flight) then leave sp_main; end if;
	set @planeloc = (select locationID from airplane join flight on airlineID = support_airline and tail_num = support_tail where flightID = ip_flightID);
	set @departair = (select arrival from leg where legID in (select legID from route_path where routeID in (select routeID from flight where flightID = ip_flightID) and sequence in (select progress from flight where flightID = ip_flightID)));
	set @portloc = (select locationID from airport where airportID = @departair);
	set @numpilots = (select count(*) from pilot where flying_airline = (select support_airline from flight where flightID = ip_flightID) and flying_tail = (select support_tail from flight where flightID = ip_flightID));
	set @seqlen = (select max(sequence) from route_path where routeID = (select routeID from flight where flightID = ip_flightID));
	if (select airplane_status from flight where flightID = ip_flightID) = 'on_ground' and
	(select count(*) from person where locationID = @planeloc) = @numpilots and
	@seqlen = (select progress from flight where flightID = ip_flightID) then
		update person set locationID = @portloc where personID in (select personID from pilot where flying_airline = (select support_airline from flight where flightID = ip_flightID)
        and flying_tail = (select support_tail from flight where flightID = ip_flightID));
        update pilot set flying_airline = null, flying_tail = null where flying_airline = (select support_airline from flight where flightID = ip_flightID)
        and flying_tail = (select support_tail from flight where flightID = ip_flightID);
	end if;
end //
delimiter ;

-- [16] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin
	if ip_flightID not in (select flightID from flight) then leave sp_main; end if;
	set @seqlen = (select max(sequence) from route_path where routeID = (select routeID from flight where flightID = ip_flightID));
    set @currprog = (select progress from flight where flightID = ip_flightID);
    if (select airplane_status from flight where flightID = ip_flightID) = 'on_ground' and (@currprog = @seqlen or @currprog = 0) then
		delete from flight where flightID = ip_flightID;
	end if;
end //
delimiter ;

-- [17] remove_passenger_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the passenger role from person.  The passenger
must be on the ground at the time; and, if they are on a flight, then they must
disembark the flight at the current airport.  If the person had both a pilot role
and a passenger role, then the person and pilot role data should not be affected.
If the person only had a passenger role, then all associated person data must be
removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_passenger_role;
delimiter //
create procedure remove_passenger_role (in ip_personID varchar(50))
sp_main: begin
	if ip_personID not in (select personID from person) then leave sp_main; end if;
	# assuming that passenger data includes any tickets they have (or should pilots keep any tickets?)
	set @loc = (select locationID from person where personID = ip_personID);
	set @ip_flightID = (select flightID from flight where support_airline = (select airlineID from airplane where locationID = @loc) and support_tail = (select tail_num from airplane where locationID = @loc));
    set @departair = (select arrival from leg where legID in (select legID from route_path where routeID in (select routeID from flight where flightID = @ip_flightID) and sequence in (select progress from flight where flightID = @ip_flightID)));
	set @fstatus = (select airplane_status from flight where support_airline = (select airlineID from airplane where locationID = @loc) and support_tail = (select tail_num from airplane where locationID = @loc));
    if @loc like 'plane%' and (@fstatus = 'in_flight' or @departair not in (select deplane_at from ticket where customer = ip_personID)) then leave sp_main; end if;
	if ip_personID in (select personID from pilot) then
		delete from passenger where personID = ip_personID;
		delete from ticket where customer = ip_personID;
		leave sp_main;
 	end if;
	delete from ticket where customer = ip_personID;
    delete from passenger where personID = ip_personID;
    delete from person where personID = ip_personID;
end //
delimiter ;

-- [18] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the pilot role from person.  The pilot must not
be assigned to a flight; or, if they are assigned to a flight, then that flight
must either be at the start or end of its route.  If the person had both a pilot
role and a passenger role, then the person and passenger role data should not be
affected.  If the person only had a pilot role, then all associated person data
must be removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_personID varchar(50))
sp_main: begin
    if ip_personID not in (select personID from person) or ip_personID not in (select personID from pilot) then leave sp_main; end if;
    if (select flying_airline from pilot where personID = ip_personID) is not null then
        set @loc = (select locationID from person where personID = ip_personID);
        set @ip_flightID = (select flightID from flight where support_airline = (select airlineID from airplane where locationID = @loc) and support_tail = (select tail_num from airplane where locationID = @loc));
        set @seqlen = (select max(sequence) from route_path where routeID = (select routeID from flight where flightID = @ip_flightID));
        set @currprog = (select progress from flight where flightID = @ip_flightID);
        if @currprog <> 0 and (@seqlen <> @currprog or (select airplane_status from flight where flightID = @ip_flightID) = 'in_flight') then leave sp_main; end if;
    end if;
    
    if ip_personID in (select personID from passenger) then
        delete from pilot_licenses where personID = ip_personID;
        delete from pilot where personID = ip_personID;
        leave sp_main;
    end if;
    
    delete from pilot_licenses where personID = ip_personID;
    delete from pilot where personID = ip_personID;
    delete from person where personID = ip_personID;
end //
delimiter ;

-- [19] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
    flight_list, earliest_arrival, latest_arrival, airplane_list) as
select departure, arrival, count(flightID), group_concat(flightID separator ', '), min(next_time), max(next_time), group_concat(airplane.locationID separator ', ')
from leg, flight, route_path, airplane where route_path.routeID = flight.routeID and route_path.legID = leg.legID and flight.airplane_status = 'in_flight'
and route_path.sequence = flight.progress and flight.support_airline = airplane.airlineID and flight.support_tail = airplane.tail_num
group by departure, arrival;

-- [20] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
    flight_list, earliest_arrival, latest_arrival, airplane_list) as 
select departure, count(flightID), group_concat(flightID separator ', '), min(next_time), max(next_time), group_concat(airplane.locationID separator ', ')
from leg, flight, route_path, airplane where route_path.routeID = flight.routeID and route_path.legID = leg.legID and flight.airplane_status = 'on_ground'
and route_path.sequence - 1 = flight.progress and flight.support_airline = airplane.airlineID and flight.support_tail = airplane.tail_num
group by departure;

-- [21] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
    airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
    num_passengers, joint_pilots_passengers, person_list) as
select departure, arrival, count(distinct flightID), group_concat(distinct airplane.locationID separator ', '), group_concat(distinct flightID separator ', '),
min(next_time), max(next_time), count((select personID from pilot where person.personID = pilot.personID)),
count((select personID from passenger where person.personID = passenger.personID)),
count(person.personID), group_concat(person.personID separator ', ')
from leg, flight, route_path, airplane, person where route_path.routeID = flight.routeID and route_path.legID = leg.legID and flight.airplane_status = 'in_flight'
and route_path.sequence = flight.progress and flight.support_airline = airplane.airlineID and flight.support_tail = airplane.tail_num
and person.locationID = airplane.locationID
group by departure, arrival;

-- [22] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select airportID, airport.locationID, airport_name, city, state,
count(distinct (select personID from pilot where person.personID = pilot.personID)) as picount,
count(distinct (select personID from passenger where passenger.personID = person.personID)) as pacount,
count(distinct (personID)),
group_concat(distinct personID separator ', ')
from flight, person, airplane, airport where 
flight.support_airline = airplane.airlineID and 
flight.support_tail = airplane.tail_num and
person.locationID = airport.locationID and
flight.airplane_status = 'On_Ground'
group by airportID
order by airportID;

-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
    num_flights, flight_list, airport_sequence) as
select r.routeID, count(distinct r.legID), group_concat(distinct r.legID order by r.sequence asc separator ','), d,
count(distinct flightID), group_concat(distinct flightID separator ','), g
from route_path as r left join flight on flight.routeID = r.routeID left join
(select o.routeID, sum(distance) as d, group_concat(concat(departure,'->',arrival) order by o.sequence separator ',') as g
from route_path as o left join leg as e on e.legID = o.legID group by o.routeID) as t on t.routeID = r.routeID group by r.routeID;

-- [24] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, num_airports,
    airport_code_list, airport_name_list) as
select city, state, count(airportID), group_concat(airportID order by airportID asc separator ','), 
group_concat(airport_name order by airportID asc separator ',') from airport group by city, state having count(airportID) > 1;

-- [25] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin
    set @selection = (select flightID from flight where support_airline is not null order by next_time asc, airplane_status asc, flightID asc limit 1);
    set @astatus = (select airplane_status from flight where flightID = @selection);
    if @astatus = 'in_flight' then
        call flight_landing(@selection);
        call passengers_disembark(@selection);
        leave sp_main;
    end if;
    set @seqlen = (select max(sequence) from route_path where routeID = (select routeID from flight where flightID = @selection));
    set @currprog = (select progress from flight where flightID = @selection);
    if @currprog = @seqlen then
        call recycle_crew(@selection);
        call retire_flight(@selection);
        leave sp_main;
    end if;
    call passengers_board(@selection);
    call flight_takeoff(@selection);
end //
delimiter ;