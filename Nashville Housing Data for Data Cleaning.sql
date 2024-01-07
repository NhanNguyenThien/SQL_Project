-- SQL Project --

SELECT TOP 100 * 
FROM Nashville_Housing

--ĐẾM SỔ CỘT TRONG BỘ DỮ LIỆU
SELECT COUNT(*) 
FROM Nashville_Housing --Bộ dữ liệu gồm 56477 dòng

--CHUYỂN ĐỔI DỮ LIỆU CỘT SALEDATE TỪ DATE TIME SANG DATE
-- Thêm một cột mới làm temp để lưu trữ giá trị DATE mới
ALTER TABLE Nashville_Housing
ADD  SaleDate_DATE DATE;

-- Cập nhật giá trị mới cho cột temp
UPDATE Nashville_Housing
SET SaleDate_DATE = CAST(SaleDate AS DATE);

-- KHÁM PHÁ CỘT ĐỊA CHỈ
Select top 5*
From Nashville_Housing
Where PropertyAddress is null
order by ParcelID
---- Có 29 hàng bị null ở cột địa chỉ, sau khi kiểm tra, phát hiện cột ParceID có dữ liệu dupliace và trong các hàng 
---- này chứa toàn bộ các hàng bị null Property Address

SELECT  t1.*
FROM Nashville_Housing t1
INNER JOIN (
    SELECT ParcelID
    FROM Nashville_Housing
    GROUP BY ParcelID
    HAVING COUNT(*) > 1
) t2 ON t1.ParcelID = t2.ParcelID
--WHERE t1.PropertyAddress is null

--UPDATE BẢNG ĐỂ CẬP NHẬT Property Addres lấy giá trị property address có giá trị trong cột ParceID trùng với hàng null property address
UPDATE t1
SET t1.PropertyAddress = t2.PropertyAddress
FROM Nashville_Housing t1
INNER JOIN (
    SELECT ParcelID, MAX(CASE WHEN PropertyAddress IS NOT NULL THEN 1 ELSE 0 END) AS HasNonNullProperty
           , MAX(PropertyAddress) AS PropertyAddress
    FROM Nashville_Housing
    GROUP BY ParcelID
    HAVING COUNT(*) > 1
) t2 ON t1.ParcelID = t2.ParcelID
WHERE t1.PropertyAddress IS NULL AND t2.HasNonNullProperty = 1;


--TÁCH GIÁ TRỊ CỘT PropertyAddress thành địa chỉ và tỉnh thành
SELECT 
    PropertyAddress AS OriginalPropertyAddress,
    LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS PropertyAddress,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertyCity
FROM Nashville_Housing
WHERE CHARINDEX(',', PropertyAddress) > 0;

-- Thêm hai cột mới vào bảng
ALTER TABLE [dbo].[Nashville_Housing]
ADD PropertyCity NVARCHAR(255);
    

-- Cập nhật cột PropertyAddress và PropertyCity từ cột ban đầu
UPDATE Nashville_Housing
SET 
    PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)),
    PropertyAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1)
WHERE CHARINDEX(',', PropertyAddress) > 0;

-- TÁCH GIÁ TRỊ CỘT OwnerAddress thành địa chỉ và tỉnh thành và bang
select OwnerAddress  from Nashville_Housing
where OwnerAddress is not null

-- Xem trước dữ liệu trước khi tách cột
SELECT 
    OwnerAddress,
    LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1) AS OwnerSplitAddress,
    SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1) AS OwnerSplitCity,
    SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 1, LEN(OwnerAddress)) AS OwnerSplitState
FROM Nashville_Housing
WHERE CHARINDEX(',', OwnerAddress) > 0;

-- Thêm cột 
ALTER TABLE [dbo].[Nashville_Housing]
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255)

-- Cập nhật cột OwnerSplitAddress, OwnerSplitCity, và OwnerSplitState từ cột ban đầu
UPDATE Nashville_Housing
SET 
    OwnerSplitAddress = LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1),
    OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1),
    OwnerSplitState = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 1, LEN(OwnerAddress))
WHERE CHARINDEX(',', OwnerAddress) > 0;

-- Xem lại dữ liệu
SELECT * FROM Nashville_Housing
WHERE OwnerAddress IS NOT NULL

-- Thay đổi giá trị cột 'SoldAsVacant' từ 'Yes','No' sang '1', '0'

SELECT SoldAsVacant
, COUNT(SoldAsVacant) as Frquency
FROM Nashville_Housing
GROUP BY SoldAsVacant

-- Ta thấy trong cột có các giá trị như Y, Yes, N, No --> chuyển chúng về dạng Yes, No
UPDATE Nashville_Housing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- Thêm cột mới có tên là IsSoldAsVacantNumeric
ALTER TABLE Nashville_Housing
ADD  Int_SoldVacant INT;

-- Cập nhật giá trị cho cột mới dựa vào cột SoldAsVacant
UPDATE Nashville_Housing
SET Int_SoldVacant = CASE
    WHEN SoldAsVacant = 'Yes' THEN 1
    WHEN SoldAsVacant = 'No' THEN 0
END;

--kiểm tra kết quả 
SELECT Int_SoldVacant
, COUNT(Int_SoldVacant) as Frquency
FROM Nashville_Housing
GROUP BY Int_SoldVacant

-- Kiểm tra dữ liệu distinct
SELECT *
FROM Nashville_Housing

Select COUNT(distinct [UniqueID ]) as Distinct_Count
from Nashville_Housing

SELECT *
FROM Nashville_Housing AS nh1
INNER JOIN (
    SELECT ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice
    FROM Nashville_Housing
    GROUP BY ParcelID
	, LandUse, PropertyAddress, SaleDate, SalePrice
    HAVING COUNT(*) > 1
) AS nh2
ON nh1.ParcelID = nh2.ParcelID
    AND nh1.LandUse = nh2.LandUse
    AND nh1.PropertyAddress = nh2.PropertyAddress
    AND nh1.SaleDate = nh2.SaleDate
    AND nh1.SalePrice = nh2.SalePrice;

--QUA TRUY VẤN NÀY TA THẤY VẪN CÓ CÁC HÀNG CÓ GIÁ TRỊ DUPLICATES 
--> TẠO 1 VIEW ĐỂ XÓA CÁC CỘT KHÔNG CẦN THIẾT CŨNG NHƯ LOẠI BỎ CÁC HÀNG BỊ DUPLICATES
 
CREATE VIEW vw_Nashville_Housing AS
WITH RankedRows AS (
    SELECT
        [UniqueID],
        ParcelID,
        LandUse,
        PropertyAddress,
        PropertyCity,
        CAST(SaleDate AS DATE) AS SaleDate_DATE,
        SalePrice,
        Int_SoldVacant,
        OwnerName,
        OwnerSplitAddress,
        OwnerSplitCity,
        OwnerSplitState,
        Acreage,
        TaxDistrict,
        LandValue,
        BuildingValue,
        TotalValue,
        YearBuilt,
        Bedrooms,
        FullBath,
        HalfBath,
        ROW_NUMBER() OVER (PARTITION BY ParcelID, LandUse, PropertyAddress, CAST(SaleDate AS DATE), SalePrice ORDER BY [UniqueID] DESC) AS RowNum
    FROM
        Nashville_Housing
)
SELECT
    [UniqueID],
    ParcelID,
    LandUse,
    PropertyAddress,
    PropertyCity,
    SaleDate_DATE,
    SalePrice,
    Int_SoldVacant,
    OwnerName,
    OwnerSplitAddress,
    OwnerSplitCity,
    OwnerSplitState,
    Acreage,
    TaxDistrict,
    LandValue,
    BuildingValue,
    TotalValue,
    YearBuilt,
    Bedrooms,
    FullBath,
    HalfBath
FROM
    RankedRows
WHERE
    RowNum = 1;

-- Kiểm tra kết quả
select * from vw_Nashville_Housing