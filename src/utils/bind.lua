function bind(t, k)
    return function(...) return t[k](t, ...) end
end

function bindFunc(t, k)
    return function(...) return k(t, ...) end
end
