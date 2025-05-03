ENT.Base			= "base_gmodentity"
ENT.Type			= "anim"
ENT.PrintName		= "Currency"
ENT.Author			= "Overwatch Developers"
ENT.Purpose			= "Moneyyyyy."
ENT.Instructions	= "Use to get money."
ENT.Category 		= "Overwatch"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Amount")
end

properties.Add("ow.property.currency.setamount", {
	MenuLabel = "Set Amount",
	Order = 999,
	MenuIcon = "icon16/money.png",
	Filter = function( self, ent, ply )
		if ( !IsValid(ent) or ent:GetClass() != "ow_currency" ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "ow.property.currency.setamount", ent ) ) then return false end

		return ply:IsSuperAdmin()
	end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		Derma_StringRequest(
			"Set Amount",
			"Enter the amount of currency:",
			tostring(ent:GetAmount()),
			function(text)
				if ( !isstring(text) or text == "" ) then return end

				local amount = tonumber(text)
				if ( !isnumber(amount) or amount < 0 ) then return end

				self:MsgStart()
					net.WriteEntity(ent)
					net.WriteFloat(amount)
				self:MsgEnd()
			end
		)
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end

		local amount = net.ReadFloat()
		if ( !isnumber(amount) ) then return end

		if ( amount < 0 ) then
			ow.util:PrintWarning(Format("Admin %s (%s) tried to set the amount of currency to a negative value!", ply:SteamName(), ply:SteamID64()))
			return
		end

		ent:SetAmount(amount)
	end
})