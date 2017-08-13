require("../utils/tablemerge")
require("diff")
require("../events")

-- Used in GameplaySettings()
-- TODO: Finish copypasting from LuaMods.cs and understand it better

Diff.JumpModes = {
    NONE = "none",
    AUTO = "auto",
    MANUAL = "manual",
    RAMPS = "ramps",
    PRESS = "button_press",
    BTN = "button",
    WAKE = "wake",
    WAKE_BTN = "wake_or_button"
}

-- The groups do the same thing, just have different names for them
Diff.GreyActions = {
    CLOG      = "permanent",
    STUCK     = "permanent",
    PERMANENT = "permanent",

    ERASE_ONE    = "erasesingle",
    ERASE_SINGLE = "erasesingle",
    ERASE_BLOCK  = "erasesingle",

    ERASE_COLUMN = "erasecolumn",

    ERASE_GRID = "eraseall",
    ERASE_ALL  = "eraseall",

    DEFAULT      = "default",
    STAY_IN_GRID = "default"
}

Diff.defaults_gameSettings = {

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
    greyAction = Diff.GreyActions.DEFAULT,
    greyRailBlocks = true,

    autoOverfillClear = false,
    clearOnlyOverfilledColumn = false,
    fullGridGraceTime = 0,

    blockEnterTime = 0.35,
    blockFallTime = 0.1,
    matchTime = 1.5,

    minBlockCount = 0,
    minBestJumpTime = 2.5,

    greyType = 5,
    normalType = 6,
    invertType = 7,

    blocksInLanes = true,
    usePinatas = false,
    useAirBlocks = false,
    useCaterpillars = false,

    displayScoreboard = true,
    showComboText = false,

    airStrafing = false,
    canCrash = false,
    canPush = false,
    canScoop = false,
    smoothStrafeToWake = false,
    showboardPhysics = false,

    useJumpMarkers = false,
    minJumpTime = 2.5,
    jumpFixScaler = 1,
    jumpHeightScaler = 1,
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
    trickScoreWindow = true,

    startingScore = 0,
    ptsPerGray = 0,
    ptsPerColor = 0,

    trickPoints = {
        400,
        1000,
        3000,
        10000
    },
    trickDurations = {
        1,
        2,
        3,
        5
    },
    matchSizes = {},
    matchSize = 3,

    maxTricksPerJump = 99,
    finishGamepadJumps = true,
    finishMouseJumps = false,
    timeToSquat = 0,

    autoCenter = true,
    gamepadRSSteering = false,

    sideView = false,
    compressTraffic = 0.65,
    compressWater = 0.45,

    numBinsForFreq = 256,
    logSpacedFreqBins = false
}

table.merge(Diff.defaults, Diff.defaults_gameSettings)

function Diff:doSettings()
    GameplaySettings({
            jumpheightscaler                    = self.jumpHeightScaler,
            gravity                             = self.gravity,
            allowmusicdroponfail                = self.musicCutOnFail,
            preventautomaticoverfillclear       = self.autoOverfillClear,
            usetraffic                          = self.useTraffic,
            airstrafing                         = self.airStrafing,
            usejumpmarkers                      = self.useJumpMarkers,
            fullgrid_collectiongracetime        = self.fullGridGraceTime,
            smoothstrafetowake                  = self.smoothStrafeToWake,
            puzzleblockfallinterval             = self.blockFallTime,
            blockflight_secondstopuzzle         = self.blockEnterTime,
            calculate_antijumps_and_antitraffic = self.calcAntiTraffic,
            automatic_traffic_collisions        = self.autoCollisions,
            usepuzzlegrid                       = self.puzzleGrid,
            puzzlerows                          = self.puzzleRows,
            puzzlecols                          = self.puzzleCols,
            cleargridonlanding                  = self.clearGridOnLanding,
            forceclearsinglecolumns             = self.clearOnlyOverfilledColumn,
            forcecollectiononoverfill           = self.autoOverfillClear,
            show_x_in_a_row_text                = self.showComboText,
            useBlockTrailToOptimalJumps         = self.useBlockTrailToOptimalJumps,
            removeBlocksNearOptimalJumps        = self.removeBlocksNearOptimalJumps,
            usePinatas                          = self.usePinatas,
            useAirBlocks                        = self.useAirBlocks,
            blocksInLanes                       = self.blocksInLanes,
            useLivingScoreboardGhosts           = self.displayScoreboard,
            cancrash                            = self.canCrash,
            canpush                             = self.canPush,
            canScoop                            = self.canScoop,
            multilane                           = self.multiLane,
            colorcount                          = self.colorCount,
            blocktype_grey                      = self.greyType,
            blocktype_highway                   = self.normalType,
            blocktype_highwayinverted           = self.invertType,
            rightsticksteering                  = self.gamepadRSSteering,
            minvisibletrafficblocks             = self.minBlockCount,
            greypercent                         = self.greyPercent,
            greyrandomdistribution              = self.randomGreys,
            usecaterpillars                     = self.useCaterpillars,
            minimummultiplier                   = self.minMultiplier,
            jumpautofixscaler                   = self.jumpFixScaler,
            sideview                            = self.sideView,
            minstrafespeedforwakejump           = self.minStrafeSpeed,
            degreyatlandingzone                 = self.noGraysWhenLanding,
            launchtrickmultiplier               = self.launchMultiplier,
            maxnumtricksperjump                 = self.maxTricksPerJump,
            autofinishgamepadjumps              = self.finishGamepadJumps,
            autofinishmousejumps                = self.finishMouseJumps,
            puzzlematchmultiplier               = self.matchMultiplier,
            stealthscoremultiplier              = self.stealthMultiplier,
            secondstoblockjumpsafterlanding     = self.timeToSquat,
            easytraffic                         = self.easyTraffic,
            autostartlaunchtricksforheldbuttons = self.autoStartJumps,
            jumpmode                            = self.jumpMode,
            minimumjump_airtime                 = self.minJumpTime,
            minimumjump_height                  = self.minHeight,
            startingscore                       = self.startingScore,
            pointspergrey                       = self.ptsPerGrey,
            pointspercolor                      = self.ptsPerColor,
            matchcollectionseconds              = self.matchTime,
            minmatchsizes                       = self.matchSize,
            greyaction                          = self.greyAction,
            usetrickscorewindow                 = self.trickScoreWindow,
            trickdurations                      = self.trickDurations,
            trickpoints                         = self.trickPoints,
            playerminspeed                      = self.minSpeed,
            playermaxspeed                      = self.maxSpeed,
            minimumbestjumptime                 = self.minBestJumpTime,
            uphilltiltscaler                    = self.uphillScale,
            downhilltiltscaler                  = self.downhillScale,
            uphilltiltsmoother                  = self.uphillSmoother,
            downhilltiltsmoother                = self.downhillSmoother,
            useadvancedsteepalgorithm           = self.advancedSteepAlgo,
            alldownhill                         = self.downhillOnly,
            railedblockscanbegrey               = self.greyRailBlocks,
            trafficcompression                  = self.compressTraffic,
            watercompression                    = self.compressWater,
            autocenter                          = self.autoCenter,
            -- maxstrafe                        = self.maxStrafe, -- is different when not set from mod
            usesnowboardphysics                 = self.snowboardPhysics,
            freqtrafficbins                     = self.numBinsForFreq,
            freqtrafficbins_logspaced           = self.logSpacedFreqBins
        })
end

Diff._init_gameSettings = Diff.init

Diff.init = function(...)
    local self = Diff._init_gameSettings(...)
    self._id = EventHandler.instance:on(Events.INIT, self.doSettings, self)
    return self
end
