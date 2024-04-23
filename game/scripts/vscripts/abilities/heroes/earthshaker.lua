LinkLuaModifier("modifier_earthshaker_enchant_totem_lua", "abilities/heroes/earthshaker", LUA_MODIFIER_MOTION_NONE)

earthshaker_enchant_totem_lua = earthshaker_enchant_totem_lua or class(ability_lua_base)
function earthshaker_enchant_totem_lua:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return self.BaseClass.GetBehavior(self)
end
function earthshaker_enchant_totem_lua:GetAOERadius() return self:GetSpecialValueFor("aftershock_range") end
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
		aftershock:Aftershock(self:GetSpecialValueFor("aftershock_range"))
	end
end

modifier_earthshaker_enchant_totem_lua = modifier_earthshaker_enchant_totem_lua or class({})
function modifier_earthshaker_enchant_totem_lua:IsPurgable() return true end
function modifier_earthshaker_enchant_totem_lua:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
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
end
function modifier_earthshaker_enchant_totem_lua:GetModifierProcAttack_Feedback(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	if not kv.attacker:IsRangedAttacker() and kv.attacker:HasScepter() then
		DoCleaveAttack(kv.attacker, kv.target, self:GetAbility(), kv.attacker:GetAverageTrueAttackDamage(kv.target) * self.scepter_cleave_pct / 100, self.scepter_cleave_starting_width, self.scepter_cleave_ending_width, self.scepter_cleave_distance, "particles/items_fx/battlefury_cleave.vpcf")
	end
	kv.target:EmitSound("Hero_EarthShaker.Totem.Attack")
	self:Destroy()
end
function modifier_earthshaker_enchant_totem_lua:GetModifierBaseDamageOutgoing_Percentage() return self.bonus end
function modifier_earthshaker_enchant_totem_lua:GetModifierAttackRangeBonus() return self.range end

LinkLuaModifier("modifier_earthshaker_aftershock_lua", "abilities/heroes/earthshaker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earthshaker_aftershock_active_lua", "abilities/heroes/earthshaker", LUA_MODIFIER_MOTION_NONE)

earthshaker_aftershock_lua = earthshaker_aftershock_lua or class(ability_lua_base)
function earthshaker_aftershock_lua:GetIntrinsicModifierName() return "modifier_earthshaker_aftershock_lua" end
function earthshaker_aftershock_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_earthshaker_aftershock_active_lua", {duration=self:GetSpecialValueFor("active_duration")})
end
function earthshaker_aftershock_lua:Aftershock(radius)
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius or self:GetSpecialValueFor("aftershock_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		if self:GetCaster():HasModifier("modifier_earthshaker_aftershock_active_lua") then
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=self:GetDuration()})
		end
		ApplyDamage({victim=enemy, attacker=self:GetCaster(), damage=self:GetSpecialValueFor("aftershock_damage"), damage_type=self:GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
	end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(fx, 1, Vector(radius or self:GetSpecialValueFor("aftershock_range"), radius or self:GetSpecialValueFor("aftershock_range"), radius or self:GetSpecialValueFor("aftershock_range")))
	ParticleManager:ReleaseParticleIndex(fx)
end

modifier_earthshaker_aftershock_lua = modifier_earthshaker_aftershock_lua or class({})
function modifier_earthshaker_aftershock_lua:IsHidden() return true end
function modifier_earthshaker_aftershock_lua:IsPurgable() return false end
function modifier_earthshaker_aftershock_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_earthshaker_aftershock_lua:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or kv.ability:IsItem() or table.contains({"earthshaker_enchant_totem_lua", self:GetAbility():GetAbilityName()}, kv.ability:GetAbilityName()) then return end
	self:GetAbility():Aftershock()
end

modifier_earthshaker_aftershock_active_lua = modifier_earthshaker_aftershock_active_lua or class({})
function modifier_earthshaker_aftershock_active_lua:IsPurgable() return false end