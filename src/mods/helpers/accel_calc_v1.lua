require("../../diff/diff_export")
require("../../vr/vr_export")
require("weighted_random_v1")

--[[
IMPORTANT:

I have intentionally cheated during the acceleration calculation.
It does not change the magnitude, or the relation of the values,
but it makes for a much more readable code,
and a much more realistic set of difficulty parameters.
Refer to the README for more info.
--]]

AccelLog = Logger("AccelCalcV1")

function CalculateAccelBounds(x, time, max)
    local pow = math.pow

    return {
        x = x,
        left = x - max * pow(time, 2),
        right = x + max * pow(time, 2),
        span = 2 * max * pow(time, 2)
    }
end

function GetAccelValue(start, fin, time)
    return math.abs(fin - start) / math.pow(time, 2)
end

--
function CalculateAccelPos(time, prev, other, hand, spans)
    local prevBounds = CalculateAccelBounds(prev.x, time - prev.time, prev.max)

    local otherBounds = CalculateAccelBounds(other.x, time - other.time, other.max)
    if hand == Note.HandTypes.LEFT then
        otherBounds.left = otherBounds.left - spans.normal
        otherBounds.right = otherBounds.right + spans.crosshand
    else
        otherBounds.left = otherBounds.left - spans.crosshand
        otherBounds.right = otherBounds.right + spans.normal
    end

    local retPos = WeightedRandomWithSegment(prev.x, spans.total, prevBounds.left, prevBounds.right, prev.fact, otherBounds.left, otherBounds.right)

    return retPos
end

function CalculateAccelDoublePos(time, left, right, spans)
    local min = math.min
    local max = math.max
    local leftBounds = CalculateAccelBounds(left.x, time - left.time, left.max)
    local rightBounds = CalculateAccelBounds(right.x, time - right.time, right.max)

    if right.time < left.time then
        local leftPos = CalculateAccelPos(time, left, right, Note.HandTypes.LEFT, spans)
        if leftPos == true then
            return {
                hand = Note.HandTypes.AUTO,
                pos = 0,
                span = 0
            }
        end
        if min(leftBounds.right, rightBounds.right + spans.crosshand) < max(leftBounds.left, rightBounds.left - spans.normal) then
            return {
                hand = Note.HandTypes.LEFT,
                pos = leftPos,
                span = 0
            }
        end

        local rightPos = WeightedRandomWithHole(right.x, spans.total, max(leftPos - spans.crosshand, rightBounds.left), min(leftPos + spans.normal, rightBounds.right), right.fact, leftPos - spans.min/2, leftPos + spans.min/2)
        if rightPos == true then
            return {
                hand = Note.HandTypes.LEFT,
                pos = leftPos,
                span = 0
            }
        else
            return {
                hand = Note.HandTypes.LEFT + Note.HandTypes.RIGHT,
                pos = (leftPos + rightPos) / 2,
                span = (rightPos - leftPos)
            }
        end
    else
        local rightPos = CalculateAccelPos(time, right, left, Note.HandTypes.RIGHT, spans)
        if rightPos == true then
            return {
                hand = Note.HandTypes.AUTO,
                pos = 0,
                span = 0
            }
        end
        if min(rightBounds.right, leftBounds.right + spans.normal) < max(rightBounds.left, leftBounds.left - spans.crosshand) then
            return {
                hand = Note.HandTypes.RIGHT,
                pos = rightPos,
                span = 0
            }
        end

        local leftPos = WeightedRandomWithHole(left.x, spans.total, max(rightPos - spans.normal, leftBounds.left), min(rightPos + spans.crosshand, leftBounds.right), left.fact, rightPos - spans.min/2, rightPos + spans.min/2)
        if leftPos == true then
            return {
                hand = Note.HandTypes.RIGHT,
                pos = rightPos,
                span = 0
            }
        else
            return {
                hand = Note.HandTypes.LEFT + Note.HandTypes.RIGHT,
                pos = (leftPos + rightPos) / 2,
                span = (rightPos - leftPos)
            }
        end
    end
end

function CalculateAccelCenteredPos(time, left, right, spans)
    local max = math.max
    local min = math.min
    local abs = math.abs
    local leftBounds = CalculateAccelBounds(left.x, time - left.time, left.max)
    local rightBounds = CalculateAccelBounds(right.x, time - right.time, right.max)

    leftBounds.left = max(min(leftBounds.left, spans.crosshand / 2), -spans.normal / 2)
    leftBounds.right = max(min(leftBounds.right, spans.crosshand / 2), -spans.normal / 2)

    rightBounds.left = max(min(rightBounds.left, spans.normal / 2), -spans.crosshand / 2)
    rightBounds.right = max(min(rightBounds.right, spans.normal / 2), -spans.crosshand / 2)

    if GetAccelValue(leftBounds.x, 0, time - left.time) > GetAccelValue(rightBounds.x, 0, time - right.time)  then
        local leftPos = WeightedRandomWithHole(left.x, spans.total, max(leftBounds.left, -rightBounds.right), min(leftBounds.right, -rightBounds.left), left.fact, -spans.min/2, spans.min/2)
        if leftPos ~= true then
            local rightPos = -leftPos
            return {
                pos = (leftPos + rightPos) / 2,
                span = (rightPos - leftPos)
            }
        end

        local rightPos = WeightedRandomWithHole(right.x, spans.total, max(rightBounds.left, -leftBounds.right), min(rightBounds.right, -leftBounds.left), right.fact, -spans.min/2, spans.min/2)
        if rightPos ~= true then
            leftPos = -rightPos
            return {
                pos = (leftPos + rightPos) / 2,
                span = (rightPos - leftPos)
            }
        end

        leftPos = max(min(left.x, spans.crosshand / 2), -spans.normal / 2)
        rightPos = -leftPos

        return {
            pos = (leftPos + rightPos) / 2,
            span = (rightPos - leftPos)
        }
    else
        local rightPos = WeightedRandomWithHole(right.x, spans.total, max(rightBounds.left, -leftBounds.right), min(rightBounds.right, -leftBounds.left), right.fact, -spans.min/2, spans.min/2)
        if rightPos ~= true then
            local leftPos = -rightPos
            return {
                pos = (leftPos + rightPos) / 2,
                span = (rightPos - leftPos)
            }
        end

        local leftPos = WeightedRandomWithHole(left.x, spans.total, max(leftBounds.left, -rightBounds.right), min(leftBounds.right, -rightBounds.left), left.fact, -spans.min/2, spans.min/2)
        if leftPos ~= true then
            rightPos = -leftPos
            return {
                pos = (leftPos + rightPos) / 2,
                span = (rightPos - leftPos)
            }
        end

        rightPos = max(min(right.x, spans.normal / 2), -spans.crosshand / 2)
        leftPos = -rightPos

        return {
            pos = (leftPos + rightPos) / 2,
            span = (rightPos - leftPos)
        }
    end
end
