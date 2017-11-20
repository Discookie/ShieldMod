require("../../logger")
require("../../events")
require("../../diff/diff_export")
require("../../vr/vr_export")

ScorerV1 = {}
ScorerV1.__index = ScorerV1
setmetatable(ScorerV1, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

ScorerV1.history = {}

function ScorerV1.init(container)
    local self = setmetatable({}, ScorerV1)
    self.type = "ScorerV1"
    self.logger = Logger(self.type)
	self.logger:log("Init")
	self:reset()

    return self
end

function ScorerV1:reset()
    if self._scoreid then
        EventHandler.instance:remove(self._scoreid)
    end
    if self._noteid then
        EventHandler.instance:remove(self._noteid)
    end
    self._scoreid = EventHandler.instance:on(Events.SCORE, self.setFinalScore, self)
    self._noteid = EventHandler.instance:on(Events.NOTE, self.onNote, self)

    self.logger:log("Resetting score")

	self.prevLeft = Note()
	self.prevRight = Note()
	self.prevMisses = 0

    self.totalScore = 0
	self.combo = 0
	self.maxCombo = 0

	self.noteCount = 0
	self.misses = 0

	self.leftCount = 0
	self.rightCount = 0
	self.purpleCount = 0

    self.scores = {}
    self.intervalIDs = {}
end

function ScorerV1:scorerTimeout(data)
    local floor = math.floor
    local min = math.min
	local currentNote = data:copy()
    local handType = currentNote.handType

	local prevMisses = self.prevMisses
	local prevLeft = self.prevLeft
	local prevRight = self.prevRight

    local typeMultiplier = 0

	local leftComponent = 0
	local rightComponent = 0
    local meteorCount = 0
	local handsUsed = 0

	if currentNote:hasHands(Note.HandTypes.LEFT) then
		leftComponent = self.getScore(currentNote.startTime - prevLeft.endTime, min(Diff.instance.maxAccelLeft, GetAccelValue(prevLeft.pos.x - prevLeft.span.x/2, currentNote.pos.x - currentNote.span.x/2, currentNote.startTime - prevLeft.endTime)))
		handsUsed = handsUsed + 1
	end
	if currentNote:hasHands(Note.HandTypes.RIGHT) then
		rightComponent = self.getScore(currentNote.startTime - prevRight.endTime, min(Diff.instance.maxAccelRight, GetAccelValue(prevRight.pos.x + prevRight.span.x/2, currentNote.pos.x + currentNote.span.x/2, currentNote.startTime - prevRight.endTime)))
		handsUsed = handsUsed + 1
	end

    if handType%2 == 1 then
        if meteorCount == 0 then
            typeMultiplier = Diff.instance.singleScore
        else
            typeMultiplier = typeMultiplier * Diff.instance.doubleMultiplier
        end
        meteorCount = meteorCount + 1
		self.leftCount = self.leftCount + 1
    end
    if floor(handType/2)%2 == 1 then
        if meteorCount == 0 then
            typeMultiplier = Diff.instance.singleScore
        else
            typeMultiplier = typeMultiplier * Diff.instance.doubleMultiplier
        end
        meteorCount = meteorCount + 1
		self.rightCount = self.rightCount + 1
    end
    if floor(handType/4)%2 == 1 then
        if meteorCount == 0 then
            typeMultiplier = Diff.instance.purpleScore
        else
            typeMultiplier = typeMultiplier * Diff.instance.purpleMultiplier
        end
        meteorCount = meteorCount + 1
		self.purpleCount = self.purpleCount + 1
    end

	local accelComponent = 0
	if handsUsed ~= 0 then
		accelComponent = math.pow((math.pow(leftComponent, 3)+math.pow(rightComponent, 3))/handsUsed, 1/3)
	end

	local hitPercentage
	if meteorCount > 0 then
		hitPercentage = 1 - (GetNumShieldMisses() - self.prevMisses) / meteorCount
		self.noteCount = self.noteCount + meteorCount
		self.misses = self.misses + (GetNumShieldMisses() - self.prevMisses)
	else
		hitPercentage = 1
	end

    if hitPercentage < 0 then
        self.logger:error("You missed more than it was possible to hit! Report this error or fix your note assigner!")
        hitPercentage = 0
    end

    if hitPercentage > 0 then
	   if currentNote:hasHands(Note.HandTypes.LEFT) then
		  self.prevLeft = currentNote:copy()
	   end
	   if currentNote:hasHands(Note.HandTypes.RIGHT) then
		  self.prevRight = currentNote:copy()
	   end
    end

	if hitPercentage < 1 then
		self.combo = meteorCount + self.prevMisses - GetNumShieldMisses()
	else
		self.combo = self.combo + meteorCount
	end

	local maxScore = (Diff.instance.scoreBaseFactor + Diff.instance.scoreAccelFactor*accelComponent) * typeMultiplier
	local achievedScore = maxScore * hitPercentage

	self.maxCombo = math.max(self.combo, self.maxCombo)
	self.prevMisses = GetNumShieldMisses()

	self.scores[#self.scores + 1] = {
		time = currentNote.startTime,
		accel = accelComponent,
		meteorTypes = handType,
		meteorCount = meteorCount,
		misses = GetNumShieldMisses() - prevMisses,
		combo = self.combo,
		score = achievedScore,
		maxScore = maxScore
	}
    self.logger:trace(dump(self.scores[#self.scores]), 2)
    self.totalScore = self.totalScore + achievedScore

    self:refreshScoreboard()

    Intervals.instance:remove(self.intervalIDs[#self.scores])

    return false
end

function ScorerV1.getScore(time, accel)
    return accel * math.pow(1 / (1 + math.pow(math.abs(time - Diff.instance.scoreTimePeak), 2 + Diff.instance.scoreTimePeak)), 2*Diff.instance.scoreTimeCutoff)
end

function ScorerV1:onNote(ev)
    self.intervalIDs[#self.intervalIDs + 1] = Intervals.instance:addInterval(0.2, true, bindFunc(bindFunc(ScorerV1.scorerTimeout, self), ev.data:copy()))
end

function ScorerV1:refreshScoreboard()
    local latestScore = self.scores[#self.scores]

    SetGlobalScore({
            score = math.floor(self.totalScore*1000),
            showdelta = false
        })

    if Diff.instance.useScoreboardNote then
        SetScoreboardNote({
            text = "Combo: " .. self.combo .. " - Latest: " .. (math.floor(latestScore.score*1000)) .. ", accel: " .. (math.floor(latestScore.accel*100)/100)
        })
    end
end

function ScorerV1:setFinalScore()
    local max = math.max
    local floor = math.floor
    local maxAccel = 0
    local avgAccel = 0
    local fcText = self.misses == 0 and " (Full Combo!)" or ""

    for k,v in ipairs(self.scores) do
        maxAccel = max(maxAccel, v.accel)
        avgAccel = avgAccel + v.accel
    end
    maxAccel = floor(10000 * maxAccel)/100
    avgAccel = floor(10000 * avgAccel / #self.scores)/100

    scoreboardText = {
        "Meteors hit: " .. (self.noteCount-self.misses) .. "/" .. self.noteCount .. " (" .. (100 - floor(10000 * self.misses / self.noteCount)/100) .. "%)",
        " ",
        "--- Performance ---",
        "Max combo: " .. self.maxCombo .. fcText,
        "Max punch strength: "..(GetMaxPunchStrength()/100),
        " ",
        "--- Statistics ---",
        "Normal meteors: " .. self.leftCount .. "< >" .. self.rightCount,
        "Purple meteors: " .. self.purpleCount,
        " ",
        "--- Used settings ---",
        "maxAccel: " .. Diff.instance.maxAccelLeft .. "/" .. Diff.instance.factAccelLeft .. "< >" .. Diff.instance.maxAccelRight .. "/" .. Diff.instance.factAccelRight,
        "doubleSpans: min " .. Diff.instance.minDoubleSpan .. ", max " .. Diff.instance.maxDoubleSpan .. " || / X " .. Diff.instance.maxCrosshandSpan .. ", spanX: " .. Diff.instance.spanX,
        "speeds: ballchain " .. Diff.instance.ballchainSpeed .. ", meteor " .. Diff.instance.meteorSpeed,
        " "
    }

    self.logger:log("Setting final score of " .. floor(self.totalScore*1000))
    self.logger:log("Full scoreboard:\n" .. table.concat(scoreboardText, "\n"))
    ScoreReturn = {
        rawscore = self.totalScore,
        bonuses = scoreboardText,
        finalscore = floor(self.totalScore*1000)
    }
end

EventHandler.instance:on(Events.INIT, function(ev)
	ScorerV1.instance = ScorerV1()
end)
