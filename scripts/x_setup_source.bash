#!/usr/bin/env bash

set +e  # Don't exit immediately if a command exits with a non-zero status

#-----------------------------------------------------------------------------

readonly script=$(basename "$0")

#-----------------------------------------------------------------------------

error ()
{
    ec=$1
    shift

    [ $ec != 0 ] || return

    printf "$script: error: $*" 1>&2

    if [ $ec != 1 ]
    then
        printf ". Exiting with code $ec." 1>&2
    fi

    printf "\n" 1>&2
    exit $ec
}

#-----------------------------------------------------------------------------

warning ()
{
    printf "$script: warning: $*\n" 1>&2
}

#-----------------------------------------------------------------------------

info ()
{
    printf "$script: $*\n" 1>&2
}

#-----------------------------------------------------------------------------

is_command_available ()
{
    command -v $1 &> /dev/null
}

#-----------------------------------------------------------------------------

is_command_available_or_error ()
{
    is_command_available $1 ||  \
        error 1 "program $1$2 is not in the path or cannot be run"
}

#-----------------------------------------------------------------------------

guarded ()
{
    is_command_available_or_error $1
    eval "$*" || error $? "cannot $*"
}

#-----------------------------------------------------------------------------

INTELFPGA_INSTALL_DIR=intelFPGA_lite
QUESTA_DIR=questa_fse
QUARTUS_DIR=quartus

if [ "$OSTYPE" = "linux-gnu" ]
then
    INTELFPGA_INSTALL_PARENT_DIR="$HOME"

    QUESTA_BIN_DIR=bin
    QUESTA_LIB_DIR=linux_x86_64

    if ! [ -d "$INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR" ]
    then
        INTELFPGA_INSTALL_PARENT_DIR_FIRST="$INTELFPGA_INSTALL_PARENT_DIR"
        INTELFPGA_INSTALL_PARENT_DIR=/opt
    fi

    if [ -z "${LM_LICENSE_FILE-}" ]
    then
        export LM_LICENSE_FILE=$HOME/flexlm/license.dat
    fi

    QUARTUS_BIN_DIR=bin

elif  [ "$OSTYPE" = "cygwin"    ]  \
   || [ "$OSTYPE" = "msys"      ]
then
    INTELFPGA_INSTALL_PARENT_DIR=/c

    QUESTA_BIN_DIR=win64
    QUESTA_LIB_DIR=win64

    if [ -z "${LM_LICENSE_FILE-}" ]
    then
        export LM_LICENSE_FILE=/c/flexlm/license.dat
    fi

    QUARTUS_BIN_DIR=bin64
else
    error 1 "this script does not support your OS '$OSTYPE'"
fi

#-----------------------------------------------------------------------------

if ! [ -d "$INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR" ]
then
    if [ -z "${INTELFPGA_INSTALL_PARENT_DIR_FIRST-}" ]
    then
        error "expected to find '$INTELFPGA_INSTALL_DIR' directory"  \
              "in '$INTELFPGA_INSTALL_PARENT_DIR'"
    else
        error "expected to find '$INTELFPGA_INSTALL_DIR' directory"  \
              "either in '$INTELFPGA_INSTALL_PARENT_DIR_FIRST'"      \
              "or in '$INTELFPGA_INSTALL_PARENT_DIR'"
    fi
fi

#-----------------------------------------------------------------------------

# A workaround for a find problem when running bash under Microsoft Windows

find_to_run=find
true_find=/usr/bin/find

if [ -x "$true_find" ]
then
    find_to_run="$true_find"
fi

#-----------------------------------------------------------------------------

FIND_COMMAND="$find_to_run $INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR -mindepth 1 -maxdepth 1 -type d -print"
FIRST_VERSION_DIR=$($FIND_COMMAND -quit)

if [ -z "$FIRST_VERSION_DIR" ]
then
    error 1 "cannot find any version of Intel FPGA installed in "  \
            "'$INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR'"
fi

#-----------------------------------------------------------------------------

export QUESTA_ROOTDIR="$FIRST_VERSION_DIR/$QUESTA_DIR"
export PATH="${PATH:+$PATH:}$QUESTA_ROOTDIR/$QUESTA_BIN_DIR"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$QUESTA_ROOTDIR/$QUESTA_LIB_DIR"

export QUARTUS_ROOTDIR="$FIRST_VERSION_DIR/$QUARTUS_DIR"
export PATH="${PATH:+$PATH:}$QUARTUS_ROOTDIR/$QUARTUS_BIN_DIR"

#-----------------------------------------------------------------------------

ALL_VERSION_DIRS=$($FIND_COMMAND | xargs echo)

if [ "$FIRST_VERSION_DIR" != "$ALL_VERSION_DIRS" ]
then
    warning 1 "multiple Intel FPGA versions installed in"  \
            "'$INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR':"  \
            "'$ALL_VERSION_DIRS'"

    info "QUESTA_ROOTDIR=$QUESTA_ROOTDIR"
    info "QUARTUS_ROOTDIR=$QUARTUS_ROOTDIR"
    info "PATH=$PATH"
    info "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

                     [ -d "$QUESTA_ROOTDIR" ]  \
    || error 1 "directory '$QUESTA_ROOTDIR' expected"

                     [ -d "$QUESTA_ROOTDIR/$QUESTA_BIN_DIR" ]  \
    || error 1 "directory '$QUESTA_ROOTDIR/$QUESTA_BIN_DIR' expected"

                     [ -d "$QUARTUS_ROOTDIR" ]  \
    || error 1 "directory '$QUARTUS_ROOTDIR' expected"

                     [ -d "$QUARTUS_ROOTDIR/$QUARTUS_BIN_DIR" ]  \
    || error 1 "directory '$QUARTUS_ROOTDIR/$QUARTUS_BIN_DIR' expected"
fi

#-----------------------------------------------------------------------------

# Workarounds for Quartus library problems
# that are uncovered under RED OS from https://www.red-soft.ru

if    ! [ -f /usr/lib64/libcrypt.so.1 ] \
   &&   [ -f /usr/lib64/libcrypt.so   ]
then
    ln -sf /usr/lib64/libcrypt.so libcrypt.so.1
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$PWD"
fi
