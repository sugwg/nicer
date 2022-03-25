import numpy as np
import random
import matplotlib.pyplot as plt
from tqdm import tqdm

import sampler 

n_sat = 0.16

for i in tqdm(range(1000)):
    
    alpha =  random.uniform(0, 1)   # np.random.choice([0,0.5,1])
    n_ext_grid = np.array([2,3,4,5,6,7,8,9,10,11,12]) *n_sat
    c2_ext_grid = [random.uniform(0, 1) for i in n_ext_grid] 
    
    
    radius, mass = sampler.sample_eos(alpha,c2_ext_grid,n_ext_grid)
    
    plt.plot(radius,mass,color='black',alpha=0.1)
    
    
    
    
plt.xlim(right = 14)
plt.xlabel('Radius [km]',fontsize=14)
plt.ylabel('Mass [$M_{\odot}$]',fontsize=14)
plt.savefig('figures/M_R.pdf')
