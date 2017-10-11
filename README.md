# ShieldMod
Shieldmoding repository, https://is.gd/shieldmod

## PLAYTESTERS

You have no other task, than to run `make.bat`. It will create the entire mod for you, in the folder `output`. You can then copy this into your game directory.

**Changing difficulty**:

INSTEAD of changing the default values, paste the values you wish to change into `settings/diff.lua`, then re-run `make.bat`.

The most important task right now is to __report bugs__ and __playtest as much as you can__ - we're polishing the build for an upcoming STABLE release!

If you encounter any errors, don't forget to attach **output logs** to your bug reports!

## MOSTLY DONE

This is a temporary repository where I attempt to rewrite the entire mod using [luam](https://github.com/Discookie/luam).

The current status of the project is: 
* Refactor is finished
* Basic examples are finished
* Insane mod IS adapted, NEEDS TESTING
* Documentation is NOT done

Compile only `src/main.lua` with `-n` flag!

## Guidelines

Custom note assigners should go into `mods/assigners`, with each mod loading some of them, from `mods/modName`.

Utilities are in the `utils` folder, any external libraries are going inside there!

Classes can be made their separate folder for modularity, or made their own file. Static class initializations should always be made on `Events.INIT`, to allow for modding.

Personal settings are stored in `settings`. Do NOT try to re-write the default values - it will not change what you expect.

---

Released under the MIT license.
