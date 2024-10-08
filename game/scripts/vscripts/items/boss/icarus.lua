LinkLuaModifier("modifier_item_icarus_lua", "items/boss/icarus", LUA_MODIFIER_MOTION_NONE)

item_icarus_lua = item_icarus_lua or class(ability_lua_base)
function item_icarus_lua:GetIntrinsicModifierName() return "modifier_item_icarus_lua" end

modifier_item_icarus_lua = modifier_item_icarus_lua or class({})
function modifier_item_icarus_lua:IsHidden() return true end
function modifier_item_icarus_lua:IsPurgable()	return false end
function modifier_item_icarus_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_icarus_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE} end
function modifier_item_icarus_lua:GetModifierPreAttack_CriticalStrike(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility():entindex(), kv.attacker) then return end
	return self:GetAbility():GetSpecialValueFor("crit_multiplier")
end
function modifier_item_icarus_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end