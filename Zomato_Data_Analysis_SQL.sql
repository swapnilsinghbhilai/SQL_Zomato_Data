SELECT * FROM goldusers_signup;
SELECT * FROM product;
SELECT * FROM sales;
SELECT * FROM users;


1.  What is the total amount each customer spent on Zomato?

Select s.userid , sum(p.price) As Total_Amount
From sales As s
Join product As p
On s.product_id = p.product_id
Group by userid
Order by userid;

2. How many days has each customer visited on Zomato?

Select userid , Count(Distinct created_date) As Total_Visit
From sales As s
Group by userid
Order by userid;

3. What was the first product purchased by each customer?

-------->
Select * 
From (Select * , Rank() Over(Partition by userid Order by created_date) As Rank
From sales As s)
Where Rank = 1;
-------->
SELECT DISTINCT ON (userid) *
FROM sales
ORDER BY userid, created_date;

4. What is the most purchased item in the menu and how many time was it purchased by all customers?

Select userid , count(product_id)
From sales 
Where product_id = (Select product_id From sales Group by product_id Order by count(product_id) DESC
Limit 1)
Group by userid;

5. Which item was the most popular for each customer?

SELECT * FROM
(SELECT * , RANK() OVER(PARTITION BY userid ORDER BY cnt DESC) rnk FROM
(SELECT userid , product_id , COUNT(product_id) AS cnt FROM sales GROUP BY userid , product_id))
WHERE rnk = 1

6. Which item was purchased first after they became gold member?

Select b.*
From (Select a.* , Rank() Over(Partition by userid order by created_date ASC)
From (Select s.userid As userid, s.created_date As created_date , s.product_id As product_id , g.gold_signup_date As gold_signup_date
From sales As s Join goldusers_signup As g On s.userid = g.userid Where s.created_date >= g.gold_signup_date) As a) As b Where rank = 1

7. Which item was purchased Just before they became gold member?

Select b.*
From (Select a.* , Rank() Over(Partition by userid order by created_date DESC)
From (Select s.userid As userid, s.created_date As created_date , s.product_id As product_id , g.gold_signup_date As gold_signup_date
From sales As s Join goldusers_signup As g On s.userid = g.userid Where s.created_date <= g.gold_signup_date) As a) As b Where rank = 1

8. What is the total order and total amount spent by each customers just before they become gold member?

Select s.userid , Count(s.created_date) As Total_Order , Sum(p.price) As Total_Amount
From sales As s
Join goldusers_signup As g
On s.userid = g.userid
Join product As p
On s.product_id = p.product_id
Where s.created_date <= g.gold_signup_date
Group by s.userid
Order by s.userid Asc

9. If buying each product generates points for example 5 Rs = 2 Zomato Points 
and each product has different purchasing points For example For p1  5 Rs = 1 Zomato Points 
, For p2  10 Rs = 5 Zomato Points and For p3  5 Rs = 1 Zomato Points.

Calculate points collected by each customers and for which product most points have been given till now?

-- Part 1 of the question asked points collected by each customers

SELECT a.userid , SUM(ROUND(amount/points,0))*2.5 AS Total_Money_Earned FROM
(
SELECT s.userid , s.product_id , sum(p.price) as amount ,
CASE
WHEN s.product_id = 1 THEN 5
WHEN s.product_id = 2 THEN 2
WHEN s.product_id = 3 THEN 5
ELSE 0
END as points
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY s.userid , s.product_id
ORDER BY s.userid , s.product_id) AS a
GROUP By a.userid

-- Part 2 of the question asked for product most points have been given till now

SELECT a.product_id , SUM(ROUND(amount/points,0)) AS Total_Points_Earned FROM
(
SELECT s.userid , s.product_id , sum(p.price) as amount ,
CASE
WHEN s.product_id = 1 THEN 5
WHEN s.product_id = 2 THEN 2
WHEN s.product_id = 3 THEN 5
ELSE 0
END as points
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY s.userid , s.product_id
ORDER BY s.userid , s.product_id) AS a
GROUP BY a.product_id
ORDER BY Total_Points_Earned DESC
LIMIT 1

10. In a first one year after a customer joins the gold membership (including their join date) 
irrespective of what the customer has purchased they earn 5 zomato points for every 10 RS spent who earned 
more 1 or 3 and what was their earnings in their first year?  
1 Zomato Points  =  Rs 2  or 0.5 Zomato Points = Rs 1

SELECT s.userid , s.product_id , s.created_date , g.gold_signup_date , p.price*0.5 AS Points_Earned
FROM sales AS s JOIN goldusers_signup AS g ON s.userid = g.userid
AND s.created_date >= g.gold_signup_date AND s.created_date <= g.gold_signup_date + 365
JOIN product AS p ON s.product_id = p.product_id
ORDER BY Points_Earned DESC
LIMIT 1

11. Rank all transactions of the customers?

SELECT * , RANK() OVER(PARTITION BY userid ORDER BY created_date)
FROM sales