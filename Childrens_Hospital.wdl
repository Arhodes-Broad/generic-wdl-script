## Copyright Broad Institute, 2018
## Purpose: 
## This WDL workflow runs a set of commands provided by the Children's Hospital linked to a docker they have developed.
##
## Requirements/expectations :
## - Updated docker version, Current version is: duplexa/xteab:v3
## - Two sample input files: sample_id.txt and either illumina_bam_list.txt or 10X_bam_list.txt 
## - Two reference input files: hg19_decoy.tar.gz, rep_lib_annotation.tar.gz

## Outputs :
## - A script file that is then run on the docker to produce a table candidate_disc_filtered_cns.txt
##
## Cromwell version support 
## - Successfully tested on v36
## - Does not work on versions < v23 due to output syntax
##
## Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
##
## LICENSING : 
## This script is released under the WDL source code license (BSD-3) (see LICENSE in 
## https://github.com/broadinstitute/wdl). Note however that the programs it calls may 
## be subject to different licenses. Users are responsible for checking that they are
## authorized to run all programs before running this script. Please see the dockers
## for detailed licensing information pertaining to the included programs.



# WORKFLOW DEFINITION 

workflow genericworkflow {

  String? docker_override
#  String docker = select_first([docker_override, "ubuntu:14.04"])
  String docker = select_first([docker_override,"duplexa/xtea:v3"]
  call GenericTask {
    input:
      docker = docker
  }

}


# TASK DEFINITIONS
task GenericTask {
    # Command parameters
    Input_files: sample_id
    String output_dir
    String shell_command

    # Runtime parameters
    String docker
    Int? machine_mem_gb
    Int machine_mem = select_first([machine_mem_gb, 7])
    Int? disk_space_gb
    Boolean use_ssd = false
    Int? cpu
    Int? preemptible_attempts

    command <<<
        set -eo pipefail
        mv -t . ${sep=' ' input_files}
        mkdir ${output_dir}
        ${shell_command}
        find ${output_dir} -type f > listofoutputfiles.txt
    >>>

    runtime {
        docker: docker
        memory: machine_mem + " GB"
        disks: "local-disk " + select_first([disk_space_gb, 100]) + if use_ssd then " SSD" else " HDD"
        cpu: select_first([cpu, 1])
        preemptible: select_first([preemptible_attempts, 3])
    }

    output {
        Array[File] output_files = read_lines("listofoutputfiles.txt")
    }
}

