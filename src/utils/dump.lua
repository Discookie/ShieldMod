function jsonify(object)
    return _dump_recur(object, 0)
end

function dump(object)
    return _dump_recur(object, 0)
end

function _dump_recur(obj, level)
  local ret = "{"
  if not level then level = 1 end
  for k, v in pairs(obj) do
    if type(v) == "table" then
      ret = ret..tostring(k)..":".._dump_recur(v, level+1)..","
    elseif type(v) == 'boolean' or type(v) == 'number' or type(v) == 'function' then
      ret = ret..tostring(k)..": "..tostring(v)..","
    else
      ret = ret..tostring(k)..": \""..v.."\","
    end
  end
  return ret.."}"
end
