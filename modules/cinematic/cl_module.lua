--- Cinematic
-- Clientside Bézier-based camera system using keyframes and timestamped playback.
-- @module ow.cinematic

ow.cinematic = ow.cinematic or {}
ow.cinematic.Active = nil
ow.cinematic.Path = {}
ow.cinematic.TotalDistance = 0
ow.cinematic.StartTime = 0
ow.cinematic.Duration = 0
ow.cinematic.Debug = true
ow.cinematic.RenderPaths = {}

--- Starts a new cinematic path.
-- @param duration Playback duration
-- @param path Table of {pos, ang, [fov], [ctrl]} entries
function ow.cinematic:Start(duration, path)
    self:Stop()

    self.Path = {}
    self.TotalDistance = 0
    self.Duration = duration
    self.StartTime = CurTime()

    local lastPos

    for i, node in ipairs(path) do
        local pos = node.pos
        local ctrl = node.ctrl or {}
        local ang = node.ang or Angle()
        local fov = node.fov or 90

        local segment = {
            pos = pos,
            ang = ang,
            fov = fov,
            ctrl = ctrl,
            distanceStart = self.TotalDistance
        }

        if ( lastPos ) then
            local distance = 0
            local points = table.Copy(ctrl)
            table.insert(points, 1, lastPos)
            table.insert(points, pos)
            segment.points = points

            for j = 1, 50 do
                local a = self:Bezier(points, (j - 1) / 50)
                local b = self:Bezier(points, j / 50)
                distance = distance + a:Distance(b)
            end

            segment.distanceFromLast = distance
            segment.distanceEnd = self.TotalDistance + distance
            segment.points = points
            self.TotalDistance = self.TotalDistance + distance
        else
            segment.distanceFromLast = 0
            segment.distanceEnd = 0
            segment.points = {}
        end

        table.insert(self.Path, segment)
        lastPos = pos
    end

    self.Active = true
    self.RenderPaths["Cinematic"] = path
end

--- Stops the current cinematic.
function ow.cinematic:Stop()
    self.Path = {}
    self.TotalDistance = 0
    self.StartTime = 0
    self.Duration = 0
    self.Active = nil
    self.RenderPaths["Cinematic"] = nil
end

--- Cubic Bézier curve calculator.
-- @param points Table of 4 control points
-- @param t Normalized progress
function ow.cinematic:Bezier(points, t)
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local uuu = uu * u
    local ttt = tt * t

    return uuu * points[1] +
        3 * uu * t * points[2] +
        3 * u * tt * points[3] +
        ttt * points[4]
end

function ow.cinematic:GetValue()
    local elapsed = CurTime() - self.StartTime
    if elapsed >= self.Duration then self:Stop() return end

    local t = elapsed / self.Duration
    t = math.Clamp(t, 0, 1)

    local curveDist = self.TotalDistance * t
    local path = self.Path

    for i = 2, #path do
        local node = path[i]
        local prev = path[i - 1]

        if node.distanceEnd >= curveDist then
            local localDist = curveDist - prev.distanceEnd
            local localT = localDist / node.distanceFromLast

            -- Compute smoothed shared control handles
            local handleOut = prev.ctrl and prev.ctrl[2] or prev.pos + (node.pos - prev.pos):GetNormalized() * 64
            local handleIn  = node.ctrl and node.ctrl[1] or node.pos - (node.pos - prev.pos):GetNormalized() * 64

            local p0 = prev.pos
            local p1 = handleOut
            local p2 = handleIn
            local p3 = node.pos

            local pos = self:Bezier({p0, p1, p2, p3}, localT)
            local ang = LerpAngle(localT, prev.ang, node.ang)
            local fov = Lerp(localT, prev.fov or 90, node.fov or 90)

            return pos, ang, fov
        end
    end
end

--- Example usage:
local path = {
    {
        pos = Vector(531.986389, -174.066559, -108.851448),
        ang = Angle(-3.142246, -137.042877, 0.000000),
        fov = 90,
        ctrl = {
            Vector(485.217525, -217.613838, -105.343285),
            Vector(578.755253, -130.519279, -112.359611)
        }
    },
    {
        pos = Vector(-1013.600403, -1664.180786, -139.107208),
        ang = Angle(-1.426245, 145.010925, 0.000000),
        fov = 90,
        ctrl = {
            Vector(-1066.016891, -1627.493263, -137.514242),
            Vector(-961.183914, -1700.868309, -140.700175)
        }
    },
    {
        pos = Vector(-2279.062744, -1428.237671, -120.096176),
        ang = Angle(2.797755, 70.100945, 0.000000),
        fov = 90,
        ctrl = {
            Vector(-2257.305412, -1368.130608, -123.220056),
            Vector(-2300.820076, -1488.344734, -116.972296)
        }
    },
    {
        pos = Vector(-2087.961914, -807.570313, -121.843903),
        ang = Angle(-0.898245, 66.470901, 0.000000),
        fov = 90,
        ctrl = {
            Vector(-2062.415314, -748.898651, -120.840594),
            Vector(-2113.508514, -866.241974, -122.847211)
        }
    },
    {
        pos = Vector(-1588.201660, 606.799805, 273.604950),
        ang = Angle(-5.650244, -96.549080, 0.000000),
        fov = 90,
        ctrl = {
            Vector(-1595.465667, 543.526360, 279.906108),
            Vector(-1580.937653, 670.073250, 267.303792)
        }
    },
}

concommand.Add("ow_cinematic_example", function()
    ow.cinematic:Start(#path * 4, path)
end)

-- Prints a point with the current eye pos, angle and fov, used for adding new points
concommand.Add("ow_cinematic_print", function(ply, cmd, args)
    local pos = ply:EyePos()
    local ang = ply:EyeAngles()
    local fov = 90

    local output = string.format("{\n\tpos = Vector(%f, %f, %f),\n\tang = Angle(%f, %f, %f),\n\tfov = %d,\n\tctrl = {\n\t\tVector(%f, %f, %f),\n\t\tVector(%f, %f, %f)\n\t}\n},",
        pos.x, pos.y, pos.z,
        ang.p, ang.y, ang.r,
        fov,
        pos.x + ply:GetForward().x * 64, pos.y + ply:GetForward().y * 64, pos.z + ply:GetForward().z * 64,
        pos.x - ply:GetForward().x * 64, pos.y - ply:GetForward().y * 64, pos.z - ply:GetForward().z * 64
    )

    print(output)
    SetClipboardText(output)
end)