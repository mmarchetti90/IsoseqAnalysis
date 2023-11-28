process MergeXml {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/merged/${params.reports_dir}/${params.clustering_reports}", mode: "copy", pattern: "merged_refined_dataset.xml"
  
  input:
  path scripts_dir
  path xml_files

  output:
  path "merged_refined_dataset.xml", optional: false, emit: merged_xml

  """
  # Merge xml files
  python ${scripts_dir}/merge_xml.py
  """

}