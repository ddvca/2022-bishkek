#!/usr/bin/env bash

# See the decription of these settings in scripts/README.md file
set -Eeuo pipefail
# set -x

#-----------------------------------------------------------------------------

main_board=omdazz
all_boards="$main_board c5gx de10_lite piswords rzrd zeowaa"

#-----------------------------------------------------------------------------

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
pkg_src_root_name=$(basename "$pkg_src_root")

#-----------------------------------------------------------------------------

git clean -d -f -x ..

# We dont't need to cleanup on EXIT
trap cleanup SIGINT SIGTERM ERR

cleanup ()
{
  trap - SIGINT SIGTERM ERR
  cd "$pkg_src_root"
  git clean -d -f -x . 1>&2 >/dev/null
}

#-----------------------------------------------------------------------------

f=$(git diff --name-status --diff-filter=R HEAD ..)

if [ -n "${f-}" ]
then
    error "there are renamed files in the tree."                            \
          "\nYou should check them in before preparing a release package."  \
          "\nSpecifically:\n\n$f"
fi

f=$(git ls-files --others --exclude-standard ..)

if [ -n "${f-}" ]
then
    error "there are untracked files in the tree."          \
          "\nYou should either remove or check them in"     \
          "before preparing a release package."             \
          "\nSpecifically:\n\n$f"                           \
          "\n\nYou can also see the file list by running:"  \
          "\n    git clean -d -n $pkg_src_root"             \
          "\n\nAfter reviewing (be careful!),"              \
          "you can remove them by running:"                 \
          "\n    git clean -d -f $pkg_src_root"             \
          "\n\nNote that \"git clean\" does not see"        \
          "the files from the .gitignore list."
fi

f=$(git ls-files --others ..)

if [ -n "${f-}" ]
then
    error "there are files in the tree, ignored by git,"                    \
          "based on .gitignore list."                                       \
          "\nThis repository is not supposed to have the ignored files."    \
          "\nYou need to remove them before preparing a release package."   \
          "\nSpecifically:\n\n$f"
fi

f=$(git ls-files --modified ..)

if [ -n "${f-}" ]
then
    error "there are modified files in the tree."                           \
          "\nYou should check them in before preparing a release package."  \
          "\nSpecifically:\n\n$f"
fi

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
          "You can fix them by doing:" \
          "\ngrep -rlIU \$'\\\\r\$' \"$pkg_src_root\"/* | xargs dos2unix"
fi

exclude_urg="--exclude-dir=urgReport"

if grep -rqI $exclude_urg $'\t' ../*
then
    grep -rlI $exclude_urg $'\t' ../*

    error "there are text files with tabulation characters." \
          "\nTabs should not be used." \
          "\nDevelopers should not need to configure the tab width" \
          " of their text editors in order to be able to read source code." \
          "\nPlease replace the tabs with spaces" \
          "before checking in or creating a package." \
          "\nYou can find them by doing:" \
          "\ngrep -rlI $exclude_urg \$'\\\\t' \"$pkg_src_root\"/*" \
          "\nYou can fix them by doing the following," \
          "but make sure to review the fixes:" \
          "\ngrep -rlI $exclude_urg \$'\\\\t' \"$pkg_src_root\"/*" \
          "| xargs sed -i 's/\\\\t/    /g'"
fi

if grep -rqI $exclude_urg '[[:space:]]\+$' ../*
then
    grep -rlI $exclude_urg '[[:space:]]\+$' ../*

    error "there are spaces at the end of line, please remove them." \
          "\nYou can fix them by doing:" \
          "\ngrep -rlI $exclude_urg '[[:space:]]\\\\+\$' \"$pkg_src_root\"/*" \
          "| xargs sed -i 's/[[:space:]]\\\\+\$//g'"
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

cp ../boards/$main_board/day_2/lab_07_note_recognition/seven_segment_4_digits.sv \
   ../boards/$main_board/day_2/lab_07_note_recognition/music_notes.pdf \
   ../boards/$main_board/day_4/lab_13_note_recognition_new_mic

#-----------------------------------------------------------------------------

for board in $all_boards
do
  [ -d ../boards/$board ] || continue

  [ $board == $main_board ] \
    || cp -r -n ../boards/$main_board/day* ../boards/$board

  ls -d ../boards/$board/day*/lab*/run/ \
    | xargs -n 1 cp ../boards/$board/scripts/*

  for d in ../boards/$board/day*/lab*
  do
    ls $d/*extra*  &> /dev/null && cp $d/*extra*  $d/run
    ls $d/x_*.bash &> /dev/null && cp $d/x_*.bash $d/run
  done
done

#-----------------------------------------------------------------------------

rm -f ../boards/{c5gx,de10_lite,zeowaa}/day*/lab*/seven_segment_4_digits.sv

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
