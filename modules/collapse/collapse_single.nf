process Collapse {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.abundance.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.flnc_count.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.group.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.read_stat.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.report.json"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.collapsed_dir}", mode: "copy", pattern: "*.sorted.gff"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.collapsed_dir}", mode: "copy", pattern: "*.sorted.gff.pgi"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.collapsed_dir}", mode: "copy", pattern: "*collapsed.fasta"

  input:
  tuple val(sample_id), path(hifi), path(hifi_index)

  output:
  tuple val(sample_id), path("${sample_id}_collapsed.sorted.gff"), path("${sample_id}_collapsed.sorted.gff.pgi"), path("*flnc_count.txt"), optional: false, emit: collapsed_gff
  path "*.{abundance.txt,group.txt,read_stat.txt,report.json}", optional: false, emit: collapse_reports
  path "*collapsed.fasta", optional: true
  
  """
  # Collapse into unique isoforms
  isoseq collapse \
  ${params.collapse_parameters} \
  -j \$SLURM_CPUS_ON_NODE \
  ${hifi} \
  ${sample_id}_collapsed.gff

  # Prepare for Pigeon
  pigeon prepare \
  ${sample_id}_collapsed.gff
  """

}