local function clone(tab,visited)
    --visited is infinite recursion protection, courtesy of chatgpt
    --thanks chatgpt, programming might be one of the few things you're good at
    visited = visited or {}
    if visited[tab] then
        return visited[tab]
    end
    if type(tab)~="table" then
        error("Expected table, got "..type(tab))
    end
    local copy = {}
    visited[tab] = copy
    for k,v in pairs(tab) do
        if type(v)=="table" then
            copy[k] = clone(v,visited)
        else
            copy[k] = v
        end
    end
    setmetatable(copy,getmetatable(tab))
    return copy
end
return clone
