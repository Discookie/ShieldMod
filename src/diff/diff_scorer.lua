require("../utils/tablemerge")
require("diff")

Diff.defaults_scorer = {
    singleScore      = 1,
    doubleMultiplier = 1.5,
    purpleScore      = 1.25,
    purpleMultiplier = 1.33,

    scoreBaseFactor  = 2.5,
    scoreAccelFactor = .75,

    scoreTimePeak   =  .25,
    scoreTimeCutoff = 1,

    useScoreboardNote = true
}

Diff.external_scorer = {
    useScoreboardNote = true
}

table.merge(Diff.defaults, Diff.defaults_scorer)
table.merge(Diff.external, Diff.external_scorer)
