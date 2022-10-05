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
Plugins[CMD_SRV_DIR]=$2
Plugins[CMD_CUR_SUB_CMD]=$1

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
path+=( $Plugins[CMD_SRV_DIR]/bin )
fpath+=( $Plugins[CMD_SRV_DIR]/functions )
# Load all functions.
autoload -Uz $Plugins[CMD_SRV_DIR]/functions/*~*\~(:t)

# Cleanup on exit.
trap 'fpath=( ${fpath[@]:#$Plugins[CMD_SRV_DIR]/functions} ); return 0' EXIT
trap 'path=( ${path[@]:#$Plugins[CMD_SRV_DIR]/bin} ); return 0' EXIT
trap 'fpath=( ${fpath[@]:#$Plugins[CMD_SRV_DIR]/functions} ); return 0' INT
trap 'path=( ${path[@]:#$Plugins[CMD_SRV_DIR]/bin} ); return 0' INT
local -a mbegin mend match reply
integer MBEGIN MEND
local MATCH REPLY

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
