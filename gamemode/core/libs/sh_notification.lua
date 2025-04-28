ow.notification = ow.notification or {}

function ow.notification:Send(ply, text, type, duration)
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