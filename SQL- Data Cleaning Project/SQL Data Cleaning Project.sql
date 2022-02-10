--cleaning data in SQL Queries


use Portfolioproject

select*from housing

--cleaning data in SQL Queries

select saledate from housing

select saledate, CONVERT(date,saledate)
from housing

update housing set saledate=CONVERT(date,saledate)


alter table housing add saledateconverted date; -- (add a new table saledateconverted and datatype date)
update housing set saledateconverted =CONVERT(date,saledate)  --(then update the CONVERT(date,saledate) value into saledateconverted )

select saledateconverted, CONVERT(date,saledate)  
from housing

--2 populate property address data


select propertyaddress from housing
where propertyaddress is null


select*from Housing  --(there is repeated parcel_id and the property address so we actually doing this two are same by the below code)
order by ParcelID

select*from Housing a join Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]


--the below code is doing creating new ParcelID ,propertyaddress columns but its notpopulated so we need eliminate all null values from a.properyaddress 
select a.ParcelID,a.propertyaddress, b.ParcelID,b.propertyaddress  
from Housing a join Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--for populating a.propertyaddress

select a.ParcelID,a.propertyaddress,b.ParcelID,b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress) 
from Housing a join Housing b
on a.ParcelID = b.ParcelID                                 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- updating propertyaddress column like below (if we ae joining two table then only use alliance word(a))

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress) -- now property addrsess is updated we canot see any null values
from Housing a join Housing b
on a.ParcelID = b.ParcelID                                 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- we canot see any null values now below code

select a.ParcelID,a.propertyaddress, b.ParcelID,b.propertyaddress  
from Housing a join Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--3 breaking out propertyaddress into individual columns(address,city,state)

select propertyaddress from housing


select SUBSTRING(propertyaddress,1, CHARINDEX(',',propertyaddress)-1)as address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) as city 
from housing

--we cant seperate two values from one column so we need create 2 other columns to add address and city

alter table housing add propertysplitaddress nvarchar(255)

update Housing
set propertysplitaddress = SUBSTRING(propertyaddress,1, CHARINDEX(',',propertyaddress)-1)

alter table housing add propertysplitcity nvarchar(255)

update Housing
set propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

-- now the below code we can see a two good new columns propertysplitaddress and propertysplitcity

select*from Housing


--4 spliting the owner address column

--but here we are using diffrent method(parsename) not substring

select OwnerAddress
from Housing

select PARSENAME(replace(OwnerAddress,',','.'),3),                                                    
PARSENAME(replace(OwnerAddress,',','.'),1)
from Housing

-- then same like property address create 3 seperate columns and add the values

alter table housing add ownersplitaddress nvarchar(255)

update Housing
set ownersplitaddress = PARSENAME(replace(OwnerAddress,',','.'),3)


alter table housing add ownersplitcity nvarchar(255)

update Housing
set ownersplitcity = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table housing add ownersplitstate nvarchar(255)

update Housing
set ownersplitstate = PARSENAME(replace(OwnerAddress,',','.'),3)


--5 change Y and N into YES and NO in 'soldasvacant' column

select distinct(soldasvacant),COUNT(soldasvacant)
from Housing
group by soldasvacant
order by 2

select soldasvacant,
case when soldasvacant ='Y' then 'Yes'
     when soldasvacant= 'N' then 'No'
	 else soldasvacant
	 end
from Housing

update Housing
set soldasvacant =case when soldasvacant ='Y' then 'Yes'
     when soldasvacant= 'N' then 'No'
	 else soldasvacant
	 end
from Housing

-- now the below code we cant see any Y And N

select distinct(soldasvacant),COUNT(soldasvacant)
from Housing
group by soldasvacant
order by 2


--6 Delete the duplicate rows in housing table

select*from Housing

--for deleting duplicate we need to ctreate a cte (temp result set) like the name rawnumcte

select *,Row_number() over (
    partition by parcelid,propertyaddress,saledate,saleprice,legalreference
    order by uniqueid
	) as row_num
from housing
order by ParcelID              


with rownumcte as(
select *,Row_number() over (
    partition by parcelid,propertyaddress,saledate,saleprice,legalreference
    order by uniqueid
	) as row_num
from housing
--order by ParcelID
)
select*from rownumcte
where row_num>1
order by propertyaddress

--for deleting the duplicates rows only

with rownumcte as(
select *,Row_number() over (
    partition by parcelid,propertyaddress,saledate,saleprice,legalreference
    order by uniqueid
	) as row_num
from housing
--order by ParcelID
)
delete from rownumcte
where row_num>1


--7 delete unused columns

select*from Housing

alter table housing
drop column owneraddress,propertyaddress,taxdistrict 

alter table housing
drop column saledate