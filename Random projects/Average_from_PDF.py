# Calculates the grade average from a certain type of PDF transcript of records

from PyPDF2 import PdfFileReader
import re

# change the path to your ToR here
tor = "/Users/transcript.pdf"
pdf = PdfFileReader(tor)

def pdf2txt(pdf):
    with open('transcript.txt', 'w') as f:
        for page_num in range(pdf.numPages):
            pageObj = pdf.getPage(page_num)
    
            try: 
                txt = pageObj.extractText()
            except:
                pass
            else:
                f.write('Page {0}\n'.format(page_num+1))
                f.write(txt)
        f.close()

def searchInfo(word):
    match = re.search(r'\d{2}.\d{2}.\d{4}', word) #r'\d{1,2}\d{1}\d{1,3}\d{2}.\d{2}.\d{4}
    if match:
        spanStart=str(match)[24:26]
        spanStartStripped=spanStart.strip(",")
        grade="" 

        try:
            grade=int(word[(int(spanStartStripped)-1):(int(spanStartStripped))])
        except:
            pass
        else:
            return grade
    else:
        return ""

def textAnalysis():
    with open('transcript.txt', 'r') as t:
        lines=t.readlines()
        grades = []
        for j in lines:
            line=j.split()
            for word in line:
                gradeFound = searchInfo(word)
                if gradeFound != "" and gradeFound != None:
                    #print(word, "\n" , gradeFound)
                    grades.append(gradeFound)
    
    return grades

def getAverage(gradesList):
    total = 0
    length = 0
    for i in gradesList:
        total += int(i)
        length += 1
    
    average = total/length

    return (average, total, length)

pdf2txt(pdf)
grades=textAnalysis()
print(grades)
print(getAverage(grades))