process Collapse {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.abundance.txt"
  //publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.flnc_count.txt"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.group.txt"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.read_stat.txt"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "*.report.json"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.collapsed_dir}", mode: "copy", pattern: "*.sorted.gff"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.collapsed_dir}", mode: "copy", pattern: "*.sorted.gff.pgi"
  publishDir "${projectDir}/${params.results_dir}/merged/${params.collapsed_dir}", mode: "copy", pattern: "*collapsed.fasta"

  input:
  path merged_xml
  path refined_bams
  path aln_hifi
  path aln_hifi_index

  output:
  tuple val("merged"), path("merged_collapsed.sorted.gff"), path("merged_collapsed.sorted.gff.pgi"), optional: false, emit: collapsed_gff
  path "*.read_stat.txt", optional: false, emit: read_stats
  path "*.{abundance.txt,group.txt,report.json}", optional: false, emit: collapse_reports
  path "*collapsed.fasta", optional: true
  
  """
  # Collapse into unique isoforms
  isoseq collapse \
  ${params.collapse_parameters} \
  -j \$SLURM_CPUS_ON_NODE \
  ${aln_hifi} \
  ${merged_xml} \
  merged_collapsed.gff

  # Prepare for Pigeon
  pigeon prepare \
  merged_collapsed.gff
  """

}