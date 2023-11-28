process Cluster {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.clustering_reports}", mode: "copy", pattern: "*cluster_report.csv"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.clustering_reports}", mode: "copy", pattern: "*clustering.log"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.clusters_dir}", mode: "copy", pattern: "*.bam"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.clusters_dir}", mode: "copy", pattern: "*.pbi"

  input:
  path merged_xml
  path bams

  output:
  tuple val("merged"), path("merged_clustered.bam"), path("merged_clustered.bam.pbi"), optional: false, emit: clustered_hifi
  path "*{cluster_report.csv,clustering.log}", optional: false, emit: clustering_reports

  """
  # Run isoseq cluster2
  isoseq cluster2 \
  ${params.isoseq_cluster2_parameters} \
  -j \$SLURM_CPUS_ON_NODE \
  ${merged_xml} \
  merged_clustered.bam 2> merged_clustering.log
  """

}