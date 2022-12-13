
knn = require 'lib.knn'

local dataset = {}
dataset = knn.readFromCSV("iris.csv")
local k = 15
local label, count = knn.getPrediction({5.0,4.5,2.6,2.2}, dataset, k)
print("The input most likely has the class " .. label .. " with a confidence of " .. (count/k) * 100 .. "%.")
