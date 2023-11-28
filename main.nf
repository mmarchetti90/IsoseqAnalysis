#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
Pipeline to analyze PacBio CCS/HiFi RNA reads
Currently does not support demultiplexing
*/

// ----------------Workflow---------------- //

include { ISOSEQ_SINGLE } from './workflows/isoseq_single.nf'
include { ISOSEQ_MERGED } from './workflows/isoseq_merged.nf'

workflow {

  if ("$workflow.profile" == "standard") {
    
    ISOSEQ_SINGLE()

  }
  else if ("$workflow.profile" == "single") {
    
    ISOSEQ_SINGLE()

  }
  else if ("$workflow.profile" == "merged") {
    
    ISOSEQ_MERGED()

  } else {

    println "ERROR: Unrecognized profile!"
    println "Please chose one of: standard, single, merged"

  }

}