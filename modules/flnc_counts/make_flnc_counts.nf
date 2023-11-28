process MakeFlncCount {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.collapse_reports}", mode: "copy", pattern: "flnc_count.txt"
  
  input:
  path scripts_dir
  path read_ids
  path read_stats

  output:
  path "flnc_count.txt", optional: false, emit: flnc_count

  """
  # Merge xml files
  python ${scripts_dir}/make_flnc_counts.py
  """

}