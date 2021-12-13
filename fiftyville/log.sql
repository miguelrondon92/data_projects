-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Count the number of suspects in total
SELECT COUNT(name) FROM people; --200

-- Select all from crime_scene_reports from 7, 28, 2020, in Chamberlin Street
SELECT * FROM crime_scene_reports WHERE month = 7 AND day = 28 AND year = 2020 AND street = "Chamberlin Street";
-- Results:
    -- id | year | month | day | street | description
    -- 295 | 2020 | 7 | 28 | Chamberlin Street |
    --Theft of the CS50 duck took place at 10:15am at the Chamberlin Street courthouse.
    --Interviews were conducted today with three witnesses who were present at the time —
    --each of their interview transcripts mentions the courthouse.

-- examine interviews from witnesses
SELECT * FROM interviews WHERE month = 7 AND day = 28 AND year = 2020 AND transcript LIKE "%courthouse%";
--Result:
    --id | name | year | month | day | transcript
    --161 | Ruth | 2020 | 7 | 28 | Sometime within ten minutes of the theft, I saw the thief get into a car in the courthouse parking lot and drive away.
        --If you have security footage from the courthouse parking lot, you might want to look for cars that left the parking lot in that time frame.
    --162 | Eugene | 2020 | 7 | 28 | I don't know the thief's name, but it was someone I recognized. Earlier this morning,
        --before I arrived at the courthouse, I was walking by the ATM on Fifer Street and saw the thief there withdrawing some money.
    --163 | Raymond | 2020 | 7 | 28 | As the thief was leaving the courthouse, they called someone who talked to them for less than a minute.
        --In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow.
        --The thief then asked the person on the other end of the phone to purchase the flight ticket.

-- view courthouse camera - thief got into a car and exited
SELECT * FROM courthouse_security_logs WHERE month = 7 AND day = 28 AND year = 2020 AND hour = 10 AND minute BETWEEN 15 AND 25;
--RESULTS:
    --id | year | month | day | hour | minute | activity | license_plate
    --260 | 2020 | 7 | 28 | 10 | 16 | exit | 5P2BI95
    --261 | 2020 | 7 | 28 | 10 | 18 | exit | 94KL13X
    --262 | 2020 | 7 | 28 | 10 | 18 | exit | 6P58WS2
    --263 | 2020 | 7 | 28 | 10 | 19 | exit | 4328GD8
    --264 | 2020 | 7 | 28 | 10 | 20 | exit | G412CB7
    --265 | 2020 | 7 | 28 | 10 | 21 | exit | L93JTIZ
    --266 | 2020 | 7 | 28 | 10 | 23 | exit | 322W7JE
    --267 | 2020 | 7 | 28 | 10 | 23 | exit | 0NTHK55


-- Eugene did not enter the courthouse that morning via a car... suspicious... but then again... maybe he walked.
SELECT * FROM courthouse_security_logs WHERE license_plate = (SELECT license_plate FROM people WHERE name = "Eugene");
--id | year | month | day | hour | minute | activity | license_plate
--101 | 2020 | 7 | 26 | 13 | 22 | entrance | 47592FJ
--135 | 2020 | 7 | 26 | 17 | 27 | exit | 47592FJ
--356 | 2020 | 7 | 30 | 8 | 53 | entrance | 47592FJ
--419 | 2020 | 7 | 30 | 15 | 45 | exit | 47592FJ


--Let's Check the ATM!
SELECT * FROM atm_transactions WHERE month = 7 AND day = 28 AND year = 2020 AND atm_location = "Fifer Street" AND transaction_type = "withdraw";
--Results:
    --246 | 28500762 | 2020 | 7 | 28 | Fifer Street | withdraw | 48
    --264 | 28296815 | 2020 | 7 | 28 | Fifer Street | withdraw | 20
    --266 | 76054385 | 2020 | 7 | 28 | Fifer Street | withdraw | 60
    --267 | 49610011 | 2020 | 7 | 28 | Fifer Street | withdraw | 50
    --269 | 16153065 | 2020 | 7 | 28 | Fifer Street | withdraw | 80
    --288 | 25506511 | 2020 | 7 | 28 | Fifer Street | withdraw | 20
    --313 | 81061156 | 2020 | 7 | 28 | Fifer Street | withdraw | 30
    --336 | 26013199 | 2020 | 7 | 28 | Fifer Street | withdraw | 35

-- Let's check the names of those who utilitized the ATM - while we're at it... let's check their license plates...
SELECT name, license_plate FROM people WHERE id IN (SELECT person_id FROM bank_accounts where account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND year = 2020 AND atm_location = "Fifer Street" AND transaction_type = "withdraw"));
--Results:
    --name | license_plate
    --Bobby | 30G67EN
    --Elizabeth | L93JTIZ
    --Victoria | 8X428L0
    --Madison | 1106N58
    --Roy | QX4YZN3
    --Danielle | 4328GD8
    --Russell | 322W7JE
    --Ernest | 94KL13X

-- let's cross reference those who used the ATM AND who's vehicles left the court house that day....MUST JOIN!
-- Returns name of license plate from people who exited courthouse.
SELECT name FROM people JOIN bank_accounts ON people.id = bank_accounts.person_id WHERE license_plate IN (SELECT license_plate FROM courthouse_security_logs WHERE month = 7 AND day = 28 AND year = 2020 AND hour = 10 AND minute BETWEEN 15 AND 25);
--Results
    --name
    --Ernest
    --Russell
    --Elizabeth
    --Danielle
    --Amber

-- Returns person_id of people who had atm transaction.
SELECT name from people JOIN bank_accounts ON people.id = bank_accounts.person_id WHERE account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND year = 2020 AND atm_location = "Fifer Street" AND transaction_type = "withdraw");
--Results:
    --name
    --Ernest
    --Russell
    --Roy
    --Bobby
    --Elizabeth
    --Danielle
    --Madison
    --Victoria

-- Now to cross reference the two lists of people...
SELECT name FROM people JOIN bank_accounts ON people.id = bank_accounts.person_id WHERE license_plate IN
(SELECT license_plate FROM courthouse_security_logs WHERE month = 7 AND day = 28 AND year = 2020 AND hour = 10 AND minute BETWEEN 15 AND 25)
AND account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND year = 2020 AND atm_location = "Fifer Street"
AND transaction_type = "withdraw");
--Result:
    --name
    --Ernest
    --Russell
    --Elizabeth
    --Danielle

-- RECALL: As the thief was leaving the courthouse, they called someone who talked to them for less than a minute.
        --In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow.
        --The thief then asked the person on the other end of the phone to purchase the flight ticket.

-- identfy the caller and receiver of calls during the time in question...
-- I need side

--Code that gets me the phone numbers of callers and receivers... but I only see numbers, not names....
SELECT id, caller, receiver FROM phone_calls WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60 ORDER BY id;
-- id | caller | receiver
-- 221 | (130) 555-0289 | (996) 555-8899
-- 224 | (499) 555-9472 | (892) 555-8872
-- 233 | (367) 555-5533 | (375) 555-8161
-- 251 | (499) 555-9472 | (717) 555-1342
-- 254 | (286) 555-6063 | (676) 555-6554
-- 255 | (770) 555-1861 | (725) 555-3243
-- 261 | (031) 555-6622 | (910) 555-3251
-- 279 | (826) 555-1652 | (066) 555-9701
-- 281 | (338) 555-6650 | (704) 555-2131

-- Try 1;
SELECT id, caller, receiver,
    (SELECT name FROM people AS caller_table WHERE caller_table.phone_number = caller) --AS caller_name,
    (SELECT name FROM people AS receiver_table WHERE receiver_table.phone_number = receiver) --AS receiver_name
FROM phone_calls
WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60 ORDER BY id);

-- Try 2; This gets me one step closer, the first name of both caller and receiver show up - but not the rest of the list.
SELECT
    (SELECT name FROM people WHERE phone_number IN
        (SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60 ORDER BY id)
    ) AS Caller,
    (SELECT name FROM people WHERE phone_number IN
        (SELECT receiver FROM phone_calls WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60 ORDER BY id)
        ) AS Receiver;

-- Mig try 3;
SELECT
    (SELECT name FROM people) AS Caller,
    (SELECT name FROM people) AS Receiver
FROM people
WHERE
phone_number IN
(SELECT caller, receiver FROM phone_calls WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60 ORDER BY id);

-- Mig Try 4;
SELECT caller.name AS caller, receiver.name AS receiver
FROM people caller, people receiver
WHERE caller.phone_number IN
(SELECT caller, receiver FROM phone_calls WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60);



-- I gave up on making it look pretty...

--

-- name of callers
SELECT id, name AS caller FROM people WHERE phone_number IN
(SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60 ORDER BY id)
--395717 | Bobby
--398010 | Roger
--438727 | Victoria
--449774 | Madison
--514354 | Russell
--560886 | Evelyn
--686048 | Ernest
--907148 | Kimberly


--name of receivers
SELECT id, name as receiver FROM people WHERE phone_number IN
(SELECT receiver FROM phone_calls WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60 ORDER BY id);
--250277 | James
--251693 | Larry
--484375 | Anna
--567218 | Jack
--626361 | Melissa
--712712 | Jacqueline
--847116 | Philip
--864400 | Berthold
--953679 | Doris



--Earliest flight out of fiftyville...
SELECT * FROM flights
WHERE origin_airport_id IN (SELECT id FROM airports WHERE full_name LIKE "%fiftyville%") AND year = 2020 AND month = 7 AND day = 29 ORDER BY hour, minute LIMIT 1;

-- Thief was on this flight:
-- id | origin_airport_id | destination_airport_id | year | month | day | hour | minute
-- 36 | 8 | 4 | 2020 | 7 | 29 | 8 | 20

--Next, let's find out what passengers
--were on the flight
--AND were placing a call on the date in question
--AND at the ATM at the date in quest
--AND Who's license plate was spotted leaving the courthouse

SELECT name
FROM people
WHERE passport_number IN
    (SELECT passport_number
    FROM passengers
    WHERE flight_id =
        (SELECT id
        FROM flights
        WHERE origin_airport_id IN
            (SELECT id FROM airports WHERE full_name LIKE "%fiftyville%")
        AND year = 2020 AND month = 7 AND day = 29 ORDER by hour, minute LIMIT 1)
    )
AND phone_number IN
    (SELECT caller
    FROM phone_calls
    WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60)
AND id IN
    (SELECT person_id
    FROM bank_accounts
    WHERE account_number IN
        (SELECT account_number
        FROM atm_transactions
        WHERE month = 7 AND day = 28 AND year = 2020 AND atm_location = "Fifer Street" AND transaction_type = "withdraw")
    )
AND license_plate IN
    (SELECT license_plate
    FROM courthouse_security_logs
    WHERE month = 7 AND day = 28 AND year = 2020 AND hour = 10 AND minute BETWEEN 15 AND 25);

-- ANSWER: ERNEST!

--What city did he go to?
SELECT city FROM airports 
WHERE id IN 
    (SELECT destination_airport_id 
    FROM flights 
    WHERE id IN
        (SELECT id
        FROM flights
        WHERE origin_airport_id IN
            (SELECT id FROM airports WHERE full_name LIKE "%fiftyville%")
        AND year = 2020 AND month = 7 AND day = 29 ORDER by hour, minute LIMIT 1)
    );
    
-- ANSWER: London 

-- Who's the accomplice? 
SELECT name 
FROM people 
WHERE phone_number IN
    (SELECT receiver FROM phone_calls WHERE caller IN
        (SELECT phone_number FROM people WHERE name IN 
            (SELECT name
            FROM people
            WHERE passport_number IN
                (SELECT passport_number
                FROM passengers
                WHERE flight_id =
                    (SELECT id
                    FROM flights
                    WHERE origin_airport_id IN
                        (SELECT id FROM airports WHERE full_name LIKE "%fiftyville%")
                    AND year = 2020 AND month = 7 AND day = 29 ORDER by hour, minute LIMIT 1)
                )
            AND phone_number IN
                (SELECT caller
                FROM phone_calls
                WHERE month = 7 AND day = 28 AND year = 2020 AND duration < 60)
            AND id IN
                (SELECT person_id
                FROM bank_accounts
                WHERE account_number IN
                    (SELECT account_number
                    FROM atm_transactions
                    WHERE month = 7 AND day = 28 AND year = 2020 AND atm_location = "Fifer Street" AND transaction_type = "withdraw")
                )
            AND license_plate IN
                (SELECT license_plate
                FROM courthouse_security_logs
                WHERE month = 7 AND day = 28 AND year = 2020 AND hour = 10 AND minute BETWEEN 15 AND 25)
            )
            AND month = 7 AND day = 28 AND year = 2020 AND duration < 60
        )
    );