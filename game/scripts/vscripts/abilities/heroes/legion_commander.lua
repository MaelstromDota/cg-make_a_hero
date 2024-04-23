LinkLuaModifier("modifier_legion_commander_moment_of_courage_lua", "abilities/heroes/legion_commander", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_legion_commander_moment_of_courage_lifesteal_lua", "abilities/heroes/legion_commander", LUA_MODIFIER_MOTION_NONE)

legion_commander_moment_of_courage_lua = legion_commander_moment_of_courage_lua or class(ability_lua_base)
function legion_commander_moment_of_courage_lua:GetIntrinsicModifierName() return "modifier_legion_commander_moment_of_courage_lua" end

modifier_legion_commander_moment_of_courage_lua = modifier_legion_commander_moment_of_courage_lua or class({})
function modifier_legion_commander_moment_of_courage_lua:IsHidden() return true end
function modifier_legion_commander_moment_of_courage_lua:IsPurgable() return false end
function modifier_legion_commander_moment_of_courage_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_START} end
function modifier_legion_commander_moment_of_courage_lua:OnAttackStart(kv)
	if not IsServer() then return end
	if kv.target ~= self:GetParent() or kv.target:PassivesDisabled() or not self:GetAbility():IsCooldownReady() then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("trigger_chance"), self:GetAbility():entindex(), kv.target) then return end
	kv.target:AddNewModifier(kv.target, self:GetAbility(), "modifier_legion_commander_moment_of_courage_lifesteal_lua", {duration=self:GetAbility():GetSpecialValueFor("buff_duration")})
	self:GetAbility():StartCooldown(self:GetAbility():GetEffectiveCooldown(self:GetAbility():GetLevel()))
end

modifier_legion_commander_moment_of_courage_lifesteal_lua = modifier_legion_commander_moment_of_courage_lifesteal_lua or class({})
function modifier_legion_commander_moment_of_courage_lifesteal_lua:IsPurgable() return false end
function modifier_legion_commander_moment_of_courage_lifesteal_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_legion_commander_moment_of_courage_lifesteal_lua:OnCreated()
	self.lifesteal = self:GetAbility():GetSpecialValueFor("hp_leech_percent")
	if not IsServer() then return end
	self:GetParent():AttackNoEarlierThan(0, 0)
end
function modifier_legion_commander_moment_of_courage_lifesteal_lua:OnRefresh()
	self:OnCreated()
end
function modifier_legion_commander_moment_of_courage_lifesteal_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	if UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then
		kv.attacker:Lifesteal(self.lifesteal, kv.damage, self:GetAbility(), false, false)
	end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(fx)
	local fx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.target)
	ParticleManager:ReleaseParticleIndex(fx2)
	kv.attacker:EmitSound("Hero_LegionCommander.Courage")
	self:Destroy()
end
function modifier_legion_commander_moment_of_courage_lifesteal_lua:GetModifierAttackSpeedBonus_Constant() return 1000 end