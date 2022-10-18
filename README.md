# command-CI-server

The command-CI-server is an utility that allows to:
- define a command precisely via an `ini` definition file,
- run the command periodically in background,
- run it manually via `cmd run …` command.

The command can have any output/input redirected in a flexible
manner and also its run directory set, plus some other settings
(like e.g.: an `if` condition throttling its execution).

## Command Definition Files

If a file called `CMD.ini` will be found in `~/.config/cmds`
it'll be executed in background in configured interval. An
example definition file that runs `ctags`:

```ini
[vars]
q=$HOME/github/zinit

[main]
type=binary
shell=
runnable=ctags -R -e -G
run-path=%q
disabled=no

[args]
arg-1=--options=%q/zsh.ctags
arg-2=--maxdepth=1
arg-3=--languages=zsh
arg-4=%q

[io]
in=stdin
out=[!%q/ctags.out,stdout]
err=[!%q/ctags.out,stdout]

[activation]
on-update-of=%q/config.h
if=\"$(type -w ctags)\" == \"ctags: command\"
interval=70
```

The file is self commenting. The `on-update-of` field defines
a file whose modification time will be examined for any change.
If no such change occurs then the interval will be used to run
the command every `interval` of seconds, **if** also the `if`
condition is meet. Otherwise, a manual run of the command can
be performed via a command: `cmd run ctags`. As it can be
seen the command will be run in directory given in `run-path`,
via a variable `%q`, which points to a `~/github/zinit` directory.

## Log files

Commands output messages that are forwarded to *two* different
locations:

- `~/.cache/command/cmd.log`,
- `{path to the server directory}/cmd.log`.

If you run the `command-server` command manually, the logs go to the
standard output.


## [zinit](https://github.com/zdharma-continuum/zinit)

A service-plugin (i.e.: the file `make.service.zsh`) can use a plugin manager
that supports loading single plugin instance per all active Zsh sessions,
in background. For example, `Zinit` supports this, add:

```zsh
zinit lucid service'cmd' param'CMD_COMMAND_PATH→~/cmds; CMD_INTERVAL→70' for \
            zservices/command-server
```

to `~/.zshrc` to have `command-server` automatically run in background in one of
your zsh sessions, with 70 seconds between each run of any command done by it.

## Explanation of Zsh-spawned services

First Zsh instance that will gain a lock will spawn the service. Other Zsh
instances will wait. When you close the initial Zsh session, another Zsh will
gain lock and resume the service.
