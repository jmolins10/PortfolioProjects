/* Cleaning Data with SQL Queries */

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

--Standardize date format, Sales Date

ALTER TABLE PortfolioProject.dbo.NashvilleHousing -- adding a new column
ADD SaleDateConverted date;

UPDATE PortfolioProject.dbo.NashvilleHousing  --filling in the column with the info from saledate as date
SET saledateconverted= CONVERT(date,saledate);

SELECT saledateconverted
FROM PortfolioProject.dbo.NashvilleHousing;  -- to confirm new column containes requested informantion

-- Populate address data, I will use a second unique column to populate the corresponding address, VLOOKUP kind of style

SELECT A.parcelid, A.propertyaddress, B.parcelid, B.propertyaddress, ISNULL(A.propertyaddress, B.propertyaddress) -- confirmed how to fill in missing values
FROM PortfolioProject.dbo.NashvilleHousing AS A
	JOIN PortfolioProject.dbo.NashvilleHousing AS B 
	ON A.parcelid=B.parcelid
	AND A.uniqueid<>B.uniqueid
WHERE A.propertyaddress IS NULL

UPDATE A															--here we are actually modifying the table with needed values
SET propertyaddress = ISNULL(A.propertyaddress, B.propertyaddress)
	FROM PortfolioProject.dbo.NashvilleHousing AS A
		JOIN PortfolioProject.dbo.NashvilleHousing AS B 
		ON A.parcelid=B.parcelid
		AND A.uniqueid<>B.uniqueid
	WHERE A.propertyaddress IS NULL

--Breaking out address into individual columns (Address, City, State)

SELECT propertyaddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
	-- we verify we get only address but comma appears, below on how to remove
	SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) AS address, 
	--CHARINDEX(',', propertyaddress) --here we can confirm the position of the comma on all and help identify we can reduce on above by -1
	SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) AS address -- look to separate city
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing -- adding a new column
ADD property_address nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET property_address= SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing -- adding a new column
ADD property_city nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing  
SET property_city= SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress));


--Updating Owner Address diff. method than above

SELECT 
	PARSENAME(REPLACE(owneraddress, ',', '.'), 3), --Grabs the string based on delimiter of a period from back to front
	PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
	PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing;

--Actually putting them into table
--Owner Address
ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
ADD owner_address nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing  
SET owner_address= PARSENAME(REPLACE(owneraddress, ',', '.'), 3);

--Owner City
ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
ADD owner_city nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing  
SET owner_city= PARSENAME(REPLACE(owneraddress, ',', '.'), 2);

--Owner State

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
ADD owner_state nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing  
SET owner_state= PARSENAME(REPLACE(owneraddress, ',', '.'), 1);


--editing Yes No responses in uniform way

SELECT soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing  
SET soldasvacant =
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant END


--Remove Duplicates, based on if certain columns are all the same the assumption is that they are duplicates

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



-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate