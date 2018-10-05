import numpy as np

#input dimensioni della griglia
n1 = int(input('insert x dimension:'))
n2 = int(input('insert y dimension:'))
e1 = int(input('insert exit dimension:'))

#setto tutto a zero
data = np.zeros([n2,n1])

#setto i contorni a 1 e le uscite a 2
data[:,0] = np.ones([1,n2])
data[1:e1+1,0] = np.ones([1,e1])*2
data[n2-1-e1:n2-1,0] = np.ones([1,e1])*2

data[:,-1] = np.ones([1,n2])
data[1:e1+1,n1-1] = np.ones([1,e1])*2
data[n2-1-e1:n2-1,n1-1] = np.ones([1,e1])*2

data[0,:] = np.ones([1,n1])
data[0,n1//2-e1//2:n1//2-e1//2+e1]=np.ones([1,e1])*2

data[-1,:] = np.ones([1,n1])
data[-1,n1//2-e1//2:n1//2-e1//2+e1]=np.ones([1,e1])*2

#salva il file
np.savetxt("test.csv", data, delimiter=",",fmt='%d')