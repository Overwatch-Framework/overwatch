--[[
    Advanced Background Animations for Garry's Mod
    
    A collection of animated backgrounds of various styles.
    Part of the Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    -- Base settings
    Style = 'matrix', -- matrix, starfield, honeycomb, circuit, bubbles, noise
    BackgroundColor = Color(20, 22, 30),
    
    -- Motion settings
    Speed = 1,
    Density = 0.5,
    Depth = true,
    
    -- Visual settings
    PrimaryColor = Color(70, 150, 255, 100),
    SecondaryColor = Color(255, 70, 150, 100),
    AccentColor = Color(100, 255, 100, 100),
    GlowEffect = false,
    
    -- Interaction settings
    MouseInteraction = true,
    InteractionStrength = 1,
    
    -- Performance settings
    UpdateFrequency = 0.03,
    ElementsCount = 100,
    
    -- Style-specific settings
    MatrixCharacters = '01',
    MatrixFontSize = 14,
    CircuitComplexity = 0.7,
    StarfieldDepth = 0.8,
    HoneycombSize = 20,
    NoiseScale = 0.05,
    BubblesMaxSize = 30
}

-- Style drawing functions
local StyleDrawers = {
    -- Matrix-style digital rain
    matrix = function(self, w, h, config, time)
        local charset = config.MatrixCharacters or '01'
        if charset == '' then charset = '01' end
        
        local columns = math.floor(w / (config.MatrixFontSize or 14))
        local fontSize = config.MatrixFontSize or 14
        local density = config.Density or 0.5
        local speed = config.Speed or 1
        
        -- Ensure we have the drops array
        if not self.MatrixDrops then
            self.MatrixDrops = {}
            for i = 1, columns do
                self.MatrixDrops[i] = {
                    y = math.random(-20, h),
                    length = math.random(5, 20),
                    speed = (math.random(5, 15) / 10) * speed,
                    chars = {}
                }
                
                -- Generate random characters for this drop
                for j = 1, self.MatrixDrops[i].length do
                    self.MatrixDrops[i].chars[j] = string.sub(charset, math.random(1, #charset), math.random(1, #charset))
                end
            end
        end
        
        -- Set font
        surface.SetFont('MatrixFont' .. fontSize)
        
        -- Update and draw each drop
        for i, drop in ipairs(self.MatrixDrops) do
            -- Update position
            drop.y = drop.y + drop.speed
            
            -- Randomize characters occasionally
            if math.random() < 0.05 then
                local changePos = math.random(1, #drop.chars)
                drop.chars[changePos] = string.sub(charset, math.random(1, #charset), math.random(1, #charset))
            end
            
            -- Draw characters with fading effect
            for j = 1, drop.length do
                local charY = drop.y - (j * fontSize)
                
                -- Skip if not visible
                if charY < -fontSize or charY > h then
                    continue
                end
                
                -- Determine color based on position in the drop
                local alpha
                if j == 1 then
                    -- Leading character is brightest
                    alpha = 255
                else
                    -- Others fade out the further they are from the lead
                    alpha = 255 - (j / drop.length) * 220
                end
                
                local color
                if j == 1 then
                    -- Leading character in accent color
                    color = Color(
                        config.AccentColor.r,
                        config.AccentColor.g,
                        config.AccentColor.b,
                        alpha
                    )
                else
                    -- Rest in primary color with fading
                    color = Color(
                        config.PrimaryColor.r,
                        config.PrimaryColor.g,
                        config.PrimaryColor.b,
                        alpha
                    )
                end
                
                -- Draw glow effect if enabled
                if config.GlowEffect and j == 1 then
                    local glowColor = Color(
                        config.AccentColor.r,
                        config.AccentColor.g,
                        config.AccentColor.b,
                        alpha * 0.4
                    )
                    
                    draw.SimpleText(
                        drop.chars[j],
                        'MatrixFont' .. (fontSize + 2),
                        i * fontSize,
                        charY,
                        glowColor,
                        TEXT_ALIGN_CENTER
                    )
                end
                
                -- Draw the character
                draw.SimpleText(
                    drop.chars[j],
                    'MatrixFont' .. fontSize,
                    i * fontSize,
                    charY,
                    color,
                    TEXT_ALIGN_CENTER
                )
            end
            
            -- Reset drop if it's gone off-screen
            if drop.y - (drop.length * fontSize) > h then
                drop.y = math.random(-100, -20)
                drop.length = math.random(5, 20)
                drop.speed = (math.random(5, 15) / 10) * speed
                
                -- Regenerate characters
                drop.chars = {}
                for j = 1, drop.length do
                    drop.chars[j] = string.sub(charset, math.random(1, #charset), math.random(1, #charset))
                end
            end
        end
    end,
    
    -- Starfield animation
    starfield = function(self, w, h, config, time)
        local centerX, centerY = w/2, h/2
        local depth = config.StarfieldDepth or 0.8
        local speed = config.Speed or 1
        local starCount = math.floor(config.ElementsCount or 100)
        
        -- Ensure we have the stars array
        if not self.Stars then
            self.Stars = {}
            for i = 1, starCount do
                local angle = math.random() * math.pi * 2
                local distance = math.random(50, 500)
                
                self.Stars[i] = {
                    x = math.cos(angle) * distance + centerX,
                    y = math.sin(angle) * distance + centerY,
                    z = math.random(1, 1000) / 1000, -- depth
                    size = math.random(1, 4),
                    color = i % 20 == 0 and config.SecondaryColor or 
                            i % 10 == 0 and config.AccentColor or 
                            config.PrimaryColor
                }
            end
        end
        
        -- Mouse position influence
        local mouseInfluence = {x = 0, y = 0}
        if config.MouseInteraction and self.MouseX then
            mouseInfluence.x = (self.MouseX - centerX) / w * 5 * config.InteractionStrength
            mouseInfluence.y = (self.MouseY - centerY) / h * 5 * config.InteractionStrength
        end
        
        -- Update and draw each star
        for i, star in ipairs(self.Stars) do
            -- Move star toward the center (creates zooming effect)
            star.z = star.z - 0.002 * speed
            
            -- Reset when star goes past the observer
            if star.z <= 0 then
                local angle = math.random() * math.pi * 2
                local distance = math.random(300, 500)
                
                star.x = math.cos(angle) * distance + centerX
                star.y = math.sin(angle) * distance + centerY
                star.z = 1 -- reset to far distance
                star.size = math.random(1, 4)
                
                -- Occasionally create special colored stars
                if math.random() < 0.1 then
                    star.color = config.SecondaryColor
                elseif math.random() < 0.05 then
                    star.color = config.AccentColor
                else
                    star.color = config.PrimaryColor
                end
            end
            
            -- Project 3D position to 2D screen
            local factor = 1 / star.z
            local projectedX = (star.x - centerX) * factor * depth + centerX + mouseInfluence.x
            local projectedY = (star.y - centerY) * factor * depth + centerY + mouseInfluence.y
            
            -- Skip if outside screen
            if projectedX < 0 or projectedX > w or projectedY < 0 or projectedY > h then
                continue
            end
            
            -- Calculate size and brightness based on depth
            local adjustedSize = star.size * factor
            local brightness = (1 - star.z) * 255
            
            -- Determine color
            local color = Color(
                star.color.r,
                star.color.g,
                star.color.b,
                brightness
            )
            
            -- Draw motion trail if moving fast enough
            if speed > 1 and config.Depth then
                local trailLength = math.min(3, speed)
                local prevX, prevY = projectedX, projectedY
                local factor2 = 1 / (star.z + 0.01 * speed)
                local prevProjX = (star.x - centerX) * factor2 * depth + centerX
                local prevProjY = (star.y - centerY) * factor2 * depth + centerY
                
                surface.SetDrawColor(color.r, color.g, color.b, brightness * 0.3)
                surface.DrawLine(projectedX, projectedY, prevProjX, prevProjY)
            end
            
            -- Draw glow effect if enabled
            if config.GlowEffect and star.size > 2 then
                draw.NoTexture()
                surface.SetDrawColor(color.r, color.g, color.b, brightness * 0.4)
                surface.SafeDrawCircle(projectedX, projectedY, adjustedSize * 2, 8)
            end
            
            -- Draw the star
            draw.NoTexture()
            surface.SetDrawColor(color)
            surface.SafeDrawCircle(projectedX, projectedY, adjustedSize, 8)
        end
    end,
    
    -- Honeycomb pattern
    honeycomb = function(self, w, h, config, time)
        local hexSize = config.HoneycombSize or 20
        local spacing = hexSize * 1.5
        local verticalSpacing = hexSize * 1.73205 -- sqrt(3)
        local speed = config.Speed or 1
        local density = config.Density or 0.5
        
        -- Draw hexagonal grid
        for row = -1, math.ceil(h / verticalSpacing) + 1 do
            local offset = (row % 2) * (spacing / 2)
            
            for col = -1, math.ceil(w / spacing) + 1 do
                local centerX = col * spacing + offset
                local centerY = row * verticalSpacing
                
                -- Skip some hexagons based on density
                if density < 1 and math.random() > density * 1.2 then
                    continue
                end
                
                -- Calculate pulse effect
                local distFromCenter = math.sqrt((centerX - w/2)^2 + (centerY - h/2)^2)
                local pulseTime = time * speed * 0.5
                local pulseFactor = math.sin(pulseTime - distFromCenter * 0.01) * 0.2 + 0.8
                local pulseSize = hexSize * pulseFactor
                
                -- Determine color based on position and time
                local colorValue = math.sin(distFromCenter * 0.01 + pulseTime)
                local color
                
                if colorValue > 0.3 then
                    color = config.PrimaryColor
                elseif colorValue < -0.3 then
                    color = config.SecondaryColor
                else
                    color = config.AccentColor
                end
                
                -- Apply alpha based on pulse
                color = Color(color.r, color.g, color.b, (70 + pulseFactor * 40))
                
                -- Draw hexagon
                local points = {}
                for i = 0, 5 do
                    local angle = math.rad(i * 60)
                    table.insert(points, {
                        x = centerX + math.cos(angle) * pulseSize,
                        y = centerY + math.sin(angle) * pulseSize
                    })
                end
                
                -- Draw hexagon border
                surface.SetDrawColor(color.r, color.g, color.b, color.a * 1.5)
                for i = 1, 6 do
                    local j = i % 6 + 1
                    surface.DrawLine(points[i].x, points[i].y, points[j].x, points[j].y)
                end
                
                -- Draw filled hexagon with reduced alpha
                surface.SetDrawColor(color.r, color.g, color.b, color.a * 0.3)
                draw.NoTexture()
                surface.DrawPoly(points)
                
                -- Draw glow effect if enabled
                if config.GlowEffect and pulseFactor > 0.9 then
                    surface.SetDrawColor(color.r, color.g, color.b, color.a * 0.2)
                    for i = 1, 6 do
                        local j = i % 6 + 1
                        surface.DrawLine(
                            centerX + (points[i].x - centerX) * 1.1, 
                            centerY + (points[i].y - centerY) * 1.1, 
                            centerX + (points[j].x - centerX) * 1.1, 
                            centerY + (points[j].y - centerY) * 1.1
                        )
                    end
                end
                
                -- Draw central dot
                if math.random() < 0.3 then
                    surface.SetDrawColor(color.r, color.g, color.b, color.a * 2)
                    surface.SafeDrawCircle(centerX, centerY, 2, 6)
                end
            end
        end
    end,
    
    -- Digital circuit pattern
    circuit = function(self, w, h, config, time)
        local nodeSize = 3
        local lineWidth = 2
        local complexity = config.CircuitComplexity or 0.7
        local density = config.Density or 0.5
        local speed = config.Speed or 1
        
        -- Create nodes grid if not exists
        if not self.CircuitNodes then
            local gridSize = 30
            local cols = math.ceil(w / gridSize)
            local rows = math.ceil(h / gridSize)
            
            self.CircuitNodes = {}
            
            -- Generate nodes
            for row = 0, rows do
                for col = 0, cols do
                    -- Skip some nodes based on density
                    if math.random() > density * 1.2 then
                        continue
                    end
                    
                    -- Add randomness to position
                    local jitterX = math.random(-10, 10)
                    local jitterY = math.random(-10, 10)
                    
                    local node = {
                        x = col * gridSize + jitterX,
                        y = row * gridSize + jitterY,
                        connections = {},
                        pulseTime = math.random() * 10,
                        pulseSpeed = (0.5 + math.random() * 0.8) * speed,
                        active = math.random() < 0.3,
                        size = math.random(nodeSize - 1, nodeSize + 2),
                        color = math.random() < 0.2 and config.AccentColor or 
                                math.random() < 0.5 and config.SecondaryColor or
                                config.PrimaryColor
                    }
                    
                    -- Add to circuit nodes
                    table.insert(self.CircuitNodes, node)
                end
            end
            
            -- Generate connections between nearby nodes
            for i, node1 in ipairs(self.CircuitNodes) do
                for j, node2 in ipairs(self.CircuitNodes) do
                    if i ~= j then
                        local dx = node1.x - node2.x
                        local dy = node1.y - node2.y
                        local dist = math.sqrt(dx*dx + dy*dy)
                        
                        -- Connect nearby nodes with probability based on complexity
                        if dist < 100 and math.random() < complexity * 0.5 then
                            table.insert(node1.connections, j)
                            
                            -- Create some animation for the connection
                            node1['conn_' .. j] = {
                                progress = 0,
                                speed = 0.2 + math.random() * 0.8,
                                active = false,
                                pulseStart = math.random() * 10,
                                lastActive = 0
                            }
                        end
                    end
                end
            end
        end
        
        -- Update circuit animation
        for i, node in ipairs(self.CircuitNodes) do
            -- Update node pulse
            node.pulseTime = node.pulseTime + 0.016 * node.pulseSpeed
            
            -- Activate/deactivate nodes randomly
            if math.random() < 0.002 * speed then
                node.active = not node.active
            end
            
            -- Update connections
            for _, connIndex in ipairs(node.connections) do
                local conn = node['conn_' .. connIndex]
                if conn then
                    -- Propagate activation along connections
                    if node.active and not conn.active and math.random() < 0.01 * speed then
                        conn.active = true
                        conn.progress = 0
                        conn.lastActive = time
                    end
                    
                    -- Update progress of active connections
                    if conn.active then
                        conn.progress = conn.progress + 0.016 * conn.speed * speed
                        
                        -- Deactivate when complete
                        if conn.progress >= 1 then
                            conn.active = false
                            
                            -- Activate the target node
                            local targetNode = self.CircuitNodes[connIndex]
                            if targetNode then
                                targetNode.active = true
                            end
                        end
                    end
                end
            end
        end
        
        -- Draw circuit nodes and connections
        for i, node in ipairs(self.CircuitNodes) do
            -- Skip if outside screen
            if node.x < -20 or node.x > w + 20 or node.y < -20 or node.y > h + 20 then
                continue
            end
            
            -- Determine node color based on active state
            local pulseValue = math.sin(node.pulseTime) * 0.5 + 0.5
            local nodeColor
            
            if node.active then
                -- Active node uses original color at full brightness
                nodeColor = Color(
                    node.color.r, 
                    node.color.g, 
                    node.color.b, 
                    150 + pulseValue * 105
                )
            else
                -- Inactive node is dimmed
                nodeColor = Color(
                    node.color.r * 0.6, 
                    node.color.g * 0.6, 
                    node.color.b * 0.6, 
                    60 + pulseValue * 40
                )
            end
            
            -- Draw node glow if active and glow enabled
            if config.GlowEffect and node.active then
                surface.SetDrawColor(nodeColor.r, nodeColor.g, nodeColor.b, nodeColor.a * 0.4)
                surface.SafeDrawCircle(node.x, node.y, node.size * 2, 8)
            end
            
            -- Draw the node
            surface.SetDrawColor(nodeColor)
            surface.SafeDrawCircle(node.x, node.y, node.size * (node.active and (0.8 + pulseValue * 0.4) or 1), 8)
            
            -- Draw connections to other nodes
            for _, connIndex in ipairs(node.connections) do
                local targetNode = self.CircuitNodes[connIndex]
                if not targetNode then continue end
                
                local conn = node['conn_' .. connIndex]
                if not conn then continue end
                
                local lineColor
                if conn.active then
                    -- Active connection with bright color
                    lineColor = Color(node.color.r, node.color.g, node.color.b, 150 + pulseValue * 105)
                else
                    -- Recent activity fading
                    local timeSince = time - (conn.lastActive or 0)
                    local fade = math.max(0, 1 - timeSince * 0.5)
                    
                    if fade > 0.1 then
                        -- Recently active connection
                        lineColor = Color(
                            node.color.r * 0.8, 
                            node.color.g * 0.8, 
                            node.color.b * 0.8, 
                            fade * 100
                        )
                    else
                        -- Inactive connection
                        lineColor = Color(
                            node.color.r * 0.4, 
                            node.color.g * 0.4, 
                            node.color.b * 0.4, 
                            30 + pulseValue * 15
                        )
                    end
                end
                
                -- Draw connection line
                surface.SetDrawColor(lineColor)
                
                if conn.active then
                    -- Calculate partial line for animation
                    local startX, startY = node.x, node.y
                    local endX, endY = targetNode.x, targetNode.y
                    local dx, dy = endX - startX, endY - startY
                    
                    local animX = startX + dx * conn.progress
                    local animY = startY + dy * conn.progress
                    
                    -- Draw animated line
                    surface.DrawLine(startX, startY, animX, animY)
                    
                    -- Draw pulse dot at the animation progress point
                    surface.SafeDrawCircle(animX, animY, lineWidth + 1, 6)
                else
                    -- Draw full line for inactive connections
                    surface.DrawLine(node.x, node.y, targetNode.x, targetNode.y)
                    
                    -- Draw small marks on the line
                    if math.random() < 0.3 * pulseValue then
                        local midX = (node.x + targetNode.x) / 2
                        local midY = (node.y + targetNode.y) / 2
                        surface.SafeDrawCircle(midX, midY, lineWidth, 4)
                    end
                end
            end
        }
    end,
    
    -- Bubbles/particles effect
    bubbles = function(self, w, h, config, time)
        local bubbleCount = math.floor(config.ElementsCount or 100)
        local maxSize = config.BubblesMaxSize or 30
        local speed = config.Speed or 1
        local density = config.Density or 0.5
        
        -- Create bubbles if not exists
        if not self.Bubbles then
            self.Bubbles = {}
            for i = 1, bubbleCount do
                local size = math.random(3, maxSize)
                local bubble = {
                    x = math.random(0, w),
                    y = math.random(0, h),
                    size = size,
                    xSpeed = (math.random(-20, 20) / 10) * speed,
                    ySpeed = (math.random(-20, 20) / 10) * speed,
                    color = math.random() < 0.2 and config.AccentColor or
                            math.random() < 0.5 and config.SecondaryColor or
                            config.PrimaryColor,
                    pulseTime = math.random() * 10,
                    pulseSpeed = 0.5 + math.random() * 0.8,
                    opacity = 0.3 + math.random() * 0.7,
                    type = math.random(1, 3) -- 1=circle, 2=square, 3=triangle
                }
                
                table.insert(self.Bubbles, bubble)
            end
        end
        
        -- Mouse position for interaction
        local mouseX, mouseY = self.MouseX or w/2, self.MouseY or h/2
        
        -- Update and draw bubbles
        for i, bubble in ipairs(self.Bubbles) do
            -- Update pulse animation
            bubble.pulseTime = bubble.pulseTime + 0.016 * bubble.pulseSpeed
            local pulse = math.sin(bubble.pulseTime) * 0.3 + 0.7
            
            -- Apply mouse interaction if enabled
            if config.MouseInteraction and mouseX and mouseY then
                local dx = bubble.x - mouseX
                local dy = bubble.y - mouseY
                local dist = math.sqrt(dx*dx + dy*dy)
                
                if dist < 150 then
                    local power = (1 - dist/150) * config.InteractionStrength
                    local angle = math.atan2(dy, dx)
                    
                    bubble.xSpeed = bubble.xSpeed + math.cos(angle) * power * 0.3
                    bubble.ySpeed = bubble.ySpeed + math.sin(angle) * power * 0.3
                end
            end
            
            -- Apply some randomness to movement
            if math.random() < 0.02 then
                bubble.xSpeed = bubble.xSpeed + (math.random(-10, 10) / 30) * speed
                bubble.ySpeed = bubble.ySpeed + (math.random(-10, 10) / 30) * speed
            end
            
            -- Limit max speed
            local maxSpeed = 5 * speed
            local currentSpeed = math.sqrt(bubble.xSpeed^2 + bubble.ySpeed^2)
            if currentSpeed > maxSpeed then
                bubble.xSpeed = bubble.xSpeed * (maxSpeed / currentSpeed)
                bubble.ySpeed = bubble.ySpeed * (maxSpeed / currentSpeed)
            end
            
            -- Update position
            bubble.x = bubble.x + bubble.xSpeed * 0.5
            bubble.y = bubble.y + bubble.ySpeed * 0.5
            
            -- Bounce off edges
            if bubble.x < 0 then
                bubble.x = 0
                bubble.xSpeed = -bubble.xSpeed * 0.8
            elseif bubble.x > w then
                bubble.x = w
                bubble.xSpeed = -bubble.xSpeed * 0.8
            end
            
            if bubble.y < 0 then
                bubble.y = 0
                bubble.ySpeed = -bubble.ySpeed * 0.8
            elseif bubble.y > h then
                bubble.y = h
                bubble.ySpeed = -bubble.ySpeed * 0.8
            end
            
            -- Determine color with pulse effect
            local color = Color(
                bubble.color.r,
                bubble.color.g,
                bubble.color.b,
                bubble.opacity * pulse * 120
            )
            
            -- Draw bubble glow if enabled
            if config.GlowEffect then
                surface.SetDrawColor(color.r, color.g, color.b, color.a * 0.4)
                surface.SafeDrawCircle(bubble.x, bubble.y, bubble.size * 1.5 * pulse, 16)
            end
            
            -- Draw the bubble based on type
            surface.SetDrawColor(color)
            
            if bubble.type == 1 then
                -- Circle
                surface.SafeDrawCircle(bubble.x, bubble.y, bubble.size * pulse, 16)
            elseif bubble.type == 2 then
                -- Square
                local halfSize = bubble.size * pulse / 2
                surface.DrawRect(bubble.x - halfSize, bubble.y - halfSize, halfSize * 2, halfSize * 2)
            else
                -- Triangle
                local points = {}
                local size = bubble.size * pulse
                
                for j = 0, 2 do
                    local angle = math.rad(j * 120 + time * 30 * bubble.pulseSpeed)
                    table.insert(points, {
                        x = bubble.x + math.cos(angle) * size,
                        y = bubble.y + math.sin(angle) * size
                    })
                end
                
                draw.NoTexture()
                surface.DrawPoly(points)
            end
            
            -- Draw motion trail for fast moving bubbles
            local speed = math.sqrt(bubble.xSpeed^2 + bubble.ySpeed^2)
            if speed > 1.5 then
                surface.SetDrawColor(color.r, color.g, color.b, color.a * 0.3)
                surface.DrawLine(
                    bubble.x, 
                    bubble.y, 
                    bubble.x - bubble.xSpeed, 
                    bubble.y - bubble.ySpeed
                )
            end
        end
    end,
    
    -- Perlin noise with gradient effect
    noise = function(self, w, h, config, time)
        local scale = config.NoiseScale or 0.05
        local speed = config.Speed or 1
        local density = config.Density or 0.5
        
        -- Define noise resolution based on density
        local resolution = math.max(3, math.floor(15 * density))
        local cellWidth = w / resolution
        local cellHeight = h / resolution
        
        -- Get mouse position for interaction
        local mouseX, mouseY = self.MouseX or w/2, self.MouseY or h/2
        
        -- Generate smooth noise values
        if not self.NoiseValues or not self.LastNoiseUpdate or
           time - self.LastNoiseUpdate > config.UpdateFrequency then
            
            self.NoiseValues = {}
            self.LastNoiseUpdate = time
            
            for x = 0, resolution + 1 do
                self.NoiseValues[x] = {}
                for y = 0, resolution + 1 do
                    local noiseX = x * scale + time * 0.1 * speed
                    local noiseY = y * scale + time * 0.08 * speed
                    
                    -- Use sine waves to approximate noise
                    local noise = (math.sin(noiseX) + math.sin(noiseY * 1.2) + 
                                  math.sin((noiseX + noiseY) * 0.7) + 
                                  math.sin(math.sqrt(noiseX * noiseX + noiseY * noiseY) * 0.8)) / 4
                    
                    self.NoiseValues[x][y] = noise * 0.5 + 0.5 -- Normalize to 0-1
                end
            end
        end
        
        -- Draw noise field
        for x = 0, resolution do
            for y = 0, resolution do
                local cellX = x * cellWidth
                local cellY = y * cellHeight
                
                -- Get noise values at cell corners
                local n00 = self.NoiseValues[x][y]
                local n10 = self.NoiseValues[x+1][y]
                local n01 = self.NoiseValues[x][y+1]
                local n11 = self.NoiseValues[x+1][y+1]
                
                -- Apply mouse interaction
                if config.MouseInteraction then
                    local centerX = cellX + cellWidth / 2
                    local centerY = cellY + cellHeight / 2
                    local dx = centerX - mouseX
                    local dy = centerY - mouseY
                    local dist = math.sqrt(dx*dx + dy*dy)
                    local maxDist = 150 * config.InteractionStrength
                    
                    if dist < maxDist then
                        local influence = (1 - dist/maxDist) * 0.5
                        n00 = n00 + influence
                        n10 = n10 + influence
                        n01 = n01 + influence
                        n11 = n11 + influence
                    end
                end
                
                -- Create cell points
                local points = {
                    {x = cellX, y = cellY},
                    {x = cellX + cellWidth, y = cellY},
                    {x = cellX + cellWidth, y = cellY + cellHeight},
                    {x = cellX, y = cellY + cellHeight}
                }
                
                -- Calculate average noise value for the cell
                local avgNoise = (n00 + n10 + n01 + n11) / 4
                
                -- Determine cell color based on noise value
                local color
                if avgNoise < 0.33 then
                    color = config.PrimaryColor
                elseif avgNoise < 0.66 then
                    color = config.SecondaryColor
                else
                    color = config.AccentColor
                end
                
                -- Adjust alpha based on noise value
                color = Color(
                    color.r,
                    color.g,
                    color.b,
                    (avgNoise * 80 + 20) * density
                )
                
                -- Draw cell
                surface.SetDrawColor(color)
                draw.NoTexture()
                surface.DrawPoly(points)
                
                -- Draw cell border 
                for i = 1, 4 do
                    local j = i % 4 + 1
                    
                    -- Get noise values of adjacent points
                    local startNoise = i == 1 and n00 or i == 2 and n10 or i == 3 and n11 or n01
                    local endNoise = j == 1 and n00 or j == 2 and n10 or j == 3 and n11 or n01
                    
                    -- Only draw lines with high noise values
                    if (startNoise + endNoise) / 2 > 0.5 then
                        surface.SetDrawColor(
                            color.r,
                            color.g,
                            color.b,
                            color.a * 2 * ((startNoise + endNoise) / 2)
                        )
                        surface.DrawLine(points[i].x, points[i].y, points[j].x, points[j].y)
                    end
                end
                
                -- Draw glow if enabled and noise value is high
                if config.GlowEffect and avgNoise > 0.7 then
                    surface.SetDrawColor(color.r, color.g, color.b, color.a * 0.5)
                    surface.SafeDrawCircle(
                        cellX + cellWidth / 2, 
                        cellY + cellHeight / 2, 
                        (cellWidth + cellHeight) / 4 * avgNoise,
                        8
                    )
                end
            end
        end
    end
}

-- Register fonts for matrix animation
local function RegisterMatrixFonts()
    for i = 10, 20, 2 do
        surface.CreateFont('MatrixFont' .. i, {
            font = 'Courier New',
            size = i,
            weight = 700,
            antialias = true
        })
    end
end

function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.Time = 0
    self.LastUpdateTime = 0
    self.MouseX, self.MouseY = 0, 0
    
    -- Register matrix fonts
    RegisterMatrixFonts()
end

function PANEL:Configure(config)
    -- Check if style has changed, if so reset specific data
    if config and config.Style and self.Config.Style ~= config.Style then
        -- Clear style-specific data when changing styles
        self.MatrixDrops = nil
        self.Stars = nil
        self.CircuitNodes = nil
        self.Bubbles = nil
        self.NoiseValues = nil
    end
    
    self.Config = table.Merge(self.Config, config or {})
end

function PANEL:Think()
    local curTime = CurTime()
    self.Time = curTime
    
    -- Only update on interval for performance
    if curTime - self.LastUpdateTime < self.Config.UpdateFrequency then
        return
    end
    
    self.LastUpdateTime = curTime
    
    -- Get current mouse position
    local x, y = self:CursorPos()
    if x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall() then
        self.MouseX, self.MouseY = x, y
    end
end

function PANEL:Paint(w, h)
    -- Paint background
    surface.SetDrawColor(self.Config.BackgroundColor)
    surface.DrawRect(0, 0, w, h)
    
    -- Get the drawer function for the current style
    local drawStyle = StyleDrawers[self.Config.Style] or StyleDrawers.matrix
    
    -- Draw the style
    drawStyle(self, w, h, self.Config, self.Time)
    
    return true
end

vgui.Register('AnimatedAdvancedBackground', PANEL, 'Panel')