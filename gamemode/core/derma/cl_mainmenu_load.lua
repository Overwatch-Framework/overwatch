local padding = ScreenScale(32)
local smallPadding = ScreenScale(16) -- not used
local tinyPadding = ScreenScale(8)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:SetVisible(false)
end

function PANEL:Populate()
    local ply = LocalPlayer()
    if ( !IsValid(ply) ) then return end

    local parent = self:GetParent()
    parent:SetGradientLeftTarget(0)
    parent:SetGradientRightTarget(0)
    parent:SetGradientTopTarget(1)
    parent:SetGradientBottomTarget(1)
    parent:SetDimTarget(0.25)
    parent.container:Clear()
    parent.container:SetVisible(false)

    self:Clear()
    self:SetVisible(true)

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText(string.upper("mainmenu.select.character"))

    local navigation = self:Add("EditablePanel")
    navigation:Dock(BOTTOM)
    navigation:DockMargin(padding, 0, padding, padding)
    navigation:SetTall(ScreenScale(24))

    local backButton = navigation:Add("ow.mainmenu.button.small")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")
    backButton.DoClick = function()
        self:Clear()
        self:SetVisible(false)
        parent:Populate()
    end

    local characterList = self:Add("DScrollPanel")
    characterList:Dock(FILL)
    characterList:DockMargin(padding * 4, padding, padding * 4, padding)
    characterList:InvalidateParent(true)
    characterList:GetVBar():SetWide(0)
    characterList.Paint = nil

    local plyTable = ply:GetTable()
    for k, v in pairs(plyTable.owCharacters) do
        -- In HL2 the create (chapter) background images are 2048x1024 -- thank you eon
        local button = characterList:Add("ow.mainmenu.button.small")
        button:Dock(TOP)
        button:DockMargin(0, 0, 0, 16)
        button:SetText(v.name or "Unknown Character")
        button:SetTall(characterList:GetWide() / 8)

        button.DoClick = function()
            net.Start("ow.character.load")
                net.WriteUInt(v.id, 32)
            net.SendToServer()
        end

        local image = button:Add("DImage")
        image:Dock(LEFT)
        image:DockMargin(0, 0, tinyPadding, 0)
        image:SetSize(button:GetTall() * 1.75, button:GetTall())
        image:SetImage(v.Image or "gamepadui/chapter14")
    end
end

vgui.Register("ow.mainmenu.load", PANEL, "EditablePanel")