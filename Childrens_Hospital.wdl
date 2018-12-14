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



task GenerateRunScript {

    File input_bam
    File input_bam_index
    File hg19_decoy 
    File rep_lib_annotation

    command <<<
        python gnrt_pipeline_cloud.pyc -D -b ${input_bam} -p . -o run_jobs.sh -x /usr/local/bin  -l ${hg19_decoy} -r ${rep_lib_annotation} --nclip 3 --cr 2 --nd 5 --nfclip 3 --nfdisc 5 --flklen 3000 -f 19 -y 7 
        >>>

	runtime {
        disks: "local-disk 200 HDD"
        memory: "7 GB"
        docker: "duplexa/xteab:v3"
        preemptible: 3
    }

    output {
        File output_shell_command = "run_jobs.sh"
    }
}

workflow CHSworkflow {
    call GenerateRunScript {}
}
