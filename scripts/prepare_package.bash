#!/usr/bin/env bash

#-----------------------------------------------------------------------------

#
#  Setting advised in https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#  Arguments against it https://www.reddit.com/r/commandline/comments/g1vsxk/comment/fniifmk/
#  Another idea http://redsymbol.net/articles/unofficial-bash-strict-mode/
#
#  set -e           - Exit immediately if a command exits with a non-zero
#                     status.  Note that failing commands in a conditional
#                     statement will not cause an immediate exit.
#
#  set -o pipefail  - Sets the pipeline exit code to zero only if all
#                     commands of the pipeline exit successfully.
#
#  set -u           - Causes the bash shell to treat unset variables as an
#                     error and exit immediately.
#
#  set -x           - Causes bash to print each command before executing it.
#
#  set -E           - Improves handling ERR signals

set -Eeuxo pipefail

#-----------------------------------------------------------------------------

pkg_src_root_name=2022-bishkek

main_board=omdazz
all_boards="$main_board de10_lite piswords rzrd zeowaa"

script_path="$0"
script=$(basename "$script_path")
script_dir=$(dirname "$script_path")

error ()
{
  printf "$script: $*\n" 1>&2
  exit 1
}

run_dir="$PWD"
cd "$script_dir"
pkg_src_root=$(readlink -e ..)

#-----------------------------------------------------------------------------

git clean -d -f ..

# We dont't need to cleanup on EXIT
trap cleanup SIGINT SIGTERM ERR

cleanup ()
{
  trap - SIGINT SIGTERM ERR
  cd "$pkg_src_root"
  git clean -d -f
}

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

cp ../boards/$main_board/day_3/lab_08_snail_fsm/snail_moore_fsm.sv $fsm_asic_dir

#-----------------------------------------------------------------------------

lab_glob=../boards/$main_board/day*/lab*/

ls -d $lab_glob | xargs -n 1 -I % rm -rf %run
ls -d $lab_glob | xargs -n 1 -I % mkdir  %run

ls -d ${lab_glob}run/ \
  | xargs -n 1 cp {top.qpf,x_,xx_,run_icarus,run_questa}*

ls -d ${lab_glob}run/ \
  | xargs -I % touch %top_extra.{qsf,sdc} %xx_gtkwave_extra.tcl

ls -d ../boards/$main_board/day*/homework/ | xargs -n 1 cp run_all*

cp ../boards/$main_board/day_1/lab_02_7segment_letter/*.jpg \
   ../boards/$main_board/day_2/lab_06_7segment_word

cp ../boards/$main_board/day_2/lab_07_note_recognition/digilent_pmod_mic3_spi_receiver.sv \
   ../boards/$main_board/day_2/lab_07_note_recognition/music_notes.pdf \
   ../boards/$main_board/day_3/lab_09_music_recognition

cp ../boards/$main_board/day_1/lab_03_vga/vga.sv \
   ../boards/$main_board/day_3/lab_10_game

cp ../boards/$main_board/day_2/lab_07_note_recognition/seven_segment_4_digits.sv \
   ../boards/$main_board/day_4/lab_11_uart

#-----------------------------------------------------------------------------

for board in $all_boards
do
  [ -d ../boards/$board ] || continue

  [ $board == $main_board ] \
    || cp -r -n ../boards/$main_board/day* ../boards/$board

  ls -d ../boards/$board/day*/lab*/run/ \
    | xargs -n 1 cp ../boards/$board/scripts/*
done

#-----------------------------------------------------------------------------

rm -f ../boards/{de10_lite,zeowaa}/day*/lab*/seven_segment_4_digits.sv

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

rm -rf ${pkg_src_root_name}_*.zip
cd "$pkg_src_root/.."

package_name=${pkg_src_root_name}_$(date '+%Y%m%d_%H%M%S')

zip -r "$run_dir/$package_name.zip" $pkg_src_root_name/{boards/*/day,lecture,README,LICENSE}*

zip -r "$run_dir/${package_name}_labs_only_no_lecture.zip" \
       $pkg_src_root_name/{boards/*/day,README,LICENSE}*
