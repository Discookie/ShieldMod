function math.round(number, precision)
    if type(number) == "string" then
        number = tonumber(number)
    end
    if type(number) ~= "number" then
        return 0
    end

    if type(precision) == "string" then
        precision = tonumber(precision)
    end
    if type(precision) ~= "number" then
        precision = 0
    end

    local tenk = math.pow(10, math.floor(precision))
    return math.floor(number * tenk) / tenk
end
