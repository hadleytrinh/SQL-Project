-- CLEANING DATA IN SQL

Select * from NashvilleHousing

-- Populate Property Address Data
Select * from NashvilleHousing
Where PropertyAddress is NULL
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a 
Join NashvilleHousing b 
on a.ParcelID = b.ParcelID 
and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a 
Join NashvilleHousing b 
on a.ParcelID = b.ParcelID 
and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress from NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From NashvilleHousing

ALTER TABLE NashvilleHousing 
Add PropertySlitAddress nvarchar(250);

Update NashvilleHousing 
SET PropertySlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
Add PropertySlitCity nvarchar(250);

Update NashvilleHousing 
SET PropertySlitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select 
PARSENAME(Replace(OwnerAddress,',','.'),1),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),3)
from NashvilleHousing

ALTER TABLE NashvilleHousing 
Add OwnerSlitAddress nvarchar(250);

Update NashvilleHousing 
SET OwnerSlitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing 
Add OwnerSlitCity nvarchar(250);

Update NashvilleHousing 
SET OwnerSlitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing 
Add OwnerSlitState nvarchar(250);

Update NashvilleHousing 
SET OwnerSlitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
       End
from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
                        when SoldAsVacant = 'N' then 'No' 
                        Else SoldAsVacant 
                        End

-- Remove Duplicates

WITH RowNumCTE AS
(
Select *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
from NashvilleHousing
)
--Order by UniqueID

SELECT * From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select * From NashvilleHousing