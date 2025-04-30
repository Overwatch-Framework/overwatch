ow.character:RegisterVariable("steamid", {
    Type = ow.type.string,
    Field = "steamid",
    Default = ""
})

ow.character:RegisterVariable("schema", {
    Type = ow.type.string,
    Field = "schema",
    Default = "overwatch"
})

ow.character:RegisterVariable("data", {
    Type = ow.type.string,
    Field = "schema",
    Default = "[]"
})

ow.character:RegisterVariable("name", {
    Type = ow.type.string,
    Field = "name",
    Default = "John Doe",

    Editable = true,
    ZPos = -3,
    Name = "Name",

    AllowNonAscii = false,
    Numeric = false,

    OnValidate = function(self, parent, payload, ply)
        if ( string.len(payload.name) < 3 ) then
            return false, "Name must be at least 3 characters long!"
        elseif ( string.len(payload.name) > 32 ) then
            return false, "Name must be at most 32 characters long!"
        end

        if ( string.find(payload.name, "[^%a%d%s]") ) then
            return false, "Name can only contain letters, numbers and spaces!"
        end

        if ( string.find(payload.name, "%s%s") ) then
            return false, "Name cannot contain multiple spaces in a row!"
        end

        return true
    end
})

ow.character:RegisterVariable("description", {
    Type = ow.type.text,
    Field = "description",
    Default = "A mysterious person.",

    Editable = true,
    ZPos = 0,
    Name = "Description",

    OnValidate = function(self, parent, payload, ply)
        if ( string.len(payload.description) < 10 ) then
            return false, "Description must be at least 10 characters long!"
        end

        return true
    end
})

ow.character:RegisterVariable("model", {
    Type = ow.type.string,
    Field = "model",
    Default = "models/player/kleiner.mdl",

    Editable = true,
    ZPos = 0,
    Name = "Model",

    OnValidate = function(self, parent, payload, ply)
        local faction = ow.faction:Get(payload.faction)
        if ( faction and faction.Models ) then
            local found = false
            for _, v in SortedPairs(faction.Models) do
                if ( v == payload.model ) then
                    found = true
                    break
                end
            end

            if ( !found ) then
                return false, "Model is not valid for this faction!"
            end
        end

        return true
    end,

    OnPopulate = function(self, parent, payload, ply)
        local label = parent:Add("ow.text")
        label:Dock(TOP)
        label:SetFont("ow.fonts.button")
        label:SetText(self.Name or k)

        local scroller = parent:Add("DScrollPanel")
        scroller:Dock(TOP)
        scroller:DockMargin(0, 0, 0, ScreenScale(16))
        scroller:SetTall(256)

        local layout = scroller:Add("DIconLayout")
        layout:Dock(FILL)

        local faction = ow.faction:Get(payload.faction)
        if ( faction and faction.Models ) then
            for _, v in SortedPairs(faction.Models) do
                local icon = layout:Add("SpawnIcon")
                icon:SetModel(v)
                icon:SetSize(64, 128)
                icon:SetTooltip(v)
                icon.DoClick = function()
                    notification.AddLegacy("Model set to " .. v, NOTIFY_GENERIC, 5)
                    payload.model = v
                end
            end
        end
    end
})

ow.character:RegisterVariable("money", {
    Type = ow.type.number,
    Field = "money",
    Default = 0
})

ow.character:RegisterVariable("faction", {
    Type = ow.type.number,
    Field = "faction",
    Default = 0,

    Editable = true,

    OnValidate = function(self, parent, payload, ply)
        return ow.faction:CanSwitchTo(ply, payload.faction)
    end,

    OnSet = function(this, character, value)
        local faction = ow.faction:Get(value)
        if ( faction and faction.OnSet ) then
            faction:OnSet(character, value)
        end

        local ply = character:GetPlayer()
        if ( IsValid(ply) ) then
            ply:SetTeam(value)
        end
    end
})

ow.character:RegisterVariable("class", {
    Type = ow.type.number,
    Field = "class",
    Default = 0
})

ow.character:RegisterVariable("flags", {
    Type = ow.type.string,
    Field = "flags",
    Default = "",
})