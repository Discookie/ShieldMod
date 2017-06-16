require("logger")

Diff = {}
Diff.__index = Diff
setmetatable(Diff, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

Diff.defaults = {
    maxAccel  = 10,
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
    spanScale = 1.7,
    minSpacingSeconds = 0,
    doubleFactor = 0.2,

    chestHeight          =    1.3,
    curveFactorX         =  100,
    curveFactorY         =  170,
    curveY_max           =   75,
    curveY_min           =   17,
    curveY_tiltInfluence =     .8,
    maxNodeDistShown     = 1500,
    meteorSpeed          =     .09,

    minX = -.5,
    --spanX = 1,
    maxX =  .5,
    --[[
    blueMinX    = -.5,
    blueSpanX   =  1,
    redMinX     = -.5,
    redSpanX    =  1,
    purpleMinX  = -.5,
    purpleSpanX =  1,
    --]]
    spanY = .5,
    spanY_random = .1,
    spanZ = .7,
    maxDoubleSpan = 0.8,
    minDoubleSpan = 0.2,
    maxCrosshandSpan = 0.6,

    musicCutOnFail = false
}

function Diff.init(values)
    local self = setmetatable({}, Diff)
    self.type = "Diff"
    self.logger = Logger(self.type)
    self:loadDefaults()
    if values ~= nil then
        self:loadValues(values)
    end
    return self
end

function Diff:loadDefaults()
    self.minX  = self.defaults.minX  or (self.defaults.maxX - self.defaults.spanX)
    self.spanX = self.defaults.spanX or (self.defaults.maxX - self.defaults.minX )
    self.maxX  = self.defaults.maxX  or (self.defaults.minX + self.defaults.spanX)

    self.maxAccelLeft  = self.defaults.maxAccelLeft  or self.defaults.maxAccel  or self.defaults.maxAccelRight
    self.factAccelLeft = self.defaults.factAccelLeft or self.defaults.factAccel or self.defaults.factAccelRight
    self.minAccelLeft  = self.defaults.minAccelLeft  or self.defaults.minAccel  or self.defaults.minAccelRight

    self.maxAccelRight  = self.defaults.maxAccelRight  or self.defaults.maxAccel  or self.defaults.maxAccelLeft
    self.factAccelRight = self.defaults.factAccelRight or self.defaults.factAccel or self.defaults.factAccelLeft
    self.minAccelRight  = self.defaults.minAccelRight  or self.defaults.minAccel  or self.defaults.minAccelLeft

    self.maxAccel  = self.defaults.maxAccel  or ((self.maxAccelLeft  + self.maxAccelRight ) / 2)
    self.factAccel = self.defaults.factAccel or ((self.factAccelLeft + self.factAccelRight) / 2)
    self.minAccel  = self.defaults.minAccel  or ((self.minAccelLeft  + self.minAccelRight ) / 2)

    self.spanScale         = self.defaults.spanScale
    self.minSpacingSeconds = self.defaults.minSpacingSeconds
    self.self.doubleFactor = self.defaults.self.doubleFactor

    self.spanY        = self.defaults.spanY
    self.spanY_random = self.defaults.spanY_random
    self.spanZ        = self.defaults.spanZ

    self.chestHeight = self.defaults.chestHeight
    self.meteorSpeed = self.defaults.meteorSpeed

    self.maxDoubleSpan    = self.defaults.maxDoubleSpan
    self.minDoubleSpan    = self.defaults.minDoubleSpan
    self.maxCrosshandSpan = self.defaults.maxCrosshandSpan

    self.curveFactorX         = self.defaults.curveFactorX
    self.curveFactorY         = self.defaults.curveFactorY
    self.curveY_max           = self.defaults.curveY_max
    self.curveY_min           = self.defaults.curveY_min
    self.curveY_tiltInfluence = self.defaults.curveY_tiltInfluence

    self.musicCutOnFail = self.defaults.musicCutOnFail
end

function Diff:loadValues(values)
    self.minX  = values.minX  or ((values.maxX or self.maxX) - (values.spanX or self.spanX)) or self.minX
    self.spanX = values.spanX or ((values.maxX or self.maxX) - (values.minX  or self.minX )) or self.spanX
    self.maxX  = values.maxX  or ((values.minX or self.minX) + (value.spanX  or self.spanX)) or self.maxX

    self.maxAccelLeft  = values.maxAccelLeft  or values.maxAccel  or values.maxAccelRight  or self.maxAccelLeft
    self.factAccelLeft = values.factAccelLeft or values.factAccel or values.factAccelRight or self.factAccelLeft
    self.minAccelLeft  = values.minAccelLeft  or values.minAccel  or values.minAccelRight  or self.minAccelLeft

    self.maxAccelRight  = values.maxAccelRight  or values.maxAccel  or values.maxAccelLeft  or self.maxAccelRight
    self.factAccelRight = values.factAccelRight or values.factAccel or values.factAccelLeft or self.factAccelRight
    self.minAccelRight  = values.minAccelRight  or values.minAccel  or values.minAccelLeft  or self.minAccelRight

    self.maxAccel  = values.maxAccel  or (((values.maxAccelLeft  or self.maxAccel) + (values.maxAccelRight  or self.maxAccel)) / 2)
    self.factAccel = values.factAccel or (((values.factAccelLeft or self.maxAccel) + (values.factAccelRight or self.maxAccel)) / 2)
    self.minAccel  = values.minAccel  or (((values.minAccelLeft  or self.maxAccel) + (values.minAccelRight  or self.maxAccel)) / 2)

    self.spanScale         = values.spanScale         or self.spanScale
    self.minSpacingSeconds = values.minSpacingSeconds or self.minSpacingSeconds
    self.doubleFactor      = values.doubleFactor      or self.doubleFactor

    self.spanY        = values.spanY        or self.spanY
    self.spanY_random = values.spanY_random or self.spanY_random
    self.spanZ        = values.spanZ        or self.spanZ

    self.chestHeight = values.chestHeight or self.chestHeight
    self.meteorSpeed = values.meteorSpeed or self.meteorSpeed

    self.maxDoubleSpan    = values.maxDoubleSpan    or self.maxDoubleSpan
    self.minDoubleSpan    = values.minDoubleSpan    or self.minDoubleSpan
    self.maxCrosshandSpan = values.maxCrosshandSpan or self.maxCrosshandSpan

    self.curveFactorX         = values.curveFactorX         or self.curveFactorX
    self.curveFactorY         = values.curveFactorY         or self.curveFactorY
    self.curveY_max           = values.curveY_max           or self.curveY_max
    self.curveY_min           = values.curveY_min           or self.curveY_min
    self.curveY_tiltInfluence = values.curveY_tiltInfluence or self.curveY_tiltInfluence

    self.musicCutOnFail = values.musicCutOnFail or self.musicCutOnFail
end
