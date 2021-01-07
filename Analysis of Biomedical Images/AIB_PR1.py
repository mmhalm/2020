# -*- coding: utf-8 -*-
"""
Created on Sat May  9 18:45:01 2020

@author: Mona
"""

import numpy as np
import cv2
from matplotlib import pyplot as plt


BN12c = cv2.imread("BN_12_2.5.BMP")
BN15c = cv2.imread("BN_15_1.BMP")
BN19c = cv2.imread("BN_19_1.BMP")
BN24c = cv2.imread("BN_024_1.1.jpg")
BN56c = cv2.imread("BN_056_3.jpg")
BN58c = cv2.imread("BN_058_2.jpg")
BT03c = cv2.imread("BT_03_1.BMP")
BT04c = cv2.imread("BT_04_1.BMP")
BT12c = cv2.imread("BT_12_2.5.BMP")
BT13c = cv2.imread("BT_13_2.BMP")

# cat1= [BN15c, BN19c, BN24c, BT03c, BT04c]
# cat2= [BN58c, BT13c]
# cat25= [BN12c, BT12c]
# cat3= [BN56c]

imgOrderedC = [BN15c, BN19c, BN24c, BT03c, BT04c, BN58c, BT13c, BN12c , BT12c, BN56c]

category1 = []
category2 = []
category3 = []


for img in imgOrderedC:
    
    im_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) 
    im_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    im4 = im_hsv*1

    roiHSV = im4[192:576, 256:768] 
    
    lower_red2 = np.array([0,80,0])
    upper_red2 = np.array([10,220,255])
    mask2Roi = cv2.inRange(roiHSV, lower_red2, upper_red2)
    
    im = im_gray*1
    cv2.rectangle(im, (256, 192), (768, 576), (0, 0, 255), 5)
    
    f, ax = plt.subplots(1,3)
    ax[0].imshow(im, cmap='gray')
    ax[1].imshow(roiHSV)
    ax[2].imshow(mask2Roi)
    plt.show()
    
    zeros = 0
    maxs = 0
    
    for i in mask2Roi:
        x = list(i)
        
        for r in x:
            if r == "0" or r == 0:
                zeros += 1
            elif r == "255" or r == 255:
                maxs += 1
    print("0:",zeros)
    print("255:",maxs)
    
    ratio = maxs / zeros
    
    print("ratio: ", ratio)
    
    if ratio <= 0.1:
        category1.append(img)
    elif ratio > 0.1 and ratio < 0.7:
        category2.append(img)
    elif ratio >= 0.7:
        category3.append(img)
        
    
    
    
    