#!/bin/bash

set +e  # Don't exit immediately if a command exits with a non-zero status

root_name=2022-bishkek

script=$(basename "$0")
pwd=$PWD
root=$pwd/..

error ()
{
  printf "$script: $*\n" 1>&2
  exit 1
}

git clean -d -f ..

ls -d ../day*/lab*/ | xargs -n 1 cp {top.,x_,xx_,run_icarus,run_questa}* \
  || error "cannot copy the required scripts to ../day*/lab* subdirectories"

ls -d ../day*/homework/ | xargs -n 1 cp run_all* \
  || error "cannot copy run_all scripts to ../day*/homework subdirectories"

ls -d ../day*/lab*/ | xargs -I % touch %top_extra.qsf \
  || error "cannot create top_extra.qsf in ../day*/lab* subdirectories"

cp ../day_1/lab_2_7segment_letter/*.jpg ../day_2/lab_6_7segment_word \
  || error "cannot create a copy of pictures for 7segment example"

fsm_asic_dir=../day_3/lecture_8_fsm/OpenLane/designs/moore_fsm/src
mkdir -p $fsm_asic_dir

cp ../day_3/lab_8_fsm/moore_fsm.sv $fsm_asic_dir \
  || error "cannot create a copy of sources for ASIC flow"

if ! command -v zip &> /dev/null
then
  printf "$script: cannot find zip utility"

  if [ "$OSTYPE" = "msys" ]
  then
    printf "\n$script: download zip for Windows from https://sourceforge.net/projects/gnuwin32/files/zip/3.0/zip-3.0-setup.exe/download"
    printf "\n$script: then add zip to the path: %s" '%PROGRAMFILES(x86)%\GnuWin32\bin'
  fi

  exit 1
fi

rm -rf ${root_name}_*.zip \
  || error "cannot remove old zip files"

cd $root/.. \
  || error "something is wrong with directory structure or permissions"

zip -r $pwd/${root_name}_$(date '+%Y%m%d_%H%M%S').zip $root_name/{day,README,LICENSE}* \
  || error "cannot zip the package"

exit 0
