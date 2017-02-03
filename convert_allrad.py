# this script converts an allrad file for 3dhst objects to something more useable

import numpy as np

imagename = np.loadtxt("allrad.0.5.20.dat",dtype=str,usecols=[0], converters = {0: lambda x : x.decode()})
pixsize = np.loadtxt("allrad.0.5.20.dat",usecols=[1])
field = []
fieldid = []
for i,name in enumerate(imagename):
    idlist = name.split("_")[-3:]
    field.append(idlist[0])
    fieldid.append(idlist[1])

with open("allrad.dat",'w') as output:
    output.write("#field id half_light_pix \n")
    for i in range(len(field)):
        line = field[i] + ' ' + fieldid[i] + ' ' + str(pixsize[i]) + '\n'
        output.write(line)

