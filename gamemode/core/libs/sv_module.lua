--- Sets the value of a module to be disabled or enabled.
-- @realm server
-- @string identifier The unique identifier of the module.
-- @return boolean whether or not the function was called successfully.

function ow.module:SetDisabled(identifier, bDisabled)
    if ( bDisabled == nil ) then bDisabled = true end

    if ( identifier == nil or !isstring(identifier) ) then
        ow.util:PrintError("Attempted to set an invalid module!")
        return false
    end

    if ( !file.Exists("overwatch", "DATA") ) then
        file.CreateDir("overwatch")
    end

    local folder = SCHEMA and SCHEMA.Folder or "core"
    if ( !file.Exists("overwatch/" .. folder, "DATA") ) then
        file.CreateDir("overwatch/" .. folder)
    end

    if ( !file.Exists("overwatch/" .. folder .. "/disabled_modules.txt", "DATA") ) then
        file.Write("overwatch/" .. folder .. "/disabled_modules.txt", "[]")
    end

    local stored = self.stored[identifier]
    if ( stored ) then
        self.disabled[identifier] = bDisabled
        file.Write("overwatch/" .. folder .. "/disabled_modules.txt", util.TableToJSON(self.disabled))

        return true
    end

    return false
end