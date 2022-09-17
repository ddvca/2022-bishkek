#!/bin/bash

set +e  # Don't exit immediately if a command exits with a non-zero status

pkg_src_root_name=2022-bishkek

main_board=rzrd
all_boards="$main_board de10_lite omdazz piswords zeowaa"

script_path="$0"
script=$(basename "$script_path")
script_dir=$(dirname "$script_path")

error ()
{
  printf "$script: $*\n" 1>&2
  exit 1
}

run_dir="$PWD"

cd "$script_dir" \
  || error "cannot cd \"$script_dir\""

pkg_src_root=$(readlink -e ..)

#-----------------------------------------------------------------------------

git clean -d -f .. \
  || error "cannot remove local files that are not added to the Git repository"

#-----------------------------------------------------------------------------

# Search for the text files with DOS/Windows CR-LF line endings

# -r     - recursive
# -l     - file list
# -q     - status only
# -I     - Ignore binary files
# -U     - don't strip CR from text file by default
# $'...' - string literal in Bash with C semantics ('\r', '\t')

if [ "$OSTYPE" = linux-gnu ] && grep -rqIU $'\r$' ../*
then
  grep -rlIU $'\r$' ../*

  error "there are text files with DOS/Windows CR-LF line endings." \
        "You can fix them by doing:\ngrep -rlIU \$'\\\\r\$' \"$pkg_src_root/*\" | xargs dos2unix"
fi

if grep -rqI $'\t' ../*
then
  grep -rlI $'\t' ../*

  error "there are text files with tabulation characters." \
        "Tabs should not be used." \
        "Developers should not need to configure the tab width of their text editors in order to be able to read source code." \
        "Please replace the tabs with spaces before checking in or creating a package."
fi

#-----------------------------------------------------------------------------

fsm_asic_dir=../lecture/3_asic_openlane/src/OpenLane/designs/snail_moore_fsm/src
mkdir -p $fsm_asic_dir

cp ../boards/$main_board/day_3/lab_08_snail_fsm/snail_moore_fsm.sv $fsm_asic_dir \
  || error "cannot create a copy of sources for ASIC flow"

#-----------------------------------------------------------------------------

ls -d ../boards/$main_board/day*/lab*/ \
  | xargs -n 1 cp {top.qpf,x_,xx_,run_icarus,run_questa}* \
  || error "cannot copy the required common scripts to ../boards/$main_board/day*/lab* subdirectories"

ls -d ../boards/$main_board/day*/lab*/ | xargs -I % touch %top_extra.qsf \
  || error "cannot create top_extra.qsf in ../boards/$main_board/day*/lab* subdirectories"

ls -d ../boards/$main_board/day*/homework/ \
  | xargs -n 1 cp run_all* \
  || error "cannot copy run_all scripts to ../boards/$main_board/day*/homework subdirectories"

cp ../boards/$main_board/day_1/lab_02_7segment_letter/*.jpg \
   ../boards/$main_board/day_2/lab_06_7segment_word \
  || error "cannot create a copy of pictures for 7segment example"

cp ../boards/$main_board/day_2/lab_07_note_recognition/digilent_pmod_mic3_spi_receiver.sv \
   ../boards/$main_board/day_2/lab_07_note_recognition/music_notes.pdf \
   ../boards/$main_board/day_3/lab_09_music_recognition \
  || error "cannot create local copies of files for music recognition"

cp ../boards/$main_board/day_1/lab_03_vga/vga.sv \
   ../boards/$main_board/day_3/lab_10_game \
  || error "cannot create a local copy of VGA file"

#-----------------------------------------------------------------------------

for board in $all_boards
do
  [ -d ../boards/$board ] || continue

  [ $board == $main_board ] \
    || cp -r -u ../boards/$main_board/day* ../boards/$board

  ls -d ../boards/$board/day*/lab*/ \
    | xargs -n 1 cp ../boards/$board/scripts/* \
    || error "cannot copy the required board-specific scripts to ../boards/$board/day*/lab* subdirectories"
done

#-----------------------------------------------------------------------------

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

#-----------------------------------------------------------------------------

rm -rf ${pkg_src_root_name}_*.zip \
  || error "cannot remove old zip files"

cd "$pkg_src_root/.." \
  || error "something is wrong with directory structure or permissions"

package_name=${pkg_src_root_name}_$(date '+%Y%m%d_%H%M%S')

zip -r "$run_dir/$package_name.zip" $pkg_src_root_name/{boards/*/day,lecture,README,LICENSE}* \
  || error "cannot zip the full package"

zip -r "$run_dir/${package_name}_labs_only_no_lecture.zip" \
       $pkg_src_root_name/{boards/*/day,README,LICENSE}* \
  || error "cannot zip the labs-only no-lecture package"

#-----------------------------------------------------------------------------

exit 0
