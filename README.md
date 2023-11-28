# Isoseq analysis
## Dockerized Nextflow pipeline for PacBio long mRNA reads analysis with Isoseq and Pigeon

/// --------------------------------------- //

### RUN COMMAND:

nextflow run [OPTIONS] --reads_list_path "path/to/reads/list.tsv" main.nf

### OPTIONS: (See config file for more)

-profile

		If not specified or equal to "standard", which is equivalent to "single"

		If equal to "single", samples are processed separately during reads clustering.
		Use this option when analyzing samples from different species
		Note that the isoform names assigned by Pigeon will be sample-specific (i.e. PB.1.1 will
		mean different isoforms in different samples)

		If equal to "merged", samples are processed together during reads clustering
		Use this option when analyzing samples from same the species (can be different tissues)
		Unlike for "single" mode, the isoform names assigned by Pigeon will not be sample-specific

--reads_list_path

		Path to a tab-separated txt document with lines SampleID\tHiFi
		SampleID is a unique sample identifier
		HiFi is the full path to the CCS/HiFi bam file
		Note that paired-end files are reported in separate lines, but have same sample_id

--reference_fasta_path

		Path to Gencode genome fasta file

--gtf_annotation_path

		Path to Gencode genome annotation gtf

--primers_fasta_path

		Path to primers sequences in fasta format

/// --------------------------------------- ///

### DEPENDENCIES:

Nextflow 20.10+

Singularity 3.8.5+

Python 3.9.7+ &

	numpy
	pandas

isoseq3 4.0.0+

lima 2.9.0+

pbccs 6.4.0+

pbmm2 1.13.1+

pbpigeon 1.2.0+

pysam 0.22.0+

samtools 1.18+

/// --------------------------------------- ///

### NOTES:

- Docker image also contains pbccs to convert subreads to CCS/HiFi;

- Use the Python script scripts/plot_isoforms.py to plot isoforms and expression values for desired genes.
