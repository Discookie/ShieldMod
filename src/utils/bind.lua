function bind(func, table)
    return function(...) return table[func](table, ...) end
end

function bindFunc(func, table)
    return function(...) return func(table, ...) end
end
