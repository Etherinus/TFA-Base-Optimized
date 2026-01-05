ATTACHMENT = ATTACHMENT or {}

ATTACHMENT.Name = "Base Attachment"
ATTACHMENT.Description = {color_white, "Line1", color_black, "Line2"}
ATTACHMENT.Icon = nil
ATTACHMENT.IconScale = 0.7
ATTACHMENT.Type = "none"

local pairs = pairs
local IsValid = IsValid

local function prepareBodygroups(wep)
    wep.VMBodyGroups = wep.VMBodyGroups or {}
    wep.WMBodyGroups = wep.WMBodyGroups or {}
    wep.OGVMBodyGroups = wep.OGVMBodyGroups or {}
    wep.OGWMBodyGroups = wep.OGWMBodyGroups or {}
    wep.AttachmentBodygroups = wep.AttachmentBodygroups or {}
end

function ATTACHMENT:DoIronSights(wep)
    if not self.IronSightsPos and not self.IronSightsAng then return end

    if not wep.OGIronSightsPos then
        wep.OGIronSightsPos = wep.IronSightsPos
    end

    if not wep.OGIronSightsAng then
        wep.OGIronSightsAng = wep.IronSightsAng
    end

    wep.IronSightsPos = self.IronSightsPos
    wep.IronSightsAng = self.IronSightsAng
end

function ATTACHMENT:RevertIronSights(wep)
    if not self.IronSightsPos and not self.IronSightsAng then return end

    if wep.OGIronSightsPos then
        wep.IronSightsPos = wep.OGIronSightsPos
    end

    if wep.OGIronSightsAng then
        wep.IronSightsAng = wep.OGIronSightsAng
    end
end

local function applyBodygroups(wep, attachID)
    local attachmentBodygroups = wep.AttachmentBodygroups[attachID]
    if not attachmentBodygroups then return end

    local vg = attachmentBodygroups.V or {}
    local wg = attachmentBodygroups.W or {}

    for k, v in pairs(vg) do
        if wep.OGVMBodyGroups[k] == nil then
            wep.OGVMBodyGroups[k] = wep.VMBodyGroups[k]
        end

        wep.VMBodyGroups[k] = v
    end

    for k, v in pairs(wg) do
        if wep.OGWMBodyGroups[k] == nil then
            wep.OGWMBodyGroups[k] = wep.WMBodyGroups[k]
        end

        wep.WMBodyGroups[k] = v
    end
end

local function revertBodygroups(wep, attachID)
    local attachmentBodygroups = wep.AttachmentBodygroups[attachID]
    if not attachmentBodygroups then return end

    local vg = attachmentBodygroups.V or {}
    local wg = attachmentBodygroups.W or {}

    for k in pairs(vg) do
        wep.VMBodyGroups[k] = wep.OGVMBodyGroups[k] or 0
        wep.OGVMBodyGroups[k] = nil
    end

    for k in pairs(wg) do
        wep.WMBodyGroups[k] = wep.OGWMBodyGroups[k] or 0
        wep.OGWMBodyGroups[k] = nil
    end
end

function ATTACHMENT:AttachBase(wep)
    if not IsValid(wep) then return end

    self:DoIronSights(wep)

    if self.Type ~= "bodygroup" then return end

    prepareBodygroups(wep)

    wep.AttachmentBodygroups[self.ID] = wep.AttachmentBodygroups[self.ID] or {}
    applyBodygroups(wep, self.ID)

    if wep.DoBodyGroups then
        wep:DoBodyGroups()
    end
end

function ATTACHMENT:DetachBase(wep)
    if not IsValid(wep) then return end

    self:RevertIronSights(wep)

    if self.Type ~= "bodygroup" then return end

    prepareBodygroups(wep)

    wep.AttachmentBodygroups[self.ID] = wep.AttachmentBodygroups[self.ID] or {}
    revertBodygroups(wep, self.ID)

    if wep.DoBodyGroups then
        wep:DoBodyGroups()
    end
end

function ATTACHMENT:Attach(wep)
    if not IsValid(wep) then return end
end

function ATTACHMENT:Detach(wep)
    if not IsValid(wep) then return end
end

if not TFA_ATTACHMENT_ISUPDATING then
    TFAUpdateAttachments()
end
