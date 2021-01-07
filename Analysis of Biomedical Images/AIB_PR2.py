# -*- coding: utf-8 -*-
"""
Created on Wed May 20 09:49:25 2020

@author: Mona
"""

import numpy as np
import cv2
import matplotlib.pyplot as plt
import os                           # for load_images_from_folder
import random                       # for randomOrderContours(conts, im)
 
def load_images_from_folder(folder):
    images = []
    for filename in os.listdir(folder):
        img = cv2.imread(os.path.join(folder,filename), cv2.IMREAD_GRAYSCALE)
        if img is not None:
            images.append(img)
    return images


def modification1(im):    
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
    cl1 = clahe.apply(im) 
    thrOtsu, dstOtsu = cv2.threshold(cl1, 0 ,200, cv2.THRESH_BINARY+cv2.THRESH_OTSU)   
    er = cv2.morphologyEx(dstOtsu, cv2.MORPH_OPEN, np.ones((17,17)))   
    contours, hierarchy = cv2.findContours(er, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    return contours

def alt1(im):
    adaptThr = cv2.adaptiveThreshold(im, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 141, 5)
    er = cv2.morphologyEx(adaptThr, cv2.MORPH_OPEN, np.ones((3,3)))
    contours, hierarchy = cv2.findContours(er, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    return contours

def modification2(im):    
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
    cl1 = clahe.apply(im)
    thrOtsu, dstOtsu = cv2.threshold(cl1, 0 , 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)   
    er = cv2.morphologyEx(dstOtsu, cv2.MORPH_OPEN, np.ones((5,5)))   
    contours, hierarchy = cv2.findContours(er, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    return contours

def alt2(im):
    # difference is the thresh binary INV
    adaptThr = cv2.adaptiveThreshold(im, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY_INV, 141, 5)
    er = cv2.morphologyEx(adaptThr, cv2.MORPH_OPEN, np.ones((3,3)))
    contours, hierarchy = cv2.findContours(er, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    return contours


# for randomising the order of contours in case the lung contours are not one after another
# basically the same thing as forLungs1 but with the contour order randomised
def randomOrderContours(conts, im):
        random.shuffle(conts)
        lastRatio = 0.0  
        lastContour = []
        lungContour = []
        img = im *1
        we, he = im.shape
        imSize = we*he  
        for i in conts:
            area = cv2.contourArea(i)
            ratio = area/imSize  
            if lastRatio != 0 and ((lastRatio*0.5) < ratio < (lastRatio*1.8)):  
                lungContour.append(lastContour)
                lungContour.append(i) 
                print("lungs ratio(area/image size):", (lastRatio + ratio))
                cont= cv2.drawContours(img, lungContour, -1, (0,255,0), 3)
                plt.imshow(cont, cmap='gray')
                plt.show()
            if 0.14 < ratio < 0.25:   # this is the case for most contours with boths lungs
                lungContour.append(i)   
                print("lungs ratio(area/image size):", ratio)
                cont= cv2.drawContours(img, lungContour, -1, (0,255,0), 3)
                plt.imshow(cont, cmap='gray')
                plt.show() 
            lastRatio = ratio
            lastContour = i
        return lungContour
                
def showContouredAreas(contours, im):
    img = im*1
    imgg = im*1
    masks = []
    for cnt in contours:
        mask = np.zeros(img.shape,np.uint8)
        cv2.drawContours(mask,[cnt],0,255,-1)
        masks.append(mask)
    if len(masks)>1:
        totalMask = masks[0] + masks[1]
        res1 = cv2.bitwise_and(imgg, imgg, mask=totalMask)
        plt.imshow(res1, cmap='gray')
        plt.show()
    elif len(masks) ==1:
        res1 = cv2.bitwise_and(imgg, imgg, mask=mask)
        plt.imshow(res1, cmap='gray')
        plt.show()
    return res1
        
def forLungs1(lungs1):
    count=1
    justLungs1 = []
    for im in lungs1:
        print(count)
        we, he = im.shape
        imSize = we*he
        lungContour = []
        contours = modification1(im)
        if len(contours)<=1:
            contours = alt1(im)   
        lastRatio = 0.0  
        lastContour = []
        img = im *1
        conts = []      #this is accessed only if there's an error
        for i in contours:
            area = cv2.contourArea(i)
            ratio = area/imSize # use ratio for code so if images are different size it doesn't matter
            # the ratios were determined by seeing which ratios correspond to lungs and 
            # which to the outlines
            if ratio >= 0.012 and ratio <= 0.45:     # these values have been chosen especially for this dataset
                conts.append(i)
                if lastRatio != 0 and ((lastRatio*0.5) < ratio < (lastRatio*1.8)):  
                    lungContour.append(lastContour)
                    lungContour.append(i) 
                    print("lungs ratio(area/image size):", (lastRatio + ratio))
                    cont= cv2.drawContours(img, lungContour, -1, (0,255,0), 3)
                    plt.imshow(cont, cmap='gray')
                    plt.show()
                if 0.14 < ratio < 0.25:   # this is the case for most contours with boths lungs
                    lungContour.append(i)   
                    print("lungs ratio(area/image size):", ratio)
                    cont= cv2.drawContours(img, lungContour, -1, (0,255,0), 3)
                    plt.imshow(cont, cmap='gray')
                    plt.show() 
                lastRatio = ratio
                lastContour = i
                
        while len(lungContour) == 0:
            lungContour = randomOrderContours(conts, im)       
        justLungs1.append(showContouredAreas(lungContour, im))
        count+=1
    return justLungs1
    
def forLungs2(imgs):
    count=1
    justLungs2 = []
    for im in imgs:
        print(count)
        we, he = im.shape
        imSize = we*he
        lungContour = []
        contours = modification2(im)
        if count == 2 or count == 4:  # these images had problems with normal modification
            contours = alt2(im)
        lastRatio = 0.0  
        lastContour = []
        img = im *1
        #conts = []      #this is accessed only if there's an error (with the order of contours)
        for i in contours:
            area = cv2.contourArea(i)
            ratio = area/imSize # use ratio for code so if images are different size it doesn't matter
            if 0.65 > ratio > 0.055:       # the value is chosen by finding the lowest ratio (of the smallest lung)
                #conts.append(i)
                if lastRatio != 0 and ((lastRatio*0.5) < ratio < (lastRatio*1.8)):  
                    lungContour.append(lastContour)
                    lungContour.append(i) 
                    print("lungs ratio(area/image size):", (lastRatio + ratio))
                    cont= cv2.drawContours(img, lungContour, -1, (0,255,0), 2)
                    plt.imshow(cont, cmap='gray')
                    plt.show()
                lastRatio = ratio
                lastContour = i
        #while len(lungContour) == 0:
            #lungContour = randomOrderContours(conts, im)
        justLungs2.append(showContouredAreas(lungContour, im))
        count+=1
    return justLungs2

        
lungs1 = load_images_from_folder('Lungs/1')
lungs2 = load_images_from_folder('Lungs/2')

croppedLungs1 = forLungs1(lungs1)   
croppedLungs2 = forLungs2(lungs2)
