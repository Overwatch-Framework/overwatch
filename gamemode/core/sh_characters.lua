ow.character:RegisterVariable("steamid", {
    Type = ow.type.string,
    Field = "steamid",
    Default = "STEAM_0:0:00000000"
})

ow.character:RegisterVariable("schema", {
    Type = ow.type.string,
    Field = "schema",
    Default = "overwatch"
})

ow.character:RegisterVariable("name", {
    Type = ow.type.string,
    Field = "name",
    Default = "John Doe",

    Editable = true,
    ZPos = -3,
    DisplayName = "Name"
})

ow.character:RegisterVariable("description", {
    Type = ow.type.text,
    Field = "description",
    Default = "A mysterious person.",

    Editable = true,
    ZPos = 0,
    DisplayName = "Description"
})

ow.character:RegisterVariable("model", {
    Type = ow.type.string,
    Field = "model",
    Default = "models/player/kleiner.mdl",

    Editable = true,
    ZPos = 0,
    DisplayName = "Model",
    OnPopulate = function(self, parent)
        local label = parent:Add("DLabel")
        label:Dock(TOP)
        label:SetText(self.DisplayName or k)
        label:SetFont("ow.fonts.button")
        label:SetTextColor(color_white)
        label:SizeToContents()

        local scroller = parent:Add("DScrollPanel")
        scroller:Dock(TOP)
        scroller:DockMargin(0, 0, 0, ScreenScale(16))
        scroller:SetTall(256)

        local layout = scroller:Add("DIconLayout")
        layout:Dock(FILL)

        for k, v in SortedPairs(player_manager.AllValidModels()) do
            local icon = layout:Add("SpawnIcon")
            icon:SetModel(v)
            icon:SetSize(64, 128)
            icon:SetTooltip(v)
            icon.DoClick = function()
                notification.AddLegacy("Model set to " .. v, NOTIFY_GENERIC, 5)
            end
        end
    end
})

ow.character:RegisterVariable("money", {
    Type = ow.type.number,
    Field = "money",
    Default = 0
})