require("diff")
require("../utils/tablemerge")

Diff.defaults_timing = {
    useGameTime = false
}

table.merge(Diff.defaults, Diff.defaults_timing)
