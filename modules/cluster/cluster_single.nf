process Cluster {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.clustering_reports}", mode: "copy", pattern: "*cluster_report.csv"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.clustering_reports}", mode: "copy", pattern: "*clustering.log"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.clusters_dir}", mode: "copy", pattern: "*.bam"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.clusters_dir}", mode: "copy", pattern: "*.pbi"

  input:
  tuple val(sample_id), path(hifi), path(hifi_index)

  output:
  tuple val(sample_id), path("${sample_id}_clustered.bam"), path("${sample_id}_clustered.bam.pbi"), optional: false, emit: clustered_hifi
  path "*{cluster_report.csv,clustering.log}", optional: false, emit: clustering_reports

  """
  # Run isoseq cluster2
  isoseq cluster2 \
  ${params.isoseq_cluster2_parameters} \
  -j \$SLURM_CPUS_ON_NODE \
  ${hifi} \
  ${sample_id}_clustered.bam 2> ${sample_id}_clustering.log
  """

}