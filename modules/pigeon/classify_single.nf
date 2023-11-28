process Classify {

  label 'contained'

  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.classify_reports}", mode: "copy", pattern: "*classify.log"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.classify_reports}", mode: "copy", pattern: "*report.json"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.classify_reports}", mode: "copy", pattern: "*summary.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.classify_reports}", mode: "copy", pattern: "*filter.log"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.reports_dir}/${params.classify_reports}", mode: "copy", pattern: "*saturation.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.collapsed_dir}", mode: "copy", pattern: "*sorted.filtered_lite.gff"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.classify_dir}", mode: "copy", pattern: "*classification.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.classify_dir}", mode: "copy", pattern: "*classification.filtered_lite_classification.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.classify_dir}", mode: "copy", pattern: "*junctions.txt"
  publishDir "${projectDir}/${params.results_dir}/${sample_id}/${params.classify_dir}", mode: "copy", pattern: "*reasons.txt}"

  input:
  each path(pigeon_ref)
  each path(pigeon_ref_index)
  each path(pigeon_gtf)
  each path(pigeon_gtf_index)
  tuple val(sample_id), path(collapsed_sorted_gtf), path(collapsed_sorted_gtf_index), path(flnc_count)

  output:
  tuple val(sample_id), path("${sample_id}_classification.filtered_lite_classification.txt"), optional: false, emit: transcripts
  path "*{classify.log,report.json}", optional: false, emit: classify_reports
  path "*filter.log", optional: false, emit: filter_reports
  path "*junctions.txt", optional: true
  //path "*filtered_lite_junctions.txt", optional: true
  path "*summary.txt", optional: true
  //path "*filtered.summary.txt", optional: true
  path "*reasons.txt", optional: true
  //path "*.filtered_lite_reasons.txt", optional: true
  path "*sorted.filtered_lite.gff"
  path "*saturation.txt"

  """
  # Classify using pigeon
  pigeon classify \
  -j \$SLURM_CPUS_ON_NODE \
  --out-prefix ${sample_id} \
  --log-level INFO \
  --log-file ${sample_id}_classify.log \
  --fl ${flnc_count} \
  ${params.classify_parameters} \
  ${collapsed_sorted_gtf} \
  ${pigeon_gtf} \
  ${pigeon_ref}

  # Filter classification
  pigeon filter \
  -j \$SLURM_CPUS_ON_NODE \
  --log-level INFO \
  --log-file ${sample_id}_filter.log \
  ${params.filter_parameters} \
  ${sample_id}_classification.txt \
  --isoforms ${collapsed_sorted_gtf}

  # Report gene saturation
  pigeon report \
  ${sample_id}_classification.filtered_lite_classification.txt \
  ${sample_id}_saturation.txt
  """

}