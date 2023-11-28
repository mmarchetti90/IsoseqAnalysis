#!/usr/bin/env python3

"""
This script parses the collapsed.read_stat.txt from isoseq collapse and read ids from individual samples and creates a flnc_counts file for pigeon classify
"""

### ---------------------------------------- ###

def generate_flnc_count(read_stats, read_ids):
    
    # List unique isoforms
    unique_isoforms = list(set(read_stats.pbid))
    
    # Init flnc_count data frame
    flnc_count = {}
    flnc_count['id'] = unique_isoforms
    for key in read_ids.keys():
        
        flnc_count[key] = [0 for _ in range(len(unique_isoforms))]
    
    flnc_count = pd.DataFrame(flnc_count, index=unique_isoforms)
    
    # For each sample, find isoforms, count them, then update flnc_count
    for key,reads in read_ids.items():
    
        key_isos = read_stats.loc[read_stats.id.isin(reads.values), ['pbid']]
        key_isos['counts'] = [1 for _ in range(key_isos.shape[0])]
        key_isos = key_isos.groupby(by='pbid').sum()
        
        flnc_count.loc[key_isos.index.to_list(), key] = key_isos.counts.to_list()
    
    # Convert to int
    col_dtypes = {}
    for col in flnc_count.columns:
        
        col_dtypes[col] = str if col == 'id' else int
    
    flnc_count = flnc_count.astype(col_dtypes)
    
    return flnc_count

### ------------------MAIN------------------ ###

import pandas as pd

from os import listdir

### Get input file lists

reads_ids_files = [file for file in listdir() if file.endswith('_reads_id.txt')]
reads_ids_files_names = [file.replace('_reads_id.txt', '') for file in reads_ids_files]
read_stats_file = [file for file in listdir() if file.endswith('.read_stat.txt')][0]

### Read files

read_stats = pd.read_csv(read_stats_file, header=0, sep='\t')

read_ids = {file_id : pd.Series(open(file).read().split('\n')) for file_id,file in zip(reads_ids_files_names, reads_ids_files)}

### Create flnc_count

flnc_count = generate_flnc_count(read_stats, read_ids)

### Write flnc_count to file

output_name = 'flnc_count.txt'
flnc_count.to_csv(output_name, index=False, sep=',')
