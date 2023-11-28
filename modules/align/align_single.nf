process Align {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.alignment_reports}", mode: "copy", pattern: "*pbmm2.log"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.alignment_dir}", mode: "copy", pattern: "*_mapped.bam"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.alignment_dir}", mode: "copy", pattern: "*_mapped.bam.bai"

  input:
  each path(ref)
  tuple val(sample_id), path(hifi), path(hifi_index)

  output:
  tuple val(sample_id), path("${sample_id}_mapped.bam"), path("${sample_id}_mapped.bam.bai"), optional: false, emit: aligned_hifi
  path "*pbmm2.log", optional: false, emit: alignment_reports

  """
  # Align with Minimap2
  pbmm2 align \
  ${params.pbmm2_parameters} \
  --log-level INFO \
  -j \$SLURM_CPUS_ON_NODE \
  ${hifi} \
  ${ref} \
  ${sample_id}_mapped.bam 2> ${sample_id}_pbmm2.log
  """

}