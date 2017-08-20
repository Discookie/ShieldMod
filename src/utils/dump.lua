function jsonify(object)
    return _dump_recur(object)
end

function dump(object)
    return _dump_recur(object)
end

function _dump_recur(obj, level)
    if type(obj) == 'boolean' or type(obj) == 'number' or type(obj) == 'function' then
        return tostring(obj)
    elseif type(obj) == 'number' or type(obj) == 'string' then
        return obj
    end

    if not level then
        level = 1
    end

    local ret = "{"
    local was = false

    for k, v in pairs(obj) do
        if was then
            ret = ret .. ",\n"
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

function dump_with_func(object)
    return _dwf_recur(object)
end

function _dwf_recur(obj, level)
    if type(obj) == 'boolean' or type(obj) == 'number' then
        return tostring(obj)
    elseif type(obj) == 'function' then
        return _dwf_f2h(obj)
    elseif type(obj) == 'number' or type(obj) == 'string' then
        return obj
    end

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
            ret = ret .. tostring(k) .. ": \"" .. _dwf_f2h(v) .. "\""
        else
            ret = ret .. tostring(k) .. ": \""..v.."\""
        end

        was = true
    end
    return ret.."}"
end

function _dwf_f2h(func)
    return "func:" .. string.gsub(string.dump(func), ".", function(c)
        return string.format("%02x", string.byte(c))
    end) .. ":" .. string.len(string.dump(func))

end
