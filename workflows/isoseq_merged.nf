
// ----------------Workflow---------------- //

include { PrepareRefs } from '../modules/pigeon/prepare_refs.nf'
include { Lima } from '../modules/lima/lima.nf'
include { Refine } from '../modules/refine/refine.nf'
include { GetReadIDs } from '../modules/read_ids/get_read_ids.nf'
include { MergeXml } from '../modules/merge_xml/merge_xml.nf'
include { Cluster } from '../modules/cluster/cluster_merged.nf'
include { Align } from '../modules/align/align_merged.nf'
include { Collapse } from '../modules/collapse/collapse_merged.nf'
include { MakeFlncCount } from '../modules/flnc_counts/make_flnc_counts.nf'
include { Classify } from '../modules/pigeon/classify_merged.nf'

workflow ISOSEQ_MERGED {

  main:
  
  // LOADING RESOURCES -------------------- //

  // Channel for the directory containing the scripts used by the pipeline
  Channel
    .fromPath("${projectDir}/scripts")
    .set{ scripts_dir }

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

  // GET READ IDS ------------------------- //

  GetReadIDs(Refine.out.refined_hifi)

  // MERGE REFINED XMLS ------------------- //

  MergeXml(scripts_dir, Refine.out.refined_xmls.collect())

  // CLUSTER READS ------------------------ //

  Cluster(MergeXml.out.merged_xml, Refine.out.refined_bams.collect())

  // MINIMAP2 ALIGNMENT ------------------- //

  Align(ref_fasta, Cluster.out.clustered_hifi)

  // COLLAPSE INTO UNIQUE ISOFORMS -------- //

  Collapse(MergeXml.out.merged_xml, Refine.out.refined_bams.collect(), Align.out.aligned_hifi, Align.out.aligned_hifi_index)

  // CREATE FLNC COUNTS ------------------- //

  MakeFlncCount(scripts_dir, GetReadIDs.out.read_ids.collect(), Collapse.out.read_stats)

  // PIGEON ------------------------------- //

  // Prepare references for Pigeon
  PrepareRefs(ref_fasta, gtf_annotation)

  // Classify transcripts with pigeon
  Classify(PrepareRefs.out.pigeon_ref, PrepareRefs.out.pigeon_ref_index, PrepareRefs.out.pigeon_gtf, PrepareRefs.out.pigeon_gtf_index, MakeFlncCount.out.flnc_count, Collapse.out.collapsed_gff)

}