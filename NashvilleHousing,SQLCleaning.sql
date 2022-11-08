-- Data Cleaning, Nashville Housing




select *
from PortfolioProject.dbo.NashvilleHousing





---------------------------------------------------------------------

-- Standardize Data Format


select SaleDate, convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing


-- Update NashvilleHousing
-- SET SaleDate = convert(date,SaleDate) 
--this query is unable to work for some reason, below 2 queries used instead


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;


Update NashvilleHousing
SET SaleDateConverted = convert(date,SaleDate)



-----------------------------------------------------------------------


-- Populate Property Address Data


select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID



select *
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
-- Consolidating listings by joining the table to itself: NULL addresses with complete address by ParcelID and UniqueID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--null vs completed addresses list




select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--using ISNULL to find NULL listings and replace referencing the completed addresses




UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--updating PropertyAddress to ISNULL column from above









------------------------------------------------------------------------------------

-- Separating Address into Individual Columns (Address, City, State)



select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID
 
 SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
 -- "-1" is to backspace the comma collected by the SUBSTRING command, removing the comma rather than including it
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
-- this SUBSTRING separates City by setting the starting point AT the comma rather than 1, and setting the end point at the end of the length (LEN) of the rest of the address, "+1" removes the included comma
 from PortfolioProject.dbo.NashvilleHousing


 --now creating the columns for the new info


 ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);


Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



 ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);


Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))




select *
from PortfolioProject.dbo.NashvilleHousing






select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing
--using PARSENAME this time, replacing commas with periods



select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from PortfolioProject.dbo.NashvilleHousing



--now to add columns and new separated info





 ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);


Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)




 ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);


Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)





 ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);


Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)



-- execute ALTER TABLE lines before UPDATE






select *
from PortfolioProject.dbo.NashvilleHousing








----------------------------------------------------------------------------------------------

-- Change Y and N to "Yes"/"No" in "Sold as Vacant"




select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2






select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END
from PortfolioProject.dbo.NashvilleHousing





update NashvilleHousing
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END







------------------------------------------------------------------

-- Remove Duplicates
-- Partition duplicate data and adding "row_num" to distinguish duplicates

WITH RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by 
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
From RowNumCTE
where row_num > 1
-- order by PropertyAddress
-- separating and deleting duplicates with row_num greater than 1 (replaced "Select *" with DELETE)


select *
from PortfolioProject.dbo.NashvilleHousing



-------------------------------------------------------------------------------

-- Delete Unused Columns



select *
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate