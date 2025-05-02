DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:SetFont("ow.fonts.title")
    title:SetText("CONFIG")

    local config = self:Add("ow.config")
    config:Dock(FILL)
end

vgui.Register("ow.tab.config", PANEL, "EditablePanel")