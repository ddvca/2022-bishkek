#!/bin/bash

set +e  # Don't exit immediately if a command exits with a non-zero status

root_name=2022-bishkek

script=$(basename "$0")
pwd=$PWD
root=$(readlink -e ..)

error ()
{
  printf "$script: $*\n" 1>&2
  exit 1
}

git clean -d -f ..

# Search for the text files with DOS/Windows CR-LF line endings

# -r - recursive
# -l - file list
# -q - status only
# -I - Ignore binary files
# -P - Perl-style regexp
# -U - don't strip CR from text file by default

if [ "$OSTYPE" = linux-gnu ] && grep -rqIPU '\r$' ../*/
then
  grep -rlIPU '\r$' ../*/

  error "there are text files with DOS/Windows CR-LF line endings." \
        "You can fix them by doing:\ngrep -rlIPU '\\\\r\$' \"$root/*/\" | xargs dos2unix"
fi

#        "grep -rlIPU '\\r\\\$' \"$root/*/\" | xargs dos2unix"

ls -d ../day*/lab*/ | xargs -n 1 cp {top.,x_,xx_,run_icarus,run_questa}* \
  || error "cannot copy the required scripts to ../day*/lab* subdirectories"

ls -d ../day*/homework/ | xargs -n 1 cp run_all* \
  || error "cannot copy run_all scripts to ../day*/homework subdirectories"

ls -d ../day*/lab*/ | xargs -I % touch %top_extra.qsf \
  || error "cannot create top_extra.qsf in ../day*/lab* subdirectories"

cp ../day_1/lab_02_7segment_letter/*.jpg ../day_2/lab_06_7segment_word \
  || error "cannot create a copy of pictures for 7segment example"

fsm_asic_dir=../lecture/3_asic_openlane/src/OpenLane/designs/snail_moore_fsm/src
mkdir -p $fsm_asic_dir

cp ../day_3/lab_08_snail_fsm/snail_moore_fsm.sv $fsm_asic_dir \
  || error "cannot create a copy of sources for ASIC flow"

cp ../day_2/lab_07_note_recognition/digilent_pmod_mic3_spi_receiver.sv \
   ../day_2/lab_07_note_recognition/music_notes.pdf \
   ../day_3/lab_09_music_recognition \
  || error "cannot create local copies of files for music recognition"

cp ../day_1/lab_03_vga/vga.sv ../day_3/lab_10_game \
  || error "cannot create a local copy of VGA file"

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

# Not sure if I should put lecture to the package

zip -r $pwd/${root_name}_$(date '+%Y%m%d_%H%M%S').zip $root_name/{day,README,LICENSE}* \
  || error "cannot zip the package"

exit 0
