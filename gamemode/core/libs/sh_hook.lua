--- Custom function based hooks.
-- @module ow.hooks

ow.hooks = {}
ow.hooks.stored = {}

--- Registers a new hook type.
-- @realm shared
-- @string name The name of the hook type.
function ow.hooks:Register(name)
    self.stored[name] = true
end

--- Unregisters a hook type.
-- @realm shared
-- @string name The name of the hook type.
-- @internal
function ow.hooks:UnRegister(name)
    self.stored[name] = nil
end

hook.owCall = hook.owCall or hook.Call

function hook.Call(name, gm, ...)
    for k, v in pairs(ow.hooks.stored) do
        local tab = _G[k]
        if ( !tab ) then continue end

        local fn = tab[name]
        if ( !fn ) then continue end

        local a, b, c, d, e, f = fn(tab, ...)

        if ( a != nil ) then
            return a, b, c, d, e, f
        end
    end

    for k, v in pairs(ow.module.stored) do
        for k2, v2 in pairs(v) do
            if ( type(v2) == "function" ) then
                if ( k2 == name ) then
                    local a, b, c, d, e, f = v2(v, ...)

                    if ( a != nil ) then
                        return a, b, c, d, e, f
                    end
                end
            end
        end
    end

    return hook.owCall(name, gm, ...)
end