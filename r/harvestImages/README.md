Harvesting fotos from Google Streetview
===========================

Why is this important?
---------------------

When classifying individual properties, it is essential to download good imagery from streetview. In the UK, the Google API is not terribly accurate in "pointing at the right building". We therefore have to find the optimal camera location and zoom levels ourselves. 


## Approach

1. Find centroid of polygon
2. Make call to Streetview Metadata API and find closest panorama
3. From that panorama, find all lines of sights to the building that are not obstructed by other buildings
4. Estimate direction of best "camera shot" and the optimal zoom level
5. Download picture from Streetview API

![fan](fan.png)
