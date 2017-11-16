require("../utils/tablemerge")
require("diff")

-- Used in Insane VR

Diff.defaults_accels = {
    scoreMode = "SHIELD",

    maxAccel  = 24,
    factAccel =  0.6,
    minAccel  =  0,
    --[[
    maxAccelLeft = 7,
    factAccelLeft = 0.6,
    minAccelLeft = 0,
    maxAccelRight = 7,
    factAccelRight = 0.6,
    minAccelRight = 0,
    --]]
    minSpacing      = 0,
    doubleFactor    = 0.2,
    doubleIntensity = 0.75,
    ballchainSpeed  =  .025,

    chestHeight          =    1.3,
    curveFactorX         =  100,
    curveFactorY         =  170,
    curveY_max           =   75,
    curveY_min           =   17,
    curveY_tiltInfluence =     .8,
    maxNotesShown        =  100,
    maxDistanceShown     = 1500,

    noteScale   = {0.035, 0.035, 0.035},
    tailScale   = {0.035, 0.035, 0.035},
    meteorSpeed =  .09,

    spanX        = 1.7,
    spanX_offset = 0,
    --[[
    blueSpanX          = 1,
    blueSpanX_offset   = 0,
    redSpanX           = 1,
    redSpanX_offset    = 0,
    purpleSpanX        = 1,
    purpleSpanX_offset = 0,
    --]]
    spanY        =  .5,
    spanY_offset = 0,
    spanY_random =  .1,
    spanZ        =  .7,
    spanZ_factor =  .45,

    maxDoubleSpan    = 3.0,
    minDoubleSpan    = 1.0,
    maxCrosshandSpan = 2.0
}

Diff.external_accels = {

    maxAccel  = true,
    factAccel = true,
    minAccel  = true,

    maxAccelLeft = true,
    factAccelLeft = true,
    minAccelLeft = true,
    maxAccelRight = true,
    factAccelRight = true,
    minAccelRight = true,

    minSpacing      = true,
    doubleFactor    = true,
    doubleIntensity = true,
    ballchainSpeed  = true,

    chestHeight          = true,
    curveFactorX         = true,
    curveFactorY         = true,
    curveY_max           = true,
    curveY_min           = true,
    curveY_tiltInfluence = true,
    maxNotesShown        = true,
    maxDistanceShown     = true,

    noteScale   = true,
    tailScale   = true,
    meteorSpeed = true,

    spanX        = true,
    spanX_offset = true,

    blueSpanX          = true,
    blueSpanX_offset   = true,
    redSpanX           = true,
    redSpanX_offset    = true,
    purpleSpanX        = true,
    purpleSpanX_offset = true,

    spanY        = true,
    spanY_offset = true,
    spanY_random = true,
    spanZ        = true,
    spanZ_factor = true,

    maxDoubleSpan    = true,
    minDoubleSpan    = true,
    maxCrosshandSpan = true
}

table.merge(Diff.defaults, Diff.defaults_accels)
table.merge(Diff.external, Diff.external_accels)

Diff._loadValues_accels = Diff.loadValues

function Diff:loadValues(values)
    if self:_loadValues_accels(values) then
        return true
    end

    self.maxAccelLeft  = values.maxAccelLeft  or values.maxAccel  or values.maxAccelRight  or self.maxAccelLeft
    self.factAccelLeft = values.factAccelLeft or values.factAccel or values.factAccelRight or self.factAccelLeft
    self.minAccelLeft  = values.minAccelLeft  or values.minAccel  or values.minAccelRight  or self.minAccelLeft

    self.maxAccelRight  = values.maxAccelRight  or values.maxAccel  or values.maxAccelLeft  or self.maxAccelRight
    self.factAccelRight = values.factAccelRight or values.factAccel or values.factAccelLeft or self.factAccelRight
    self.minAccelRight  = values.minAccelRight  or values.minAccel  or values.minAccelLeft  or self.minAccelRight

    self.maxAccel  = values.maxAccel  or (((values.maxAccelLeft  or self.maxAccel) + (values.maxAccelRight  or self.maxAccel)) / 2)
    self.factAccel = values.factAccel or (((values.factAccelLeft or self.maxAccel) + (values.factAccelRight or self.maxAccel)) / 2)
    self.minAccel  = values.minAccel  or (((values.minAccelLeft  or self.maxAccel) + (values.minAccelRight  or self.maxAccel)) / 2)

    return false
end

Diff._loadDefaults_accels = Diff.loadDefaults

function Diff:loadDefaults()
    if Diff:_loadDefaults_accels() then
        return true
    end

    self.maxAccelLeft  = self.defaults.maxAccelLeft  or self.defaults.maxAccel  or self.defaults.maxAccelRight
    self.factAccelLeft = self.defaults.factAccelLeft or self.defaults.factAccel or self.defaults.factAccelRight
    self.minAccelLeft  = self.defaults.minAccelLeft  or self.defaults.minAccel  or self.defaults.minAccelRight

    self.maxAccelRight  = self.defaults.maxAccelRight  or self.defaults.maxAccel  or self.defaults.maxAccelLeft
    self.factAccelRight = self.defaults.factAccelRight or self.defaults.factAccel or self.defaults.factAccelLeft
    self.minAccelRight  = self.defaults.minAccelRight  or self.defaults.minAccel  or self.defaults.minAccelLeft

    self.maxAccel  = self.defaults.maxAccel  or ((self.maxAccelLeft  + self.maxAccelRight ) / 2)
    self.factAccel = self.defaults.factAccel or ((self.factAccelLeft + self.factAccelRight) / 2)
    self.minAccel  = self.defaults.minAccel  or ((self.minAccelLeft  + self.minAccelRight ) / 2)

    return false
end
