function jsonify(object)
    return _dump_recur(object)
end

function dump(object)
    return _dump_recur(object)
end

function _dump_recur(obj, level)
    if not level then
        level = 1
    end

    local ret = "{"
    local was = false

    for k, v in pairs(obj) do
        if was then
            ret = ret .. ","
        end

        if type(v) == "table" then
            ret = ret .. tostring(k) .. ":" .. _dump_recur(v, level+1)
        elseif type(v) == 'boolean' or type(v) == 'number' then
            ret = ret .. tostring(k) .. ": " .. tostring(v)
        elseif type(v) == 'function' then
            ret = ret .. tostring(k) .. ": \"" .. tostring(v) .. "\""
        else
            ret = ret .. tostring(k) .. ": \""..v.."\""
        end

        was = true
    end
    return ret.."}"
end
