import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit


def func(t,alpha,sfmax):
  return sfmax/(1.+(sfmax*2.-1.)*np.exp(-alpha*sfmax*t))


# read data
filename='../data/sf_data.dat'
sf=np.fromfile(filename,dtype=np.float32).reshape(15,-1)

sf=np.where(sf>0.,sf,np.nan)


growth=np.zeros(15)
sf_max=np.zeros(15)
for i in np.arange(0,15):
  x=np.arange(0,2399)
  y=sf[i,0:2399]

  x=x[y>=0.]
  y=y[y>=0.]

  popt, pcov = curve_fit(func,x,y,bounds=(0,[0.5,1.]))
  growth[i]=popt[0]
  sf_max[i]=popt[1]

  #print(popt)
  #plt.plot(x,func(x,*popt),x,y)
  #plt.show()


growth=growth.reshape(3,5)
sf_max=sf_max.reshape(3,5)

print(np.mean(growth,axis=1))
print(np.mean(sf_max,axis=1))


