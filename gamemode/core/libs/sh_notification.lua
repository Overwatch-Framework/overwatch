ow.notification = ow.notification or {}

NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_HINT = 2
NOTIFY_UNDO = 3
NOTIFY_CLEANUP = 4

function ow.notification:Send(ply, text, type, duration)
    if ( !text or text == "" ) then return end

    type = type or NOTIFY_GENERIC
    duration = duration or 3

    if ( SERVER ) then
        net.Start("ow.notification.send")

        net.WriteString(text)
        net.WriteUInt(type, 8)
        net.WriteUInt(duration, 16)

        if ( IsValid(ply) ) then
            net.Send(ply)
        else
            net.Broadcast()
        end
    else
        notification.AddLegacy(text, type, duration)
    end
end