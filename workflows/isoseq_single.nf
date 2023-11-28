
// ----------------Workflow---------------- //

include { PrepareRefs } from '../modules/pigeon/prepare_refs.nf'
include { Lima } from '../modules/lima/lima.nf'
include { Refine } from '../modules/refine/refine.nf'
include { Cluster } from '../modules/cluster/cluster_single.nf'
include { Align } from '../modules/align/align_single.nf'
include { Collapse } from '../modules/collapse/collapse_single.nf'
include { Classify } from '../modules/pigeon/classify_single.nf'

workflow ISOSEQ_SINGLE {

  main:
  
  // LOADING RESOURCES -------------------- //

  // Loading reads list file
  Channel
    .fromPath("${params.reads_list_path}")
    .splitCsv(header: true, sep: '\t')
    .map{row -> tuple(row.SampleID, file(row.HiFi))}
    .set{ hifi_reads }

  // Load primers file for lima
  Channel
    .fromPath("${params.primers_fasta_path}")
    .set{ primers }

  // Load reference fasta
  Channel
    .fromPath("${params.reference_fasta_path}")
    .set{ ref_fasta }

  // Load gtf annotation
  Channel
    .fromPath("${params.gtf_annotation_path}")
    .set{ gtf_annotation }

  // LIMA --------------------------------- //

  Lima(primers, hifi_reads)

  // REFINE FILES ------------------------- //

  Refine(primers, Lima.out.trimmed_hifi)

  // CLUSTER READS ------------------------ //

  Cluster(Refine.out.refined_hifi)

  // MINIMAP2 ALIGNMENT ------------------- //

  Align(ref_fasta, Cluster.out.clustered_hifi)

  // COLLAPSE INTO UNIQUE ISOFORMS -------- //

  Collapse(Align.out.aligned_hifi)

  // PIGEON ------------------------------- //

  // Prepare references for Pigeon
  PrepareRefs(ref_fasta, gtf_annotation)

  Classify(PrepareRefs.out.pigeon_ref, PrepareRefs.out.pigeon_ref_index, PrepareRefs.out.pigeon_gtf, PrepareRefs.out.pigeon_gtf_index, Collapse.out.collapsed_gff)

}