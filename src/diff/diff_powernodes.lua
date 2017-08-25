require("../utils/tablemerge")
require("diff")

Diff.defaults_powerNodes = {
    -- Used in Track

    minJumpAirTime = 2.5,
    jumpEndOffset = 10,
    powerNodesPerMin = 1,
    extraMinsForNodes = 2,
    slopeTest = 100
}

table.merge(Diff.defaults, Diff.defaults_powerNodes)
