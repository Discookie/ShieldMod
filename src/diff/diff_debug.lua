require("../utils/tablemerge")
require("diff")

Diff.defaults_debug = {
    -- Used in debug scoring modules
    debugAccelDisplay = false,
    debugAccelMode = "Current",
    debugAccelTimer = 1,
    debugDoubleSpanDisplay = false,
    debugDoubleSpanMode = "Current",
    debugDoubleSpanTimer = 1
}

table.merge(Diff.defaults, Diff.defaults_debug)
