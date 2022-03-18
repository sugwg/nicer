#!/usr/bin/env python

import matplotlib
matplotlib.use('Agg')

import numpy
import matplotlib.pyplot as plt

files = ['/home/chaitanya.afle/projects/nicer/output_single_machine/run_j0030.7098345.out', 
         '/home/chaitanya.afle/projects/nicer/j0030_analysis/logs/run_j0030.7098479.out', 
         '/home/chaitanya.afle/projects/nicer/j0030_analysis/logs/run_j0030.7098486.out', 
         '/home/chaitanya.afle/projects/nicer/j0030_analysis/logs/run_j0030.7098487.out']

labels = ['1 X 40 cores', '2 X 64 cores', '5 X 64 cores', '9 X 64 cores']

for index, filename in enumerate(files):
    print(index, filename)
    file = open(filename, 'r')
    Lines = file.readlines()
 
    lnz_list = []
    samples_list = []
    for line in Lines:
        if 'Nested Sampling ln(Z):' in line:
            try:
                lnz_list.append(float(line.split(':')[1]))
            except:
                print('omitting the first few lines')

        if 'Total Samples:' in line:
            try:
                samples_list.append(float(line.split(':')[1]))
            except:
                print('omitting the first few lines')

    samples_list = samples_list[(len(samples_list) - len(lnz_list)):]

    if index==0:
        plt.plot(samples_list[300:], lnz_list[300:], label=labels[index], lw=2, marker='o')
    else:
        plt.plot(samples_list[300:], lnz_list[300:], label=labels[index], lw=2)
# plt.yscale('log')
plt.xlabel('Total samples')
plt.ylabel('Nested Sampling ln(Z)')
plt.grid()
plt.legend(loc="lower right")
plt.savefig('job_progress.png', dpi=200, bbox_inches = "tight")
