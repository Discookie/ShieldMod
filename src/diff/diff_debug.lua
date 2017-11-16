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

-- Allow external access to these settings
Diff.external_debug = {
    debugAccelDisplay = true,
    debugAccelMode = true,
    debugAccelTimer = true,
    debugDoubleSpanDisplay = true,
    debugDoubleSpanMode = true,
    debugDoubleSpanTimer = true
}

table.merge(Diff.defaults, Diff.defaults_debug)
table.merge(Diff.external, Diff.external_debug)
