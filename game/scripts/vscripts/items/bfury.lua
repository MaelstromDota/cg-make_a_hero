LinkLuaModifier("modifier_item_bfury_2_lua", "items/bfury", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bfury_2_unique_lua", "items/bfury", LUA_MODIFIER_MOTION_NONE)

item_bfury_2_lua = item_bfury_2_lua or class(ability_lua_base)
function item_bfury_2_lua:GetIntrinsicModifiers() return {"modifier_item_bfury_2_lua", "modifier_item_bfury_2_unique_lua"} end
function item_bfury_2_lua:OnSpellStart()
	-- self:GetCursorTarget():CutDown(self:GetCaster():GetTeamNumber())
	GridNav:DestroyTreesAroundPoint(self:GetCursorTarget():GetAbsOrigin(), self:GetSpecialValueFor("chop_radius"), true)
end

modifier_item_bfury_2_lua = modifier_item_bfury_2_lua or class({})
function modifier_item_bfury_2_lua:IsHidden() return true end
function modifier_item_bfury_2_lua:IsPurgable() return false end
function modifier_item_bfury_2_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_bfury_2_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE} end
function modifier_item_bfury_2_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:IsRangedAttacker() then return end
	DoCleaveAttack(kv.attacker, kv.target, self:GetAbility(), kv.attacker:GetAverageTrueAttackDamage(kv.target) * self:GetAbility():GetSpecialValueFor("cleave_damage_percent") / 100, self:GetAbility():GetSpecialValueFor("cleave_starting_width"), self:GetAbility():GetSpecialValueFor("cleave_ending_width"), self:GetAbility():GetSpecialValueFor("cleave_distance"), "particles/items_fx/battlefury_cleave.vpcf")
end
function modifier_item_bfury_2_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_bfury_2_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_bfury_2_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_bfury_2_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_bfury_2_lua:GetModifierMoveSpeedBonus_Percentage_Unique() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end
function modifier_item_bfury_2_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_item_bfury_2_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

modifier_item_bfury_2_unique_lua = modifier_item_bfury_2_unique_lua or class({})
function modifier_item_bfury_2_unique_lua:IsHidden() return true end
function modifier_item_bfury_2_unique_lua:IsPurgable() return false end
function modifier_item_bfury_2_unique_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE} end
function modifier_item_bfury_2_unique_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or not kv.target:IsCreep() or kv.target:IsHero() or kv.target:IsRoshan() then return end
	return self:GetAbility():GetSpecialValueFor(not kv.attacker:IsRangedAttacker() and "damage_bonus" or "damage_bonus_ranged")
end
function modifier_item_bfury_2_unique_lua:GetModifierStatusResistanceStacking() return self:GetAbility():GetSpecialValueFor("status_resistance") end
function modifier_item_bfury_2_unique_lua:GetModifierHPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end
function modifier_item_bfury_2_unique_lua:GetModifierLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end