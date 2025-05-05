local CREDITS = {
    {"Riggs", "76561197963057641", {"credit.developer.lead", "credit.designer.lead"}},
    {"bloodycop", "76561198373309941", {"credit.developer.lead", "credit.qol"}}
}

local SPECIALS = {
    {
        {"Luna", "76561197988658543"},
        {"Rain GBizzle", "76561198036111376"}
    },
    {
        {"Black Tea", "76561197999893894"}
    }
}

local MISC = {
    {"Helix", "For this credits screen"},
    {"Project Ordinance", "something"}
}

local logoMat = ow.util:GetMaterial("overwatch/logo_aquamarine_outline_x512.png", "smooth mips")
local padding = 32

-- logo
local PANEL = {}

function PANEL:Init()
    self:SetTall(ScrH() * 0.60)
    self:Dock(TOP)
end

function PANEL:Paint(width, height)
    surface.SetDrawColor(color_white)
    local angle = (CurTime() * 10) % 360
    surface.SetMaterial(logoMat)
    surface.DrawTexturedRectRotated(width / 2, height / 2, height, height, angle)
end

vgui.Register("ow.credits.logo", PANEL, "Panel")

-- nametag
PANEL = {}

function PANEL:Init()
    self.name = self:Add("ow.text")
    self.name:SetFont("ow.fonts.large.bold")

    self.avatar = self:Add("AvatarImage")
end

function PANEL:SetName(name)
    self.name:SetText(name, true)
end

function PANEL:SetAvatar(steamid)
    self.avatar:SetSteamID(steamid, 64)
end

function PANEL:PerformLayout(width, height)
    self.name:SetPos(width - self.name:GetWide(), 0)
    self.avatar:MoveLeftOf(self.name, padding / 2)
end

function PANEL:SizeToContents()
    self.name:SizeToContents()

    local tall = self.name:GetTall()
    self.avatar:SetSize(tall, tall)
    self:SetSize(self.name:GetWide() + self.avatar:GetWide() + padding / 2, self.name:GetTall())
end

vgui.Register("ow.credits.name", PANEL, "Panel")

-- name row
PANEL = {}

function PANEL:Init()
    self:DockMargin(0, padding, 0, 0)
    self:Dock(TOP)

    self.nametag = self:Add("ow.credits.name")

    self.tags = self:Add("ow.text")
    self.tags:SetFont("ow.fonts.large")

    self:SizeToContents()
end

function PANEL:SetName(name)
    self.nametag:SetName(name)
end

function PANEL:SetAvatar(steamid)
    self.nametag:SetAvatar(steamid)
end

function PANEL:SetTags(tags)
    for i = 1, #tags do
        tags[i] = ow.localization:GetPhrase(tags[i])
    end

    self.tags:SetText(table.concat(tags, "\n"))
end

function PANEL:Paint(width, height)
    surface.SetDrawColor(ow.config:Get("color.framework"))
    surface.DrawRect(width / 2 - 1, 0, 1, height)
end

function PANEL:PerformLayout(width, height)
    self.nametag:SetPos(width / 2 - self.nametag:GetWide() - padding, 0)
    self.tags:SetPos(width / 2 + padding, 0)
end

function PANEL:SizeToContents()
    self.nametag:SizeToContents()
    self.tags:SizeToContents()

    self:SetTall(math.max(self.nametag:GetTall(), self.tags:GetTall()))
end

vgui.Register("ow.credits.row", PANEL, "Panel")

PANEL = {}

function PANEL:Init()
    self.left = {}
    self.right = {}
end

function PANEL:AddLeft(name, steamid)
    local nametag = self:Add("ow.credits.name")
    nametag:SetName(name)
    nametag:SetAvatar(steamid)
    nametag:SizeToContents()

    self.left[#self.left + 1] = nametag
end

function PANEL:AddRight(name, steamid)
    local nametag = self:Add("ow.credits.name")
    nametag:SetName(name)
    nametag:SetAvatar(steamid)
    nametag:SizeToContents()

    self.right[#self.right + 1] = nametag
end

function PANEL:PerformLayout(width, height)
    local y = 0

    for _, v in ipairs(self.left) do
        v:SetPos(width * 0.25 - v:GetWide() / 2, y)
        y = y + v:GetTall() + padding
    end

    y = 0

    for _, v in ipairs(self.right) do
        v:SetPos(width * 0.75 - v:GetWide() / 2, y)
        y = y + v:GetTall() + padding
    end

    if ( IsValid(self.center) ) then
        self.center:SetPos(width / 2 - self.center:GetWide() / 2, y)
    end
end

function PANEL:SizeToContents()
    local heightLeft, heightRight, centerHeight = 0, 0, 0

    if ( #self.left > #self.right ) then
        local center = self.left[#self.left]
        centerHeight = center:GetTall()

        self.center = center
        self.left[#self.left] = nil
    elseif ( #self.right > #self.left ) then
        local center = self.right[#self.right]
        centerHeight = center:GetTall()

        self.center = center
        self.right[#self.right] = nil
    end

    for _, v in ipairs(self.left) do
        heightLeft = heightLeft + v:GetTall() + padding
    end

    for _, v in ipairs(self.right) do
        heightRight = heightRight + v:GetTall() + padding
    end

    self:SetTall(math.max(heightLeft, heightRight) + centerHeight)
end

vgui.Register("ow.credits.specials", PANEL, "Panel")

PANEL = {}

function PANEL:Init()
    self:Add("ow.credits.logo")

    for _, v in ipairs(CREDITS) do
        local row = self:Add("ow.credits.row")
        row:SetName(v[1])
        row:SetAvatar(v[2])
        row:SetTags(v[3])
        row:SizeToContents()
    end

    local specials = self:Add("ow.text")
    specials:SetFont("ow.fonts.button")
    specials:SetText("credit.specials")
    specials:SetTextColor(ow.config:Get("color.framework"))
    specials:SetContentAlignment(5)
    specials:DockMargin(0, padding * 2, 0, padding)
    specials:Dock(TOP)
    specials:SizeToContents()

    local specialList = self:Add("ow.credits.specials")
    specialList:DockMargin(0, padding, 0, 0)
    specialList:Dock(TOP)

    for _, v in ipairs(SPECIALS[1]) do
        specialList:AddLeft(v[1], v[2])
    end

    for _, v in ipairs(SPECIALS[2]) do
        specialList:AddRight(v[1], v[2])
    end

    specialList:SizeToContents()

    if ( IsValid(specialList.center) ) then
        specialList:DockMargin(0, padding, 0, padding)
    end

    for _, v in ipairs(MISC) do
        local title = self:Add("ow.text")
        title:SetFont("ow.fonts.extralarge.bold")
        title:SetText(v[1], true)
        title:SetContentAlignment(5)
        title:SizeToContents()
        title:DockMargin(0, padding, 0, -padding / 2)
        title:Dock(TOP)

        local description = self:Add("ow.text")
        description:SetFont("ow.fonts.large")
        description:SetText(v[2], true)
        description:SetContentAlignment(5)
        description:SizeToContents()
        description:Dock(TOP)
    end

    self:Dock(TOP)
    self:SizeToContents()
end

function PANEL:SizeToContents()
    local height = padding

    for _, v in pairs(self:GetChildren()) do
        local _, top, _, bottom = v:GetDockMargin()
        height = height + v:GetTall() + top + bottom
    end

    self:SetTall(height)
end

vgui.Register("ow.credits", PANEL, "Panel")