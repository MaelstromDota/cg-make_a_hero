LinkLuaModifier("modifier_item_null_talisman_lua", "items/null_talisman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_null_talisman_lua_active", "items/null_talisman", LUA_MODIFIER_MOTION_NONE)

item_null_talisman_lua = item_null_talisman_lua or class(ability_lua_base)
function item_null_talisman_lua:GetIntrinsicModifierName() return "modifier_item_null_talisman_lua" end
function item_null_talisman_lua:OnSpellStart()
	local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_null_talisman_lua_active", {duration=self:GetSpecialValueFor("duration")})
	modifier:SetStackCount(table.length(self:GetCaster():GetItemsByName({self:GetName()})))
	self:GetCaster():EmitSound("DOTA_Item.ClarityPotion.Activate")
end

modifier_item_null_talisman_lua = modifier_item_null_talisman_lua or class({})
function modifier_item_null_talisman_lua:IsHidden() return true end
function modifier_item_null_talisman_lua:IsPurgable() return false end
function modifier_item_null_talisman_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_null_talisman_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_null_talisman_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_null_talisman_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_null_talisman_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_null_talisman_lua:GetModifierExtraManaPercentage() return self:GetAbility():GetSpecialValueFor("bonus_max_mana_percentage") end
function modifier_item_null_talisman_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

modifier_item_null_talisman_lua_active = modifier_item_null_talisman_lua_active or class({})
function modifier_item_null_talisman_lua_active:IsPurgable() return false end
function modifier_item_null_talisman_lua_active:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_null_talisman_lua_active:GetEffectName() return "particles/items_fx/healing_clarity.vpcf" end
function modifier_item_null_talisman_lua_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_null_talisman_lua_active:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.mp_regen = self:GetAbility():GetSpecialValueFor("active_mp_regen")
end
function modifier_item_null_talisman_lua_active:OnRefresh()
	self:OnCreated()
end
function modifier_item_null_talisman_lua_active:GetModifierConstantManaRegen() return self.mp_regen * self:GetStackCount() end