---------------- Retrieve All The Data From NashvilleHousing Data ----------------

SELECT *
FROM dbo.NashvilleHousing

---------------- Standardize Date Format ------------------

SELECT SaleDate,CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD ConSaleDate Date

UPDATE NashvilleHousing
SET ConSaleDate = CONVERT(Date,SaleDate)

---------------- Populate Property Address Data ----------------

SELECT PropertyAddress
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

---------------- Using Self Join we update PropertyAddress by ParcelID ----------------

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

---------------- Breaking out PropertyAddress into Individual Columns (Address, City, State) ----------------

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) As Address,  
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyHAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertyHAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

---------------- Breaking out OwnerAddress into Individual Columns (Address, City, State) ----------------

ALTER TABLE NashvilleHousing
ADD OwnerHAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerHAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---------------- Change Y and N to Yes and No in SoldAsVacant Field ----------------

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END AS CorSoldAsVacant
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END

---------------- Remove Duplicates ----------------

WITH rn AS (SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM NashvilleHousing 
)
--DELETE FROM rn
SELECT * FROM rn
WHERE row_num > 1

---------------- DELETE Unused Column ----------------

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict,SaleDate


---------------- Cleaned NashvilleHousing Data For Analysis ----------------

SELECT * FROM NashvilleHousing
