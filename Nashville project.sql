
-- Alter date format

SELECT SaleDateUpdated
FROM PortProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateUpdated Date;

UPDATE NashvilleHousing
SET SaleDateUpdated = CONVERT(Date, SaleDate)



--Populate property address data


SELECT a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortProject..NashvilleHousing a
JOIN PortProject..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortProject..NashvilleHousing a
JOIN PortProject..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1 ,CHARINDEX(',', PropertyAddress) -1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 ,LEN(PropertyAddress))	
FROM PortProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 ,CHARINDEX(',', PropertyAddress) -1)	


ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 ,LEN(PropertyAddress))



SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Changed Y and S to Yes and No in 'Sold as vacant field'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortProject..NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END	
FROM PortProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						 WHEN SoldAsVacant = 'N' THEN 'NO'
						 ELSE SoldAsVacant
						 END



--Remove duplicates

WITH RowNumCTE 
as(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY UniqueID)
									as row_num
FROM PortProject..NashvilleHousing
)

SELECT * 
FROM RowNumCTE
ORDER BY row_num DESC





