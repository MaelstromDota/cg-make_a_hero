LinkLuaModifier("modifier_item_aether_eye_lua", "items/aether_eye", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_aether_eye_unique_lua", "items/aether_eye", LUA_MODIFIER_MOTION_NONE)

item_aether_eye_lua = item_aether_eye_lua or class(ability_lua_base)
function item_aether_eye_lua:GetIntrinsicModifiers() return {"modifier_item_aether_eye_lua", "modifier_item_aether_eye_unique_lua"} end

modifier_item_aether_eye_lua = modifier_item_aether_eye_lua or class({})
function modifier_item_aether_eye_lua:IsHidden() return true end
function modifier_item_aether_eye_lua:IsPurgable() return false end
function modifier_item_aether_eye_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_aether_eye_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_aether_eye_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_aether_eye_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end

modifier_item_aether_eye_unique_lua = modifier_item_aether_eye_unique_lua or class({})
function modifier_item_aether_eye_unique_lua:IsHidden() return true end
function modifier_item_aether_eye_unique_lua:IsPurgable() return false end
function modifier_item_aether_eye_unique_lua:DeclareFunctions() return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING} end
function modifier_item_aether_eye_unique_lua:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_aether_eye_unique_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_aether_eye_unique_lua:OnIntervalThink()
	self.visible_enemies = table.length(table.filter(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false), function(_, unit) return unit:IsTrueHero() end))
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_item_aether_eye_unique_lua:AddCustomTransmitterData() return {visible_enemies = self.visible_enemies} end
function modifier_item_aether_eye_unique_lua:HandleCustomTransmitterData(kv)
	self.visible_enemies = kv.visible_enemies
end
function modifier_item_aether_eye_unique_lua:GetModifierCastRangeBonusStacking() return self:GetAbility():GetSpecialValueFor("cast_range_bonus") + self:GetAbility():GetSpecialValueFor("cast_range_bonus_per_enemy") * (self.visible_enemies or 0) end