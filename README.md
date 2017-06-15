# ShieldMod
Shieldmoding repository, https://is.gd/shieldmod

## NOT PLAYABLE
This is a temporary repository where I attempt to rewrite the entire mod using [luam](https://github.com/Discookie/luam).

Compile only `src/main.lua` with `-n` flag!

## Guidelines

Modules should create objects that branch into the `events` and `intervals` modules. They shall not use excessive `while` loops or timeouts!

Avoid global variables, although static variables and enumerators are allowed.

Misc. utilities go into `utils` folder, separate mods go into `mods/<modname>` folder, sub-, but complete modules go into `modules/<modulename>`!