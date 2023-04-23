-- FOR ALL THE TEST CASES, 0 ROWS SHOULD BE AFFECTED UNLESS SPECIFIED

-- ADD_AIRPLANE CASES

-- call add_airplane('Delta', 'n120jn', 10, 350, NULL, 'jet', NULL, NULL, 4);
-- call add_airplane('Delta', 'n1303jn', 10, 350, NULL, 'prop', NULL, 1, null);
-- Fails because 'Shresht' is not an airlineID
-- call add_airplane('Shresht', 'n129jn', 700, 350, null, 'jet', null, null, 4); 

-- check to make sure that typos dont work
-- call add_airplane('Delta', 'n1030jn', 700, 350, null, 'pr0p', null, null, 4); 

-- make sure tail is unique 
-- call add_airplane('Southwest', 'n1jn', 700, 350, null, 'jet', 1, null, 4); 

-- make sure seat capacity is not 0
-- call add_airplane('Southwest', 'n2jn', 0, 10, null, 'jet', null, null, 5);

-- make sure that speed is not 0 
-- call add_airplane('American', 'n3jn', 10, 0, null, 'pr0p', null, null, 1);

-- make sure locationID can be null, THIS SHOULD AFFECT A ROW
-- call add_airplane('American', 'n4jn', 10, 10, null, 'jet', null, null, 1);

-- make sure tailNum cant be null
-- call add_airplane('American', null, 10, 10, null, 'jet', null, null, 1);

-- ------------------------------------------ AIRPORT TEST CASES ------------------------------------------------------

-- a new airport must have a unique identifier
-- call add_airport('SJC', 'San Jose Mineta International Airport', 'San Jose', 'CA', null); -- this should work
-- call add_airport('SJC', 'Santa Jesus California', 'San Joese', 'CA', null);

-- must have a city 
-- call add_airport('ABC', 'Africa Bosnia Crunch', null, 'NE', null);

-- must have a state
-- call add_airport('CBA', 'rar', 'Omaha', null, null);

-- -------------------------------------- Person Test Cases --------------------------------------------------------------

-- needs a personID, and will be added to passenger since last value is not null
-- call add_person(null,'Sam','Jones','port_2', NULL, 4, 'American', 'n330ss', 20);

-- needs a locationID
-- call add_person('p100','Shresht','Yadav',null, NULL, 4, 'American', 'n330ss', 20);

-- needs to be also added to pilot if the taxID is not null (CHECK PILOT)
-- call add_person('p101','Sam','Jones','port_2', 'taxID', 4, 'American', 'n330ss', null);

-- needs to be in both passenger and pilor since taxID and last value are not null
-- call add_person('p103','Asta',null,'plane_1', 'notaxes', 4,'American', 'n330ss', 30);

-- ------------------------------------ Pilot License Cases ---------------------------------------------------------------

-- default test case
-- call grant_pilot_license('p1', 'prop');

-- switch the null values below and run them since neither can be null
-- call grant_pilot_license('p101', null);

-- ------------------------------------- Offer Flight Cases ------------------------------------------------------------------

-- default
-- call offer_flight('UN_3403', 'westbound_north_milk_run', 'American', 'n380sd', 0, 'on_ground', '15:30:00');

-- route must be valid
-- call offer_flight('UN_3400', null, 'American', 'n380sd', 0, 'on_ground', '15:30:00');



