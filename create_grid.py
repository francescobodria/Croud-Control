import numpy as np
from scipy.spatial.distance import euclidean
from scipy.spatial.distance import cityblock
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import math 

n1 = int(input('insert x dimension:'))
n2 = int(input('insert y dimension:'))
e1 = int(input('insert exit dimension:'))

index=np.zeros([n2,n1])
k=1
for i in range(n2):
	for j in range(n1):
		index[i,j]=k
		k+=1
exit_index=[]

cella_uscita=np.zeros([n2,n1])
data = np.zeros([n2,n1])
exit_coord = dict(zip(list(map(str,range(6))), [[] for i in range(6)]))

data[:,0] = np.ones([1,n2])

data[1:e1+1,0] = np.ones([1,e1])*2
cella_uscita[1:e1+1,0] = index[1:e1+1,0] 
for i in range(1,e1+1):
	exit_coord['0'].append([i,0])
	exit_index.append(index[i,0])

data[n2-1-e1:n2-1,0] = np.ones([1,e1])*2
cella_uscita[n2-1-e1:n2-1,0] = index[n2-1-e1:n2-1,0]
for i in range(n2-1-e1,n2-1):
	exit_coord['1'].append([i,0])
	exit_index.append(index[i,0])

data[:,-1] = np.ones([1,n2])

data[1:e1+1,n1-1] = np.ones([1,e1])*2
cella_uscita[1:e1+1,n1-1] = index[1:e1+1,n1-1]
for i in range(1,e1+1):
	exit_coord['2'].append([i,n1-1])
	exit_index.append(index[i,n1-1])

data[n2-1-e1:n2-1,n1-1] = np.ones([1,e1])*2
cella_uscita[n2-1-e1:n2-1,n1-1] = index[n2-1-e1:n2-1,n1-1]
for i in range(n2-1-e1,n2-1):
	exit_coord['3'].append([i,n1-1])
	exit_index.append(index[i,n1-1])

data[0,:] = np.ones([1,n1])

data[0,n1//2-e1//2:n1//2-e1//2+e1]=np.ones([1,e1])*2
cella_uscita[0,n1//2-e1//2:n1//2-e1//2+e1]=index[0,n1//2-e1//2:n1//2-e1//2+e1]
for i in range(n1//2-e1//2,n1//2-e1//2+e1):
	exit_coord['4'].append([0,i])
	exit_index.append(index[0,i])

data[-1,:] = np.ones([1,n1])

data[-1,n1//2-e1//2:n1//2-e1//2+e1]=np.ones([1,e1])*2
cella_uscita[-1,n1//2-e1//2:n1//2-e1//2+e1]=index[-1,n1//2-e1//2:n1//2-e1//2+e1]
for i in range(n1//2-e1//2,n1//2-e1//2+e1):
	exit_coord['5'].append([n2-1,i])
	exit_index.append(index[n2-1,i])

#print(exit_index)
#print(exit_coord)
#print(data)
np.savetxt("./includes/mappa.csv", data, delimiter=",",fmt='%d')

#print(exit_coord)

l=0
distanza_uscita=np.zeros([n2,n1])

for i in range(n2):
	for j in range(n1):
		if data[i,j]==0:
			m = []
			for k in range(6):
			#	for l in range(e1):
			#		m.append(euclidean([i,j],exit_coord[str(k)][l]))
				m.append(euclidean([i,j],exit_coord[str(k)][len(exit_coord[str(k)])//2]))
			distanza_uscita[i,j]=min(m)
			cella_uscita[i,j]=exit_index[np.argmin(m)]

		elif data[i,j]==1:
			distanza_uscita[i,j]=-1
			cella_uscita[i,j]=-1

#print(distanza_uscita)
np.savetxt("./includes/distanza_uscita.csv", distanza_uscita, delimiter=",",fmt='%1.2f')
#print(cella_uscita)
np.savetxt("./includes/numero_uscita.csv", cella_uscita, delimiter=",",fmt='%d')

#fig = plt.figure()
#plt.contourf(distanza_uscita)
#plt.yticks(np.arange(0, n2, 1.0))
#plt.colorbar()
#plt.grid()
#ax = Axes3D(fig)
#X = np.arange(0, n1, 1)
#Y = np.arange(0, n2, 1)
#X, Y = np.meshgrid(X, Y)
#ax.plot_surface(X, Y, distanza_uscita, rstride=1, cstride=1, cmap=cm.viridis)
#plt.show()























