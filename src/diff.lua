--[[
    Difficulty settings - check README.url for options!
--]]

maxAccelLeft = 7      -- Left hand max acceleration => change this if too fast
factAccelLeft = 0.6   -- Left hand factor - shouldn't touch
minAccelLeft = 0      -- Left hand min acceleration - mustn't touch
maxAccelRight = 7     -- Right hand max acceleration => change this if too fast
factAccelRight = 0.6  -- Right hand factor - shouldn't touch
minAccelRight = 0     -- Right hand min acceleration - mustn't touch

impactX_Scaler = 1.7  -- Armspan multiplier => change this if too wide

minSpacingSeconds = 0 -- Minimum spacing => change this if too dense

doubleFactor = 0.2

--[[
Other values - not recommended to change them
--]]

chestHeight = 1.3
curveFactorX = 100
curveFactorY = 170
curveY_Max = 75
curveY_Min = 17
curveY_tiltInfluence = .8
maxNodeDistShown = 1500
meteorSpeed = .09
blueMinX = -.5
blueSpanX = 1
redMinX = -.5
redSpanX = 1
purpleMaxX = .5
purpleSpanX = -1
yImpactSpan = .5
yImpactSpan_MaxRandomExtra = .1
zImpact = .7
maxNeighborXspan = 1
maxMirroredX = .5

convertPurplesToCrossUps = false

allowMusicCutOutOnFail=false

--[[
    Parser to have easier access to each param
--]]
