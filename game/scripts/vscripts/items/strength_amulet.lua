LinkLuaModifier("modifier_item_strength_amulet_lua", "items/strength_amulet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_strength_amulet_active_lua", "items/strength_amulet", LUA_MODIFIER_MOTION_NONE)

item_strength_amulet_lua = item_strength_amulet_lua or class(ability_lua_base)
function item_strength_amulet_lua:GetIntrinsicModifierName() return "modifier_item_strength_amulet_lua" end
function item_strength_amulet_lua:OnRuneActivated(rune)
	self:SetCurrentCharges(self:GetCurrentCharges() + (self:GetCurrentCharges() < 5 and 2 or 1))
	self:GetCaster():CalculateStatBonus(true)
end
function item_strength_amulet_lua:OnDeath()
	self:SetCurrentCharges(math.max(math.floor(self:GetCurrentCharges()/2), 0))
end
function item_strength_amulet_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_strength_amulet_active_lua", {duration=self:GetSpecialValueFor("active_duration")})
end

modifier_item_strength_amulet_lua = modifier_item_strength_amulet_lua or class({})
function modifier_item_strength_amulet_lua:IsHidden() return true end
function modifier_item_strength_amulet_lua:IsPurgable() return false end
function modifier_item_strength_amulet_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS} end
function modifier_item_strength_amulet_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") + (self:GetAbility():GetSpecialValueFor("bonus_strength_per_charge") * self:GetAbility():GetCurrentCharges()) end
function modifier_item_strength_amulet_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor_per_charge") * self:GetAbility():GetCurrentCharges() end
function modifier_item_strength_amulet_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health_per_charge") * self:GetAbility():GetCurrentCharges() end

modifier_item_strength_amulet_active_lua = modifier_item_strength_amulet_active_lua or class({})
function modifier_item_strength_amulet_active_lua:IsPurgable() return true end
function modifier_item_strength_amulet_active_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_item_strength_amulet_active_lua:OnCreated()
	self.strength_multiplier = self:GetAbility():GetSpecialValueFor("active_strength_multiplier")
end
function modifier_item_strength_amulet_active_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_strength_amulet_active_lua:GetModifierBonusStats_Strength()
	if self.lock1 then return end
	self.lock1 = true
	local strength = IsServer() and self:GetParent():GetStrength() or (self:GetParent():GetStrength()/2)*self.strength_multiplier/100
	self.lock1 = false
	return strength*self.strength_multiplier/100
end