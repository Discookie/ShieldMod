require("logger")

Diff = {}
Diff.__index = Diff
setmetatable(Diff, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

-- TODO: Finish copypasting from LuaMods.cs and understand it better

Diff.JumpModes = {
    NONE = "none",
    AUTO = "auto",
    MANUAL = "manual",
    RAMPS = "ramps",
    PRESS = "button_press",
    BTN = "button",
    WAKE = "wake",
    WAKE_BTN = "wake_or_button",
}

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

    musicCutOnFail = false,
    advancedSteepAlgo = true,
    downhillOnly = false,

    minSpeed = 0.1,
    avgSpeed = 1.5,
    maxSpeed = 2.9,

    gravity = -0.45,
    uphillScale = 0.8,
    downhillScale = 1.55,
    uphillSmoother = 0.03,
    downhillSmoother = 0.06,

    jumpMode = Diff.JumpModes.NONE,

    calcAntiTraffic = false,
    autoCollisions = true,
    multiLane = true,

    puzzleGrid = false,
    puzzleRows = 7,
    puzzleCols = 3,
    useTraffic = false,
    easyTraffic = false,

    colorCount = 1,
    greyPercent = 0.3,
    randomGreys = false,

    autoOverfillClear = false,
    clearOnlyOverfilledColumn = false,
    fullGridGraceTime = 0,

    blockEnterTime = 0.35,
    blockFallTime = 0.1,
    matchTime = 1.5,

    minBlockCount = 0,
    greyType = 5,
    normalType = 6,
    invertType = 7,

    blocksInLanes = true,
    usePinatas = false,
    useAirBlocks = false,
    useCaterpillars = false,

    displayScoreboard = true,
    showXInARowText = false,

    airStrafing = false,
    canCrash = false,
    canPush = false,
    canScoop = false,
    smoothStrafeToWake = false,

    useJumpMarkers = false,
    minJumpTime = 2.5,
    jumpFixScaler = 1,
    minStrafeSpeed = -1,
    minAirTime = 0.9,
    minHeight = 3.5,
    autoStartJumps = true,

    clearGridOnLanding = true,
    noGraysWhenLanding = true,
    useBlockTrailToOptimalJumps = false,
    removeBlocksNearOptimalJumps = 0,

    minMultiplier = 0,
    launchMultiplier = 1,
    matchMultiplier = 1,
    stealthMultiplier = 1,

    startingScore = 0,
    ptsPerGray = 0,
    ptsPerColor = 0,

    matchSizes = [],
    matchSize = 3,

    maxTricksPerJump = 99,
    finishGamepadJumps = true,
    finishMouseJumps = false,
    timeToSquat = 0,

    gamepadRSSteering = false,
    sideView = false,

    towRopes = false
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
    for (k, v) in pairs(Diff.defaults) do
        self[k] = v
    end

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
end

function Diff:loadValues(values)
    for (k, v) in pairs(values) do
        if type(v) == "string" and (v == "" or v == "default") then
            self[k] = Diff[k]
        end
        self[k] = v
    end
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
end
