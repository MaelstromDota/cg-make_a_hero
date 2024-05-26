LinkLuaModifier("modifier_earthshaker_enchant_totem_lua", "abilities/heroes/earthshaker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earthshaker_enchant_totem_slugger_lua", "abilities/heroes/earthshaker", LUA_MODIFIER_MOTION_NONE)

earthshaker_enchant_totem_lua = earthshaker_enchant_totem_lua or class(ability_lua_base)
function earthshaker_enchant_totem_lua:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return self.BaseClass.GetBehavior(self)
end
function earthshaker_enchant_totem_lua:GetAOERadius()
	local aftershock = self:GetCaster():FindAbilityByName("earthshaker_aftershock_lua")
	if aftershock then
		return aftershock:GetSpecialValueFor("aftershock_range")
	end
end
function earthshaker_enchant_totem_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("distance_scepter")
	end
	return self.BaseClass.GetCastRange(self, vLocation, hTarget) - self:GetCaster():GetCastRangeBonus()
end
function earthshaker_enchant_totem_lua:CastFilterResultLocation(vLocation)
	if self:GetCaster():IsRooted() then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
function earthshaker_enchant_totem_lua:GetCustomCastErrorLocation(vLocation)
	return "#dota_hud_error_ability_disabled_by_root"
end
function earthshaker_enchant_totem_lua:OnAbilityPhaseStart()
	if self:GetCaster():HasScepter() and self:GetCaster() ~= self:GetCursorTarget() then
		self:SetOverrideCastPoint(0)
	end
	return true
end
function earthshaker_enchant_totem_lua:OnSpellStart()
	self:SetOverrideCastPoint(self:GetKVValueFor({"AbilityCastPoint"}))
	if self:GetCaster():HasScepter() and self:GetCaster() ~= self:GetCursorTarget() then
		local direction = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized()
		direction.z = 0
		self:GetCaster():SetForwardVector(direction)
		local z_delta = math.abs(self:GetCaster():GetAbsOrigin().z - self:GetCursorPosition().z)
		local arc = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_generic_arc_lua", {target_x = self:GetCursorPosition().x, target_y = self:GetCursorPosition().y, distance = CalculateDistance(self:GetCursorPosition(), self:GetCaster():GetAbsOrigin()), duration = self:GetSpecialValueFor("scepter_leap_duration") + self:GetCastPoint()/2, height = math.max(z_delta, math.max(0, self:GetSpecialValueFor("scepter_height")/2-z_delta))+self:GetSpecialValueFor("scepter_height_arcbuffer"), fix_end = false, isForward = true, isStun = true, activity = ACT_DOTA_OVERRIDE_ABILITY_2})
		arc:SetEndCallback(function(interrupted)
			if interrupted then return end
			self:Enchant()
		end)
		return
	end
	self:Enchant()
end
function earthshaker_enchant_totem_lua:Enchant()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_earthshaker_enchant_totem_lua", {duration=self:GetDuration()})
	self:GetCaster():EmitSound("Hero_EarthShaker.Totem")
	local aftershock = self:GetCaster():FindAbilityByName("earthshaker_aftershock_lua")
	if aftershock and aftershock:IsTrained() then
		aftershock:Aftershock()
	end
end
function earthshaker_enchant_totem_lua:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
	if not hTarget then return end
	local ignore_units_entindexes = table.map(string.split(extraData["ignore_units"], ","), function(entindex) return tonumber(entindex) end)
	if table.contains(ignore_units_entindexes, hTarget:entindex()) then return end
	ApplyDamage({victim=hTarget, attacker=self:GetCaster(), damage=extraData["damage"], damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
end
function earthshaker_enchant_totem_lua:OnProjectileThink_ExtraData(vLocation, extraData)
	local body = EntIndexToHScript(extraData["body"])
	if IsValidEntity(body) then
		body:SetAbsOrigin(GetGroundPosition(vLocation, body))
	end
end

modifier_earthshaker_enchant_totem_lua = modifier_earthshaker_enchant_totem_lua or class({})
function modifier_earthshaker_enchant_totem_lua:IsPurgable() return true end
function modifier_earthshaker_enchant_totem_lua:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_earthshaker_enchant_totem_lua:OnCreated()
	self:OnRefresh()
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_totem_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, self:GetParent():ScriptLookupAttachment("attach_totem")~=0 and "attach_totem" or "attach_attack1", Vector(0,0,0), true)
	self:AddParticle(fx, false, false, -1, false, false)
end
function modifier_earthshaker_enchant_totem_lua:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor("totem_damage_percentage")
	self.range = self:GetAbility():GetSpecialValueFor("bonus_attack_range")
	self.scepter_cleave_pct = self:GetAbility():GetSpecialValueFor("scepter_cleave_pct")
	self.scepter_cleave_starting_width = self:GetAbility():GetSpecialValueFor("scepter_cleave_starting_width")
	self.scepter_cleave_ending_width = self:GetAbility():GetSpecialValueFor("scepter_cleave_ending_width")
	self.scepter_cleave_distance = self:GetAbility():GetSpecialValueFor("scepter_cleave_distance")
	self.projectile_body_on_kill = self:GetAbility():GetSpecialValueFor("projectile_body_on_kill")
end
function modifier_earthshaker_enchant_totem_lua:GetModifierProcAttack_Feedback(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	if self.projectile_body_on_kill == 1 then
		kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_earthshaker_enchant_totem_slugger_lua", {duration=0.1})
	end
	if not kv.attacker:IsRangedAttacker() and kv.attacker:HasScepter() then
		DoCleaveAttack(kv.attacker, kv.target, self:GetAbility(), kv.attacker:GetAverageTrueAttackDamage(kv.target) * self.scepter_cleave_pct / 100, self.scepter_cleave_starting_width, self.scepter_cleave_ending_width, self.scepter_cleave_distance, "particles/items_fx/battlefury_cleave.vpcf")
	end
	kv.target:EmitSound("Hero_EarthShaker.Totem.Attack")
	self:Destroy()
end
function modifier_earthshaker_enchant_totem_lua:GetModifierBaseDamageOutgoing_Percentage() return self.bonus end
function modifier_earthshaker_enchant_totem_lua:GetModifierAttackRangeBonus() return self.range end
function modifier_earthshaker_enchant_totem_lua:GetActivityTranslationModifiers() return "enchant_totem" end

modifier_earthshaker_enchant_totem_slugger_lua = modifier_earthshaker_enchant_totem_slugger_lua or class({})
function modifier_earthshaker_enchant_totem_slugger_lua:IsHidden() return true end
function modifier_earthshaker_enchant_totem_slugger_lua:IsPurgable() return false end
function modifier_earthshaker_enchant_totem_slugger_lua:RemoveOnDeath() return false end
function modifier_earthshaker_enchant_totem_slugger_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_earthshaker_enchant_totem_slugger_lua:OnCreated()
	self.projectile_body_initial_impact_radius = self:GetAbility():GetSpecialValueFor("projectile_body_initial_impact_radius")
	self.projectile_body_speed = self:GetAbility():GetSpecialValueFor("projectile_body_speed")
	self.projectile_body_distance = self:GetAbility():GetSpecialValueFor("projectile_body_distance")
	self.projectile_body_width = self:GetParent():IsHero() and self:GetAbility():GetSpecialValueFor("projectile_body_width_hero") or self:GetAbility():GetSpecialValueFor("projectile_body_width_creep")
	self.projectile_body_vision = self:GetAbility():GetSpecialValueFor("projectile_body_vision")
	self.projectile_body_damage = self:GetParent():IsHero() and self:GetAbility():GetSpecialValueFor("projectile_body_damage_hero") or self:GetAbility():GetSpecialValueFor("projectile_body_damage_creep")
	self.projectile_body_damage_additional_percent_health = self:GetAbility():GetSpecialValueFor("projectile_body_damage_additional_percent_health")
end
function modifier_earthshaker_enchant_totem_slugger_lua:OnRefresh()
	self:OnCreated()
end
function modifier_earthshaker_enchant_totem_slugger_lua:OnDeath(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() and kv.attacker == self:GetCaster() then return end
	self.active = true
	self:SetDuration(self.projectile_body_distance/self.projectile_body_speed, true)
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), kv.unit:GetAbsOrigin(), nil, self.projectile_body_initial_impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local extraData = {damage=self.projectile_body_damage+(kv.unit:GetMaxHealth()*self.projectile_body_damage_additional_percent_health/100), ignore_units="", body=kv.unit:entindex()}
	for _, unit in pairs(units) do
		self:GetAbility():OnProjectileHit_ExtraData(unit, unit:GetAbsOrigin(), extraData)
	end
	local direction = kv.unit:GetAbsOrigin()-kv.attacker:GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()
	extraData["ignore_units"] = table.join(table.map(units, function(_, unit) return unit:entindex() end), ",")
	print(self.projectile_body_speed, self.projectile_body_distance)
	ProjectileManager:CreateLinearProjectile({
		vSpawnOrigin=kv.unit:GetAbsOrigin(),
		vVelocity=direction*self.projectile_body_speed,
		fMaxSpeed=self.projectile_body_speed,
		fDistance=self.projectile_body_distance,
		fStartRadius=self.projectile_body_width,
		fEndRadius=self.projectile_body_width,
		fExpireTime=GameRules:GetGameTime()+self.projectile_body_distance/self.projectile_body_speed,
		iUnitTargetTeam=DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags=DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType=DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		bIgnoreSource=true,
		bDrawsOnMinimap=false,
		bVisibleToEnemies=true,
		EffectName="particles/units/heroes/hero_earthshaker/earthshaker_slugger.vpcf",
		Ability=self:GetAbility(),
		Source=self:GetCaster(),
		bProvidesVision=true,
		iVisionRadius=self.projectile_body_vision,
		iVisionTeamNumber=self:GetCaster():GetTeamNumber(),
		ExtraData=extraData,
	})
end

LinkLuaModifier("modifier_earthshaker_aftershock_lua", "abilities/heroes/earthshaker", LUA_MODIFIER_MOTION_NONE)

earthshaker_aftershock_lua = earthshaker_aftershock_lua or class(ability_lua_base)
function earthshaker_aftershock_lua:GetIntrinsicModifierName() return "modifier_earthshaker_aftershock_lua" end
function earthshaker_aftershock_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_earthshaker_aftershock_active_lua", {duration=self:GetSpecialValueFor("active_duration")})
end
function earthshaker_aftershock_lua:Aftershock(radius, ignore_facet)
	radius = (radius or self:GetSpecialValueFor("aftershock_range")) + (not ignore_facet and self:GetSpecialValueFor("aftershock_range_increase_per_level_interval")*math.floor(self:GetCaster():GetLevel()/self:GetSpecialValueFor("aftershock_range_level_interval")) or 0)
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=self:GetDuration()})
		ApplyDamage({victim=enemy, attacker=self:GetCaster(), damage=self:GetSpecialValueFor("aftershock_damage"), damage_type=self:GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
	end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(fx, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(fx)
end

modifier_earthshaker_aftershock_lua = modifier_earthshaker_aftershock_lua or class({})
function modifier_earthshaker_aftershock_lua:IsHidden() return true end
function modifier_earthshaker_aftershock_lua:IsPurgable() return false end
function modifier_earthshaker_aftershock_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_earthshaker_aftershock_lua:OnCreated()
	self.required_ability_cooldown = self:GetAbility():GetSpecialValueFor("required_ability_cooldown")
end
function modifier_earthshaker_aftershock_lua:OnRefresh()
	self:OnCreated()
end
function modifier_earthshaker_aftershock_lua:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or kv.ability:IsItem() or kv.ability:GetCooldown(kv.ability:GetMaxLevel()) < self.required_ability_cooldown or table.contains({"earthshaker_enchant_totem_lua", self:GetAbility():GetAbilityName()}, kv.ability:GetAbilityName()) then return end
	self:GetAbility():Aftershock()
end