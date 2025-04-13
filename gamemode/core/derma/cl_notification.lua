local PANEL = {}

function PANEL:Init()
    if ( IsValid(ow.gui.notification) ) then
        ow.gui.notification:Remove()
    end

    ow.gui.notification = self

    self:SetSize(ScrW() / 3, ScrH())
    self:SetPos(ScrW() / 2 - (self:GetWide() / 2), ScrH() - self:GetTall())
    self:SetAlpha(0)

    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)

    self.notifications = {}
end

function PANEL:SendNotification(message, icon, duration)
    if ( !message or message == "" ) then return end

    local x, y = self:GetPos()

    local notification = vgui.Create("ow.notification")
    notification:SetSize(self:GetWide(), ScreenScale(12))
    notification:SetPos(x, y - notification:GetTall())
    notification:SetMessage(message)
    notification:SetIcon(icon)

    table.insert(self.notifications, notification)

    notification.created = CurTime()
    notification.duration = duration or 5

    timer.Simple(duration or 5, function()
        if ( IsValid(notification) ) then
            notification:AlphaTo(0, 0.5, 0, function()
                if ( IsValid(notification) ) then
                    notification:Remove()

                    table.RemoveByValue(self.notifications, notification)
                    self:OrderNotifications()
                end
            end)
        end
    end)

    self:OrderNotifications()
end

function PANEL:OrderNotifications()
    local x, y = self:GetPos()
    y = y - ScreenScale(12) -- Adjust the y position to account for the notification height

    local count = table.Count(self.notifications)
    if ( count == 0 ) then return end

    for _, v in pairs(self.notifications) do
        if ( IsValid(v) ) then
            v:MoveTo(x, y + ((v:GetTall() + ScreenScale(4)) * count), 0.5, 0, 1, function()
                -- This is where we can add any additional logic after the notification has moved
            end)

            count = count - 1
        end
    end
end

function PANEL:ClearNotifications()
    for k, v in pairs(self.notifications) do
        if ( IsValid(v) ) then
            v:Remove()
        end
    end

    self.notifications = {}
end

function PANEL:OnRemove()
    self:ClearNotifications()
end

vgui.Register("ow.notification.core", PANEL, "DPanel")

PANEL = {}

function PANEL:Init()
    -- Play a sound when the notification is created
    LocalPlayer():EmitSound("garrysmod/balloon_pop_cute.wav", 75, math.random(90, 110), 0.5)

    self.message = self:Add("DLabel")
    self.message:SetText("Notification Message")
    self.message:SetTextColor(Color(255, 255, 255, 255))
    self.message:SetFont("ow.fonts.default.bold")
    self.message:SizeToContents()
    self.message:SetPos(10, self:GetTall() / 2 - self.message:GetTall() / 2)
end

function PANEL:SetMessage(message)
    if ( !message or message == "" ) then return end
    if ( message == self.message:GetText() ) then return end

    local wrapped = ow.util:WrapText(message, "ow.fonts.default.bold", self:GetWide() - ScreenScale(20))
    if ( table.Count(wrapped) > 1 ) then
        self.message:SetText("")

        for k, v in pairs(wrapped) do
            if ( k == 1 ) then
                self.message:SetText(v)
                self.message:SizeToContents()
            else
                local newLabel = self:Add("DLabel")
                newLabel:SetText(v)
                newLabel:SetTextColor(Color(255, 255, 255, 255))
                newLabel:SetFont("ow.fonts.default.bold")
                newLabel:SizeToContents()
                newLabel:SetPos(10, self:GetTall() / 2 - self.message:GetTall() / 2 + (k - 1) * (self.message:GetTall() + ScreenScale(2)))
            end
        end

        self:SetTall(self:GetTall() + (table.Count(wrapped) - 1) * (self.message:GetTall() + ScreenScale(2)))
    else
        self.message:SetText(message)
        self.message:SizeToContents()
    end
end

function PANEL:SetIcon(icon)
    if ( !icon or icon == "" ) then return end
    if ( self.icon and self.icon:GetImage() == icon ) then return end

    if ( !self.icon ) then
        self.icon = self:Add("DImage")
        self.icon:SetSize(ScreenScale(12), ScreenScale(12))
        self.icon:SetPos(10, 10)
    end

    self.icon:SetImage(icon)

    self.message:SetPos(self.icon:GetWide() + 20, self:GetTall() / 2 - self.message:GetTall() / 2)
end

function PANEL:Paint(width, height)
    local fraction = 0
    if ( self.created and self.duration ) then
        fraction = math.Clamp((CurTime() - self.created) / self.duration, 0, 1)
    end

    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, 0, width, height)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(0, height - 1, width - width * fraction, 1)
end

vgui.Register("ow.notification", PANEL, "DPanel")

concommand.Add("ow_notification_test", function(ply, cmd, args)
    if ( !IsValid(ow.gui.notification) ) then
        ow.gui.notification = vgui.Create("ow.notification.core")
    end

    local message = args[1] or "Test Notification"
    local icon = args[2] or "icon16/information.png"
    local duration = tonumber(args[3]) or 5

    ow.gui.notification:SendNotification(message, icon, duration)
end)

concommand.Add("ow_notification_clear", function(ply, cmd, args)
    if ( !IsValid(ow.gui.notification) ) then
        ow.gui.notification = vgui.Create("ow.notification.core")
    end

    ow.gui.notification:ClearNotifications()
end)

concommand.Add("ow_notification_reload", function(ply, cmd, args)
    if ( IsValid(ow.gui.notification) ) then
        ow.gui.notification:Remove()
    end

    ow.gui.notification = vgui.Create("ow.notification.core")
    ow.gui.notification:ClearNotifications()
    ow.gui.notification:SendNotification("Reloaded Notifications", "icon16/information.png", 5)
end)

hook.Add("InitPostEntity", "ow.notification.init", function()
    if ( !IsValid(ow.gui.notification) ) then
        ow.gui.notification = vgui.Create("ow.notification.core")
    end
end)

notification.AddLegacy = function(text, type, length)
    if ( !IsValid(ow.gui.notification) ) then
        ow.gui.notification = vgui.Create("ow.notification.core")
    end

    ow.gui.notification:SendNotification(text, "icon16/information.png", length or 5)
end