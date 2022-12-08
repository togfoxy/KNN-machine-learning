
inspect = require 'inspect'

cf = require 'commonfunctions'

dataset = {}

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

-- normalise the data, including the query data
col1min = 999
col2min = 999
col1max = 0
col2max = 0
for i = 1, #dataset do
    if dataset[i][1] > col1max then col1max = dataset[i][1] end
    if dataset[i][1] < col1min then col1min = dataset[i][1] end

    if dataset[i][2] > col2max then col2max = dataset[i][2] end
    if dataset[i][2] < col2min then col2min = dataset[i][2] end
end
for i = 1, #dataset do
    dataset[i][1] =cf.round( (dataset[i][1] - col1min) / (col1max - col1min) , 2)
    dataset[i][2] =cf.round( (dataset[i][2] - col2min) / (col2max - col2min) , 2)
end

val1 = 161
val2 = 61

val1normalised = cf.round( (val1 - col1min) / (col1max - col1min) , 2)
val2normalised = cf.round( (val2 - col2min) / (col2max - col2min) , 2)

print(inspect(dataset))

for i = 1, #dataset do
    local dist = cf.getDistance(val1normalised, val2normalised, dataset[i][1], dataset[i][2])
    dataset[i][4] = cf.round(dist, 1)
end

table.sort(dataset, function(k1, k2) return k1[4] < k2[4] end)

result = {}
result["L"] = 0
result["M"] = 0
k = 5

for i = 1, k do
    print(dataset[i][1], dataset[i][2], dataset[i][3], dataset[i][4])
    if dataset[i][3] == "L" then
        result["L"] = result["L"] + 1
    else
        result["M"] = result["M"] + 1
    end
end

print("Answer")
print(result["M"], result["L"])
