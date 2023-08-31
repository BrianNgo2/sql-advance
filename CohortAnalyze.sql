/* Ex1. Using Database AdventureWorksDW2020, table dbo.FactInternetSales 

Write a query that'll query Rention Cohort Analysis based on First time Customer Purchase in the period of Jan 2020 to Jan 2021*/ 

 

Use AdventureWorksDW2020 

; 

  

WITH  

Orderlist AS ( 

SELECT  

CustomerKey 

, OrderDate 

FROM FactInternetSales 

), 

FPD AS ( 

Select  

CustomerKey 

,MIN(OrderDate) AS FirstPurchaseDate 

,FORMAT(MIN(OrderDate),'yyyy-MM') As FirstPurchaseMonth 

From Orderlist 

Group by CustomerKey 

), CHI AS ( 

SELECT  

DISTINCT OL.CustomerKey 

,FPD.FirstPurchaseMonth 

,DATEDIFF(MONTH,FirstPurchaseDate,OrderDate) AS CohortInd 

FROM Orderlist OL  

LEFT JOIN FPD FPD ON OL.CustomerKey=FPD.CustomerKey 

), 

CohortPivot AS ( 

SELECT  

* 

FROM CHI 

PIVOT ( 

COUNT (Customerkey) 

FOR CohortIND IN ( 

[0] 

,[1] 

,[2] 

,[3] 

,[4] 

,[5] 

,[6] 

,[7] 

,[8] 

,[9] 

,[10] 

,[11] 

,[12] 

) ) AS  PT 

) 

  

  

SELECT  

FirstPurchaseMonth 

, FORMAT([0]/[0],'p') AS '0' 

, FORMAT(1.0*[1]/[0],'p') AS '1' 

, FORMAT(1.0*[2]/[0],'p') AS '2' 

, FORMAT(1.0*[3]/[0],'p') AS '3' 

, FORMAT(1.0*[4]/[0],'p') AS '4' 

, FORMAT(1.0*[5]/[0],'p') AS '5' 

, FORMAT(1.0*[6]/[0],'p') AS '6' 

, FORMAT(1.0*[7]/[0],'p') AS '7' 

, FORMAT(1.0*[8]/[0],'p') AS '8' 

, FORMAT(1.0*[9]/[0],'p') AS '9' 

, FORMAT(1.0*[10]/[0],'p') AS '10' 

, FORMAT(1.0*[11]/[0],'p') AS '11' 

, FORMAT(1.0*[12]/[0],'p') AS '12' 

FROM CohortPivot 

Order by 1 DESC 

 

 

 

 

 

-- Task 2. Thực hiện bài toán bên dưới 

 

/* Ex2. Sử dụng Database AdventureWorksFull, bảng Sales.SalesOrderHeder 

Xác định các CustomerID của Khách hàng mua hàng từ 2 đơn vào 2 ngày liên tiếp 

 */ 

 

USE AdventureWorksFull

SELECT 

DISTINCT SOD.SalesOrderID 

  

FROM Sales.SalesOrderHeader SOD  

  

  

JOIN Sales.SalesOrderHeader SO ON SOD.CustomerID=SO.CustomerID 

  

WHERE  DATEDIFF(Day,SOD.OrderDate,SO.OrderDate) = 1 