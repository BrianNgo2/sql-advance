-- Task 1. Thực hiện lại 2 bài Lab trong Slide:  

 

/* Ex1:  

Using AdventureWorksDW2020, table DimEmployee 

Query all Hierarchical Level for the employee whose EmployeeKey = 4 

*/  

-- Your code here 

WITH Employee_hierarchy  

AS ( 

SELECT  

EmployeeKey, 

FirstName As Employee_Name, 

ParentEmployeeKey 

FROM DimEmployee  

WHERE EmployeeKey = 4 

UNION ALL  

SELECT  

DE.EmployeeKey, 

DE.FirstName , 

DE.ParentEmployeeKey 

FROM DimEmployee DE   

JOIN Employee_hierarchy EH 

On DE.EmployeeKey = EH.ParentEmployeeKey 

) 

SELECT  

EH.EmployeeKey, 

EH.Employee_Name, 

EH.ParentEmployeeKey, 

MN.Manager_Name 

FROM Employee_hierarchy EH 

LEFT JOIN ( 

Select  

EmployeeKey As ParentEmployeeKey, 

FirstName As Manager_Name 

FROM DimEmployee  

) AS MN 

On MN.ParentEmployeeKey=EH.ParentEmployeeKey  

 

--- Bài chữa có dùng declare  

Declare @empkey as int  

Set @empkey = 4 ; 

  

  

WITH Employee_hierarchy  

AS ( 

SELECT  

EmployeeKey, 

FirstName As Employee_Name, 

ParentEmployeeKey 

FROM DimEmployee  

WHERE EmployeeKey = @empkey 

UNION ALL  

SELECT  

DE.EmployeeKey, 

DE.FirstName , 

DE.ParentEmployeeKey 

FROM DimEmployee DE   

JOIN Employee_hierarchy EH 

On DE.EmployeeKey = EH.ParentEmployeeKey 

) 

SELECT  

EH.EmployeeKey, 

EH.Employee_Name, 

EH.ParentEmployeeKey, 

MN.Employee_Name As mn 

FROM Employee_hierarchy EH 

LEFT JOIN  Employee_hierarchy MN 

/*(Select  

EmployeeKey As ParentEmployeeKey,  --- Self join với bảng trên luôn, không cần tạo                                                                                 mới 

FirstName As Manager_Name 

FROM DimEmployee ) AS MN */ 

On MN.ParentEmployeeKey=EH.ParentEmployeeKey  

 

 

/*Ex2: Rewrite Ex5 in Assignment 1 applied Window function */  

-- Your code here 

SELECT  

DISTINCT(FIS.ProductKey), 

DP.EnglishProductName, 

FIS.SalesAmount, 

DST.SalesTerritoryCountry, 

SUM(SalesAmount) Over (Partition by SalesTerritoryCountry) AS Revenue_Country, 

SUM(SalesAmount) Over (Partition by SalesTerritoryCountry,FIS.ProductKey) AS Revenue_Country_Product, 

FORMAT((SUM(SalesAmount) Over (Partition by SalesTerritoryCountry,FIS.ProductKey)/SUM(SalesAmount) Over (Partition by SalesTerritoryCountry)),'P') AS '%_Rev' 

FROM FactInternetSales FIS 

LEFT JOIN DimProduct DP ON FIS.ProductKey= DP.ProductKey 

LEFT JOIN DimSalesTerritory DST ON FIS.SalesTerritoryKey=DST.SalesTerritoryKey 

 

--- Cach tot nhat: 

  

WITH Rev AS ( 

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

) 

SELECT  

ProductKey 

, EnglishProductName 

,Revenue 

,SalesTerritoryCountry 

, SUM(Revenue) Over ( Partition by SalesTerritoryCountry ) AS Rev_country 

,FORMAT(Revenue/SUM(Revenue) Over ( Partition by SalesTerritoryCountry),'P' ) AS PerRev 

FROM Rev 

 

 

 

 

-- Task 2: Thực hiện các bài toán bên dưới 

/* Ex3:  

Sử dụng bộ AdventureWorksDW2020, bảng FactInternetSales 

Tính toán báo cáo doanh thu tháng cho phòng Kinh doanh gồm các chỉ số sau  

- Tổng doanh thu (sử dụng cột SalesAmount) từng tháng đặt tên là TotalRev 

- Tổng doanh thu cộng dồn từng tháng trong năm đặt tên là RunningTotalRev 

- Tổng doanh thu tháng liền trước as TotalRevLastMonth  

- Tăng trưởng % so với tổng doanh thu tháng liền trước  

 */  

-- Your code here 

 

--- Tao 1 bảng thời gian chứa tháng năm và tháng năm trước đấy 1 tháng 

WITH Time_table  

AS( 

SELECT  

DISTINCT(MONTH(DATETRUNC(month,OrderDate))) as Monthdate 

,YEAR(DATETRUNC(month,OrderDate)) Yeardate 

,MONTH(DATEADD(MONTH,-1,DATETRUNC(month,OrderDate))) as PreviousMonth_Month 

,YEAR(DATEADD(MONTH,-1,DATETRUNC(month,OrderDate))) as PreviousMonth_Year 

FROM FactInternetSales 

) 

, Rev_month  --- Tạo bảng tạm tính revenue theo từng tháng 

AS ( 

SELECT  

DISTINCT(Month(OrderDate)) AS Monthdate 

,Year(OrderDate) AS Yeardate 

,SUM(SalesAmount) OVER (Partition by Month(orderdate),Year(orderdate)) AS TotalRev 

,SUM(SalesAmount) OVER (Partition by Year(orderdate) ORDER BY Month(orderdate)) AS RunningTotalRev 

FROM FactInternetSales 

) 

SELECT  

T.Monthdate 

,T.Yeardate 

,R.TotalRev 

,R.RunningTotalRev 

,T.PreviousMonth_Month 

,T.PreviousMonth_Year 

,PR.TotalRev AS TotalRevLastMonth 

,FORMAT((R.TotalRev/PR.TotalRev)-1,'P') As Growth_Month 

FROM Time_table T 

LEFT JOIN Rev_month R ON T.Monthdate=R.Monthdate AND T.Yeardate=R.Yeardate 

LEFT JOIN Rev_month PR  

ON T.PreviousMonth_Month=PR.Monthdate AND PR.Yeardate=T.PreviousMonth_Year 

--- Join bảng thời gian với bảng doanh thu theo tháng tương ứng 

ORDER BY T.Yeardate,T. Monthdate 

 

 

-- Dung LAG windowfunc tion 

WITH Rev AS( 

SELECT  

DISTINCT(Month(OrderDate)) AS Month_REV 

,Year(OrderDate) AS Year_Rev 

,SUM(SalesAmount) OVER (Partition by Month(orderdate),Year(orderdate)) AS TotalRev 

FROM FactInternetSales 

) 

SELECT 

Month_REV 

,Year_Rev 

,TotalRev 

,LAG(TotalRev) OVER ( ORDER by Year_REV,Month_REV) AS PrevTotalRev 

FROM Rev 

 

 

 

/* Ex4:  

Sử dụng bộ AdventureWorksDW2020, bảng FactInternetSales 

Tính toán báo cáo tháng tổng hợp lượng khách hàng cho phòng ban Marketing gồm các chỉ số sau: 

- Tổng số lượng Khách hàng có mua hàng từng tháng đặt tên là NumberofActiveCustomer 

- Tổng số lượng Khách hàng mới mua lần đầu trong tháng đó đặt tên là NumberofNewCustomer  

- Tổng số lượng Khách hàng quay lại trong tháng đó đặt tên là NumberofReturnCustomer 

*/  

-- Your code here 

 

--- tao bang number active customer 

WITH act_cus  

as ( 

SELECT  

MONTH(Orderdate) As month_order 

,Year(OrderDate) As year_order 

,Count(DISTINCT CustomerKey) As NumberofActiveCustomer  

FROM FactInternetSales 

GROUP BY MONTH(Orderdate),Year(OrderDate) 

) 

--- bang so lan mua cua tung khach hang trong 1 thang, va lay ra khach hang mua 1 lan 1 thang 

,Buy_times 

 AS ( 

SELECT 

YEAR(OrderDate) AS year_order 

,MONTH(OrderDate) AS month_order 

,CustomerKey 

,COUNT(Customerkey) as Buy_times 

FROM FactInternetSales 

Group by CustomerKey,YEAR(OrderDate),MONTH(OrderDate) 

Having COUNT(Customerkey) = 1 

) 

,New_cus  --- Tao bang new customer 

AS ( 

SELECT  

year_order 

,month_order  

, COUNT( CustomerKey) AS NumberofNewCustomer 

FROM Buy_times  as BT 

Group by year_order, month_order 

) 

SELECT  

AC.month_order 

,AC.year_order 

,AC.NumberofActiveCustomer 

,NC.NumberofNewCustomer 

,AC.NumberofActiveCustomer-NC.NumberofNewCustomer AS NumberofReturnCustomer 

FROM New_cus NC 

LEFT JOIN act_cus AC  

ON NC.month_order=AC.month_order AND NC.year_order=AC.year_order  

Order by AC.year_order,AC.month_order 

--- Khach hang quay lai = khach hang active – khach hang moi 

 

 

--- Bai chua 


  

--- Tim ra ngay mua dau -> xep theo thang nam 

  

WITH Cus_order AS ( 

SELECT  

CustomerKey 

,OrderDate 

,MIN(OrderDate) Over (Partition by CustomerKey) As FirstPurchase 

FROM FactInternetSales 

GROUP BY CustomerKey,OrderDate 

), New_cus_flag AS ( 

SELECT  

CustomerKey 

, YEAR(OrderDate) AS Year_order 

,MONTH(OrderDate) AS Month_order 

,FirstPurchase 

, CASE  

WHEN OrderDate = FirstPurchase THEN 1 

ELSE 0 

END AS flag_new_cus 

FROM Cus_order 

), New_cus AS ( 

SELECT  

Year_order 

,Month_order 

,COUNT(flag_new_cus) AS New_cus 

FROM New_cus_flag 

WHERE flag_new_cus= 1 

Group by Year_order,Month_order 

), Act_cus as ( 

SELECT  

MONTH(OrderDate) As Month_order 

,YEAR(orderdate) AS year_order 

, COUNT( DISTINCT CustomerKey) AS Act_cus 

FROM FactInternetSales 

GROUP BY YEAR(orderdate),MONTH(OrderDate) 

) 

SELECT  

AC.year_order 

,AC.Month_order 

,Ac.Act_cus 

,NC.New_cus 

,AC.Act_cus-NC.New_cus AS Re_Cus 

FROM Act_cus AC 

LEFT JOIN New_cus NC ON AC.Month_order=NC.Month_order 

 AND AC.year_order= NC.Year_order 

ORDER BY AC.year_order,AC.Month_order 

 

 

/*Ex5:  

Sử dụng bộ AdventureWorksDW2020, bảng FactResellerSales, DimEmployee  

Tính toán báo cáo cho phòng Nhân sự cho ra top 5 nhân viên có doanh thu cao nhất trong hệ thống từng tháng 

Hiển thị EmployeeKey, EmployeeFullName (combine FirstName, MiddleName, LastName), tổng doanh thu tháng của họ  kèm ParentEmployeeKey đặt tên là ManagerKey và ManagerFullName  

*/  

-- Your code here 

 

---Cách 1 : Tìm 5 nhân viên trước rồi ghép thông tin sau: 

WITH Top_emp ---Bảng tạm chứa 5 nhân viên suất sắc 

AS( 

SELECT TOP 5 

EmployeeKey AS EK 

,SUM(SalesAmount) As SalesRevenue  

FROM FactResellerSales 

GROUP BY EmployeeKey 

ORDER BY SalesRevenue 

) 

,Emp_Key ---Bảng chứa thông tin nhân viên 

AS( 

SELECT 

DE.EmployeeKey 

,CONCAT_WS(' ',DE.FirstName, DE.LastName,DE.MiddleName) As EmployeeFullName 

,DE.ParentEmployeeKey 

,CONCAT_WS(' ',DPE.FirstName, DPE.LastName,DPE.MiddleName) As ManagerFullName 

FROM DimEmployee DE 

LEFT JOIN DimEmployee DPE On DE.ParentEmployeeKey=DPE.EmployeeKey 

) 

SELECT  

EK.EmployeeKey 

,EK.EmployeeFullName 

,EK.ParentEmployeeKey 

,EK.ManagerFullName 

,TE.SalesRevenue 

FROM Emp_Key EK  

RIGHT JOIN Top_emp TE 

On TE.EK=EK.EmployeeKey 

---Gộp bảng theo thông tin Employeekey 

 

---Cách 2: Tìm 5 nhân viên sau, ghép thông tin trước 

WITH Emp_Key ---Bảng chứa thông tin nhân viên 

AS( 

SELECT 

DE.EmployeeKey 

,CONCAT_WS(' ',DE.FirstName, DE.LastName,DE.MiddleName) As EmployeeFullName 

,DE.ParentEmployeeKey 

,CONCAT_WS(' ',DPE.FirstName, DPE.LastName,DPE.MiddleName) As ManagerFullName 

FROM DimEmployee DE 

LEFT JOIN DimEmployee DPE On DE.ParentEmployeeKey=DPE.EmployeeKey 

) 

SELECT TOP 5 

EK.EmployeeKey 

,EK.EmployeeFullName 

,EK.ParentEmployeeKey 

,EK.ManagerFullName 

,SUM(SalesAmount) AS SalesRevenue 

FROM FactResellerSales FRS  

JOIN Emp_Key EK  

ON FRS.EmployeeKey=EK.EmployeeKey 

GROUP BY 

EK.EmployeeKey 

,EK.EmployeeFullName 

,EK.ParentEmployeeKey 

,EK.ManagerFullName 

ORDER BY SalesRevenue 

 

--- Cho em hỏi cách nào phù hợp hơn ạ