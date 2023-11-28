process PrepareRefs {

  label 'contained'

  input:
  path ref_fasta
  path gtf

  output:
  path "${ref_fasta}", optional: false, emit: pigeon_ref
  path "${ref_fasta}.fai", optional: false, emit: pigeon_ref_index
  path "*.sorted.gtf", optional: false, emit: pigeon_gtf
  path "*.sorted.gtf.pgi", optional: false, emit: pigeon_gtf_index

  """
  # Prepare gtf for Pigeon
  pigeon prepare \
  ${gtf} \
  ${ref_fasta}
  """

}