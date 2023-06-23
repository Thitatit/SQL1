use Portfolio
go
SELECT C.NAME AS COLUMN_NAME,
       TYPE_NAME(C.USER_TYPE_ID) AS DATA_TYPE,
       C.IS_NULLABLE,
       C.MAX_LENGTH,
       C.PRECISION,
       C.SCALE
FROM SYS.COLUMNS C
JOIN SYS.TYPES T
     ON C.USER_TYPE_ID=T.USER_TYPE_ID
WHERE C.OBJECT_ID=OBJECT_ID('NashvilleHousing');


use Portfolio
go
-- Satandardize Date Format

Select SaleDate, Convert(date, SaleDate)
From Portfolio.dbo.NashvilleHousing;

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate);

Alter Table NashvilleHousing
Add SaleDateCoverted date;

Update NashvilleHousing
Set SaleDateCoverted =  Convert(Date, SaleDate);

-- Populate Property Address data

Select * from Portfolio.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing as a
Join Portfolio.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null or b.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing a
JOIN Portfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out address into Individual Columns (Address, City, State)

Select PropertyAddress
from Portfolio.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Adress
from Portfolio.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

Select *
from Portfolio.dbo.NashvilleHousing

Select OwnerAddress
From Portfolio.dbo.NashvilleHousing

Select
OwnerAddress,
Parsename(Replace(OwnerAddress, ',', '.'), 1),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 3)
From Portfolio.dbo.Nashvillehousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3);

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity  = Parsename(Replace(OwnerAddress, ',', '.'), 2);

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1);

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
From Portfolio.dbo.NashvilleHousing;

Update NashvilleHousing
Set 
SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END;

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-- Remove duplicates

With RowNumCTE as (
Select *, ROW_NUMBER() OVER(
		  PARTITION BY ParcelID,
					   PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   ORDER BY
					   UniqueID) as row_num
From Portfolio.dbo.NashvilleHousing
)

select*
From RowNumCTE
where row_num > 1
Order by PropertyAddress

--Delete Unsed Columns

Select *
From Portfolio.dbo.NashvilleHousing

Alter Table PortFolio.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table Portfolio.dbo.NashivilleHousing
Drop column SaleDate
