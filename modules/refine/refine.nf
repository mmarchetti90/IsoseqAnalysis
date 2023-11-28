process Refine {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.refining_reports}", mode: "copy", pattern: "*.report.csv"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.refining_reports}", mode: "copy", pattern: "*.report.json"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.refining_reports}", mode: "copy", pattern: "*.consensusreadset.xml"

  input:
  each path(primers)
  tuple val(sample_id), path(hifi), path(hifi_index)

  output:
  tuple val(sample_id), path("${sample_id}_refined_*.bam"), path("${sample_id}_refined_*.bam.pbi"), optional: false, emit: refined_hifi
  path "${sample_id}_refined_*.consensusreadset.xml", optional: false, emit: refined_xmls
  path "${sample_id}_refined_*.bam*", optional: false, emit: refined_bams
  path "*.report.csv", optional: false, emit: refining_reports
  path "*.report.json", optional: true

  """
  # Run isoseq refine
  isoseq refine \
  ${params.isoseq_refine_parameters} \
  -j \$SLURM_CPUS_ON_NODE \
  ${hifi} \
  ${primers} \
  ${sample_id}_refined_${hifi}
  """

}