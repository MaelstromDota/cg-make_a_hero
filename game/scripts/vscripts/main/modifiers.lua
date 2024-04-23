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