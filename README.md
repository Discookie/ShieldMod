# ShieldMod
Shieldmoding repository, https://is.gd/shieldmod

## MOSTLY DONE
This is a temporary repository where I attempt to rewrite the entire mod using [luam](https://github.com/Discookie/luam).

The current status of the project is: 
* Refactor is finished
* Basic examples are finished
* Insane mod is NOT adapted
* Documentation is NOT done

Compile only `src/main.lua` with `-n` flag!

## Guidelines

Custom note assigners should go into `mods/assigners`, with each mod loading some of them, from `mods/modName`.

Utilities are in the `utils` folder, any external libraries are going inside there!

Classes can be made their separate folder for modularity, or made their own file. Static class initializations should always be made on `Events.INIT`, to allow for modding.

Personal settings are stored in `settings`. Do NOT try to re-write the default values - it will not change what you expect.

---

Released under the MIT license.