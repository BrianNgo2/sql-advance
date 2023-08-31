Use AdventureWorksFull
-- Task 1. Thực hiện lại 2 bài toán trong Slide Lab buổi 1 gồm:  

---Tính tăng trưởng phần % so với cùng kỳ năm ngoái và tìm danh sách Returning Active Customer  

/* Ex1: % Growth YoY  

Using Database AdventureWorksFull, table Sales.SalesOrderHeader  

Write a query that'll calculate: 

Total Revenue of each Month (from SubTotal column) 

% Growth of Total Revenue compared with same Month last year (YoY)  

*/  

-- Your code here 

---Bai 1 

With  

table1 as ( 

Select  

Month(OrderDate) as Month, 

Year(orderdate) as Year, 

Sum(SubTotal) as Revenue 

From Sales.SalesOrderHeader 

Group by Month(OrderDate),Year(orderdate) 

) 

select  

t1.Year, 

t1.Month, 

Format(t1.revenue,'N') as 'renvenue', 

Format(t2.revenue,'N') as 'revenue LP', 

Format(t1.revenue/t2.revenue-1,'P') as '% LY same period' 

from table1 as t1 

left join table1 as t2 

on t1.year-1=t2.year and t1.month=t2.month 

order by t1.year desc, t1.month desc 

 

 

 

/* Ex2. Find returning active customer 

Using Database AdventureWorksFull, table Sales.SalesOrderHeader  

Write a query that'll identify returning active users.  

A returning active user is a user that has made a second purchase within 7 days of any other of their purchases.  

Output a list of CustomerID of these returning active users. 

*/  

-- Your code here 

--- Bai 2 

WITH  

Bai2a AS ( 

SELECT  

CustomerID, 

OrderDate 

FROM Sales.SalesOrderHeader 

), 

Bai2b AS ( 

SELECT  

T1.CustomerID 

FROM Bai2a AS T1 

LEFT JOIN Bai2a AS T2 

On T1.CustomerID=T2.CustomerID AND T1.OrderDate <> T2.OrderDate 

WHERE T2.Orderdate > T1.Orderdate  

AND DATEDIFF(Day,T1.OrderDate,T2.OrderDate) <= 7 

) 

Select  

CustomerID, 

COUNT(CustomerID) AS 'Order times' 

From Bai2b 

GROUP BY CustomerID 

ORDER BY [Order times] DESC 

 

 

 

-- Task 2. Thực hiện các bài toán bên dưới 

 

/* Ex3. Sử dụng Database AdventureWorksFull, bảng Sales.SalesOrderHeder 

Xác định danh sách các Khách hàng mua hàng từ 2 đơn trở lên.  

Kết quả trả về gồm các thông tin sau:  

CustomerID 

NumberofOrders */ 

 

--Your code here 

 

Select  

CustomerID, 

COUNT(CustomerID) AS 'Order times' 

From Sales.SalesOrderHeader 

GROUP BY CustomerID 

HAVING COUNT(CustomerID) >= 2 

ORDER BY [Order times] DESC 

 

/* Ex4. Từ bảng DimProduct, DimSalesTerritory và FactInternetSales, 

Sử du Database AdventureWorksDW2020, ừ bảng DimProduct, DimSalesTerritory và FactInternetSales, 

tính tổng doanh thu (đặt tên là InternetTotalSales) 

của từng sản phẩm theo mỗi  quốc gia từ bảng DimSalesTerritory. Kết quả trả về gồm có các thông tin sau: 

SalesTerritoryCountry 

ProductKey 

EnglishProductName 

InternetTotalSales 

 */  

--Your code here 

USE AdventureWorksDW2020 

---Cach 1 

SELECT 

Bai4.ProductKey, 

Bai4.EnglishProductName, 

SUM(Bai4.SalesAmount) AS Revenue, 

Bai4.SalesTerritoryCountry 

FROM ( 

SELECT  

FIS.ProductKey, 

DP.EnglishProductName, 

FIS.SalesAmount, 

DST.SalesTerritoryCountry 

FROM FactInternetSales FIS 

LEFT JOIN DimProduct DP ON FIS.ProductKey= DP.ProductKey 

LEFT JOIN DimSalesTerritory DST ON FIS.SalesTerritoryKey=DST.SalesTerritoryKey 

) AS Bai4 

GROUP BY Bai4.ProductKey,Bai4.SalesTerritoryCountry,Bai4.EnglishProductName 

---Cach 2  

SELECT  

Rev.ProductKey, 

DP.EnglishProductName, 

DST.SalesTerritoryCountry, 

Revenue 

FROM ( 

SELECT 

ProductKey, 

SalesTerritoryKey, 

SUM(SalesAmount) AS Revenue 

FROM FactInternetSales 

GROUP BY ProductKey, SalesTerritoryKey 

) AS Rev 

LEFT JOIN DimProduct AS DP ON DP.ProductKey=Rev.Productkey 

LEFT JOIN DimSalesTerritory AS DST ON DST.SalesTerritoryKey=Rev.SalesTerritoryKey 

--- Thay co cho em hoi cach nao toi uu hon a ? 

/* Ex5. Phát triển từ Ex4, tính tỷ trọng % tỷ trọng doanh thu của từng sản phẩm (đặt tên là PercentofTotaInCountry) 

trong Tổng doanh thu của mỗi quốc gia tương ứng 

Kết quả trả về gồm có các thông tin sau: 

SalesTerritoryCountry 

ProductKey 

EnglishProductName 

InternetTotalSales 

PercentofTotaInCountry (định dạng %) 

*/ 

--Your code here 

WITH RevCountry AS ( 

SELECT 

SalesTerritoryKey, 

SUM(SalesAmount) AS Revenue 

FROM FactInternetSales 

GROUP BY  SalesTerritoryKey 

), 

RevProduct AS ( 

SELECT 

ProductKey, 

SalesTerritoryKey, 

SUM(SalesAmount) AS Revenue 

FROM FactInternetSales 

GROUP BY ProductKey, SalesTerritoryKey 

), 

PercentRev AS ( 

SELECT  

RP.ProductKey, 

RP.SalesTerritoryKey, 

RP.Revenue AS RevenuePerProduct, 

RC.Revenue AS RevenueCountry, 

FORMAT(RP.Revenue/RC.Revenue,'P') AS '% Revenue' 

FROM RevProduct RP 

LEFT JOIN RevCountry RC ON  RP.SalesTerritoryKey=RC.SalesTerritoryKey 

) 

SELECT  

DST.SalesTerritoryCountry AS Country, 

PR.ProductKey, 

DP.EnglishProductName AS ProductName , 

PR.RevenuePerProduct, 

PR.RevenueCountry, 

[% Revenue] 

FROM PercentRev PR 

LEFT JOIN DimProduct DP ON PR.ProductKey=DP.ProductKey 

LEFT JOIN DimSalesTerritory DST ON DST.SalesTerritoryKey=PR.SalesTerritoryKey 

ORDER BY Country,ProductKey 