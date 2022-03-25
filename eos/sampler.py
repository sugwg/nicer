import numpy as np
from scipy import interpolate
from scipy import integrate

import tov


# Read the lower boundary of the low-density EoS
f= np.loadtxt('EFT_limits/EOSCEFTfull_ChEFTTPE_-1_032.dat')

n_low = f[:,0]
p_low = f[:,1]
eps_low = f[:,2]



# Read the upper boundary of the low-density EoS
f= np.loadtxt('EFT_limits/EOSCEFTfull_ChEFTVE1_1_032.dat')

n_high = f[:,0]
p_high = f[:,1]
eps_high = f[:,2]


n = n_low # = n_high

diff_eps = eps_high - eps_low
diff_p = p_high - p_low



def sample_eos(alpha,c2_ext_grid,n_ext_grid):
    '''
    Requires as input:
        1. A parameter alpha that determines the EoS up to 2*n_sat
        2. For the high-density extrapolation, a grid of values for the sound speed
        3. The number density grid corresponding to the above sound-speed grid.
        
    Outputs the neutron star mass-radius curve. 
    '''
    

    # Construct the interpolated EoS in between the upper and lower boundaries 
    eps_new = eps_low + alpha * diff_eps
    p_new = p_low + alpha * diff_p    
    mu_new = (p_new + eps_new)/n
    
    
    spl = interpolate.splrep(eps_new, p_new )
    c2_new = interpolate.splev(eps_new, spl, der=1)   # Compute the sound speed of the interpolated EoS
    
    c2_ext_grid[0] = c2_new[-1]    # Fixes the sound speed at 2*n_sat as determined by the interpolated EoS 
    
    mu_ext_grid = np.zeros_like(n_ext_grid)   # Empy grid for the chemical potential corresponding to n_ext_grid
    mu_ext_grid[0] =  mu_new[-1]
    
    
    # Creates grides of 50 points in between two points in n_ext_grid
    num=50  
    n_ext = np.array (  [np.linspace(n_ext_grid[i],n_ext_grid[i+1],endpoint=False,num=num) for i in range(n_ext_grid.size-1)] )
    c2_ext = np.zeros_like(n_ext)
    mu_ext = np.zeros_like(n_ext)
    
    
    # Integrates the sound speed to compute the chemical potential
    # Fills in all elements of mu_ext
    for i in range(n_ext_grid.size-1):
            slope = (c2_ext_grid[i+1] - c2_ext_grid[i] )/(n_ext_grid[i+1] - n_ext_grid[i])
            
            c2_ext[i,:] =  slope * (n_ext[i,:] - n_ext_grid[i])   +  c2_ext_grid[i] 
            
            mu_ext_grid[i+1] =   mu_ext_grid[i] * np.exp(  slope*( n_ext_grid[i+1] - n_ext_grid[i] - n_ext_grid[i]*np.log(n_ext_grid[i+1]/n_ext_grid[i])   )  +  c2_ext_grid[i]*np.log(n_ext_grid[i+1]/n_ext_grid[i]) ) 
    
            mu_ext[i,:] =   mu_ext_grid[i] * np.exp(  slope*( n_ext[i,:] - n_ext_grid[i] - n_ext_grid[i]*np.log(n_ext[i,:]/n_ext_grid[i])   )  +  c2_ext_grid[i]*np.log(n_ext[i,:]/n_ext_grid[i]) ) 
    
            
    
    n_ext = n_ext.flatten()
    c2_ext = c2_ext.flatten()
    mu_ext = mu_ext.flatten()
    
    # Integrates to obtain the energy density and pressure
    eps_ext = integrate.cumulative_trapezoid(mu_ext, n_ext, initial=0) + eps_new[-1]
    p_ext = mu_ext* n_ext  - eps_ext
    
    # Full EoS with low-density and high-density appended together
    n_full = np.append(n,n_ext)
    c2_full = np.append(c2_new,c2_ext)
    eps_full = np.append(eps_new,eps_ext)
    p_full = np.append(p_new,p_ext)
    
    # Compute the mass and radius by solving the TOV
    radius, mass = tov.tov_solve(eps_full,p_full)
    
    return radius, mass

    

    



