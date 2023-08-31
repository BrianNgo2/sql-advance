-- Task 1: Thao tác lại các bài lab trên lớp 

/* Ex1:  

Using AdventureWorksDW2020, table FactInternetSales 

Calculate either TotalRevenue (using SalesAmount column) by EnglishProductName, EnglishProductSubcategoryName, EnglishCategoryName and Grand Revenue */ 

-- Your code here 

WITH Product 

AS ( 

Select  

ProductKey 

, SalesAmount 

From FactInternetSales 

), 

ProductName AS ( 

Select  

ProductKey 

, EnglishProductName 

, ProductSubcategoryKey 

From DimProduct 

), 

SubCat AS ( 

Select  

ProductCategoryKey 

,ProductSubcategoryKey 

,EnglishProductSubcategoryName 

From DimProductSubcategory 

), 

Cat AS ( 

Select  

ProductCategoryKey 

,EnglishProductCategoryName 

From DimProductCategory 

) 

SELECT  

PN.EnglishProductName 

,SC.EnglishProductSubcategoryName 

,C.EnglishProductCategoryName 

,SUM(SalesAmount) AS Grandtotal 

FROM Product P 

LEFT JOIN ProductName PN ON P.ProductKey=PN.ProductKey 

LEFT JOIN SubCat SC ON PN.ProductSubcategoryKey=SC.ProductSubcategoryKey 

LEFT JOIN Cat C ON SC.ProductCategoryKey=C.ProductCategoryKey 

GROUP BY 

ROLLUP ( 

C.EnglishProductCategoryName 

,PN.EnglishProductName 

,SC.EnglishProductSubcategoryName) 

 

 

 

 

 

/*Ex2:  

Using AdventureWorksDW2020, table dbo.DimEmployee 

Pivot the number of Employee in DepartmentName: Production, Engineering and Sales for each Gender. Then assign result to temp table named #PivotEmp 

 */
-- Your code here 

SELECT  

Gender 

, Production 

, Engineering 

, Sales 

INTO #PIVOT_EMP 

FROM (SELECT 

DepartmentName 

,Gender 

, EmployeeKey 

FROM DimEmployee ) emp 

PIVOT 

( 

COUNT(Employeekey) 

FOR Departmentname IN (  [Production],[Engineering], [Sales]) 

) as P_T 

Order by 1 

; 

SELECT * 

FROM #PIVOT_EMP 

 

 

 

/*Ex3: Write query to unpivot table #PivotEmp  */

-- Your code here 

 

SELECT  

Gender 

,DepartmentName 

, NoEMp 

FROM #PIVOT_EMP 

UNPIVOT (NoEmp for DepartmentName IN ( [Production],[Engineering], [Sales])) AS ok 

 

 

 

-- Task 2. Đọc bổ sung kiến thức về Set operators (Tham khảo: https://learn.microsoft.c	om/en-us/sql/t-sql/language-elements/set-operators-except-and-intersect-transact-sql?view=sql-server-ver16) và thực hành các bài tập bên dưới 

 

/* Ex4.  

Sử dung  AdventureWorksDW2020, bảng DimGeography, DimCustomer, DimGeography 

Lấy danh sách các địa điểm (gồm thông tin City, EnglishCountryRegionName) mà có đồng thời ít nhất một Khách hàng và một Reseller của công ty đang cư trú */ 

 

  -- Your code here 

 

WITH Geo_Name AS ( 

SELECT  

GeographyKey 

,City 

,EnglishCountryRegionName 

FROM DimGeography 

), Geo_Key AS ( 

SELECT  

GeographyKey 

FROM DimCustomer 

INTERSECT 

SELECT  

GeographyKey 

FROM DimReseller 

) 

SELECT  

N.GeographyKey 

,N.City 

,N.EnglishCountryRegionName 

FROM Geo_Key K 

LEFT JOIN Geo_Name N ON K.GeographyKey=N.GeographyKey 

 

 

 

 

/* Ex5. Từ danh sách City và EnglishCountryRegionName, của bài 4, tính toán thêm các chỉ số tương ứng từng nơi:  

- Số lượng khách hàng lẻ đặt tên NumberofCustomer 

- Số lượng Reseller đặt tên là NumberofReseller */ 

 

-- Your code here 

 

 

WITH Nores as ( 

SELECT  

GeographyKey 

, Count ( ResellerKey) As NoReseller 

FROM DimReseller 

Group by GeographyKey 

), NoCus AS ( 

SELECT  

GeographyKey 

, Count (CustomerKey) As NoCus 

FROM DimCustomer 

Group by GeographyKey 

) 

SELECT  

K.City 

,K.EnglishCountryRegionName 

,C.NoCus 

,R.NoReseller 

From Geo_Key K 

LEFT JOIN NoCus C ON K.GeographyKey = C.NoCus 

LEFT JOIN Nores R ON K.GeographyKey = R.NoReseller 