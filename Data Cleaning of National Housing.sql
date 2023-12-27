/*

Cleaning data in SQL Queries

*/

Select *
from Portfolio..NationalHousing

--------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate) 
from Portfolio..NationalHousing

Update NationalHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NationalHousing
ADD SaleDateConverted Date;

Update NationalHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------

--Populate Property address data

Select *
from Portfolio..NationalHousing
Where PropertyAddress IS NULL;
Order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio..NationalHousing a
JOIN Portfolio..NationalHousing b
	On a.ParcelID=b.ParcelID
	AND a.[UniqueID ]!=b.[UniqueID ]
Where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio..NationalHousing a
JOIN Portfolio..NationalHousing b
	On a.ParcelID=b.ParcelID
	AND a.[UniqueID ]!=b.[UniqueID ]
Where a.PropertyAddress is null;

--------------------------------------------------------------

--Breaking Out address into Individual Columns
Select PropertyAddress
from Portfolio..NationalHousing

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Portfolio..NationalHousing

ALTER TABLE NationalHousing
ADD PropertySplitAddress varchar(255);

Update NationalHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NationalHousing
ADD PropertySplitCity varchar(255);

Update NationalHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Portfolio..NationalHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio..NationalHousing

ALTER TABLE NationalHousing
ADD OwnerSplitAddress varchar(255);

Update NationalHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NationalHousing
ADD OwnerSplitCity varchar(255);

Update NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NationalHousing
ADD OwnerSplitState varchar(255);

Update NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From Portfolio..NationalHousing

--------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio..NationalHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Portfolio..NationalHousing

UPDATE Portfolio..NationalHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 


--------------------------------------------------------------

--Remove Duplicates

With RowNumCTE AS (
Select *,
       ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by 
					UniqueID
					) row_num

FROM Portfolio..NationalHousing
)
DELETE 
FROM RowNumCTE
Where row_num > 1


--------------------------------------------------------------

--Delete Unused Columns


Select *
From Portfolio..NationalHousing

ALTER TABLE Portfolio..NationalHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio..NationalHousing
DROP COLUMN SaleDate


