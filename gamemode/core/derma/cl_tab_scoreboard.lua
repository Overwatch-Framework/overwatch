local padding = ScreenScale(32)
local gradientLeft = ow.util:GetMaterial("vgui/gradient-l")
local gradientBottom = ow.util:GetMaterial("vgui/gradient-d")

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:SetFont("ow.fonts.title")
    title:SetText("SCOREBOARD")
    title:SetContentAlignment(5)

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
    self.container:DockMargin(0, padding / 8, 0, 0)

    self.cache = {}
    self.cache.players = {}
end

function PANEL:Think()
    if ( #self.cache.players != #player.GetAll() ) then
        self:Populate()
    end
end

function PANEL:Populate()
    self.cache.players = player.GetAll()

    -- Divide the players into teams
    local teams = {}
    for _, ply in ipairs(self.cache.players) do
        local teamID = ply:Team()
        if ( !istable(teams[teamID]) ) then
            teams[teamID] = {}
        end

        table.insert(teams[teamID], ply)
    end

    -- Sort the teams by their team ID
    local sortedTeams = {}
    for teamID, players in pairs(teams) do
        table.insert(sortedTeams, { teamID = teamID, players = players })
    end

    table.sort(sortedTeams, function(a, b) return a.teamID < b.teamID end)

    -- Clear the current scoreboard
    self.container:Clear()

    for _, teamData in ipairs(sortedTeams) do
        local teamID = teamData.teamID
        local players = teamData.players

        -- Create a new panel for the team
        local teamPanel = self.container:Add("ow.tab.scoreboard.team")
        teamPanel:SetTeam(teamID)

        -- Add each player to the team panel
        for _, ply in ipairs(players) do
            local playerPanel = teamPanel.container:Add("ow.tab.scoreboard.player")
            playerPanel:SetPlayer(ply)

            teamPanel.players[ply:SteamID64()] = playerPanel
        end
    end
end

vgui.Register("ow.tab.scoreboard", PANEL, "EditablePanel")

PANEL = {}

function PANEL:Init()
    self:Dock(TOP)
    self:DockMargin(0, 0, 0, ScreenScale(8))

    self.teamID = 0
    self.players = {}

    self.teamName = self:Add("ow.text")
    self.teamName:SetTall(ScreenScale(10))
    self.teamName:Dock(TOP)
    self.teamName:DockMargin(ScreenScale(2), 0, 0, 0)
    self.teamName:SetFont("ow.fonts.default.italic.bold")
    self.teamName:SetContentAlignment(7)

    self.container = self:Add("DPanel")
    self.container:Dock(FILL)
    self.container.Paint = function(this, width, height)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, width, height)

        surface.SetMaterial(gradientBottom)
        surface.SetDrawColor(50, 50, 50, 200)
        surface.DrawTexturedRect(0, 0, width, height)
    end
end

function PANEL:SetTeam(teamID)
    self.teamID = teamID

    if ( IsValid(self.teamName) ) then
        self.teamName:SetText(team.GetName(teamID), true, true)
    end
end

function PANEL:PerformLayout(width, height)
    -- Resize the panel height to fit the team name and the other players
    local teamNameHeight = self.teamName:GetTall()
    local containerHeight = 0

    for _, playerPanel in pairs(self.players) do
        containerHeight = containerHeight + playerPanel:GetTall()
    end

    self:SetTall(teamNameHeight + containerHeight)
end

function PANEL:Paint(width, height)
    local color = team.GetColor(self.teamID)

    surface.SetMaterial(gradientLeft)
    surface.SetDrawColor(color.r, color.g, color.b, 200)
    surface.DrawTexturedRect(0, 0, width, self.teamName:GetTall())
end

vgui.Register("ow.tab.scoreboard.team", PANEL, "EditablePanel")

PANEL = {}

function PANEL:Init()
    self:Dock(TOP)
    self:SetTall(ScreenScale(16))

    self.avatar = self:Add("AvatarImage")
    self.avatar:SetSize(self:GetTall(), self:GetTall())
    self.avatar:SetPos(0, 0)

    self.name = self:Add("ow.text")
    self.name:SetFont("ow.fonts.large.bold")

    self.ping = self:Add("ow.text")
    self.ping:SetSize(ScreenScale(32), self:GetTall())
    self.ping:SetFont("ow.fonts.large.bold")
    self.ping:SetContentAlignment(6)
end

function PANEL:SetPlayer(ply)
    self.player = ply

    if ( IsValid(self.avatar) ) then
        self.avatar:SetPlayer(ply, self:GetTall())
    end

    if ( IsValid(self.name) ) then
        self.name:SetText(ply:SteamName(), true)
        self.name:SetPos(self.avatar:GetWide() + 16, self:GetTall() / 2 - self.name:GetTall() / 2)
    end
end

function PANEL:Think()
    if ( IsValid(self.ping) and IsValid(self.player) ) then
        self.ping:SetText(self.player:Ping() .. "ms", true)
        self.ping:SetPos(self:GetWide() - self.ping:GetWide() - 16, self:GetTall() / 2 - self.ping:GetTall() / 2)
    end
end

vgui.Register("ow.tab.scoreboard.player", PANEL, "EditablePanel")