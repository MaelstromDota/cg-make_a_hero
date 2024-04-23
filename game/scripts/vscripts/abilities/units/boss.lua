LinkLuaModifier("modifier_boss_ability", "abilities/units/boss", LUA_MODIFIER_MOTION_NONE)

boss_ability = boss_ability or class(ability_lua_base)
function boss_ability:GetIntrinsicModifierName() return "modifier_boss_ability" end

modifier_boss_ability = modifier_boss_ability or class({})
function modifier_boss_ability:IsHidden() return true end
function modifier_boss_ability:IsPurgable() return false end
function modifier_boss_ability:CheckState() return {[MODIFIER_STATE_CANNOT_MISS] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_UNSLOWABLE] = true} end
function modifier_boss_ability:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_boss_ability:IsAura() return true end
function modifier_boss_ability:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("true_sight_radius") end
function modifier_boss_ability:GetModifierAura() return "modifier_truesight" end
function modifier_boss_ability:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_boss_ability:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_boss_ability:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER end
function modifier_boss_ability:GetAuraDuration() return 0.5 end
function modifier_boss_ability:OnCreated()
	if not IsServer() then return end
	Timers:CreateTimer({endTime=0.1, callback=function()
		self:GetParent().spawnpos = self:GetParent():GetAbsOrigin()
	end}, nil, self)
end
function modifier_boss_ability:OnDeath(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or kv.unit:IsIllusion() then return end
	local npc_info = {name=kv.unit:GetUnitName(), position=kv.unit.spawnpos}
	Timers:CreateTimer({endTime=BOSS_RESPAWN, callback=function()
		CreateUnitByNameAsync(npc_info["name"], npc_info["position"], true, nil, nil, DOTA_TEAM_NEUTRALS, function(unit) end)
	end}, nil, self)
end
function modifier_boss_ability:GetModifierPureResistanceBonus() return self:GetAbility():GetSpecialValueFor("pure_resistance") end