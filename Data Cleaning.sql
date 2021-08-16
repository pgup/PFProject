/*

Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing
----------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SaleDate, CONVERT(date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
add SaleDateConverted Date

update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate) 

 
----------------------------------------------------------------------------------------------------------------------

--Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing 
--where PropertyAddress is null
order by ParcelID




Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]



Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null






----------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing 
--where PropertyAddress is null
--order by ParcelID

--splitting Address and checking if it works
SELECT 
     REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress), ',', '.'), 1)) AS [Street]
   , REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress), ',', '.'), 2)) AS [City]
From PortfolioProject.dbo.NashvilleHousing; 

--PropertySplitAddress
--PropertySplitCity
-- the split above worked so now create a column PropertySplitAddress & PropertySplitCity
Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress), ',', '.'), 1))

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress), ',', '.'), 2))



--split the owneraddress

Select OwnerAddress, 
	REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),1)),
	REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),2)),
	REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),3))
From PortfolioProject.dbo.NashvilleHousing

--OwnerSplitAddress, OwnerSplitCity, OwnerSplitState

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress =  REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),1))

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity =  REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),2))

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState =  REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),3))


--------------------------------------------------------------------------------------------------------

--change Y and N to YES and No in the 'Sold as vacant" field

--count each 'Y', 'N',No,'Yes' amd prder by column 2
select  SoldAsVacant,count( SoldAsVacant) as number_of_errors 
from PortfolioProject.dbo.NashvilleHousing 
group by SoldAsVacant
--order by SoldAsVacant
order by 2

-- check out sql case statment 
select SoldAsVacant,
case 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END 
from PortfolioProject.dbo.NashvilleHousing 

update PortfolioProject.dbo.NashvilleHousing 
SET SoldAsVacant = case 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END 



--------------------------------------------------------------
--Remove duplicates

--check out group by vs partition by difference

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




Select *
From PortfolioProject.dbo.NashvilleHousing



-------------------------------------------
-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

	