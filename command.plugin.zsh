# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2022 Sebastian Gniazdowski

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

0=${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}
0=${${(M)0:#/*}:-$PWD/$0}

# Then ${0:h} to get plugin's directory

if [[ ${zsh_loaded_plugins[-1]} != */command-server && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}" )
}

# Standard hash for plugins, to not pollute the namespace
typeset -gA Plugins
Plugins+=( CMD_DIR "${0:h}"
    CMD_CONF_INTERVAL "${CMD_CONF_INTERVAL:=5}"
    CMD_COMMAND_PATH "$CMD_COMMAND_PATH"
    CMD_CONF_ARGS "$CMD_CONF_ARGS"
    CMD_CONF_PAUSE_AFTER "${CMD_CONF_PAUSE_AFTER:=30}" 
    CMD_CONF_SETUP_ALIAS "$CMD_CONF_SETUP_ALIAS" )

# Make the variables used by command-server exported.
export CMD_DIR="${0:h}" CMD_CONF_INTERVAL CMD_COMMAND_PATH \
    CMD_CONF_ARGS CMD_CONF_PAUSE_AFTER CMD_CONF_SETUP_ALIAS

# The functions/scripts provided by the plugin
autoload -Uz zcommand

zmodload zsh/stat zsh/datetime zsh/system

alias zcmd=zcommand

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
