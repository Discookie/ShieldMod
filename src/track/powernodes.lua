require("track")
require("../diff/diff_export")

Track._beforePowerNodes_clear = Track.clear

function Track:clear()
    if self:_beforePowerNodes_clear() then
        return true
    end

    self._powerNodes = {}

    return false
end

function Track:calcPowerNodes()
    self.logger:log("Calculating power nodes")
    local sec = {}
    local av = {}

    for i=1,self.size do
        sec[i] = i
        av[i] = true
    end

    function cmp(a, b)
        return self._jumpAirTime[a] < self._jumpAirTime[b]
    end
    table.sort(sec, cmp)

    for i=1,self.size do
        if self._jumpAirTime[sec[i]] >= Diff.instance.minJumpAirTime then
            if av[sec[i]] then
                local isClear = true
                local jumpEndTime = self._time[sec[i]] + self._jumpAirTime[sec[i]] + Diff.instance.jumpEndOffset
                local jumpEndNode = self:timeToNode(jumpEndTime).id

                for j=sec[i],jumpEndNode do
                    if not av[j] then
                        isClear = false
                    end
                end

                if isClear and sec[i] > 300 then
                    local tiltBefore = 0
                    local tiltAfter = 0

                    for j=sec[i],math.max(sec[i] - Diff.instance.slopeTest, 1),-1 do
                        tiltBefore = tiltBefore + self._rot[j].tilt
                    end
                    for j=sec[i],math.min(sec[i] + Diff.instance.slopeTest, self.size) do
                        tiltAfter = tiltAfter + self._rot[j].tilt
                    end

                    tiltBefore = tiltBefore / Diff.instance.slopeTest
                    tiltAfter = tiltAfter / Diff.instance.slopeTest

                    if i == 1 or (5 < tiltBefore and tiltAfter > 15) then
                        self._powerNodes[#self._powerNodes + 1] = sec[i]
                        self.logger:debug(dump(sec[i]))
                    end
                end
            end
        end
        if #self._powerNodes > Diff.instance.powerNodesPerMin * self._time[self.size] / 60 then
            break
        end
    end
    return false
end

Track._beforePowerNodes_process = Track.process

function Track:process(tr)
    if self:_beforePowerNodes_process(tr) then
        return true
    end

    return self:calcPowerNodes()
end
