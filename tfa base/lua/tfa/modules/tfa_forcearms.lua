local arms_forced = "models/weapons/handsfb/c_arms_refugee.mdl"
local cl_tfa_forcearms

hook.Add("PreDrawPlayerHands", "TFAForceArms", function(hands, vm, ply, weapon)
    cl_tfa_forcearms = cl_tfa_forcearms or GetConVar("cl_tfa_forcearms")
    if not cl_tfa_forcearms then return end

    if weapon.Think2 and cl_tfa_forcearms:GetBool() then
        if not hands.HasSetTFAForce then
            hands.OldHandsMDLTFA = hands:GetModel()
            hands:SetModel(arms_forced)
            hands:SetBodygroup(1, 1)
            hands.HasSetTFAForce = true
        end
    elseif hands.HasSetTFAForce then
        local pmName = player_manager.TranslateToPlayerModelName(ply:GetModel()) or ""
        local defaultHands = player_manager.TranslatePlayerHands(pmName).model or hands.OldHandsMDLTFA
        hands:SetModel(defaultHands)
        hands.HasSetTFAForce = false
    end
end)
