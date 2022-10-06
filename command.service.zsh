#!/usr/bin/env zsh
#
# A z-service file that runs redis database server (redis-server).
#
# Use with plugin manager that supports single plugin load per all
# active Zsh sessions. The p-msg should set parameters `ZSRV_WORK_DIR`
# and `ZSRV_ID`.
# These are the only two variables obtained from p-msg and should
# be exported (apart from ZERO).

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Allow running the plugin as script if one desires (e.g. for debugging).
# The if checks if loaded from plugin manager or if the standard
# ZSRV_* vars are provided by it.
if [[ ${+zsh_loaded_plugins} == 0 || $zsh_loaded_plugins[(I)*/command-server] == 0 || \
    -z $ZSRV_WORK_DIR || -z $ZSRV_ID ]]; then
    typeset -gx ZSRV_WORK_DIR ZSRV_ID
    : ${ZSRV_WORK_DIR:=$0:h} ${ZSRV_ID:=cmd}
    export ZSRV_WORK_DIR ZSRV_ID
fi
ZSRV_WORK_DIR=${ZSRV_WORK_DIR%/.}

# Allow but strip non-number format codes, for future expansions.
# Implemented by `msg` function/script.
msg() {
    # No redundancy – reuse…
    $Plugins[CMD_DIR]/functions/msg "$@" \
         >>!$srv_loclogfile >>!$srv_cachelogfile;
}

run_command() {
    builtin eval "$*"
}

# Own global and exported variables.
typeset -gx ZERO=$0 ZSRV_THIS_DIR=${0:h} \
    ZSRV_THIS_CACHE=${${ZSH_CACHE_DIR:+$ZSH_CACHE_DIR:h}:-${XDG_CACHE-HOME:-$HOME/.cache}}
ZSRV_THIS_CACHE+=/commandsrv

integer -gx ZSRV_PID
typeset -gA Plugins
Plugins+=( CMD_DIR "${0:h}"
    CMD_CONF_INTERVAL "${CMD_CONF_INTERVAL:=5}"
    CMD_COMMAND_PATH "$CMD_COMMAND_PATH"
    CMD_CONF_ARGS "$CMD_CONF_ARGS"
    CMD_CONF_PAUSE_AFTER "${CMD_CONF_PAUSE_AFTER:=30}" )

export CMD_DIR CMD_CONF_INTERVAL CMD_COMMAND_PATH \
    CMD_CONF_ARGS CMD_CONF_PAUSE_AFTER CMD_CONF_SETUP_ALIAS

local pidfile=$ZSRV_WORK_DIR/$ZSRV_ID.pid \
        srv_loclogfile=$ZSRV_THIS_DIR/$ZSRV_ID.log \
        srv_cachelogfile=$ZSRV_THIS_CACHE/$ZSRV_ID.log \
        config=${XDG_CONFIG_HOME:-$HOME/.config}/commandsrv/command-server.conf

command mkdir -p $config:h

# Test to detect lack of service'' ice if loaded from a plugin manager.
if (( !${+ZSRV_WORK_DIR} || !${+ZSRV_ID} )); then
    msg {208}Error{39}:{70} plugin \`{174}zservices/command-server{70}\` needs to be loaded as service, aborting.
    return 1
fi

if [[ ! -f $config ]]; then
    command cp -f $ZSRV_THIS_DIR/command-server.conf $config || \
        config=$ZSRV_THIS_DIR/command-server.conf
fi

msg ZSERVICE: Using config: $config

if [[ -r $config ]]; then
    { local pid=$(<$pidfile); } 2>/dev/null
    if [[ ${+commands[pkill]} -eq 1 && $pid = <-> && $pid -gt 0 ]]; then
        if command pkill -HUP -x -F $pidfile; then
            msg ZSERVICE: Stopped previous command-server instance, PID: $pid
            LANG=C sleep 1.5
        else
            noglob msg ZSERVICE: Previous command-server instance (PID:$pid) not running.
        fi
    fi

    builtin trap 'kill -INT $ZSRV_PID; command sleep 1; builtin exit 1' HUP
    () {
        emulate -L zsh -o multios
        local -a cmd=( command $ZSRV_THIS_DIR/command-server $config \
                "&>>!$srv_loclogfile" "&>>!$srv_cachelogfile" "&" )

        # Output to three locations, one under Zinit home, second
        # in the plugin directory, third under ZICACHE/../{service-name}.log.0
        command mkdir -p $srv_cachelogfile:h
        repeat 1 { run_command "${cmd[@]}" }

        # Remember PID of the server.
        ZSRV_PID=$!
    }
    # Save PID of the server.
    builtin print $ZSRV_PID >! $pidfile
    LANG=C command sleep 0.7
    builtin return 0
else
    msg ZSERVICE: No readable command-server.conf found, command-server did not run 
    builtin return 1
fi
