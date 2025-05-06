ow.notification = ow.notification or {}

NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_HINT = 2
NOTIFY_UNDO = 3
NOTIFY_CLEANUP = 4

function ow.notification:Send(client, text, iType, duration)
    if ( !text or text == "" ) then return end

    if ( !iType and string.EndsWith(text, "!") ) then
        iType = NOTIFY_ERROR
    elseif ( !iType and string.EndsWith(text, "?") ) then
        iType = NOTIFY_HINT
    else
        iType = iType or NOTIFY_GENERIC
    end

    duration = duration or 3

    if ( SERVER ) then
        ow.net:Start(client, "notification.send", text, iType, duration)
    else
        notification.AddLegacy(text, iType, duration)
    end
end