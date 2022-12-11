
knn = require 'lib.knn'

dataset = {}
dataset = knn.readFromCSV("iris.csv")
local label, count = knn.getPrediction({4.7,3.2,1.3,0.2}, dataset, 15)

print (label, count)
