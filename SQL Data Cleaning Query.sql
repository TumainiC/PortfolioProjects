--DATA CLEANING

Select * 
FROM ThePortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------

--Removing Time from SaleDate column

Update ThePortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data


Select *
FROM ThePortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ThePortfolioProject.dbo.NashvilleHousing a
JOIN ThePortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is  null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ThePortfolioProject.dbo.NashvilleHousing a
JOIN ThePortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is  null

-----------------------------------------------------------------------------------------------------------------------------------

--Breaking apart address into individual columns i.e (Address, City, State)
--Delimiter used is comma ','
-- '-1/ +1' removes delimiter


Select PropertyAddress
FROM ThePortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--Order by ParcelID

Select Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM ThePortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update ThePortfolioProject.dbo.NashvilleHousing
SET  PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update ThePortfolioProject.dbo.NashvilleHousing
SET  PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

----------------------------------------------------------------------------------------------------------------------------------

--Split using Parsing, parsing looks for periods and does things backwards


Select OwnerAddress
FROM ThePortfolioProject.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as OwnerSplitState
FROM ThePortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update ThePortfolioProject.dbo.NashvilleHousing
SET  OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update ThePortfolioProject.dbo.NashvilleHousing
SET  PropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update ThePortfolioProject.dbo.NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) 

----------------------------------------------------------------------------------------------------------------------------------

-- Changing 'Y' AND 'N' to 'Yes' and 'No'


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM ThePortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 1,2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END

FROM ThePortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
END

----------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates 

Select *
FROM ThePortfolioProject.dbo.NashvilleHousing

WITH RowNumCTE as (
Select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 ORDER BY UniqueID
			 ) as row_numb
FROM ThePortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)
delete
FROM RowNumCTE
where row_numb > 1


----------------------------------------------------------------------------------------------------------------------------------

--Delete Unused columns

Select *
FROM ThePortfolioProject.dbo.NashvilleHousing


ALTER TABLE ThePortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict


