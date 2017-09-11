require("../../utils/sign")

function WeightedRandom(x, span, left, right, factor)
    local min = math.min
    local max = math.max
    local abs = math.abs
    local rand = math.random
    local pow = math.pow
    local sgn = math.sign

    if left > right then
        local temp = left
        left = right
        right = temp
    end

    left = min(span, max(left, -span))
    right = min(span, max(right, -span))

    local leftBound = pow(abs((left - x) / span), 1/factor)
    local leftSign = sgn(left - x)
    local rightBound = pow(abs((right - x) / span), 1/factor)
    local rightSign = sgn(right - x)

    local randOut = rand() * (rightBound*rightSign - leftBound*leftSign) + leftBound*leftSign
    local randSign = sgn(randOut)

    local returnPos = x + pow(abs(randOut), factor) * randSign * span

    return returnPos
end

function WeightedRandomWithHole(x, span, left, right, factor, leftHole, rightHole)
    local min = math.min
    local max = math.max
    local abs = math.abs
    local rand = math.random
    local pow = math.pow
    local sgn = math.sign

    if left > right then
        local temp = left
        left = right
        right = temp
    end

    if leftHole > rightHole then
        local temp = leftHole
        leftHole = rightHole
        rightHole = temp
    end

    left = min(span, max(left, -span))
    right = min(span, max(right, -span))

    if right <= leftHole then                  -- |---|  XxxxxX
        return WeightedRandom(x, span, left, right, factor)
    elseif leftHole <= left then
        if rightHole <= left then              -- XxxxxX |----|
            return WeightedRandom(x, span, left, right, factor)
        elseif right <= rightHole then         -- Xxx|xxxxx|xxX
            return true
        else                                   -- Xxx|xX------|
            return WeightedRandom(x, span, rightHole, right, factor)
        end
    else
        if right <= rightHole then             -- |----Xxx|xxxX
            return WeightedRandom(x, span, left, leftHole, factor)
        else                                   -- |---XxxxxxX-|
            -- continue
        end
    end

    local leftBound = pow(abs((left - x) / span), 1/factor)
    local leftSign = sgn(left - x)
    local rightBound = pow(abs((right - x) / span), 1/factor)
    local rightSign = sgn(right - x)

    local leftHoleBound = pow(abs((leftHole - x) / span), 1/factor)
    local leftHoleSign = sgn(leftHole - x)
    local rightHoleBound = pow(abs((rightHole - x) / span), 1/factor)
    local rightHoleSign = sgn(rightHole - x)

    local leftSegment = leftHole*leftHoleSign - left*leftSign
    local deadSegment = rightHole*rightHoleSign - leftHole*leftHoleSign
    local rightSegment = right*rightSign - rightHole*rightHoleSign

    local randOut = rand()*(leftSegment+rightSegment) - left
    if leftHoleBound*leftHoleSign < randOut then
        randOut = randOut + deadSegment
    end
    local randSign = sgn(randOut)

    local returnPos = x + pow(abs(randOut), 2) * randSign * span

    return returnPos
end

function WeightedRandomWithSegment(x, span, left, right, factor, leftSeg, rightSeg)
    local min = math.min
    local max = math.max

    if left > right then
        local temp = left
        left = right
        right = temp
    end

    if leftSeg > rightSeg then
        local temp = leftSeg
        leftSeg = rightSeg
        rightSeg = temp
    end

    left = min(span, max(left, -span))
    right = min(span, max(right, -span))

    if rightSeg < left or right < leftSeg then -- AaaaaA  |-----|
        return true
    elseif rightSeg == left then               -- |----|AaaaaaaaA
        return rightSeg
    elseif right == leftSeg then               -- AaaaaaA|------|
        return leftSeg
    else
        return WeightedRandom(x, span, max(left, leftSeg), min(right, rightSeg), factor)
    end
end
