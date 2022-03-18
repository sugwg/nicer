#!/usr/bin/env python

from __future__ import print_function, division

import numpy as np
import math
print("importing xpsi ...")
import xpsi
print("successfully imported xpsi")
print('Rank reporting: %d' % xpsi._rank)

from CustomData import CustomData
from CustomInstrument import CustomInstrument
from CustomInterstellar import CustomInterstellar
from CustomPulse import CustomPulse
from CustomSpacetime import CustomSpacetime
from CustomPrior import CustomPrior
from CustomPhotosphere import CustomPhotosphere

data = CustomData.from_SWG('/srv/<nicer_path>/A_NICER_VIEW_OF_PSR_J0030p0451/data/NICER_J0030_PaulRay_fixed_evt_25to299__preprocessed.txt', 1936864.0)

NICER = CustomInstrument.from_SWG(num_params=3,
                    bounds=[(0.5,1.5),(0.0,1.0),(0.5,1.5)],
                    ARF = '/srv/<nicer_path>/A_NICER_VIEW_OF_PSR_J0030p0451/model_data/ni_xrcall_onaxis_v1.02_arf.txt',
                    RMF = '/srv/<nicer_path>/A_NICER_VIEW_OF_PSR_J0030p0451/model_data/nicer_upd_d49_matrix.txt',
                    ratio = '/srv/<nicer_path>/A_NICER_VIEW_OF_PSR_J0030p0451/model_data/crab_ratio_SA80_d49.txt',
                    max_input=700,
                    min_input=0,
                    chan_edges = '/srv/<nicer_path>/A_NICER_VIEW_OF_PSR_J0030p0451/model_data/nicer_upd_energy_bounds.txt')

interstellar = CustomInterstellar.from_SWG('/srv/<nicer_path>/A_NICER_VIEW_OF_PSR_J0030p0451/model_data/interstellar_phot_frac.txt',
                                           num_params = 1,
                                           bounds = [(0.0, 5.0)])

pulse = CustomPulse(tag = 'all',
                    num_params = 2,
                    bounds = [(0.35, 0.55), (-0.25,0.75)],
                    data = data,
                    instrument = NICER,
                    interstellar = interstellar,
                    energies_per_interval = 0.25,
                    fast_rel_energies_per_interval = 0.5,
                    default_energy_spacing = 'logspace',
                    adaptive_energies = False,
                    adapt_exponent = None,
                    store = False,
                    workspace_intervals = 1000,
                    epsrel = 1.0e-8,
                    epsilon = 1.0e-3,
                    sigmas = 10.0)

from xpsi.global_imports import _c, _G, _M_s, _dpr, gravradius

bounds = [(0.235, 0.415),
          (1.0, 3.0),
          (3.0 * gravradius(1.0), 16.0),
          (0.001, math.pi/2.0)]

spacetime = CustomSpacetime(num_params = 4, bounds = bounds, S = 1.0/(4.87e-3))

bounds = [(0.001, math.pi - 0.001),
          (0.001, math.pi/2.0 - 0.001),
          (5.1, 6.8)]

primary = xpsi.Spot(num_params=3, bounds=bounds,
                    symmetry=True,
                    hole=False,
                    cede=False,
                    concentric=False,
                    sqrt_num_cells=24,
                    min_sqrt_num_cells=10,
                    max_sqrt_num_cells=64,
                    do_fast=False,
                    fast_sqrt_num_cells=8,
                    fast_min_sqrt_num_cells=8,
                    fast_max_sqrt_num_cells=16,
                    fast_num_leaves=32,
                    fast_num_rays=100,
                    num_leaves=80,
                    num_rays=200)

bounds = [(0.001, math.pi - 0.001),
          (0.001, math.pi/2.0 - 0.001),
          (0.001, math.pi - 0.001),
          (0.0, 2.0),
          (0.0, 2.0*math.pi),
          (5.1, 6.8)]

secondary = xpsi.Spot(num_params=6, bounds=bounds,
                      symmetry=True,
                      hole=True,
                      cede=False,
                      concentric=False,
                      sqrt_num_cells=24,
                      min_sqrt_num_cells=10,
                      max_sqrt_num_cells=64,
                      do_fast=False,
                      fast_sqrt_num_cells=8,
                      fast_min_sqrt_num_cells=8,
                      fast_max_sqrt_num_cells=16,
                      fast_num_leaves=32,
                      fast_num_rays=100,
                      num_leaves=80,
                      num_rays=200,
                      is_secondary=True)

from xpsi import TwoSpots

spot = TwoSpots((primary, secondary))

photosphere = CustomPhotosphere(num_params = 0, bounds = [],
                                tag = 'all', spot = spot, elsewhere = None)

photosphere.spot_atmosphere = '/srv/<nicer_path>/A_NICER_VIEW_OF_PSR_J0030p0451/model_data/nsx_H_v171019.out'

star = xpsi.Star(spacetime = spacetime, photospheres = photosphere)

likelihood = xpsi.Likelihood(star = star, pulses = pulse, threads=1)

prior = CustomPrior(bounds=likelihood.bounds, spacetime=spacetime)

likelihood.prior = prior

import time

p = [0.328978844399083370E+00,
        0.140337033600940120E+01,
        0.133784624585842025E+02,
        0.100434973113637094E+01,
        0.219377527309307840E+01,
        0.791608842011687908E-01,
        0.610655622382022134E+01,
        0.271629852479304956E+01,
        0.322342254787806259E+00,
        0.274633014642517770E+01,
        0.284416965175110226E+00,
        -0.483260905056053860E-01,
        0.611730491798804454E+01,
        0.460499862995095377E+00,
        0.103356827187160971E+01,
        0.222710719836020192E-01,
        0.874856631973894849E+00,
        0.454255509351488285E+00,
        0.476829413031657379E+00]

t = time.time()
ll = likelihood(p) # OptiPlex: ll = -36316.354394388654
print('p: ', ll, time.time() - t)

runtime_params = {'resume': False,
                  'importance_nested_sampling': False,
                  'multimodal': False,
                  'n_clustering_params': None,
                  'outputfiles_basename': '/srv/<nicer_path>/<output_directory>/run1_nlive1000_eff0.3_noCONST_noMM_noIS_tol-1',
                  'n_iter_before_update': 100,
                  'n_live_points': 1000,
                  'sampling_efficiency': 0.3,
                  'const_efficiency_mode': False,
                  'wrapped_params': [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1],
                  'evidence_tolerance': 0.1,
                  'max_iter': -1,
                  'verbose': True}

xpsi.Sample.MultiNest(likelihood, prior, **runtime_params)
