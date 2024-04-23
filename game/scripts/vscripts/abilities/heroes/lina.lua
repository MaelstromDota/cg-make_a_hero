LinkLuaModifier("modifier_lina_fiery_soul_lua", "abilities/heroes/lina", LUA_MODIFIER_MOTION_NONE)

lina_fiery_soul_lua = lina_fiery_soul_lua or class(ability_lua_base)
function lina_fiery_soul_lua:GetIntrinsicModifierName() return "modifier_lina_fiery_soul_lua" end

modifier_lina_fiery_soul_lua = modifier_lina_fiery_soul_lua or class({})
function modifier_lina_fiery_soul_lua:IsHidden() return self:GetStackCount() == 0 end
function modifier_lina_fiery_soul_lua:IsPurgable() return false end
function modifier_lina_fiery_soul_lua:RemoveOnDeath() return false end
function modifier_lina_fiery_soul_lua:AllowIllusionDuplicate() return false end
function modifier_lina_fiery_soul_lua:DestroyOnExpire() return false end
function modifier_lina_fiery_soul_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_lina_fiery_soul_lua:OnCreated()
	self:StartIntervalThink(FrameTime())
end
function modifier_lina_fiery_soul_lua:OnIntervalThink()
	if self:GetRemainingTime() <= 0 and self:GetRemainingTime() > -1 then
		self:SetStackCount(0)
		self:SetDuration(-1, true)
	end
end
function modifier_lina_fiery_soul_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL or kv.inflictor == nil or kv.inflictor:IsItem() then return end
	self:SetStackCount(math.min(self:GetStackCount()+1, self:GetAbility():GetSpecialValueFor("fiery_soul_max_stacks")))
	self:SetDuration(self:GetAbility():GetSpecialValueFor("fiery_soul_stack_duration"), true)
end
function modifier_lina_fiery_soul_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("fiery_soul_attack_speed_bonus") * self:GetStackCount() end
function modifier_lina_fiery_soul_lua:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("fiery_soul_move_speed_bonus") * self:GetStackCount() end
function modifier_lina_fiery_soul_lua:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("bonus_spell_damage") * self:GetStackCount() end