#!/bin/bash
# prepare_zip.bash

set +e  # Don't exit immediately if a command exits with a non-zero status

root_name=2022-bishkek
script=$(basename "$0")
pwd=$PWD
root=$pwd/..

if ! ls -d ../day*/lab*/ | xargs cp {top.,x_,xx_}*
then
    printf "$script: cannot copy the required scripts to ../day*/lab* subdirectories" 1>&2
    exit 1
fi

if ! command -v zip &> /dev/null
then
  printf "$script: cannot find zip utility" 1>&2

  if [ "$OSTYPE" = "msys" ]
  then
    printf "\n$script: download zip for Windows from https://sourceforge.net/projects/gnuwin32/files/zip/3.0/zip-3.0-setup.exe/download" 1>&2
    printf "\n$script: then add zip to the path: %s" '%PROGRAMFILES(x86)%\GnuWin32\bin' 1>&2
  fi

  exit 1
fi

if ! rm -rf ${root_name}_*.zip
then
    printf "$script: cannot remove old zip files" 1>&2
    exit 1
fi

if ! cd $root/..
then
    printf "$script: something is wrong with directory structure or permissions" 1>&2
    exit 1
fi

if ! zip -r $pwd/${root_name}_$(date '+%Y%m%d_%H%M%S').zip $root_name
then
    printf "$script: cannot zip the package" 1>&2
    exit 1
fi

exit 0
