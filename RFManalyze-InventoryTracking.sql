-- Task 1. Thực hiện lại  bài Lab về RFM analysis 

 

USE AdventureWorksDW2020 

; 

  

WITH OrderList AS ( 

SELECT  

CustomerKey 

,OrderDate 

,SalesAmount 

,SalesOrderNumber 

FROM FactInternetSales 

), RFM_record AS ( 

SELECT  

CustomerKey 

, COUNT(DISTINCT SalesOrderNumber ) AS F  

,SUM(SalesAmount) AS M 

, DATEDIFF(DAY,MAX(ORDERDATE),(SELECT MAX (OrderDate) FROM OrderList)) AS R 

FROM OrderList 

Group by CustomerKey 

), RFM_Score AS ( 

SELECT  

CustomerKey 

,NTILE(4) OVER (ORDER BY R DESC) AS R_Score 

,NTILE(4) OVER (ORDER BY M) AS M_Score 

,NTILE(4) OVER (ORDER BY F) AS F_Score 

FROM RFM_record 

), RFM AS ( 

SELECT  

CustomerKey 

,CONCAT(R_Score,F_Score,M_Score) AS RFM  

FROM RFM_Score 

) 

SELECT  

CustomerKey 

,CASE 

WHEN RFM LIKE '1__' THEN 'CHURNED' 

WHEN RFM LIKE '[3-4][3-4][3-4]' THEN 'LOYAL' 

WHEN RFM LIKE '[3-4][3-4][1-2]' THEN 'PROMISING' 

WHEN RFM LIKE '_[1-2]4' THEN 'BIGSPENDER' 

WHEN RFM LIKE '[3-4][1-2]_' THEN 'NEWCUSTOMER' 

WHEN RFM LIKE '2__' THEN 'POTENTIALCHURNED' 

END AS Cust_Seg 

,RFM 

FROM RFM 

 

--Task 2. Tính toán các yêu cầu sau   

 

/* Ex2. Từ bảng FactInventory, thống kê tổng số lượng hàng tồn kho (UnitBalance) đối với từng sản phẩm tại ngày cuối cùng của mỗi tháng.  

đồng thời tổng hợp lên tất cả sản phẩm trong tháng  

Kết quả trả ra gồm: Month (định dạng MM-yyyy), EndofMonthDate, EnglishProductName, TotalUnitsBalance 

*/ 

/* 

Ý tưởng của em là : Tính ra Ngày đầu tiên hàng xuất hiện trong kho rồi cộng với chênh lệch lũy kế hàng tháng để ra inventory track  

Bài làm hơi dài vì trong thực tế có thể có sản phẩm xuất hiện sau một số sản phẩm khác, nhưng trong bài này em test thử thì mọi mặt hàng đều xuất hiện cùng nhau là tháng 1-2018 

 B1: Lấy ra các cột cần dùng 

B2:Tìm Ngày đầu tiên xuất hiện của hàng trong inventory -> Tìm được Số lượng ngày đầu tiên trong kho 

B3: Tìm chênh lệch hàng (IN-OUT) -> lũy kế chênh lệch 

B4: Lấy lũy kế cuối mỗi tháng + Số lượng ban đầu 

*/ 

 

USE AdventureWorksDW2020 

; 

WITH Inv AS ( 

SELECT  

ProductKey 

, Date 

, EOMONTH(Date) AS EOM 

,UnitsIn 

,UnitsOut 

,UnitsBalance 

FROM  FactProductInventory 

) 

, FirstDateInv AS ( 

SELECT  

ProductKey 

,MiN(Date) FirstDate 

FROM Inv 

GROUP BY ProductKey  

) 

, FirstDayUnitBalance AS ( 

SELECT  

DISTINCT I.ProductKey 

,I.UnitsBalance AS FIRSTDAYUNITBALANCE 

FROM Inv I 

LEFT JOIN FirstDateInv FI On I.ProductKey=FI.ProductKey AND I.Date=FI.FirstDate 

) 

,Chenhlechthang AS ( 

SELECT  

DISTINCT ProductKey 

,EOM 

,(SUM(UnitsIn)-SUM(UnitsOut)) AS Chenh_lech_hang_thang 

FROM Inv  

GROUP BY PRODUCTKEY,EOM 

) 

SELECT 

Clt.ProductKey 

,FORMAT(Clt.EOM,'yyyy-MM') AS 'Month-Year' 

,FI.FIRSTDAYUNITBALANCE+(SUM(Clt.Chenh_lech_hang_thang) OVER ( PARTITION BY Clt.Productkey Order by Clt.EOM )) AS INVENTORY_TRACK 

FROM Chenhlechthang Clt  

LEFT JOIN FirstDayUnitBalance FI ON Clt.ProductKey=FI.ProductKey 

ORDER BY 1,2 

 

/* Ex3. Từ bảng DimEmployee,  

tính tổng thời gian dài nhất mỗi phòng ban không tuyển dụng bất cứ ai (sử dụng cột HireDate)  

*/ 

 

 

USE AdventureWorksDW2020 

; 

WITH ChenhLech AS ( 

SELECT 

DepartmentName 

,HireDate 

,LAG(HireDate) OVER (ORDER BY HireDate) AS OK 

,DATEDIFF(DAY,LAG(HireDate) OVER (PARTITION BY Departmentname ORDER BY HireDate),HireDate) AS Chenhlechngay 

FROM DimEmployee 

) 

SELECT  

DepartmentName 

,MAX(Chenhlechngay) AS ThoiGianKhongTuyenDaiNhat 

FROM ChenhLech 

Group by DepartmentName 