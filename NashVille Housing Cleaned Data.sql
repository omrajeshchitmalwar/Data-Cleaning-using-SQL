--------View the table-----------

SELECT *
FROM [NashVille Housing].[dbo].[HousingData];


--------Standardized Date Format---------

ALTER TABLE [NashVille Housing].[dbo].[HousingData]
Add SaleDateConverted Date;

Update [NashVille Housing].[dbo].[HousingData]
SET SaleDateConverted = CONVERT(Date,SaleDate);

Alter table [NashVille Housing].[dbo].[HousingData]
Drop column SaleDate;


--------Populate Property Address Data-----------

SELECT *
FROM [NashVille Housing].[dbo].[HousingData]where PropertyAddress is null;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [NashVille Housing].[dbo].[HousingData] a
join [NashVille Housing].[dbo].[HousingData] b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [NashVille Housing].[dbo].[HousingData] a
join [NashVille Housing].[dbo].[HousingData] b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;


--------Change 0 and 1 to No and Yes in SoldAsVacant-----------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [NashVille Housing].[dbo].[HousingData]
Group by SoldAsVacant
order by 2;

select SoldAsVacant, case when SoldAsVacant = 1 then 'Yes' else 'No' end 
FROM [NashVille Housing].[dbo].[HousingData];


ALTER TABLE [NashVille Housing].[dbo].[HousingData]
ADD SoldAsVacantText VARCHAR(3);


UPDATE [NashVille Housing].[dbo].[HousingData]
SET SoldAsVacantText = CASE 
                          WHEN SoldAsVacant = 1 THEN 'Yes'
                          WHEN SoldAsVacant = 0 THEN 'No'
                       END;
					   
Alter table [NashVille Housing].[dbo].[HousingData]
drop column SoldAsVacantStatus;

Alter table [NashVille Housing].[dbo].[HousingData]
drop column SoldAsVacant;

------------Remove Duplicates---------

with t1 as (
	select *, ROW_NUMBER() over(partition by ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference order by UniqueID) as rnk
	from [NashVille Housing].[dbo].[HousingData]
)
select * from t1
where rnk > 1
order by PropertyAddress;

SELECT *
FROM [NashVille Housing].[dbo].[HousingData];


-------------Breaking Addresss into individual columns(Address, City, State)------------

select *
from [NashVille Housing].[dbo].[HousingData];

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1), SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(propertyaddress))
from [NashVille Housing].[dbo].[HousingData];

ALTER TABLE [NashVille Housing].[dbo].[HousingData]
Add PropertySplitAddress Nvarchar(255);

Update [NashVille Housing].[dbo].[HousingData]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

alter table [NashVille Housing].[dbo].[HousingData]
add PropertySpiltCity Nvarchar(255);

Update [NashVille Housing].[dbo].[HousingData]
SET PropertySpiltCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(propertyaddress));

SELECT *
FROM [NashVille Housing].[dbo].[HousingData];

SELECT OwnerAddress
FROM [NashVille Housing].[dbo].[HousingData];

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [NashVille Housing].[dbo].[HousingData];

ALTER TABLE [NashVille Housing].[dbo].[HousingData]
Add OwnerSplitAddress Nvarchar(255);

Update [NashVille Housing].[dbo].[HousingData]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE [NashVille Housing].[dbo].[HousingData]
Add OwnerSplitCity Nvarchar(255);

Update [NashVille Housing].[dbo].[HousingData]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE [NashVille Housing].[dbo].[HousingData]
Add OwnerSplitState Nvarchar(255);

Update [NashVille Housing].[dbo].[HousingData]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

select *
from [NashVille Housing].[dbo].[HousingData];

-----------Delete Unused Columns-----------

select * 
FROM [NashVille Housing].[dbo].[HousingData];

alter table [NashVille Housing].[dbo].[HousingData]
drop column OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacantText;

------------Rename the columns------------

EXEC sp_rename '[NashVille Housing].[dbo].[HousingData].[OwnerSplitState]',  'OnwnerState', 'COLUMN';

EXEC sp_rename '[NashVille Housing].[dbo].[HousingData].[OwnerSplitCity]',  'OnwnerCity', 'COLUMN';

EXEC sp_rename '[NashVille Housing].[dbo].[HousingData].[OwnerSplitAddress]',  'OnwnerAddress', 'COLUMN';

EXEC sp_rename '[NashVille Housing].[dbo].[HousingData].[PropertySpiltCity]',  'PropertyCity', 'COLUMN';

EXEC sp_rename '[NashVille Housing].[dbo].[HousingData].[PropertySplitAddress]',  'PropertyAddress', 'COLUMN';

EXEC sp_rename '[NashVille Housing].[dbo].[HousingData].[SaleDateConverted]',  'SaleDate', 'COLUMN';

