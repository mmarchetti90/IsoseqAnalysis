process Lima {

  // N.B. Does not support demux for now

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.lima_reports}", mode: "copy", pattern: "*.summary"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.lima_reports}", mode: "copy", pattern: "*.report"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.lima_reports}", mode: "copy", pattern: "*.json"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.lima_reports}", mode: "copy", pattern: "*.clips"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.lima_reports}", mode: "copy", pattern: "*.counts"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.lima_reports}", mode: "copy", pattern: "*.guess"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.lima_reports}", mode: "copy", pattern: "*.consensusreadset.xml"

  input:
  each path(primers)
  tuple val(sample_id), path(hifi)

  output:
  tuple val(sample_id), path("trimmed_*.bam"), path("trimmed_*.bam.pbi"), optional: false, emit: trimmed_hifi
  path "*.{summary,report,json,clips,counts,guess,consensusreadset.xml}", optional: false, emit: lima_reports

  """
  # Run lima
  lima \
  --num-threads \$SLURM_CPUS_ON_NODE \
  ${params.lima_parameters} \
  ${hifi} \
  ${primers} \
  trimmed_${hifi}
  """

}