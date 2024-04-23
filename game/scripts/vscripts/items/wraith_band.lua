LinkLuaModifier("modifier_item_wraith_band_lua", "items/wraith_band", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_wraith_band_lua_active", "items/wraith_band", LUA_MODIFIER_MOTION_NONE)

item_wraith_band_lua = item_wraith_band_lua or class(ability_lua_base)
function item_wraith_band_lua:GetIntrinsicModifierName() return "modifier_item_wraith_band_lua" end
function item_wraith_band_lua:OnSpellStart()
	local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_wraith_band_lua_active", {duration=self:GetSpecialValueFor("duration")})
	modifier:SetStackCount(table.length(self:GetCaster():GetItemsByName({self:GetName()})))
	self:GetCaster():EmitSound("DOTA_Item.Butterfly")
end

modifier_item_wraith_band_lua = modifier_item_wraith_band_lua or class({})
function modifier_item_wraith_band_lua:IsHidden() return true end
function modifier_item_wraith_band_lua:IsPurgable() return false end
function modifier_item_wraith_band_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_wraith_band_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_wraith_band_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_wraith_band_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_wraith_band_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_wraith_band_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_wraith_band_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

modifier_item_wraith_band_lua_active = modifier_item_wraith_band_lua_active or class({})
function modifier_item_wraith_band_lua_active:IsPurgable() return false end
function modifier_item_wraith_band_lua_active:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_wraith_band_lua_active:GetEffectName() return "particles/items2_fx/butterfly_buff.vpcf" end
function modifier_item_wraith_band_lua_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_wraith_band_lua_active:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.attackspeed = self:GetAbility():GetSpecialValueFor("active_attack_speed")
end
function modifier_item_wraith_band_lua_active:OnRefresh()
	self:OnCreated()
end
function modifier_item_wraith_band_lua_active:GetModifierAttackSpeedBonus_Constant() return self.attackspeed * self:GetStackCount() end