modifier_global_override_lua = modifier_global_override_lua or class({})
function modifier_global_override_lua:IsHidden() return true end
function modifier_global_override_lua:IsPurgable() return false end
function modifier_global_override_lua:RemoveOnDeath() return false end
function modifier_global_override_lua:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_global_override_lua:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE} end
function modifier_global_override_lua:OnCreated()
	self.abilities = {
		["ability_lamp_use"] = {"active_duration", "inactive_duration", "AbilityChannelTime"},
	}
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
	self:OnIntervalThink()
end
function modifier_global_override_lua:OnIntervalThink()
	local target = self:GetCaster():GetCursorCastTarget()
	self:GetParent()._cast_target = target and target:entindex() or -1
	self:GetParent()._cast_position = self:GetCaster():GetCursorPosition()
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_global_override_lua:AddCustomTransmitterData()
	local position = self:GetParent()._cast_position
	return {target = self:GetParent()._cast_target, target_x = position.x, target_y = position.y, target_z = position.z}
end
function modifier_global_override_lua:HandleCustomTransmitterData(kv)
	self:GetParent()._cast_target = kv.target
	self:GetParent()._cast_position = Vector(target_x, target_y, target_z)
end
function modifier_global_override_lua:GetModifierOverrideAbilitySpecial(kv)
	if not kv.ability then return 0 end
	local info = self.abilities[kv.ability:GetAbilityName()]
	if info == nil then return end
	if info == "all" then
		return 1
	end
	return BoolToNum(table.contains(info, kv.ability_special_value))
end
function modifier_global_override_lua:GetModifierOverrideAbilitySpecialValue(kv)
	if not kv.ability then return 0 end
	local ability_name = kv.ability:GetAbilityName()
	local info = self.abilities[ability_name]
	if info == nil then return 0 end
	local caster = kv.ability:GetCaster()
	local target = kv.ability:GetCursorTarget()
	local point = kv.ability:GetCursorPosition()
	if ability_name == "ability_lamp_use" then
		local unit_info = target and GetUnitKeyValuesByName(target:GetUnitName()) or nil
		if target == nil or unit_info == nil or unit_info["CaptureData"] == nil or unit_info["CaptureData"]["values"] == nil or unit_info["CaptureData"]["values"][kv.ability_special_value] == nil then
			return kv.ability:GetLevelSpecialValueNoOverride(kv.ability_special_value, kv.ability_special_level)
		end
		return GetKVValue(unit_info["CaptureData"]["values"][kv.ability_special_value], kv.ability_special_level+1)
	end
end

modifier_fountain_aura_lua = modifier_fountain_aura_lua or class({})
function modifier_fountain_aura_lua:IsHidden() return true end
function modifier_fountain_aura_lua:IsAura() return true end
function modifier_fountain_aura_lua:GetModifierAura() return "modifier_fountain_buff_lua" end
function modifier_fountain_aura_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_fountain_aura_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_fountain_aura_lua:GetAuraDuration() return 0.1 end
function modifier_fountain_aura_lua:GetAuraRadius() return 1200 end

modifier_fountain_buff_lua = modifier_fountain_buff_lua or class({})
function modifier_fountain_buff_lua:GetTexture() return "fountain_heal" end
function modifier_fountain_buff_lua:CheckState() return {[MODIFIER_STATE_ATTACK_IMMUNE] = true, [MODIFIER_STATE_UNTARGETABLE_ENEMY] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_NO_HEALTH_BAR_FOR_ENEMIES] = true} end
function modifier_fountain_buff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_fountain_buff_lua:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end
function modifier_fountain_buff_lua:OnIntervalThink()
	self:GetParent():Dispell(self:GetCaster(), true)
	for _, i in pairs(INVENTORY_SLOTS) do
		local item = self:GetParent():GetItemInSlot(i)
		if item then
			if item:GetName() == "item_bottle" then
				item:SetCurrentCharges(3)
			end
		end
	end
end
function modifier_fountain_buff_lua:GetModifierHealthRegenPercentage() return 20 end
function modifier_fountain_buff_lua:GetModifierTotalPercentageManaRegen() return 20 end
function modifier_fountain_buff_lua:GetModifierConstantManaRegen() return 30 end