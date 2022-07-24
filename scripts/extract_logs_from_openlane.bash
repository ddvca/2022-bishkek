#!/bin/bash

set +e  # Don't exit immediately if a command exits with a non-zero status

script=$(basename "$0")

error ()
{
  printf "$script: $*\n" 1>&2
  exit 1
}

runs_dir=../../OpenLane/designs/moore_fsm/runs

[ -d $runs_dir ] || error "Cannot find OpenLane runs directory"

last_run_dir=$(ls -d $runs_dir/RUN* | sort | tail -1)

! [ -z "$last_run_dir" ] || error "No RUN directory"

lecture_dir=../day_3/lecture_8_fsm/logs_and_screenshots
[ -d $lecture_dir ] || error "Cannot find the lecture directory"

run_name=$(basename $last_run_dir)
target_dir=$lecture_dir/$run_name

! [ -d $target_dir ] || error "\"$target_dir\" already exists"
mkdir $target_dir || error "Cannot create \"$target_dir\""

                                                                        # 01_main.log
                                                                        # 02_main_violation.log
                                                                        # 09_mca_sta_violation.rpt
   cp $last_run_dir/results/synthesis/moore_fsm.v             $target_dir/03_synthesis.v    \
&& cp $last_run_dir/results/placement/moore_fsm.resized.v     $target_dir/04_placement.v    \
&& cp $last_run_dir/results/cts/moore_fsm.resized.v           $target_dir/05_cts.v          \
&& cp $last_run_dir/results/routing/moore_fsm.resized.v       $target_dir/06_routing.v      \
&& cp $last_run_dir/results/final/verilog/gl/moore_fsm.v      $target_dir/07_final.v        \
&& cp $last_run_dir/reports/signoff/29-rcx_mca_sta.rpt        $target_dir/08_mca_sta.rpt    \
&& cp $last_run_dir/reports/signoff/29-rcx_mca_sta.area.rpt   $target_dir/10_mca_area.rpt   \
&& cp $last_run_dir/reports/signoff/29-rcx_mca_sta.power.rpt  $target_dir/11_mca_power.rpt  \
&& cp $last_run_dir/results/signoff/moore_fsm.mag             $target_dir/12_magic.mag      \
|| error "Cannot copy something"

exit 0
