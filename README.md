# KNN-machine-learning

This is a Lua (love2d) implementation of KNN algorithm often used in supervised machine learning. This code currently does categorisation only and not regression.

See main.lua for an example of how to use.

Assumptions
===========

The dataset is in a CSV file in the same folder as main.lua but this can be changed if you provide a file path (untested).

CSV format example:

6.3,2.7,4.9,1.8,Iris-virginica

The dataset can have any number of predictors or features. This code assumes the last item is the classifier/label.

Output
======
The KNN function returns two variables:

- the classifier/label that has the strongest association with the input set

- the count or number of instances of that classifier was associated with the input set. This is essentially the level of confidence in the prediction.

Credits
-------
wolfoops, zorg, Jasoco

Contact me for bugs or defects or suggestions for improvements

MIT licence
