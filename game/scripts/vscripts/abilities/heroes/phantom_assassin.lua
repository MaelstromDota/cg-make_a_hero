LinkLuaModifier("modifier_phantom_assassin_blur_lua", "abilities/heroes/phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phantom_assassin_blur_lua_smoke", "abilities/heroes/phantom_assassin", LUA_MODIFIER_MOTION_NONE)

phantom_assassin_blur_lua = phantom_assassin_blur_lua or class(ability_lua_base)
function phantom_assassin_blur_lua:GetBehavior()
	if self:GetCaster():HasScepter() then
		return tonumber(tostring(self.BaseClass.GetBehavior(self))) + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return self.BaseClass.GetBehavior(self)
end
function phantom_assassin_blur_lua:GetIntrinsicModifierName() return "modifier_phantom_assassin_blur_lua" end
function phantom_assassin_blur_lua:OnSpellStart()
    ProjectileManager:ProjectileDodge(self:GetCaster())
    self:GetCaster():EmitSound("Hero_PhantomAssassin.Blur")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_phantom_assassin_blur_lua_smoke", {duration=self:GetSpecialValueFor("duration")})
	if self:GetCaster():HasScepter() then
		self:GetCaster():Dispell(self:GetCaster(), false)
	end
end

modifier_phantom_assassin_blur_lua = modifier_phantom_assassin_blur_lua or class({})
function modifier_phantom_assassin_blur_lua:IsHidden() return true end
function modifier_phantom_assassin_blur_lua:IsPurgable() return false end
function modifier_phantom_assassin_blur_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_EVASION_CONSTANT} end
function modifier_phantom_assassin_blur_lua:OnDeath(kv)
	if not IsServer() then return end
    if kv.attacker ~= self:GetParent() or not kv.target:IsRealHero() or not kv.attacker:HasScepter() then return end
	for i=0, DOTA_MAX_ABILITIES-1 do
		local ability = self:GetCaster():GetAbilityByIndex(i)
		if ability and not table.contains({ABILITY_TYPE_ATTRIBUTES, ABILITY_TYPE_ULTIMATE}, ability:GetAbilityType()) and ability:IsRefreshable() then
			ability:RefreshCharges()
			ability:EndCooldown()
		end
	end
end
function modifier_phantom_assassin_blur_lua:GetModifierEvasion_Constant() if not self:GetCaster():PassivesDisabled() then return self:GetAbility():GetSpecialValueFor("bonus_evasion") end return end

modifier_phantom_assassin_blur_lua_smoke = modifier_phantom_assassin_blur_lua_smoke or class({})
function modifier_phantom_assassin_blur_lua_smoke:IsPurgable() return false end
function modifier_phantom_assassin_blur_lua_smoke:GetEffectName() return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_active_blur.vpcf" end
function modifier_phantom_assassin_blur_lua_smoke:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_phantom_assassin_blur_lua_smoke:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true} end
function modifier_phantom_assassin_blur_lua_smoke:GetPriority() return MODIFIER_PRIORITY_ULTRA end
function modifier_phantom_assassin_blur_lua_smoke:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_phantom_assassin_blur_lua_smoke:OnCreated()
	if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.fade_duration = self:GetAbility():GetSpecialValueFor("fade_duration")
    self:StartIntervalThink(FrameTime())
end
function modifier_phantom_assassin_blur_lua_smoke:OnRefresh()
	self:OnCreated()
end
function modifier_phantom_assassin_blur_lua_smoke:OnIntervalThink()
	if not IsServer() then return end
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        self:StartIntervalThink(-1)
        self:SetDuration(math.min(self.fade_duration, self:GetRemainingTime()), false)
    end
end
function modifier_phantom_assassin_blur_lua_smoke:OnDestroy()
	if not IsServer() then return end
    self:GetParent():EmitSound("Hero_PhantomAssassin.Blur.Break")
end
function modifier_phantom_assassin_blur_lua_smoke:OnAttackLanded(kv)
	if not IsServer() then return end
    if kv.attacker ~= self:GetParent() then return end
	if kv.target:IsRoshan() or not kv.target:IsHero() then
    	self:SetDuration(math.min(self.fade_duration, self:GetRemainingTime()), true)
	end
end
function modifier_phantom_assassin_blur_lua_smoke:GetModifierInvisibilityLevel() return 1 end
