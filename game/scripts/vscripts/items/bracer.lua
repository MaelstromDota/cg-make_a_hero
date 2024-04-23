LinkLuaModifier("modifier_item_bracer_lua", "items/bracer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bracer_lua_active", "items/bracer", LUA_MODIFIER_MOTION_NONE)

item_bracer_lua = item_bracer_lua or class(ability_lua_base)
function item_bracer_lua:GetIntrinsicModifierName() return "modifier_item_bracer_lua" end
function item_bracer_lua:OnSpellStart()
	local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_bracer_lua_active", {duration=self:GetSpecialValueFor("duration")})
	modifier:SetStackCount(table.length(self:GetCaster():GetItemsByName({self:GetName()})))
	self:GetCaster():EmitSound("DOTA_Item.HealingSalve.Activate")
end

modifier_item_bracer_lua = modifier_item_bracer_lua or class({})
function modifier_item_bracer_lua:IsHidden() return true end
function modifier_item_bracer_lua:IsPurgable() return false end
function modifier_item_bracer_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_bracer_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_bracer_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_bracer_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_bracer_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_bracer_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_bracer_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end

modifier_item_bracer_lua_active = modifier_item_bracer_lua_active or class({})
function modifier_item_bracer_lua_active:IsPurgable() return false end
function modifier_item_bracer_lua_active:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_bracer_lua_active:GetEffectName() return "particles/items_fx/healing_flask.vpcf" end
function modifier_item_bracer_lua_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_bracer_lua_active:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.hp_regen = self:GetAbility():GetSpecialValueFor("active_hp_regen")
end
function modifier_item_bracer_lua_active:OnRefresh()
	self:OnCreated()
end
function modifier_item_bracer_lua_active:GetModifierConstantHealthRegen() return self.hp_regen * self:GetStackCount() end