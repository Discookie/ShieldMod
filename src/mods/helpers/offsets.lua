-- TODO: create two more triangle functions as described in https://stackoverflow.com/questions/1073606/ and create modified sine assigner

function offs_Triangle(id, pos, span, handType)
    local floor = math.floor
    local line = pos.x + (id * Diff.instance.ballchainSpeed * ((floor(10*pos.x)%2)*2-1))

    return {
        pos = {
            x = math.abs(line - floor(line / (2*Diff.instance.spanX))*2*Diff.instance.spanX - Diff.instance.spanX) - Diff.instance.spanX/2,
            y = pos.y
        }, span = {x = span.x, y = span.y}
    }
end

function offs_Sine(id, pos, span, handType)
    local start = math.asin(2*pos.x/Diff.instance.spanX)
    local step = ((math.floor(10*pos.x)%2)*2-1) * math.pi * Diff.instance.ballchainSpeed / Diff.instance.spanX

    return {
        pos = {
            x = math.sin(start + step*id) * Diff.instance.spanX/2,
            y = pos.y
        }, span = {x = span.x, y = span.y}
    }
end
