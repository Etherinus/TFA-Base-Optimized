local sp = game.SinglePlayer()
local l_CT = CurTime
--[[
Function Name:  ResetEvents
Syntax: self:ResetEvents()
Returns:  Nothing.
Purpose:  Cleans up events table.
]]--
function SWEP:ResetEvents()
	if not self:OwnerIsValid() then return end

	if sp and not CLIENT then
		self:CallOnClient("ResetEvents", "")
	end

	self.EventTimer = l_CT()

	for k, v in pairs(self.EventTable) do
		for l, b in pairs(v) do
			b.called = false
		end
	end
end

--[[
Function Name:  ProcessEvents
Syntax: self:ProcessEvents( ).
Returns:  Nothing.
Notes: Critical for the event table to function.
Purpose:  Main SWEP function
]]--
function SWEP:ProcessEvents()
	if not self:VMIV() then return end

	local evtbl = self.EventTable[ self:GetLastActivity() ]

	if not evtbl then return end
	for k, v in pairs(evtbl) do
		if v.called or l_CT() < self.EventTimer + v.time then continue end
		v.called = true

		if v.client == nil then
			v.client = true
		end

		if v.type == "lua" then
			if v.server == nil then
				v.server = true
			end

			if (v.client and CLIENT and (not v.client_predictedonly or self.Owner == LocalPlayer())) or (v.server and SERVER) and v.value then
				v.value(self, self.OwnerViewModel)
			end
		elseif v.type == "snd" or v.type == "sound" then
			if v.server == nil then
				v.server = false
			end

			if SERVER then
				if v.client then
					net.Start("tfaSoundEvent")
					net.WriteEntity(self)
					net.WriteString(v.value or "")

					if sp then
						net.Broadcast()
					else
						net.SendOmit(self.Owner)
					end
				elseif v.server and v.value and v.value ~= "" then
					self:EmitSound(v.value)
				end
			elseif v.client and self.Owner == LocalPlayer() and not sp and v.value and v.value ~= "" then
				self:EmitSound(v.value)
			end
		end
	end
end