knn = {}

local k = 3     -- default value

function round(val, decimal)
	-- rounding function provided by zorg and Jasoco
	if not val then return 0 end
	if (decimal) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

function getDistanceV(inputset, datapoint)
	-- accepts a variable number of arguments reflecting 2 datapoints on multiple axis (e.g. x,y,z and q,w,e)
	-- NOTE: multiple axis does not mean multiple datapoints! There are still only two datapoints.
	-- inputset eg {x,y,z}
	-- datapoint eg {q,w,e}

	local numaxis = #inputset

	-- split the args into each of the axis, remembering there are only two datapoints expressed across multiple axis
	-- sum the axis and then square those values, keep a sum of those values as we go
	local axis = {}
	local total = 0
	for i = 1, numaxis do
		axis[i] = (inputset[i] - datapoint[i])^2
		total = total + axis[i]
	end
	-- finally get the square root of that sum
	return math.sqrt(total)
end

function knn.ParseCSVLine (line,sep)
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
function knn.readFromCSV(file)
	-- if not file_exists(file) then return {} end
	local lines = {}
	for line in io.lines(file) do
		local thisline = knn.ParseCSVLine (line,",")
		if #thisline > 0 then	-- this will trim blank lines
			lines[#lines + 1] = knn.ParseCSVLine (line,",")
		end
	end
	return lines
end

function knn.getPrediction(inputset, dataset, kvalue)
    local k = kvalue
    -- assumes a standard format of x predictors and then the label and then a new column will be applied for distance calculations
    -- the new column does not need to be passed in
    local numofpredictors = #inputset
    local labelcolumn = numofpredictors + 1
    local distcolumn = labelcolumn + 1

    -- get the min/max for each predictor
    local colmin = {}
    local colmax = {}

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
    		dataset[i][j] = round((dataset[i][j] - colmin[j]) / (colmax[j] - colmin[j]), 2)
    	end
    end

    -- normalise the input
    -- if numofpredictors = x then the input needs to have x features/predictors
    for j = 1, numofpredictors do
    	inputset[j] = round((inputset[j] - colmin[j]) / (colmax[j] - colmin[j]), 2)
    	print(inputset[j])
    end

    -- compute distance between input and every dataset item
    for i = 1, #dataset do
    	local dist = getDistanceV(inputset, dataset[i])
    	dataset[i][distcolumn] = round(dist, 2)		-- store the distance in the last column
    end

    -- sort the table based on the last column (distance)
    table.sort(dataset, function(k1, k2) return k1[distcolumn] < k2[distcolumn] end)

    -- can now determine result
    result = {}
    -- add up the number of occurances in the top k data items
    for i = 1, k do
    	local label = dataset[i][labelcolumn]
    	if result[label] == nil then result[label] = 0 end		-- initial result
    	result[label] = result[label] + 1
    end

    -- determine which label got the most 'hits'
    table.sort(result, function(a, b) return a[1] < b[1] end)

    -- here is the prediction
    local incidences = 0
    local maxlabelname = ""
    for k, v in pairs(result) do
    	if v > incidences then
    		incidences = v
    		maxlabelname = k
    	end
    end

    return maxlabelname, incidences

end


return knn
