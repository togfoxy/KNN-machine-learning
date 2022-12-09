
inspect = require 'inspect'
cf = require 'commonfunctions'

dataset = {}

function ParseCSVLine (line,sep)
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos)
				if (c == '"') then txt = txt..'"' end
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if (startp) then
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end
		end
	end
	return res
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function lines_from(file)
	-- if not file_exists(file) then return {} end
	local lines = {}
	for line in io.lines(file) do
		local thisline = ParseCSVLine (line,",")
		if #thisline > 0 then	-- this will trim blank lines
			lines[#lines + 1] = ParseCSVLine (line,",")
		end
	end
	return lines
end

-- function loadDataset()
-- 	-- table.insert(dataset, {158,58,"M", 0})
-- 	-- table.insert(dataset, {158,59,"M", 0})
-- 	-- table.insert(dataset, {158,63,"M", 0})
-- 	-- table.insert(dataset, {160,59,"M", 0})
-- 	-- table.insert(dataset, {160,60,"M", 0})
-- 	-- table.insert(dataset, {163,60,"M", 0})
-- 	-- table.insert(dataset, {163,61,"M", 0})
-- 	-- table.insert(dataset, {160,64,"L", 0})
-- 	-- table.insert(dataset, {163,64,"L", 0})
-- 	-- table.insert(dataset, {165,61,"L", 0})
-- 	-- table.insert(dataset, {165,62,"L", 0})
-- 	-- table.insert(dataset, {165,65,"L", 0})
-- 	-- table.insert(dataset, {168,62,"L", 0})
-- 	-- table.insert(dataset, {168,63,"L", 0})
-- 	-- table.insert(dataset, {168,66,"L", 0})
-- 	-- table.insert(dataset, {170,63,"L", 0})
-- 	-- table.insert(dataset, {170,64,"L", 0})
-- 	-- table.insert(dataset, {170,65,"L", 0})
--
-- 	table.insert(dataset, {5.1,3.5,1.4,0.2,"setosa"})
-- 	table.insert(dataset, {4.9,3.0,1.4,0.2,"setosa"})
-- 	table.insert(dataset, {4.7,3.2,1.3,0.2,"setosa"})
-- 	table.insert(dataset, {4.6,3.1,1.5,0.2,"num"})
-- 	table.insert(dataset, {5.0,3.6,1.4,0.2,"setosa"})
-- end

dataset = {}
-- loadDataset()
dataset = lines_from("iris.csv")
inputset = {4.7,3.2,1.3,0.2}

-- print("Dataset:")
-- print(inspect(dataset))
-- print("^^^^^^^^^^^^")

-- assumes a standard format of x predictors and then the label and then a new column will be applied for distance calculations
numofpredictors = #inputset
labelcolumn = numofpredictors + 1
distcolumn = labelcolumn + 1
k = 15

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
		if predictor == nil then
			print("Nil predictor detected.")
		else
			if colmin[j] == nil then colmin[j] = predictor end
			if colmax[j] == nil then colmax[j] = predictor end
			if predictor > colmax[j] then colmax[j] = predictor end
			if predictor < colmin[j] then colmin[j] = predictor end
		end
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
print("Normalised input:")
for j = 1, numofpredictors do
	inputset[j] = cf.round((inputset[j] - colmin[j]) / (colmax[j] - colmin[j]), 2)
	print(inputset[j])
end

-- compute distance between input and every dataset item
for i = 1, #dataset do
	local dist = cf.getDistanceV(inputset, dataset[i])
	dataset[i][distcolumn] = cf.round(dist, 2)		-- store the distance in the last column
-- print(dist)
end

-- sort the table based on the last column (distance)
table.sort(dataset, function(k1, k2) return k1[distcolumn] < k2[distcolumn] end)

print("Sorted dataset with distance")
print(inspect(dataset))

-- can now determine result
result = {}
-- add up the number of occurances in the top k data items
for i = 1, k do
	local label = dataset[i][labelcolumn]
	if result[label] == nil then result[label] = 0 end		-- initial result
	result[label] = result[label] + 1
end

-- print("*********")
-- print(inspect(result))

-- determine which label got the most 'hits'
table.sort(result, function(a, b) return a[1] < b[1] end)

-- print("*********")
-- print(inspect(result))

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
