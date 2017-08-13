function table.merge(t1, t2)
    for k,v in pairs(t2) do
        t1[k] = v
    end

    return t1
end

function table.extend(t1, t2)
    local maxnum = 1
    local minnum = 1
    local max = math.max
    local min = math.min

    for k,v in pairs(t1) do
        if type(k) == "number" then
            maxnum = max(maxnum, k)
        end
    end

    for k,v in pairs(t2) do
        if type(k) == "number" then
            minnum = min(minnum, k)
        end
    end

    maxnum = maxnum - minnum + 1

    for k,v in pairs(t2) do
        if type(k) == "number" then
            t1[maxnum + k] = v
        else
            t1[k] = v
        end
    end
end
