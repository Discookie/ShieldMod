--[[

INSANE MOD - created by Discookie

Based on Normal ShieldVR and Expert mods

Released under the MIT license

https://matekos17.f.fazekas.hu/shield/

Special thanks to: /u/Zerkses, /u/Flatlander57

Version 0.40a, last modified: 2017.05.29.
--]]


function CreateLogger (logLevel)
    if logLevel == nil then
        logLevel = 5
    end
    -- Declarations:

    Logger = {}
    Logger.__index = Logger

    --Defining a constructor, for custom printing
    setmetatable(Logger, {
            __call = function(cls, ...)
                return cls.init(...)
            end,
    })

    -- Get system date
    function Logger:getDate()
        return Logger.getDate()
    end

    function Logger.getDate()
        return ""
        --return os.date("%c ") -- %c prints full "d/a/te t:i:me" and an extra space
    end

    -- Using log4j error levels, refer to self.enabled = true 
    -- https://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/Level.html
    function Logger:exc(msg)
        self:fatal(msg)
    end
    function Logger:exception(msg)
        self:fatal(msg)
    end
    function Logger:fatal(msg)
        if logLevel > 0 then
            print(self:getDate() .. " [FATAL] <" .. self.name .. ">: " .. msg)
        end
        return false
    end

    function Logger:err(msg)
        self:error(msg)
        return false
    end
    function Logger:error(msg)
        if logLevel > 1 then
            print(self:getDate() .. " [ERROR] <" .. self.name .. ">: " .. msg)
        end
        return false
    end

    function Logger:warning(msg)
        return self:warn(msg)
    end
    function Logger:warn(msg)
        if logLevel > 2 then
            print(self:getDate() .. " [WARN] <" .. self.name .. ">: " .. msg)
        end
        return false
    end

    function Logger:log(msg)
        if self.enabled then 
            return self:info(msg)
        end
    end
    function Logger:info(msg)
        if logLevel > 3 then
            --print(self:getDate() .. " [INFO] <" .. self.name .. ">: " .. msg)
            print(msg)
        end
        return false
    end

    function Logger:dbg(msg)
        return self:debug(msg)
    end
    function Logger:debug(msg)
        if logLevel > 4 then
            print(self:getDate() .. " [DEBUG] <" .. self.name .. ">: " .. msg)
        end
        return false
    end

    function Logger:trace(msg, lvl)
        if (lvl == nil and logLevel > 7) or logLevel > 4+lvl then
            print(self:getDate() .. " [TRACE] <" .. self.name .. ">: " .. msg)
        end
        return false
    end

    function Logger:cName(name)
        return self:changeName(name)
    end
    function Logger:changeName(name)
        if type(name) ~= "string" then
            self.name = "unknown"
            return true
        else
            self.name = name
            return false
        end
    end

    function Logger.init(name)
        local self = setmetatable({}, Logger)
        self.type = "Logger"
        self.enabled = true
        
        if type(name) ~= "string" then
            self.name = "unknown"
        else
            self.name = name
        end
        
        return self
    end
    lg = Logger("MyLogger")
    return lg
end

maxAccelLeft = 7      -- Left hand max acceleration => change this if too fast
factAccelLeft = 0.6   -- Left hand factor - shouldn't touch
minAccelLeft = 0      -- Left hand min acceleration - mustn't touch
maxAccelRight = 7     -- Right hand max acceleration => change this if too fast
factAccelRight = 0.6  -- Right hand factor - shouldn't touch
minAccelRight = 0     -- Right hand min acceleration - mustn't touch

impactX_Scaler = 1.6  -- Armspan multiplier => change this if too wide

minSpacingSeconds = 0 -- Minimum spacing => change this if too dense

doubleFactor = 0.2

--[[
Other values - not recommended to change them
--]]

chestHeight = 1.3           -- If notes aren't hitting your chest height
curveFactorX = 100          -- Shouldn't change this
curveFactorY = 170          -- Shouldn't change this
curveY_Max = 75             -- If notes are coming from too high
curveY_Min = 17             -- If notes are coming from too low
curveY_tiltInfluence = .8   -- If notes are too steep
maxNodeDistShown = 1500     -- If lagging like hell
meteorSpeed = .09           -- If meteors are coming too fast
blueMinX = -.5               -- Shouldn't change this
blueSpanX = 1              -- Shouldn't change this
redMinX = -.5               -- Shouldn't change this
redSpanX = 1                -- Shouldn't change this
purpleMaxX = .5             -- Shouldn't change this
purpleSpanX = -1            -- Shouldn't change this
yImpactSpan = .5            -- Shouldn't change this yet
yImpactSpan_MaxRandomExtra = .1 -- Shouldn't change this yet
zImpact = .7                -- Mustn't change this
maxNeighborXspan = 1        -- Shouldn't change this
maxMirroredX = .5           -- Shouldn't change this

convertPurplesToCrossUps = false    -- Mustn't change this

allowMusicCutOutOnFail=false    -- If you like to hear when you miss

--[[
Mustn't change anything below this point!
--]]

function fif(test, if_true, if_false)
  if test then return if_true else return if_false end
end

function MiniTrace(text, level)
    return (string.rep(">>", level).." "..text.."\n")
end
function DumpTrace(tbl, level)
  local ret = ""
  if not level then level = 1 end
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      ret = ret..MiniTrace(tostring(k).." = TABLE:", level) 
      ret = ret..DumpTrace(v, level+1)
    elseif type(v) == 'boolean' then
      ret = ret..MiniTrace(tostring(k).." = "..tostring(v), level)      
    else
      ret = ret..MiniTrace(tostring(k).." = "..v, level) 
    end
  end
  return ret
end

GameplaySettings{
        allowmusicdroponfail = allowMusicCutOutOnFail,
        jumpmode="none",
        gravity=-.45,
        playerminspeed = 0.1,
        playermaxspeed = 2.9,
        minimumbestjumptime = 2.5,
        uphilltiltscaler = 0.8,
        downhilltiltscaler = 1.55,
        uphilltiltsmoother = 0.03,
        downhilltiltsmoother = 0.06,
        useadvancedsteepalgorithm = true,
        alldownhill = false,
        usepuzzlegrid = false,
        usetraffic = false,
        towropes = false
}

nodes = nodes or {} 
nodechaincount = nodechaincount or {}

function FindTrackSpan(start, preseconds, postseconds)
    local bound = start
    local newstart = start

    local preTime = track[start].seconds + preseconds
    for i = start, 1,-1 do
        if track[i].seconds <= preTime then
            newstart = i
            break
        end
    end

    local postTime = track[start].seconds + postseconds;
    for i = start, #track do
        if track[i].seconds >= postTime then
            bound = i
            break
        end
    end

    return newstart, bound
end

function TryMarkSpan(start, bound, jumporduck)
    --local flag = false
    --if start > 5300 and bound < 5500 then
    --    flag = true
    --end

    --if flag then print("TryMarkSpan start:"..start.." bound:"..bound.." type:"..jumporduck) end
    --whenever a span is placed, it's responsible for blocking spacing time in front of itself
    local preStart, postBound = FindTrackSpan(start,-minSpacingSeconds,0)
    --Highway.TwoInts ti = Highway.Instance.FindStartEndSpanForDuration(start, -minSpacingSeconds, 0)
    --int preStart = ti.start;
    if (preStart == start) or (preStart==(start-1)) then
        preStart = math.max(1, start - 2)
    end

    if start==bound then--just wants to add a single block, special case to make sure only one block is added
        --if flag then print("solo path") end
        local allgood=true
        for i=preStart,start do
            if nodes[i] ~= nil then
                allgood=false
                break
            end
        end

        if allgood then
            for i=preStart,start do
                --if flag then print("add dirty at "..i) end
                nodes[i] = 'dirty'
                nodechaincount[i] = -1
            end
            --if flag then print("add "..jumporduck.." at "..start) end
            nodes[start] = jumporduck
            nodechaincount[start] = -1
        end
    else
        --if flag then print("multi path") end
        local startTime = -1;
        local started = false;
        for i = preStart, bound do
            if nodes[i] == nil then --this node is not claimed by a jump, duck, or buffer yet
                if not started then
                    started = true
                    startTime = track[i].seconds
                    nodes[i] = 'dirty'--at least one empty node in front of the span
                    --if flag then print("add dirty at "..i) end
                    nodechaincount[i] = -1
                else
                    if (track[i].seconds >= (startTime + minSpacingSeconds)) and (i>=start) then
                        nodes[i] = jumporduck
                        --if flag then print("add "..jumporduck.." at "..i) end
                    else
                        nodes[i] = 'dirty'
                        --if flag then print("add dirty at "..i) end
                    end
                    if bound - preStart > 4 then
                        nodechaincount[i] = bound - i
                    else
                        nodechaincount[i] = -1
                    end
                end
            else
                if started then
                    break--stop marking, ran into another (higher priority) span
                end
            end
        end
    end
end

function CompareJumpTimes(a,b) --used to sort the track nodes by jump duration
    return a.jumpairtime > b.jumpairtime
end

function CompareStrengths(a,b) --used to sort the track nodes by jump duration
    return a.strength > b.strength
end

powernodes = powernodes or {}
track = track or {}
traffic = traffic or {}
maxTilt = 0
minTilt = 0

function OnTrackCreated(theTrack)--track is created before the traffic
    print("LUA OnTrackCreated")
    track = theTrack --store globally
    local songMinutes = track[#track].seconds / 60

    for i=1,#track do
        track[i].jumpedOver = false -- if this node was jumped over by a higher proiority jump
        track[i].origIndex = i
    end

    --find the best jumps path in this song
    local strack = deepcopy(track)
    table.sort(strack, CompareJumpTimes)

    for i=1,#strack do
        maxTilt = math.max(maxTilt, strack[i].tilt)
        minTilt = math.min(minTilt, strack[i].tilt)
        if strack[i].jumpairtime >= 2.5 then --only consider jumps of at least this amount of air time
            if not track[strack[i].origIndex].jumpedOver then
                local flightPathClear = true
                local jumpEndSeconds = strack[i].seconds + strack[i].jumpairtime + 10
                for j=strack[i].origIndex, #track do --make sure a higher priority jump doesn't happen while this one would be airborne
                    if track[j].seconds <= jumpEndSeconds then
                        if track[j].jumpedOver then
                            flightPathClear = false
                        end
                    else
                        break
                    end
                end
                if flightPathClear then
                    -- if #powernodes < (songMinutes + 2) then -- allow about one power node per minute of music
                    if #powernodes < (songMinutes+2) then -- allow about one power node per minute of music
                        if strack[i].origIndex > 300 then
                            --check if this is a real transition point in the song. The nodes before it should be uphill and the nodes after it should be downhill
                            local avgSlopePrev = 0
                            local avgSlopePost = 0
                            local slopeTestCount = 100

                            local strt = math.max(1, strack[i].origIndex-slopeTestCount)
                            local bnd = strack[i].origIndex
                            for ii=strt,bnd do
                                avgSlopePrev = avgSlopePrev + track[ii].tilt
                            end
                            strt = strack[i].origIndex
                            bnd = math.min(#track-1, strack[i].origIndex+slopeTestCount)
                            for ii=strt,bnd do
                                avgSlopePost = avgSlopePost + track[ii].tilt
                            end

                            avgSlopePrev = avgSlopePrev    / slopeTestCount
                            avgSlopePost = avgSlopePost / slopeTestCount
                            --print("avgSlopePrev:"..avgSlopePrev)
                            --print("avgSlopePost:"..avgSlopePost)

                            if (avgSlopePrev < 5 and avgSlopePost >15) or (i==1) then -- only take slope qualifiers. Also, always take the biggest jump
                                powernodes[#powernodes+1] = strack[i].origIndex
                            end
                        end
                        local extraJumpOverBufferSec = 10
                        jumpEndSeconds = strack[i].seconds + strack[i].jumpairtime + extraJumpOverBufferSec
                        for j=strack[i].origIndex, #track do
                            if track[j].seconds <= jumpEndSeconds then
                                track[j].jumpedOver = true --mark this node as jumped over (a better jump took priority) so it is not marked as a powernode
                            else
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

meteorNodes = meteorNodes or {} -- declare tables this way to support (possible) future live code reloading
meteorImpacts = meteorImpacts or {}
meteorSpeeds = meteorSpeeds or {}
meteorDirections = meteorDirections or {}
meteorCurveMaximums = meteorCurveMaximums or {}
meteorScales = meteorScales or {}
meteorColors = meteorColors or {}
meteorAlbedoColors = {}
meteorTypes = {}
--nodeAttackAngles = nodeAttackAngles or {} -- for each track node, a list of what angles meteors attack from
--nodeAttackSizes = nodeAttackSizes or {} -- for each track node, what size the metoers impacting at that time are

meteorNodes_tails = meteorNodes_tails or {} -- declare tables this way to support (possible) future live code reloading
meteorImpacts_tails = meteorImpacts_tails or {}
meteorSpeeds_tails = meteorSpeeds_tails or {}
meteorDirections_tails = meteorDirections_tails or {}
meteorCurveMaximums_tails = meteorCurveMaximums_tails or {}
meteorScales_tails = meteorScales_tails or {}
meteorColors_tails = meteorColors_tails or {}
meteorAlbedoColors_tails = {}
meteorTypes_tails = {}

function OnTrafficCreated(theTraffic)
    traffic = theTraffic --store globally
    lg = CreateLogger()
    lg.enabled = true
    -- \mod
    math.randomseed(math.floor(track[#track].seconds * 10000000000))
    --math.randomseed(11)

    local minimapMarkers = {}
    for j=1,#powernodes do --insert powernode spans. They're top priority, so do them first
        local prev = 2
        for i=prev, #traffic do
            if traffic[i].chainend >= powernodes[j] then
                local spanDist = traffic[i].chainend - traffic[i].chainstart
                if spanDist > 5 then -- never make a tiny chain into a rave
                    --if traffic[i].chainstart <= powernodes[j] then
                    TryMarkSpan(traffic[i].chainstart, traffic[i].chainend, 'purple')
                    --else
                    --    local strt = math.max(1,powernodes[j]-3)
                    --    local bnd = math.min(#track-1, powernodes[j]+3)
                    --    TryMarkSpan(strt, bnd, 'purple')
                    --end
                    prev = i
                    table.insert(minimapMarkers, {tracknode=powernodes[j], startheight=0, endheight=fif(j==1, 15, 11), color={233,233,233}})
                end

                break
            end
        end
    end

    --figure out where to put jumps and ducks
    local longestSpan = 0
    local longestSpanStart = 0
    local longestSpanEnd = 0
    for i = 1, #traffic do
        local spanDist = traffic[i].chainend - traffic[i].chainstart
        if spanDist > longestSpan then
            longestSpan = spanDist
            longestSpanStart = traffic[i].chainstart
            longestSpanEnd = traffic[i].chainend
        end
        if spanDist > 2 then
            if spanDist > 10 then --long ones are more likely ducks
                local spanType = (math.random() > 0.5) and 'blue' or 'red'
                --if (traffic[i].strength > .95) and (math.random()>.9) then -- high speed areas may get additional rave sections
                --    spanType = 'purple'
                --    table.insert(minimapMarkers, {tracknode=traffic[i].chainstart, startheight=0, endheight=11, color={233,233,233}})
                --end
                TryMarkSpan(traffic[i].chainstart, traffic[i].chainend, spanType)
            else --shorter ones are more likely jumps
                TryMarkSpan(traffic[i].chainstart, traffic[i].chainend, (math.random() > 0.5) and 'blue' or 'red')
            end
        end
    end

    --if longestSpan > 0 then
    --    for i=longestSpanStart, longestSpanEnd do -- turn the longest span into a rave (if it isn't already)
    --        if nodes[i]=='blue' or nodes[i]=='red' then
    --            nodes[i] = 'purple'
    --        end
    --    end
    --
    --    table.insert(minimapMarkers, {tracknode=longestSpanStart, startheight=0, endheight=11, color={233,233,233}})
    --end

    local straffic = deepcopy(traffic)
    table.sort(straffic, CompareStrengths)

    for i = 1,#straffic do --mark these in their own loop. they're lower priority. place them in strength order to make sure the most important ones aren't overlapped and removed
        if (straffic[i].chainend - straffic[i].chainstart) < 3 then
            TryMarkSpan(straffic[i].impactnode, straffic[i].impactnode, (math.random() > 0.5) and 'blue' or 'red')
        end
    end

    for i=1,#traffic do
        --if nodes[i]==nil or nodes[i]=='dirty'
        if (nodes[i] ~= 'blue') and (nodes[i]~='red') and (nodes[i]~='purple') then
            nodes[i] = 'run' -- all non-action nodes get marked as 'run' in order to track the player's efficiency bonus
        end
    end
    --print("initialized player nodestates")
    --for jj=1, #players do
    --    local player = players[jj]
    --    for ii=1,#track do
    --        player.nodestates[ii] = 'run'
    --    end
    --end

    AddMinimapMarkers(minimapMarkers)
end

function InitMeteors()
    local playerHeight_impactYCompensator = 0 -- this is now handled in c#


    local sqrt = math.sqrt --making a local copy of global functions improves performance a bit
    local rand = math.random
    local min = math.min
    local max = math.max
    local sin = math.sin
    local cos = math.cos
  
    local degreesToRadians = .0174532925

    local chainstarter = true
    local heading
    local headingNormalized
    local lastSentNode
    local color = {255,255,255}
    local typeID
    local mirrorTypeID
    local scale = {.04,.04,.04}
    local prevBlockType = 'blue'
    local prevBlockSongTime = 0
    local prevBlockImpactX = 0
    local renderThisChain = true
    local mirrorThisChain = false
    local yDupOffset = 0;
    local xMirrorOffset = 0;
    local mirrorColor
    local mirrorScale
    local blueColor = {53,141,255} -- {53,141,173}
    local blueScale = {.035,.035,.035}
    --local redColor = {255,53,53} -- {176,53,53}
    local redColor = {255,52,0} 
    local redScale = {.035,.035,.035}
    local purpleColor = {103,53,176}
    local purpleScale = {.06,.06,.06}
    local impactX, impactY
    local isGroundTroop = false
    --local curveFactorX = 100
    --local curveFactorY = 35
    local impactY_BeyondChestHeight = 0
    local intensityFactor = 0
    local intensityFactorExp = 0

    local impactProxyScales = {}
    local impactProxyVelocities = {}
    local impactProxyScale = {.005,.005,.005}
    local idInThisChain = 1

    local nextChainStartTime = 0
    local yCurve = 0;
    local adjustedImpactY = 0

    local isBallChain = false
    local isExtraLongBallChain = false
    local sweepDir = 1
    local sweepPosX = 0
    local prevBlockIsBallChain = false
    local prevBallChainDirection = 0
    -- \mod
    local prevBluePosition = 0
    local prevRedPosition = 0
    local prevBlueTime = -5
    local prevRedTime = -5
    local dumpEnvironment = true
    local minRequiredStrafeForMirroring = .25
    local forceMirrorOn 
    local minSpacingAfterRaveBlock = 0.00
    local chainType 
    local impactDir
  local nodeLeaders =  {}
    local nodeValidity=  {}
    local chainLengths=  {}
    local tiltFactors= {}
    local intensityFactors=  {}
    local myChainEndTimes=  {}
    local nextChainStarters=  {}
    -- //////////////////////////////////////////////////
    -- AUXILIARY FUNCTION BLOCK. READ BELOW FOR MAIN LOOP
    -- //////////////////////////////////////////////////
    local nodeTypes = {}
    nodeTypes.blue = {}
    nodeTypes.red = {}
    nodeTypes.purple = {}
    nodeTypes['blue'].color = blueColor
    nodeTypes['blue'].scale = blueScale
    nodeTypes['blue'].typeID = 0
    nodeTypes['blue'].mirrorTypeID = 1
    
    nodeTypes['red'].color = redColor
    nodeTypes['red'].scale = redScale
    nodeTypes['red'].typeID = 1
    nodeTypes['red'].mirrorTypeID = 0
    
    nodeTypes['purple'].color = purpleColor
    nodeTypes['purple'].scale = purpleScale
    nodeTypes['purple'].typeID = 2
    nodeTypes['purple'].mirrorTypeID = 2
    local adjustedZImpact
    function ValidNode(nodeIndex)
        local result = nodes[nodeIndex]~=nil and nodes[nodeIndex]~='run' and nodes[nodeIndex]~='dirty'
        --local result = false
        return result
    end
    function CalculateChainsAndIntensities()
        local k=1
        local chainLength = 0
        local nextValidNodeIsChainStater = true
        local currentLeader = -1
        local tiltFactor = 0
        local maxTiltSpan = maxTilt - minTilt
        local chainlength
        while k<=#track  do --use the biggest intensity found in the span
            chainLengths[k] = 0
            if ValidNode(k) then
                nodeValidity[k]    = true
                if nextValidNodeIsChainStater == true then
                    if currentLeader ~= -1 then
                        nextChainStarters[currentLeader] = k
                    end
                    chainlength = 0
                    currentLeader = k
                    nextValidNodeIsChainStater = false
                end
                local myTiltSpan = track[k].tilt - minTilt
                tiltFactor = max(tiltFactor, myTiltSpan/maxTiltSpan)
                tiltFactors[k] = tiltFactor
                tiltFactors[currentLeader] = tiltFactor
                intensityFactor = max(intensityFactor, track[k].intensity)
                intensityFactors[currentLeader] = intensityFactor
                intensityFactors[k] = intensityFactor
                myChainEndTimes[k] = track[k].seconds -- above 1 line?
                myChainEndTimes[currentLeader] = track[k].seconds -- above 1 line?
                chainLength=chainLength + 1
                chainLengths[currentLeader] = chainLength
                nodeLeaders[k] = currentLeader
            else
                nodeValidity[k]    = false
                nextValidNodeIsChainStater = true
                tiltFactor = 0
                chainLength = 0
                intensityFactors[k] = 0
                intensityFactor=0
                nodeLeaders[k] = -1
            end
            k = k + 1
        end
        nextChainStarters[#nextChainStarters+1] = -1
        do return end
    end
    
    function InitNewChain(i)
        isBallChain = false -- most of them are squids, not ball chains
        isExtraLongBallChain = false
        if nodeLeaders[i] > 0 and nodeLeaders[i] < #track and nextChainStarters[nodeLeaders[i]] ~= nil and  nextChainStarters[nodeLeaders[i]] > 0 then
            nextChainStartTime = track[nextChainStarters[nodeLeaders[i]]].seconds
            --print("Node: "..i.." Leader: "..nodeLeaders[i].." Next chain starter: "..nextChainStarters[nodeLeaders[i]].." Time: "..track[nextChainStarters[nodeLeaders[i]]].seconds)
        else
            nextChainStartTime =-1
        end
        --nextChainStartTime = track[nextChainStarters[nodeLeaders[i]]].seconds
        heading = {0, 0, -1}
        headingNormalized = heading 
        renderThisChain = true
        mirrorThisChain = false
        isGroundTroop = false
        yDupOffset = 0
        xMirrorOffset = 0
        idInThisChain = 1
    end
    function CalculateImpactForNormalChainStarter(i, prevNodeTime, prevNodePosition, colorMinX,colorSpanX, impactX)
        local delta = math.pow(track[i].seconds - prevNodeTime, 2)
        prevNodeTime = myChainEndTimes[nodeLeaders[i]]
        impactX = prevNodePosition
        local bound1 = math.max(0, math.min(1, math.pow(( ((impactX - colorMinX) / delta) - minAccelRight) / maxAccelRight, 1/factAccelRight) ))
        local bound2 = math.max(0, math.min(1, math.pow(( ((colorSpanX + colorMinX - impactX) / delta) - minAccelRight) / maxAccelRight, 1/factAccelRight) ))
        local modRand = rand()*(bound1+bound2)-bound1

        if (modRand < 0) then
            impactX = impactX - (minAccelRight + maxAccelRight * math.pow(math.abs(modRand), factAccelRight)) * delta
        else
            impactX = impactX + (minAccelRight + maxAccelRight * math.pow(math.abs(modRand), factAccelRight)) * delta
        end
        prevNodePosition = impactX
        return prevNodePosition, prevNodeTime, impactX
    end
    function CalculateImpactForRaveChainStarter(i, prevRedTime, prevRedPosition,prevBlueTime, prevBluePosition, impactX)
        local blueImpact = 0
        local redImpact = 0
        prevBluePosition, prevBlueTime, blueImpact = CalculateImpactForNormalChainStarter(i, prevBlueTime, prevBluePosition, blueMinX, blueSpanX, impactX)
        prevRedPosition, prevRedTime, redImpact = CalculateImpactForNormalChainStarter(i, prevRedTime, prevRedPosition, redMinX, redSpanX, impactX)
        impactX = blueImpact + redImpact / 2
        return impactX,prevBluePosition,prevRedPosition,prevBlueTime,prevRedTime
    end
    
    
    
    --function AssignMeteor(i,impactX, typeId, scale,adjustedImpactY, adjustedZImpact, curveFactorX,  color,yCurve)
    function AssignMeteor(i,impactX, typeID, scale,adjustedImpactY, adjustedZImpact, curveFactorX,  innerColor,yCurve)
        meteorNodes[#meteorNodes+1] = i
        meteorDirections[#meteorDirections+1] = headingNormalized -- {math.random() - .5, 0, math.random() - .5} -- the game normalizes these for us
        meteorImpacts[#meteorImpacts+1] = {impactX, adjustedImpactY, adjustedZImpact}
        meteorScales[#meteorScales+1] = scale
        meteorCurveMaximums[#meteorCurveMaximums+1] = fif(isGroundTroop,{0,0,0},{impactX*curveFactorX, yCurve, 0})--impactY*60
        meteorColors[#meteorColors+1] = innerColor
        meteorAlbedoColors[#meteorAlbedoColors+1] = {255,255,255}
        meteorSpeeds[#meteorSpeeds+1] = meteorSpeed -- fif(isGroundTroop, .025,.05)
        meteorTypes[#meteorTypes+1] = typeID

        impactProxyScales[#impactProxyScales+1] = impactProxyScale
        impactProxyVelocities[#impactProxyVelocities+1] = {0,0,0}
    end
    
    function AssignMeteorTail(i,impactX, typeID, scale,adjustedImpactY, adjustedZImpact, curveFactorX,  mirrorColor,yCurve)
        meteorNodes_tails[#meteorNodes_tails+1] = i
        meteorDirections_tails[#meteorDirections_tails+1] = headingNormalized -- {math.random() - .5, 0, math.random() - .5} -- the game normalizes these for us
        meteorImpacts_tails[#meteorImpacts_tails+1] = {impactX, adjustedImpactY, adjustedZImpact}
        meteorScales_tails[#meteorScales_tails+1] = scale
        meteorCurveMaximums_tails[#meteorCurveMaximums_tails+1] = fif(isGroundTroop,{0,0,0},{impactX*curveFactorX, yCurve, 0})--impactY*60
        meteorColors_tails[#meteorColors_tails+1] = mirrorColor
        meteorAlbedoColors_tails[#meteorAlbedoColors_tails+1] = {255,255,255}
        meteorSpeeds_tails[#meteorSpeeds_tails+1] = meteorSpeed -- fif(isGroundTroop, .025,.05)
        meteorTypes_tails[#meteorTypes_tails+1] = typeID

        impactProxyScales[#impactProxyScales+1] = impactProxyScale
        impactProxyVelocities[#impactProxyVelocities+1] = {0,0,0}
    end
    
    function AssignMeteorAndMirror(assignMeteorFunc,i, adjustedImpactY, adjustedZImpact, curveFactorX, yCurve,
                                        impactX, typeID, scale, color,
                                        mirrorTypeID, mirrorScale, mirrorColor)
        --print("IX"..impactX)
        assignMeteorFunc(i, impactX, typeID, scale,adjustedImpactY, adjustedZImpact, curveFactorX,color,yCurve)
        if mirrorThisChain then
            local mirrorImpactX = -1*impactX
            if xMirrorOffset ~= 0 then
                mirrorImpactX = impactX + xMirrorOffset
            end
            lg:log("Creating a mirror node "..i.." of color: ("..mirrorColor[1].." "..mirrorColor[2].." "..mirrorColor[3]..") ")
            assignMeteorFunc(i, mirrorImpactX, mirrorTypeID, mirrorScale,adjustedImpactY, adjustedZImpact, curveFactorX, mirrorColor,yCurve)
        end
    end
    function ValidNodeInLongChain(isExtraLongBallChain,idInThisChain, divisionFactor)
        return not (isExtraLongBallChain and (idInThisChain>1) and (idInThisChain%divisionFactor==0))
    end
    
    function ProcessFirstNodeOrBallChain(i,adjustedImpactY, adjustedZImpact, curveFactorX, yCurve,
                                impactX,typeID,scale,color,
                                mirrorTypeID,mirrorScale,mirrorColor) 
    
        local allowRender = not (isExtraLongBallChain and (idInThisChain>1) and (idInThisChain%2==0))
        if not allowRender then
            return
        end
        
        --local additionalX_SweepAcross = 0 -- -.005 + idInThisChain * .0015
        local sweptImpactX = impactX
        if isBallChain then
            sweepPosX = sweepPosX + .025 * sweepDir
            if sweepPosX > 1 then
                sweepPosX = 1
                sweepDir = -1
            elseif sweepPosX < -1 then
                sweepPosX = -1
                sweepDir = 1
            end
            sweptImpactX = sweepPosX

            prevBlockImpactX = sweptImpactX
        end
        -- for clarity those assignments have been moved into generalized function
        AssignMeteorAndMirror(AssignMeteor, i,adjustedImpactY, adjustedZImpact, curveFactorX, yCurve,
                                sweptImpactX,typeID,scale,color,
                                mirrorTypeID,mirrorScale,mirrorColor)
    
        return prevBlockImpactX
    end
    function AssignBallChain(i,mirrorThisChain,chainType, chainLength, intensityFactor)    
        if (not mirrorThisChain) and (chainType~='purple') then
            -- intentionally blank
            if (chainLength>11) and (intensityFactor<.6) then
                isBallChain = true
            end
            if (chainLength>22) and (intensityFactor<.9) then
                isBallChain = true
            end
        end
        
        if isBallChain and chainLengths[nodeLeaders[i]]>66 then
            isExtraLongBallChain = true
        end
        return isBallChain,isExtraLongBallChain
    end
    
    function DoMirror(i, forceMirrorOn, chainType, impactX)
        if chainType == 'purple' then
            return impactX
        end
        --local prevRedPosition, prevRedTime, prevBlueTime, prevBluePosition,mirrorScale,mirrorColor
        function AssignImpactMirror(chainType, impactX)
            if chainType=='blue' then
                prevBluePosition = impactX
                prevRedPosition = -impactX
                mirrorScale = redScale
                mirrorColor = redColor
                
            else
                prevBluePosition = -impactX
                prevRedPosition = impactX
                mirrorScale = blueScale
                mirrorColor = blueColor
            end
        end
        
        function CalculateNaturalMirror(i, prevNodeTime, prevNodePosition, colorMinX,colorSpanX, otherBlock)
            local delta = math.pow(track[i].seconds - prevNodeTime, 2)
            prevNodeTime = myChainEndTimes[nodeLeaders[i]]
            local impactX = prevNodePosition
            local bound1 = math.max(0, math.min(1, math.pow(( ((impactX - colorMinX) / delta) - minAccelRight) / maxAccelRight, 1/factAccelRight) ))
            local bound2 = math.max(0, math.min(1, math.pow(( ((colorSpanX + colorMinX - impactX) / delta) - minAccelRight) / maxAccelRight, 1/factAccelRight) ))
            local oB1 = math.pow(( (math.abs(otherBlock + 0.05 - impactX) / delta) - minAccelRight) / maxAccelRight, 1/factAccelRight)
            local oBS1 = (otherBlock + 0.05 - impactX) / math.abs(otherBlock + 0.05 - impactX)
            local oB2 = math.pow(( (math.abs(otherBlock + 0.05 - impactX) / delta) - minAccelRight) / maxAccelRight, 1/factAccelRight)
            local oBS2 = (otherBlock + 0.05 - impactX) / math.abs(otherBlock + 0.05 - impactX)
            local modRand = rand()*(bound1+bound2)-bound1
            if (oB1>bound1 and oBS1<0 and oB2>bound2 and oBS2>0) then 
                return false, 0, 0, 0
            end
            
            if (oB1>bound1) then
                bound1 = min(oB2, bound1)
            elseif (oB2>bound2) then
                bound2 = min(oB1, bound2)
            else
                modRand = rand()*(bound1+bound2 - 0.1)-bound1 + 0.05
                if (modRand < oB1*oBS1) then
                    modRand = modRand - 0.05 
                end
                if (modRand > oB2*oBS2) then
                    modRand = modRand + 0.05
                end
            end
            
            if (modRand < 0) then
                impactX = impactX - (minAccelRight + maxAccelRight * math.pow(math.abs(modRand), factAccelRight)) * delta
            else
                impactX = impactX + (minAccelRight + maxAccelRight * math.pow(math.abs(modRand), factAccelRight)) * delta
            end
            prevNodePosition = impactX
            return true, prevNodePosition, prevNodeTime, impactX
        end
        
        local naturalMirror = math.abs(impactX) >= minRequiredStrafeForMirroring    
        if forceMirrorOn then 
            lg:log("Is natural mirror"..tostring(naturalMirror))
        end
        --[[if (intensityFactors[i] > .75) or forceMirrorOn then -- big hit, end of song, or before a gap
            if not naturalMirror and forceMirrorOn then
                if math.abs(impactX)< minRequiredStrafeForMirroring then
                    if (impactX < 0) then
                       impactX = - minRequiredStrafeForMirroring - .01
                    else
                       impactX = minRequiredStrafeForMirroring + .01
                    end
                    --if chainType == 'red' then
                        lg:log("Type 1 Mirroring chain: "..i) 
                        lg:log("Node 1: "..i.." Mirroring with chainType: "..chainType) 
                        AssignImpactMirror(chainType, impactX)
                    --else
--                        AssignImpactMirror('red', impactX)
                    --end
                end
            end
            if naturalMirror and ((rand() < doubleFactor) or forceMirrorOn) then
                mirrorThisChain = true
                impactX = math.max(-1*maxMirroredX, math.min(maxMirroredX, impactX))
                lg:log("Type 2 Mirroring chain: "..i) 
                lg:log("Node 2: "..i.." Mirroring wth chainType: "..chainType) 
                AssignImpactMirror(chainType,  impactX)
                -- since this is a mirror both previous red and blue should be the same
                prevRedTime = myChainEndTimes[nodeLeaders[i] ]
                prevBlueTime = myChainEndTimes[nodeLeaders[i] ]
            end
        end
        --]]
        if forceMirrorOn then
            if not naturalMirror then
                if (impactX < 0) then
                   impactX = - minRequiredStrafeForMirroring - .01
                else
                   impactX = minRequiredStrafeForMirroring + .01
                end
                AssignImpactMirror(chainType, impactX)
            end
            mirrorThisChain = true
            impactX = math.max(-1*maxMirroredX, math.min(maxMirroredX, impactX))
            lg:log("Force mirroring chain: "..i) 
            lg:log("Node 2: "..i.." Force mirroring wth chainType: "..chainType) 
            AssignImpactMirror(chainType,  impactX)
            -- since this is a mirror both previous red and blue should be the same
            prevRedTime = myChainEndTimes[nodeLeaders[i] ]
            prevBlueTime = myChainEndTimes[nodeLeaders[i] ]
        elseif (intensityFactors[i] > .75) and (rand() < doubleFactor) then 
            if chainType=='blue' then
                mirrorThisChain, prevRedPosition, prevRedTime = CalculateNaturalMirror(i,prevRedTime,prevRedPosition,redMinX, redSpanX, impactX)
            else
                mirrorThisChain, prevBluePosition, prevBlueTime = CalculateNaturalMirror(i,prevBlueTime,prevBluePosition,blueMinX, blueSpanX, impactX)
            end
        end
        return impactX
    end
    function AdjustChainXPositionByPreviousChain(chainType, distanceToPreviousChain, minSpacingAfterRaveBlock, prevBlockType,prevBlockImpactX,impactX)
        if prevBlockType == 'purple' then
            if  not (distanceToPreviousChain >= minSpacingAfterRaveBlock) then
                renderThisChain = false -- don't render anything too close right after a rave
            elseif not (distanceToPreviousChain >= 1.5) then
                --if we follow a rave, make sure we're not hidden behind it
                if chainType == 'purple' then
                    impactX = prevBlockImpactX
                elseif chainType == 'blue' then
                    if prevBlockImpactX < .2 then
                        impactX = .35
                    else
                        impactX = 0
                    end
                elseif chainType == 'red' then
                    if prevBlockImpactX > -.2 then
                        impactX = -.35
                    else
                        impactX = 0
                    end
                end
            end
        end
        return impactX
    end
    function AdjustZImpactToSphere(impactX, impactY_BeyondChestHeight, zImpact, adjustedZImpact)
        local targetMagSq = zImpact * zImpact
            adjustedZImpact = zImpact
            local impactXSq=impactX*impactX;
            local impactYSq = impactY_BeyondChestHeight*impactY_BeyondChestHeight
            for k=1, 9 do
                local mag = impactXSq + impactYSq + adjustedZImpact*adjustedZImpact
                if mag <= targetMagSq then
                    break
                else
                    adjustedZImpact = adjustedZImpact - .05
                end
            end
            return adjustedZImpact
    end
    -- //////////////////////////////////////////////////
    -- END OF AUXILIARY FUNCTION BLOCK. 
    -- //////////////////////////////////////////////////
    CalculateChainsAndIntensities()
--    for i=1,#chainLengths do
--        local nodeLeaderIsNil = nodeLeaders[i] == nil
--        if nodeLeaders[i] < 0 then
--            print("Node: "..i.."Node Leader is -1")
--        else
--            local chainLengthIsNil = chainLengths[nodeLeaders[i]] == nil
--            print("Node: "..i.."Node Leader is nil: "..tostring(nodeLeaderIsNil))
--            print("Node: "..i.."Chain Length is nil: "..tostring(chainLengthIsNil))
--            print("Node: "..i.."Node Leader: "..nodeLeaders[i].."Chain length: "..chainLengths[nodeLeaders[i]])
--        end
--    end
    function pad(s, width, padder)
      if lg.enabled == false then
        return ""
      end
      if s == nil then
        return "                      "
      end
      
      --doesntwork
      --padder = strrep(padder or " ", width)
      --if width < 0 then return strsub(padder .. s, width) end
      --return strsub(s .. padder, 1, width)
        local stringRep = tostring(s)
        if width - string.len(stringRep)> 0 then
            local padLength =width - string.len(stringRep)
            if s > 0 then
                padLength= padLength - 1
                stringRep = padder..stringRep
            end
            for i = 1, padLength do
                stringRep = stringRep..padder
            end
        end
        return stringRep
    end

    for i=1,#track do
        if nodes[i]~=nil and nodes[i]~='run' and nodes[i]~='dirty' then
            if chainstarter then -- bring all meteors in this chain from the same direction
                -- init some local variables
                InitNewChain(i)
                -- calculate impacts for chain starters
                if nodes[i] == 'red' then
                    lg:log("In data red Node: "..i.." prevRedTime:"..pad(prevRedTime,25," ").." prevRedPosition: "..pad(prevRedPosition,25," ").." impactX: "..pad(impactX,15," "))
                    prevRedPosition, prevRedTime, impactX = CalculateImpactForNormalChainStarter(i,prevRedTime,prevRedPosition,redMinX, redSpanX, impactX)
                    --print("Node: "..i.."ImpactX:"..impactX.."Pre Node: "..prevRedPosition)
                    --lg::log("Node: "..i.."ImpactX:"..impactX.."Pre Node: "..prevRedPosition)
                    lg:log("Node: "..i.." ImpactX:"..pad(impactX,25," ").." Pre Node: "..pad(prevRedPosition,25," ").." Pre time: "..pad(prevRedTime,15," "))
                elseif nodes[i] == 'blue' then
                    lg:log("In data blue Node: "..i.." prevRedTime:"..pad(prevBlueTime,25," ").." prevRedPosition: "..pad(prevBluePosition,25," ").." impactX: "..pad(impactX,15," "))
                    prevBluePosition, prevBlueTime, impactX = CalculateImpactForNormalChainStarter(i,prevBlueTime,prevBluePosition, blueMinX, blueSpanX,impactX)
                    --print("Node: "..i.."ImpactX:"..impactX.."Pre Node: "..prevBluePosition)
                    --lg:log("Node: "..i.." ImpactX:"..impactX.." Pre Node: "..prevBluePosition.." Pre time: "..prevBlueTime)
                    lg:log("Node: "..i.." ImpactX:"..pad(impactX,25," ").." Pre Node: "..pad(prevBluePosition,25," ").." Pre time: "..pad(prevBlueTime,15," "))
                else
                    lg:log("In data doing rave")
                    impactX,prevBluePosition,prevRedPosition,prevBlueTime,prevRedTime = CalculateImpactForRaveChainStarter(i,prevRedTime, prevRedPosition,prevBlueTime,prevBluePosition,impactX)
                end
                
                
                idInThisChain = 1

                intensityFactorExp = intensityFactors[i]*intensityFactors[i]*intensityFactors[i]

                heading = {0, 0, -1}
                headingNormalized = heading
                
                -- scale horizontal impacts by armspan
                impactX = impactX * impactX_Scaler -- 1.7
                -- adjust calculated y impact point to be above chest height
                impactY_BeyondChestHeight = (tiltFactors[i])*(tiltFactors[i])*yImpactSpan + rand()*yImpactSpan_MaxRandomExtra
                impactY = chestHeight + impactY_BeyondChestHeight
                
                impactDir = {impactX, impactY_BeyondChestHeight, 0}
                
                -- adjust impact Z of impact points so togetehr with x and y they form points on a sphere of constant radius
                adjustedZImpact = AdjustZImpactToSphere(impactX, impactY_BeyondChestHeight, zImpact, adjustedZImpact)
                 --AdjustZImpactToSphere(impactX, impactY_BeyondChestHeight, zImpact, adjustedZImpact)
                
                chainType = nodes[i]                
        local distanceToNextChain
                if nextChainStarters[i] ~=nil and nextChainStarters[i] > 0  then
                    distanceToNextChain = track[nextChainStarters[i]].seconds - myChainEndTimes[i] -- was track[i].seconds - prevBlockSongTime
                    lg:log("Node: "..i.." Leader starts at: "..track[i].seconds.." Leader ends at: "..myChainEndTimes[i].."Distance: "..distanceToNextChain.." Next chain: "..nextChainStarters[i].." Starts at:"..track[nextChainStarters[i]].seconds)
                else
                    lg:log("Nil chain starter for: "..i)
                    distanceToNextChain = 0
                end
                
                forceMirrorOn = (nextChainStartTime<0) or ((intensityFactors[i] > .5) and (distanceToNextChain>2.0)) or (distanceToNextChain>4.0)                
                if  distanceToNextChain < 4 and ((intensityFactors[i] > .5) and (distanceToNextChain>2.0)) then
                    lg:log("Node: "..i.." Intensity is at: "..intensityFactors[i])
                end
                --forceMirrorOn = (nextChainStartTime<0) or  (distanceToPreviousChain>4.0)                
                -- make sure chains aren't too close to each other
                impactX = AdjustChainXPositionByPreviousChain(chainType, distanceToNextChain, minSpacingAfterRaveBlock, prevBlockType,prevBlockImpactX,impactX)
                --AdjustChainXPositionByPreviousChain(chainType, distanceToPreviousChain, minSpacingAfterRaveBlock, prevBlockType,prevBlockImpactX,impactX)

                -- here was an attempt to rebind the chain so that it isnt on the opposite side when too close
                -- deleted if block here
                -- ....
                -- end deleted block
                -- mirror this chain if its time for it or song is too slow
        
            
                impactX = DoMirror(i, forceMirrorOn, chainType, impactX)
                lg:log("Node: "..i.." MImpactX: ".. pad(impactX,25," "))
        
                --DoMirror(i, forceMirrorOn, chainType, impactX)
                -- assign some aprameters based on chain leader node type
                color = nodeTypes[chainType].color
                scale = nodeTypes[chainType].scale
                typeID = nodeTypes[chainType].typeID
                mirrorTypeID = nodeTypes[chainType].mirrorTypeID


                --if i <1000 then
                --    print("intensity:"..intensityFactor)
                --end
                -- check if this chain is a ball chain
                isBallChain,isExtraLongBallChain = AssignBallChain(i,mirrorThisChain,chainType, chainLengths[i], intensityFactors[i])

                sweepDir = 1
                if impactX > 0 then sweepDir = -1 end
                sweepPosX = impactX


                chainstarter = false
            else
                idInThisChain = idInThisChain + 1
            end

            yCurve = impactY_BeyondChestHeight*curveFactorY
            yCurve = math.min(yCurve, curveY_Max)
            yCurve = math.max(yCurve, curveY_Min)
            --yCurve = curveY_Max
            --local yCurve = impactY*curveFactorY
            --local yCurve = impactY*curveFactorY*((1.0-curveY_tiltInfluence)+curveY_tiltInfluence*tiltFactor)
            --local yCurve = impactY*curveFactorY*((1.0-curveY_tiltInfluence)+curveY_tiltInfluence*intensityFactorExp)

            --if renderThisChain and ((idInThisChain%2)==1) then -- only render every other ball in the chain
            if renderThisChain then
                -- only interested in these filled out once for first rendered chainStarter 
                prevBlockSongTime = track[i].seconds
                prevBlockType = chainType -- nodes[i]
                prevBlockImpactX = impactX
                prevBlockIsBallChain = isBallChain
                prevBallChainDirection = 1

                -- this does nothing as playerHeight_impactYCompensator is always 0
                adjustedImpactY = impactY + playerHeight_impactYCompensator
                -- last rendered node
                lastSentNode = i
                
                -- removed yDuplicateThisChain check because it was always false
                if idInThisChain==1 or isBallChain then --this is the head of a chain or a strafe chain (ballChain)
                    -- I have no idea why I have to pass all these instad of capturing them in closures and using as needed inside
                    -- the result of such usage differs for some reason

                    prevBlockImpactX = ProcessFirstNodeOrBallChain(i,adjustedImpactY, adjustedZImpact, curveFactorX, yCurve,
                                impactX,typeID,scale,color,
                                mirrorTypeID,mirrorScale,mirrorColor)
                else -- this is part of a chain tail
                    --.035 -> .06
                    local additionalScale = -.005 + idInThisChain * .0015
                    additionalScale = math.min(additionalScale, .09)
                    local tailScale = {1,1,1}
                    tailScale[1] = scale[1] + additionalScale
                    tailScale[2] = scale[2] + additionalScale
                    tailScale[3] = scale[3] + additionalScale
                    -- for clarity those assignments have been moved into generalized function
                    AssignMeteorAndMirror(AssignMeteorTail, i,adjustedImpactY, adjustedZImpact, curveFactorX, yCurve,
                            impactX,typeID,tailScale,color,
                            mirrorTypeID,tailScale,mirrorColor)
                end
            end
        else
            chainstarter = true
        end
    end

    print("...............................")
    print("track length:"..#track)
    print("last meteor node"..lastSentNode)

    BatchRenderEveryFrame{prefabName="Meteor",
                            locations = meteorNodes,
                            maxShown = 100, --500, -- 1000,
                            emissivecolors = deepcopy(meteorColors), -- "nodecolor", -- "highway" for them to all be the same shifting color
                            colors = deepcopy(meteorColors),
                            --colors = meteorAlbedoColors, -- meteorColors, -- "nodecolor", -- "highway" for them to all be the same shifting color
                            scales = meteorScales,
                            maxDistanceShown = maxNodeDistShown,
                            broadcastimpactvelocities = true,
                            --songspeedratio = .05, -- amount of speed compression
                            songspeedratios = meteorSpeeds,
                            typeids = meteorTypes,
                            afternodereached_numbernodesrendered = 9,
                            override_impactpositions = meteorImpacts,
                            override_velocities = meteorDirections,
                            sinCurvePositionDistortionPeaks = meteorCurveMaximums,
                            override_velocities_scaledbytrackspeed = true}

    BatchRenderEveryFrame{prefabName="Meteor_Tail",
                            ismeteortail = true,
                            locations = meteorNodes_tails,
                            maxShown = 1500, --500, -- 1000,
                            emissivecolors = deepcopy(meteorColors_tails), -- "nodecolor", -- "highway" for them to all be the same shifting color
                            colors = deepcopy(meteorColors_tails),
                            --colors = meteorAlbedoColors_tails, -- meteorColors, -- "nodecolor", -- "highway" for them to all be the same shifting color
                            --colors = deepcopy(meteorColors_tails),
                            scales = meteorScales_tails,
                            maxDistanceShown = maxNodeDistShown,
                            broadcastimpactvelocities = true,
                            --songspeedratio = .05, -- amount of speed compression
                            songspeedratios = meteorSpeeds_tails,
                            typeids = meteorTypes_tails,
                            afternodereached_numbernodesrendered = 9,
                            override_impactpositions = meteorImpacts_tails,
                            override_velocities = meteorDirections_tails,
                            sinCurvePositionDistortionPeaks = meteorCurveMaximums_tails,
                            override_velocities_scaledbytrackspeed = true}

    --render impact positions to help debug hit timing
    local showDebugImpactPoints = false
    if showDebugImpactPoints then
        BatchRenderEveryFrame{prefabName="Meteor",
                                locations = meteorNodes,
                                maxShown = 50,
                                emissivecolors = deepcopy(meteorColors), -- "nodecolor", -- "highway" for them to all be the same shifting color
                                colors = meteorColors, -- "nodecolor", -- "highway" for them to all be the same shifting color
                                scales = impactProxyScales,
                                maxDistanceShown = maxNodeDistShown,
                                typeids = meteorTypes,
                                --broadcastimpactvelocities = true,
                                --songspeedratio = .05, -- amount of speed compression
                                --songspeedratios = meteorSpeeds,
                                afternodereached_numbernodesrendered = 1,
                                override_impactpositions = meteorImpacts,
                                override_velocities = impactProxyVelocities
        }
    end
                            --sinCurvePositionDistortionPeaks = meteorCurveMaximums,
                            --override_velocities_scaledbytrackspeed = true}
end

camHeightMax = 1100
camHeightMin = 750
camHeight = camHeightMax
score = score or 10000

skinHasLoaded = skinHasLoaded or false
function OnSkinLoaded()-- called after OnTrafficCreated
    HideBuiltinPlayerObjects()

    SetCamera{ -- calling this function (even just once) overrides the camera settings from the skin script
        pos = {0,0,0},
        rot = {0,0,0},
        railoffset = "detached" -- this camera will not move along the track
    }

    skinHasLoaded = true

    InitMeteors()
    hasInitedMeteors = true
end

--function OnPlayerHeightEstablished(playerHeight)
--    InitMeteors()
--    hasInitedMeteors = true
--end

dinoAngle = 0
hittable = true
invulnTicker = 0
invulnDuration = .7
hitsSuffered = 0
timeMoving = 0
timeTotal = 0

function GetScore()
    local numMissed = GetNumShieldMisses()
    return math.max(1, 1000 - 1 * numMissed)
end

quarterSecondCounter = 0
function UpdateEachQuarterSecond()
    local scoref = GetScore()
    SetGlobalScore{score=scoref,showdelta=false}
end

updatesRun = updatesRun or 0
hasInitedMeteors = hasInitedMeteors or false

--function Update(dt, tracklocation, strafe, input, jumpheight) --called every frame by the game engine
    --if keys["q"] then
        --SendCommand({["command"] = "SongEnded"})
        --SendCommand({["command"] = "GameplayEnd"})
    --end
--end

function OnRequestFinalScoring()
    AssignBuiltInAudioshieldScoring()
end