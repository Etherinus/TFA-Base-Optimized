local sp = game.SinglePlayer()
local l_CT = CurTime

function SWEP:ResetEvents()
	if not self:OwnerIsValid() then return end

	if sp and not CLIENT then
		self:CallOnClient("ResetEvents", "")
	end

	self.EventTimer = l_CT()

	local et = self.EventTable
	if not istable(et) then return end

	for _, v in pairs(et) do
		if istable(v) then
			for __, b in pairs(v) do
				if istable(b) then
					b.called = false
				end
			end
		end
	end
end

function SWEP:ProcessEvents()
	if not self:VMIV() then return end

	local et = self.EventTable
	if not istable(et) then return end

	local act = self:GetLastActivity()
	local evtbl = et[act]
	if not istable(evtbl) then return end

	local now = l_CT()
	local evtt = self.EventTimer or now

	for _, v in pairs(evtbl) do
		if not istable(v) then continue end
		if v.called then continue end

		local t = tonumber(v.time) or 0
		if now < evtt + t then continue end

		v.called = true

		if v.client == nil then
			v.client = true
		end

		if v.type == "lua" then
			if v.server == nil then
				v.server = true
			end

			local fn = v.value
			if not fn then continue end

			local allowClient = v.client and CLIENT and (not v.client_predictedonly or self:GetOwner() == LocalPlayer())
			local allowServer = v.server and SERVER

			if allowClient or allowServer then
				fn(self, self.OwnerViewModel)
			end
		elseif v.type == "snd" or v.type == "sound" then
			if v.server == nil then
				v.server = false
			end

			local s = v.value
			if not s or s == "" then continue end

			if SERVER then
				if v.client then
					net.Start("tfaSoundEvent")
					net.WriteEntity(self)
					net.WriteString(s)

					if sp then
						net.Broadcast()
					else
						local owner = self:GetOwner()
						if IsValid(owner) then
							net.SendOmit(owner)
						else
							net.Broadcast()
						end
					end
				elseif v.server then
					self:EmitSound(s)
				end
			else
				if v.client and self:GetOwner() == LocalPlayer() and not sp then
					self:EmitSound(s)
				end
			end
		end
	end
end
