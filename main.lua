
inspect = require 'inspect'
cf = require 'commonfunctions'

dataset = {}

function loadDataset()
	table.insert(dataset, {158,58,"M", 0})
	table.insert(dataset, {158,59,"M", 0})
	table.insert(dataset, {158,63,"M", 0})
	table.insert(dataset, {160,59,"M", 0})
	table.insert(dataset, {160,60,"M", 0})
	table.insert(dataset, {163,60,"M", 0})
	table.insert(dataset, {163,61,"M", 0})
	table.insert(dataset, {160,64,"L", 0})
	table.insert(dataset, {163,64,"L", 0})
	table.insert(dataset, {165,61,"L", 0})
	table.insert(dataset, {165,62,"L", 0})
	table.insert(dataset, {165,65,"L", 0})
	table.insert(dataset, {168,62,"L", 0})
	table.insert(dataset, {168,63,"L", 0})
	table.insert(dataset, {168,66,"L", 0})
	table.insert(dataset, {170,63,"L", 0})
	table.insert(dataset, {170,64,"L", 0})
	table.insert(dataset, {170,65,"L", 0})
end

-- -- normalise the data, including the query data
-- col1min = 999
-- col2min = 999
-- col1max = 0
-- col2max = 0

-- -- get min/max for dataset
-- for i = 1, #dataset do
    -- if dataset[i][1] > col1max then col1max = dataset[i][1] end
    -- if dataset[i][1] < col1min then col1min = dataset[i][1] end

    -- if dataset[i][2] > col2max then col2max = dataset[i][2] end
    -- if dataset[i][2] < col2min then col2min = dataset[i][2] end
-- end
-- -- normalise the dataset
-- for i = 1, #dataset do
    -- dataset[i][1] =cf.round( (dataset[i][1] - col1min) / (col1max - col1min) , 2)
    -- dataset[i][2] =cf.round( (dataset[i][2] - col2min) / (col2max - col2min) , 2)
-- end

-- val1 = 161
-- val2 = 61

-- val1normalised = cf.round( (val1 - col1min) / (col1max - col1min) , 2)
-- val2normalised = cf.round( (val2 - col2min) / (col2max - col2min) , 2)

-- print(inspect(dataset))

-- for i = 1, #dataset do
    -- local dist = cf.getDistance(val1normalised, val2normalised, dataset[i][1], dataset[i][2])
    -- dataset[i][4] = cf.round(dist, 1)
-- end

-- table.sort(dataset, function(k1, k2) return k1[4] < k2[4] end)

-- result = {}
-- result["L"] = 0
-- result["M"] = 0
-- k = 5

-- for i = 1, k do
    -- print(dataset[i][1], dataset[i][2], dataset[i][3], dataset[i][4])
    -- if dataset[i][3] == "L" then
        -- result["L"] = result["L"] + 1
    -- else
        -- result["M"] = result["M"] + 1
    -- end
-- end

-- print("Answer")
-- print(result["M"], result["L"])

-- error()

-- ************************************************

loadDataset()

-- assumes a standard format of x predictors and then the label and then a new column will be applied for distance calculations
numofpredictors = 2
labelcolumn = numofpredictors + 1
distcolumn = labelcolumn + 1
k = 5

-- get the min/max for each predictor
colmin = {}
colmax = {}
-- initialise the min/max
for i = 1, numofpredictors do
	colmin[i] = nil		-- eg colmin[1] = 999; colmin[2] = 999 etc
	colmax[i] = nil
end
-- determine min/max
for i = 1, #dataset do
	for j = 1, numofpredictors do
		local predictor = dataset[i][j]
		if colmin[j] == nil then colmin[j] = predictor end
		if colmax[j] == nil then colmax[j] = predictor end

		if predictor > colmax[j] then colmax[j] = predictor end
		if predictor < colmin[j] then colmin[j] = predictor end
	end
end

-- normalise the dataset
for i = 1, #dataset do
	for j = 1, numofpredictors do
		dataset[i][j] = cf.round((dataset[i][j] - colmin[j]) / (colmax[j] - colmin[j]), 2)
	end
end

-- normalise the input
-- if numofpredictors = x then the input needs to have x features/predictors
inputset = {161, 61}	--! might need to preserve this and copy to a new table
for j = 1, numofpredictors do
	inputset[j] = cf.round((inputset[j] - colmin[j]) / (colmax[j] - colmin[j]), 2)
end

-- compute distance between input and every dataset item
for i = 1, #dataset do
	local dist = cf.getDistanceV(inputset, dataset[i])
	dataset[i][distcolumn] = cf.round(dist, 2)		-- store the distance in the last column
end

-- sort the table based on the last column (distance)
table.sort(dataset, function(k1, k2) return k1[distcolumn] < k2[distcolumn] end)

print(inspect(dataset))

-- can now determine result
result = {}
-- add up the number of occurances in the top k data items
for i = 1, k do
	local label = dataset[i][labelcolumn]
	if result[label] == nil then result[label] = 0 end		-- initial result
	result[label] = result[label] + 1
end

print("*********")
print(inspect(result))

-- determine which label got the most 'hits'
table.sort(result, function(a, b) return a[1] < b[1] end)

print("*********")
print(inspect(result))

-- here is the prediction
print("************")
local maxlabelcount = 0
local maxlabelname = ""
print("Prediction")
for k, v in pairs(result) do
	if v > maxlabelcount then
		maxlabelcount = v
		maxlabelname = k
	end
end
print(maxlabelname, maxlabelcount)
print("************")
