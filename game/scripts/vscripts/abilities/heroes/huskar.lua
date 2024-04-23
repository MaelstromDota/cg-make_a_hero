LinkLuaModifier("modifier_huskar_berserkers_blood_lua", "abilities/heroes/huskar", LUA_MODIFIER_MOTION_NONE)

huskar_berserkers_blood_lua = huskar_berserkers_blood_lua or class({})
function huskar_berserkers_blood_lua:GetIntrinsicModifierName() return "modifier_huskar_berserkers_blood_lua" end

modifier_huskar_berserkers_blood_lua = modifier_huskar_berserkers_blood_lua or class({})
function modifier_huskar_berserkers_blood_lua:IsHidden() return true end
function modifier_huskar_berserkers_blood_lua:IsPurgable() return false end
function modifier_huskar_berserkers_blood_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_huskar_berserkers_blood_lua:OnCreated()
	self.hp_threshold_max = self:GetAbility():GetSpecialValueFor("hp_threshold_max")
	self.range = 100 - self.hp_threshold_max
	self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(self.fx, false, false, -1, false, false)
end
function modifier_huskar_berserkers_blood_lua:OnRefresh()
	self.hp_threshold_max = self:GetAbility():GetSpecialValueFor("hp_threshold_max")
	self.range = 100 - self.hp_threshold_max
end
function modifier_huskar_berserkers_blood_lua:GetModifierMagicalResistanceBonus() if not self:GetParent():IsIllusion() and not self:GetParent():PassivesDisabled() then return (1-math.max((self:GetParent():GetHealthPercent()-self.hp_threshold_max)/self.range, 0))*self:GetAbility():GetSpecialValueFor("maximum_resistance") end end
function modifier_huskar_berserkers_blood_lua:GetModifierAttackSpeedBonus_Constant() if not self:GetParent():PassivesDisabled() then return (1-math.max((self:GetParent():GetHealthPercent()-self.hp_threshold_max)/self.range, 0))*self:GetAbility():GetSpecialValueFor("maximum_attack_speed") end end
function modifier_huskar_berserkers_blood_lua:GetModifierConstantHealthRegen() if not self:GetParent():PassivesDisabled() then return (1-math.max((self:GetParent():GetHealthPercent()-self.hp_threshold_max)/self.range, 0))*self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("maximum_health_regen") * 0.01 end end
function modifier_huskar_berserkers_blood_lua:GetModifierModelScale()
	local pct = not self:GetParent():PassivesDisabled() and math.max((self:GetParent():GetHealthPercent()-self.hp_threshold_max)/self.range, 0) or 1
	if IsServer() then ParticleManager:SetParticleControl(self.fx, 1, Vector((1-pct)*100, 0, 0)) end
	return (1-pct)*35
end
function modifier_huskar_berserkers_blood_lua:GetActivityTranslationModifiers() return "berserkers_blood" end