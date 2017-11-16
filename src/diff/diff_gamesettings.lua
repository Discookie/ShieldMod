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

Diff.gameSettings_dict = {
            jumpHeightScaler             = "jumpheightscaler",
            gravity                      = "gravity",
            musicCutOnFail               = "allowmusicdroponfail",
            autoOverfillClear            = "preventautomaticoverfillclear",
            useTraffic                   = "usetraffic",
            airStrafing                  = "airstrafing",
            useJumpMarkers               = "usejumpmarkers",
            fullGridGraceTime            = "fullgrid_collectiongracetime",
            smoothStrafeToWake           = "smoothstrafetowake",
            blockFallTime                = "puzzleblockfallinterval",
            blockEnterTime               = "blockflight_secondstopuzzle",
            calcAntiTraffic              = "calculate_antijumps_and_antitraffic",
            autoCollisions               = "automatic_traffic_collisions",
            puzzleGrid                   = "usepuzzlegrid",
            puzzleRows                   = "puzzlerows",
            puzzleCols                   = "puzzlecols",
            clearGridOnLanding           = "cleargridonlanding",
            clearOnlyOverfilledColumn    = "forceclearsinglecolumns",
            autoOverfillClear            = "forcecollectiononoverfill",
            showComboText                = "show_x_in_a_row_text",
            useBlockTrailToOptimalJumps  = "useBlockTrailToOptimalJumps",
            removeBlocksNearOptimalJumps = "removeBlocksNearOptimalJumps",
            usePinatas                   = "usePinatas",
            useAirBlocks                 = "useAirBlocks",
            blocksInLanes                = "blocksInLanes",
            displayScoreboard            = "useLivingScoreboardGhosts",
            canCrash                     = "cancrash",
            canPush                      = "canpush",
            canScoop                     = "canScoop",
            multiLane                    = "multilane",
            colorCount                   = "colorcount",
            greyType                     = "blocktype_grey",
            normalType                   = "blocktype_highway",
            invertType                   = "blocktype_highwayinverted",
            gamepadRSSteering            = "rightsticksteering",
            minBlockCount                = "minvisibletrafficblocks",
            greyPercent                  = "greypercent",
            randomGreys                  = "greyrandomdistribution",
            useCaterpillars              = "usecaterpillars",
            minMultiplier                = "minimummultiplier",
            jumpFixScaler                = "jumpautofixscaler",
            sideView                     = "sideview",
            minStrafeSpeed               = "minstrafespeedforwakejump",
            noGraysWhenLanding           = "degreyatlandingzone",
            launchMultiplier             = "launchtrickmultiplier",
            maxTricksPerJump             = "maxnumtricksperjump",
            finishGamepadJumps           = "autofinishgamepadjumps",
            finishMouseJumps             = "autofinishmousejumps",
            matchMultiplier              = "puzzlematchmultiplier",
            stealthMultiplier            = "stealthscoremultiplier",
            timeToSquat                  = "secondstoblockjumpsafterlanding",
            easyTraffic                  = "easytraffic",
            autoStartJumps               = "autostartlaunchtricksforheldbuttons",
            jumpMode                     = "jumpmode",
            minJumpTime                  = "minimumjump_airtime",
            minHeight                    = "minimumjump_height",
            startingScore                = "startingscore",
            ptsPerGrey                   = "pointspergrey",
            ptsPerColor                  = "pointspercolor",
            matchTime                    = "matchcollectionseconds",
            matchSize                    = "minmatchsizes",
            greyAction                   = "greyaction",
            trickScoreWindow             = "usetrickscorewindow",
            trickDurations               = "trickdurations",
            trickPoints                  = "trickpoints",
            minSpeed                     = "playerminspeed",
            maxSpeed                     = "playermaxspeed",
            minBestJumpTime              = "minimumbestjumptime",
            uphillScale                  = "uphilltiltscaler",
            downhillScale                = "downhilltiltscaler",
            uphillSmoother               = "uphilltiltsmoother",
            downhillSmoother             = "downhilltiltsmoother",
            advancedSteepAlgo            = "useadvancedsteepalgorithm",
            downhillOnly                 = "alldownhill",
            greyRailBlocks               = "railedblockscanbegrey",
            compressTraffic              = "trafficcompression",
            compressWater                = "watercompression",
            autoCenter                   = "autocenter",
            maxStrafe                    = "maxstrafe",
            snowboardPhysics             = "usesnowboardphysics",
            numBinsForFreq               = "freqtrafficbins",
            logSpacedFreqBin             = "freqtrafficbins_logspaced"
        }

Diff.defaults_gameSettings = {

    musicCutOnFail = false,
    advancedSteepAlgo = true,
    downhillOnly = false,

    minSpeed = 0.1,
    maxSpeed = 2.9,

    gravity = -0.45,
    uphillScale = 0.8,
    downhillScale = 1.55,
    uphillSmoother = 0.03,
    downhillSmoother = 0.06,

    jumpMode = Diff.JumpModes.AUTO,

    calcAntiTraffic = false,
    autoCollisions = true,
    multiLane = true,

    puzzleGrid = true,
    puzzleRows = 7,
    puzzleCols = 3,
    useTraffic = true,
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

    --[[trickPoints = {
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
    matchSizes = {},--]]
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

Diff.external_gameSettings = {
	musicCutOnFail = true,

	minSpeed = true,
	maxSpeed = true,

    gravity = true,
    uphillScale = true,
    downhillScale = true,
    uphillSmoother = true,
    downhillSmoother = true,

	displayScoreboard = true,
	showComboText = true
}

table.merge(Diff.defaults, Diff.defaults_gameSettings)
table.merge(Diff.external, Diff.external_gameSettings)

function Diff:doSettings()
    local gsTable = {}
    for k,v in pairs(Diff.gameSettings_dict) do
        if self[k] ~= Diff.defaults[k] then
            gsTable[v] = self[k]
        end
    end
    GameplaySettings(gsTable)
end

Diff._init_gameSettings = Diff.init

Diff.init = function(...)
    local self = Diff._init_gameSettings(...)
    self._id = EventHandler.instance:on(Events.INIT, self.doSettings, self)
    return self
end
