#!/usr/bin/env python3

"""
This script merges xml files output from the refine step of the pipeline
A simple merging with cat won't do because the file path has to be trimmed
"""

### ---------------------------------------- ###

def create_header(info):
    
    # Generate unique id
    unique_id = create_unique_id()    
    id_check = lambda uid: sum([f'UniqueID="{uid}' in i['header'] for i in info])
    while id_check(unique_id) > 0:
        
        unique_id = create_unique_id()
    
    # Create header
    header = ['<pbds:ConsensusReadSet',
              'CreatedAt="2023-11-21T16:58:35.902Z"',
              'MetaType="PacBio.DataSet.ConsensusReadSet"',
              'Name="merged_dataSet"',
              'Tags=""',
              'TimeStampedName="merged_dataSet-231121_165835902"',
              f'UniqueId="{unique_id}"',
              'Version="3.0.1"',
              'xmlns="http://pacificbiosciences.com/PacBioDatasets.xsd"',
              'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',
              'xsi:schemaLocation="http://pacificbiosciences.com/PacBioDatasets.xsd"',
              'xmlns:pbbase="http://pacificbiosciences.com/PacBioBaseDataModel.xsd"',
              'xmlns:pbds="http://pacificbiosciences.com/PacBioDatasets.xsd">']
    
    header = ' '.join(header)
    
    return header

### ---------------------------------------- ###

def create_unique_id():
    
    alphanum = list('abcdefghijklmnopqrstuvwxyz0123456789')

    unique_id = []
    for k in (8, 4, 4, 12):
        
        block = ''.join(choices(population=alphanum, k=k))
        unique_id.append(block)
    
    unique_id = '-'.join(unique_id)
    
    return unique_id

### ---------------------------------------- ###

def parse_xml(xml_files):
    
    field_delimiters = {'header' : ('<pbds:ConsensusReadSet', '\n'),
                        'external_resources' : ('<pbbase:ExternalResources>', '</pbbase:ExternalResources>'),
                        'filters' : ('<pbds:Filters>', '</pbds:Filters>'),
                        'metadata' : ('<pbds:DataSetMetadata>', '</pbds:DataSetMetadata>'),
                        'datasets' : ('<pbds:DataSets>', '</pbds:DataSets>'),
                        'supplemental_resources' : ('<pbbase:SupplementalResources>', '</pbbase:SupplementalResources>')}

    parsed_xmls = []

    for xml in xml_files:
        
        xml_text = open(xml).read().replace('\t', '')
        
        # Init sample struct with whole dataset info
        sample_struct = {'dataset_info' : xml_text.replace('<?xml version="1.0" encoding="utf-8"?>\n', '')}
        
        # Look for specific fields
        for field,delims in field_delimiters.items():
            
            if delims[0] not in xml_text:
                
                field_text = ''
            
            else:
                
                start_index = xml_text.index(delims[0])
                stop_index = start_index + xml_text[start_index :].index(delims[1]) + len(delims[1])
                
                field_text = xml_text[start_index : stop_index]
                
                field_text = remove_full_path(field_text)
            
            sample_struct[field] = field_text
        
        parsed_xmls.append(sample_struct)
    
    return parsed_xmls

### ---------------------------------------- ###

def remove_full_path(txt):
    
    raw_txt = txt.split('\n')
    
    cleaned_txt = []
    
    for line in raw_txt:
        
        if 'ResourceId' in line:
    
            start_element = 'ResourceId="'
            start_index = line.index(start_element) + len(start_element)
            if '.bam"' in line[start_index :]:
                
                stop_element = '.bam"'
                
            elif '.bam.pbi"' in line[start_index :]:
                
                stop_element = '.bam.pbi"'
            
            else:
                
                stop_element = '" '
                
            stop_index = start_index + line[start_index :].index(stop_element) + len(stop_element)
            
            full_path = line[start_index : stop_index]
            basename = full_path.split('/')[-1]
            
            text_to_replace = f'{start_element}{full_path}'
            replacement_text = f'{start_element}{basename}'
            
            line = line.replace(text_to_replace, replacement_text)
            
            cleaned_txt.append(line)
        
        else:
            
            cleaned_txt.append(line)
            
    cleaned_txt = '\n'.join(cleaned_txt)
    
    return cleaned_txt

### ---------------------------------------- ###

def merge_metadata(metadata_list):
    
    # Total length
    start_element, stop_element = '<pbds:TotalLength>', '</pbds:TotalLength>'
    total_length = sum([int(ml[ml.index(start_element) + len(start_element) : ml.index(stop_element)]) for ml in metadata_list])
    
    # Num records
    start_element, stop_element = '<pbds:NumRecords>', '</pbds:NumRecords>'
    num_records = sum([int(ml[ml.index(start_element) + len(start_element) : ml.index(stop_element)]) for ml in metadata_list])
    
    merged_metadata = f'<pbds:TotalLength>{total_length}</pbds:TotalLength>\n<pbds:NumRecords>{num_records}</pbds:NumRecords>\n'
    
    return merged_metadata

### ------------------MAIN------------------ ###

from os import listdir
from random import choices

# Find xml files
xml_files = [file for file in listdir() if file.endswith('xml') and file != 'merged_refined_dataset.xml']

# Parse files
parsed_info = parse_xml(xml_files)

# Create header and footer
header = create_header(parsed_info)
footer = '</pbds:ConsensusReadSet>'

# Add fields
necessary_fields = {'external_resources' : ('<pbbase:ExternalResources>\n', '</pbbase:ExternalResources>'),
                    'dataset_info' : ('<pbds:DataSets>\n', '</pbds:DataSets>'),
                    'metadata' : ('<pbds:DataSetMetadata>\n', '</pbds:DataSetMetadata>')}
output_text = ['<?xml version="1.0" encoding="utf-8"?>', header]
for field,delims in necessary_fields.items():
    
    if field == 'external_resources':
        
        added_text = '\n'.join([delims[0]] +
                               [i[field].replace(delims[0], '').replace(delims[1], '') for i in parsed_info] +
                               [delims[1]])
    
    elif field == 'dataset_info':
        
        added_text = '\n'.join([delims[0]] +
                               [i[field] for i in parsed_info] +
                               [delims[1]])
    
    elif field == 'metadata':
        
        added_text = '\n'.join([delims[0],
                                merge_metadata([i[field] for i in parsed_info]),
                                delims[1]])
    
    else:
        
        continue

    output_text.append(added_text)

output_text.append(footer)

# Join lines
output_text = '\n'.join(output_text)

# Output merged xml
with open('merged_refined_dataset.xml', 'w') as output_file:
    
    output_file.write(output_text)
