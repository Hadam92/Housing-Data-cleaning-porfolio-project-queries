Drop Table public.housing;

Create Table public.housing(UniqueID CHAR(50),	ParcelID CHAR(50),	LandUse	CHAR(50),PropertyAddress CHAR(50),	SaleDate Timestamp,	
SalePrice Numeric,	LegalReference CHAR(50), 	SoldAsVacant CHAR(50),	OwnerName CHAR(255),OwnerAddress CHAR(50),	Acreage Numeric,	TaxDistrict	CHAR(50),LandValue Numeric,
BuildingValue Numeric,TotalValue Numeric,	YearBuilt Numeric,	Bedrooms Numeric,	FullBath Numeric,	HalfBath Numeric)

Copy public.housing from 'C:\Users\15045\Desktop\data analyst portfolio\SQL\Nashville Housing Data for Data Cleaning.csv' WITH CSV HEADER;

/*
Cleaning Data in SQL Queries
*/


Select *
From public.housing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format



ALTER TABLE public.housing
Add SaleDateConverted Date;

Update public.housing
SET SaleDateConverted = CAST(SaleDate AS DATE)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From public.housing
Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress)
From public.housing a
JOIN public.housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null


--Update a SET PropertyAddress = COALESCE(a.PropertyAddress,b.PropertyAddress)
From public.housing a
JOIN public.housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
--Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress From public.housing


SELECT
SUBSTRING(PropertyAddress, 1, POSITION(','IN PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1 ) as Address
From public.housing;


ALTER TABLE  public.housing
Add PropertySplitAddress char(255);

Update  public.housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(','IN PropertyAddress) -1 ) 


ALTER TABLE public.housing
Add PropertySplitCity char(255);

Update public.housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1 )

Select * From public.housing





Select OwnerAddress From public.housing


Select
split_part(OwnerAddress, ',' , 3)
,split_part(OwnerAddress, ',' , 2)
,split_part(OwnerAddress, ',' , 1)
From public.housing



ALTER TABLE public.housing
Add OwnerSplitAddress char(255);

Update public.housing
SET OwnerSplitAddress = split_part(OwnerAddress, ',' , 3)


ALTER TABLE public.housing
Add OwnerSplitCity char(255);

Update public.housing
SET OwnerSplitCity = split_part(OwnerAddress, ',' , 2)



ALTER TABLE public.housing
Add OwnerSplitState char(255);

Update public.housing
SET OwnerSplitState =split_part(OwnerAddress, ',' , 1)


Select * From public.housing

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From public.housing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From public.housing

Update public.housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

Create view Rownum_cte AS 
 Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID)
				 row_num
 From public.housing;


Create view Rownum_cte_update AS 
Select *
From Rownum_cte
Where row_num = 1
Order by PropertyAddress;

Select *
From Rownum_cte_update
Where row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From public.housing


ALTER TABLE public.housing
DROP COLUMN IF EXISTS OwnerAddress CASCADE,
DROP COLUMN IF EXISTS TaxDistrict CASCADE,
DROP COLUMN IF EXISTS SaleDate CASCADE,
DROP COLUMN IF EXISTS PropertyAddress CASCADE;




