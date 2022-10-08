#!/usr/bin/env zsh
# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2022 Sebastian Gniazdowski

# Set the base and typically useful options
builtin emulate -L zsh
builtin setopt extendedglob warncreateglobal typesetsilent noshortloops \
        noautopushd multios

# Set $0 given.
0=$2/lib/common.snip.zsh

# Such global variable is expected to be typeset'd -g in the plugin.zsh
# file. Here it's restored in case of the function being run as a script.
typeset -gA Plugins
Plugins[CMD_DIR]=$2
Plugins[CMD_CUR_SUB_CMD]=$1
Plugins[CMD_LIBEXEC_DIR]=$2/libexec
# Export crucial paths.
CMD_FILE_CHARS='[[:alnum:]+_%@…\[\]\{\}\(\):.,\?\~\!\/–—-]'
: ${CMD_NULL:=/dev/null}
export CMD_DIR=$2 CMD_LIBEXEC_DIR=$2/libexec CMD_NULL CMD_FILE_CHARS

{ zmodload zsh/system && zsystem supports flock
  Plugins+=( CMD_FLOCK_AVAIL $((!$?)) ); 
  zmodload zsh/datetime
  Plugins+=( CMD_DATETIME_AVAIL $((!$?)) ); 
  zmodload zsh/stat
  Plugins+=( CMD_ZSTAT_AVAIL $((!$?)) ); 
} \
    &>/dev/null

# Reach for scripts and functions
local -Ua path fpath
local -U PATH FPATH
path+=( $Plugins[CMD_DIR]/bin )
fpath+=( $Plugins[CMD_DIR]/functions )
# Load all functions.
autoload -Uz $Plugins[CMD_DIR]/functions/*~*\~(:t)

# Cleanup on exit.
trap 'fpath=( ${fpath[@]:#$Plugins[CMD_DIR]/functions} )' EXIT
trap 'path=( ${path[@]:#$Plugins[CMD_DIR]/bin} )' EXIT
trap 'fpath=( ${fpath[@]:#$Plugins[CMD_DIR]/functions} ); return 0' INT
trap 'path=( ${path[@]:#$Plugins[CMD_DIR]/bin} ); return 0' INT
local -a mbegin mend match reply
integer MBEGIN MEND
local MATCH REPLY

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
