# command-server

Make server that runs in background for configured projects and periodically
builds them (i.e.: executes `make`) catching their outputs and exposing them
interactively via `zmake` command.

If your project's build is started earlier in the background, `zmake` will
show and follow its output. If it finished, it'll show its output without
blocking of terminal. You can also request last log of given *type*, i.e.:

- last successful, non-null build: `zmake -c/--clean`,
- last null build (no actions taken by the `Makefile`/`make`): `zmake -n/--null`,
- last warning-only build: `zmake -w/--warn`,
- last error build: `zmake -e/--err`.

`make-server` remembers last log output for each o the kinds above.

## Log files

`make-server` outputs messages that are forwarded to *two* different
locations:

- `~/.cache/makesrv/make.log`,
- `{path to the plugin directory}/make.log`.

If you run the `make-server` command manually, the logs go to the
standard output.

## TL;DR Documentation

- [zmake](https://github.com/zservices/make-server/blob/main/doc/zmake.md) -
  tool to interface with the background service,
- [make-server](https://github.com/zservices/make-server/blob/main/doc/make-server.md) -
  the background build service.

You can use `Zinit`'s service feature to run exaclty one copy of the build
service process (see next section) or run it yourself simply via `./make-server`.

## [zinit](https://github.com/zdharma-continuum/zinit)

A service-plugin (i.e.: the file `make.service.zsh`) can use a plugin manager
that supports loading single plugin instance per all active Zsh sessions,
in background. For example, `Zinit` supports this, add:

```zsh
zinit lucid service'make' param'MSERV_CONF_DIRS→~/Dokumenty/neo-mc:~/github/tig;
        MSERV_CONF_SETUP_ALIAS→1; MSERV_CONF_INTERVAL→10' for \
            zservices/make-server
```

to `~/.zshrc` to have `make-server` automatically run in background in one of
your zsh sessions, with `make` aliased to `zmake` to little help with muscle
memory, with 10 seconds between each build.

## Explanation of Zsh-spawned services

First Zsh instance that will gain a lock will spawn the service. Other Zsh
instances will wait. When you close the initial Zsh session, another Zsh will
gain lock and resume the service.
