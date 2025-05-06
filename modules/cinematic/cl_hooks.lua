local MODULE = MODULE

function MODULE:CalcView(ply, pos, ang, fov)
    if ( !ow.cinematic.Active ) then return end

    local camPos, camAng, camFov = ow.cinematic:GetValue()
    if ( !camPos ) then return end

    return {
        origin = camPos,
        angles = camAng,
        fov = camFov,
        drawviewer = true
    }
end

function MODULE:PostDrawTranslucentRenderables()
    if ( !ow.cinematic.Debug ) then return end

    for id, path in pairs(ow.cinematic.RenderPaths) do
        for i = 2, #path do
            local prev = path[i - 1]
            local node = path[i]

            local points = table.Copy(node.ctrl or {})
            table.insert(points, 1, prev.pos)
            table.insert(points, node.pos)

            local last = points[1]
            for j = 1, 60 do
                local t = j / 60
                local pos = ow.cinematic:Bezier(points, t)

                -- Layered line thickness by offsetting
                for offset = -1, 1 do
                    render.DrawLine(
                        last + Vector(0, 0, offset),
                        pos + Vector(0, 0, offset),
                        Color(255, 150, 0), true
                    )
                end

                last = pos
            end

            -- Anchor
            render.DrawSphere(prev.pos, 4, 12, 12, Color(0, 255, 0))
            render.DrawSphere(node.pos, 4, 12, 12, Color(0, 255, 0))

            -- Control handles
            for _, ctrl in ipairs(node.ctrl or {}) do
                render.DrawSphere(ctrl, 2, 8, 8, Color(255, 0, 0))
                render.DrawLine(node.pos, ctrl, Color(255, 0, 0), true)
            end
        end
    end
end