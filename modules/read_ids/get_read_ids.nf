process GetReadIDs {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.refining_reports}", mode: "copy", pattern: "*_reads_id.txt"
  
  input:
  tuple val(sample_id), path(hifi), path(hifi_index)

  output:
  path "${sample_id}_reads_id.txt", optional: false, emit: read_ids

  """
  # Get read IDs
  samtools view ${hifi} | awk '{print \$1}' > ${sample_id}_reads_id.txt
  """

}