/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT *
FROM Facilities
Where membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT Count(*)
FROM Facilities 
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities 
WHERE membercost < 0.2 * monthlymaintenance
AND membercost > 0;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM Facilities
WHERE facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE 
    When monthlymaintenance > 100 THEN 'expensive'
    ELSE 'cheap'
    END AS maintenancecost
From = Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname
FROM 'members'
WHERE joindate = (SELECT MAX(joindate) FROM `Members`);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT b.facid as Facility_ID, f.name as Facility, 
    b.memid as Member_ID, CONCAT(m.firstname, ' ', m.surname) AS Member 
FROM `Members` as m 
INNER JOIN `Bookings` as b
ON m.memid = b.memid 
INNER JOIN `Facilities` as f
on f.facid = b.facid 
WHERE b.facid IN (0, 1) AND b.memid != 0
ORDER BY Member;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT b.starttime, f.name, 
CASE WHEN b.memid != 0 THEN CONCAT(m.firstname, ' ', m.surname)
     ELSE m.firstname 
END AS name, 
CASE WHEN b.memid != 0 THEN b.slots * f.membercost
     ELSE b.slots * f.guestcost
END AS cost
FROM Bookings as b
inner join Members as m
on b.memid = m.memid
inner join Facilities as f
on f.facid = b.facid
WHERE CAST(starttime AS date) = CAST('2012-09-14' AS date) AND
CASE WHEN b.memid != 0 THEN b.slots * f.membercost
     ELSE b.slots * f.guestcost
END > 30
ORDER BY cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.starttime, sub.name, 
CASE WHEN sub.memid != 0 THEN CONCAT(sub.firstname, ' ', sub.surname)
     ELSE sub.firstname 
END AS name, 
CASE WHEN sub.memid != 0 THEN sub.slots * sub.membercost
     ELSE sub.slots * sub.guestcost
END AS cost
FROM (select b.starttime, b.facid, b.memid, b.slots, f.membercost, f.guestcost, f.name,
      m.firstname, m.surname
      from Bookings as b
      inner join Members as m
      on b.memid = m.memid
      inner join Facilities as f
      on f.facid = b.facid) as sub
WHERE CAST(starttime AS date) = CAST('2012-09-14' AS date) AND
CASE WHEN memid != 0 THEN slots * membercost
     ELSE slots * guestcost
END > 30
ORDER BY cost DESC;

/* PART 2: SQLite
Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
# GROUP BY FACILITY ID, COUNT GUEST AND MEMBER BY THE FACILITY,
# MULTIPLY MEMBER COST, GUEST COST AND ADD THEM
# FILTER LESS THEN 1000
SELECT sub.name, SUM( sub.revenue ) AS revenue
FROM (
SELECT b.facid, b.memid, f.name, f.guestcost, f.membercost, COUNT( b.facid ) AS facid_count,
CASE
WHEN b.memid =0
THEN COUNT( b.facid ) * f.guestcost
ELSE COUNT( b.facid ) * f.membercost
END AS 'revenue'
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
GROUP BY b.facid, b.memid
) AS sub
GROUP BY sub.facid
HAVING revenue <=1000;


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT m.surname, m.firstname, m.recommendedby AS recomender_id, r.surname AS recomender_surname, r.firstname AS recomender_firstname
FROM Members AS m
LEFT JOIN Members AS r ON m.recommendedby = r.memid
WHERE m.recommendedby != 0
ORDER BY r.surname, r.firstname;


/* Q12: Find the facilities with their usage by member, but not guests */
SELECT b.facid, COUNT( b.memid ) AS mem_usage, f.name
FROM (
SELECT facid, memid
FROM Bookings
WHERE memid !=0
) AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
GROUP BY b.facid;


/* Q13: Find the facilities usage by month, but not guests */
SELECT b.months, COUNT( b.memid ) AS mem_usage
FROM (
SELECT MONTH( starttime ) AS months, memid
FROM Bookings
WHERE memid !=0
) AS b
GROUP BY b.months;