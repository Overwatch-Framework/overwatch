MODULE = MODULE or {}

local thirdperson = CreateClientConVar("ow_thirdperson", 0, true, false, "Enable third person view.", 0, 1)
local thirdperson_pos_x = CreateClientConVar("ow_thirdperson_pos_x", 50, true, false, "Set the X position of the third person camera.", -100, 100)
local thirdperson_pos_y = CreateClientConVar("ow_thirdperson_pos_y", 15, true, false, "Set the Y position of the third person camera.", -100, 100)
local thirdperson_pos_z = CreateClientConVar("ow_thirdperson_pos_z", 0, true, false, "Set the Z position of the third person camera.", -100, 100)
local thirdperson_follow_head = CreateClientConVar("ow_thirdperson_follow_head", 0, true, false, "Follow the player's head with the third person camera.")

concommand.Add("ow_thirdperson_toggle", function()
    RunConsoleCommand("ow_thirdperson", thirdperson:GetBool() and 0 or 1)
end, nil, "Toggle third person view.")

concommand.Add("ow_thirdperson_reset", function()
    RunConsoleCommand("ow_thirdperson_pos_x", 0)
    RunConsoleCommand("ow_thirdperson_pos_y", 0)
    RunConsoleCommand("ow_thirdperson_pos_z", 0)
end, nil, "Reset third person camera position.")

function MODULE:CalcView(ply, pos, angles, fov)
    if ( !thirdperson:GetBool() ) then return end

    local view = {}

    if ( thirdperson_follow_head:GetBool() ) then
        local head

        for i = 0, ply:GetBoneCount() do
            local bone = ply:GetBoneName(i)
            if ( ow.util:FindString(bone, "head") ) then
                head = i
                break
            end
        end

        if ( head ) then
            local head_pos, head_ang = ply:GetBonePosition(head)
            pos = head_pos
        end
    end

    view.origin = pos - (angles:Forward() * thirdperson_pos_x:GetInt()) + (angles:Right() * thirdperson_pos_y:GetInt()) + (angles:Up() * thirdperson_pos_z:GetInt())
    view.angles = angles
    view.fov = fov

    return view
end

function MODULE:ShouldDrawLocalPlayer(ply)
    return thirdperson:GetBool()
end

function MODULE:AddToolMenuCategories()
    spawnmenu.AddToolCategory("Overwatch", "User", "User")
end

function MODULE:PopulateToolMenu()
    spawnmenu.AddToolMenuOption("Overwatch", "User", "ow_thirdperson", "Third Person", "", "", function(form)
        form:CheckBox("Enable Third Person", "ow_thirdperson")
        form:CheckBox("Follow Head", "ow_thirdperson_follow_head")

        form:NumSlider("Position X", "ow_thirdperson_pos_x", -100, 100, 0)
        form:NumSlider("Position Y", "ow_thirdperson_pos_y", -100, 100, 0)
        form:NumSlider("Position Z", "ow_thirdperson_pos_z", -100, 100, 0)
    end)
end