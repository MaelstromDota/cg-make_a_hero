LinkLuaModifier("modifier_drow_ranger_marksmanship_lua", "abilities/heroes/drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_marksmanship_lua_aura", "abilities/heroes/drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_marksmanship_lua_proj", "abilities/heroes/drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_marksmanship_lua_reduction", "abilities/heroes/drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_marksmanship_lua_scepter_reduction", "abilities/heroes/drow_ranger", LUA_MODIFIER_MOTION_NONE)

drow_ranger_marksmanship_lua = drow_ranger_marksmanship_lua or class(ability_lua_base)
function drow_ranger_marksmanship_lua:GetIntrinsicModifierName() return "modifier_drow_ranger_marksmanship_lua" end
function drow_ranger_marksmanship_lua:OnProjectileHit(hTarget, vLocation)
	if hTarget == nil then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_drow_ranger_marksmanship_lua_scepter_reduction", {})
	if self:GetCaster():HasModifier("modifier_muerta_gunslinger") then
		ApplyDamage({victim=hTarget, attacker=self:GetCaster(), damage=self:GetCaster():GetAverageTrueAttackDamage(hTarget), damage_type=DAMAGE_TYPE_PHYSICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=nil})
	else
		self:GetCaster():PerformAttack(hTarget, false, false, true, false, false, false, false)
	end
	self:GetCaster():RemoveModifierByName("modifier_drow_ranger_marksmanship_lua_scepter_reduction")
end

modifier_drow_ranger_marksmanship_lua = modifier_drow_ranger_marksmanship_lua or class({})
function modifier_drow_ranger_marksmanship_lua:IsHidden() return true end
function modifier_drow_ranger_marksmanship_lua:IsPurgable() return false end
function modifier_drow_ranger_marksmanship_lua:CheckState() if self:GetStackCount() == 1 then return {[MODIFIER_STATE_CANNOT_MISS] = true} end end
function modifier_drow_ranger_marksmanship_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL} end
function modifier_drow_ranger_marksmanship_lua:IsAura() return not self:GetParent():PassivesDisabled() and not self:GetParent():IsIllusion() and self.active end
function modifier_drow_ranger_marksmanship_lua:GetModifierAura() return "modifier_drow_ranger_marksmanship_lua_aura" end
function modifier_drow_ranger_marksmanship_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("agility_range") end
function modifier_drow_ranger_marksmanship_lua:GetAuraDuration() return 0.5 end
function modifier_drow_ranger_marksmanship_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_drow_ranger_marksmanship_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_drow_ranger_marksmanship_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_RANGED_ONLY + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS end
function modifier_drow_ranger_marksmanship_lua:OnCreated()
	if not IsServer() then return end
	self.active = true
	self.records = {}
	self:SetStackCount(0)
	self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_drow/drow_marksmanship.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.fx, 2, Vector(2, 0, 0))
	self:AddParticle(self.fx, false, false, -1, false, false)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_drow/drow_marksmanship_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(fx)
	self:StartIntervalThink(0.1)
end
function modifier_drow_ranger_marksmanship_lua:OnIntervalThink()
	local no_enemies = #FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("disable_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false) <= 0
	if no_enemies ~= self.active then
		self.active = no_enemies
		ParticleManager:SetParticleControl(self.fx, 2, Vector(no_enemies and 2 or 1, 0, 0))
		if no_enemies then
			local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_drow/drow_marksmanship_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:ReleaseParticleIndex(fx)
		end
	end
end
function modifier_drow_ranger_marksmanship_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:PassivesDisabled() then return end
	if self.records[kv.record] then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end
function modifier_drow_ranger_marksmanship_lua:OnAttackStart(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:IsIllusion() then return end
	kv.attacker:RemoveModifierByName("modifier_drow_ranger_marksmanship_lua_proj")
	self:SetStackCount(0)
	if not self.active then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("chance"), self:GetAbility():entindex(), kv.attacker) then return end
	self:SetStackCount(1)
	kv.attacker:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_drow_ranger_marksmanship_lua_proj", {})
end
function modifier_drow_ranger_marksmanship_lua:OnAttackRecord(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:IsIllusion() then return end
	kv.attacker:RemoveModifierByName("modifier_drow_ranger_marksmanship_lua_proj")
	if self:GetStackCount() > 0 then
		self.records[kv.record] = true
	end
end
function modifier_drow_ranger_marksmanship_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:IsIllusion() or kv.attacker:PassivesDisabled() then return end
	if self.records[kv.record] then
		self.records[kv.record] = kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_drow_ranger_marksmanship_lua_reduction", {duration=0.5})
		kv.target:EmitSound("Hero_DrowRanger.Marksmanship.Target")
	end
	if kv.no_attack_cooldown then return end
	if self:GetAbility():GetSpecialValueFor("split_count") > 0 then
		local enemies = 0
		for _, enemy in pairs(FindUnitsInRadius(kv.attacker:GetTeamNumber(), kv.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("split_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)) do
			if enemy ~= kv.target then
				ProjectileManager:CreateTrackingProjectile({vSourceLoc=kv.target:GetAbsOrigin(), Target=enemy, iMoveSpeed=kv.attacker:GetProjectileSpeed(), bDodgeable=true, bIsAttack=false, bReplaceExisting=false, iSourceAttachment=DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, bDrawsOnMinimap=false, bVisibleToEnemies=true, EffectName=kv.attacker:GetRangedProjectileName(), Ability=self:GetAbility(), bProvidesVision=false})
				enemies = enemies + 1
				if enemies > self:GetAbility():GetSpecialValueFor("split_count") then break end
			end
		end
	end
end
function modifier_drow_ranger_marksmanship_lua:OnAttackRecordDestroy(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:IsIllusion() then return end
	if not self.records[kv.record] then return end
	if type(self.records[kv.record])=="table" and not self.records[kv.record]:IsNull() then self.records[kv.record]:Destroy() end
	self.records[kv.record] = nil
end

modifier_drow_ranger_marksmanship_lua_aura = modifier_drow_ranger_marksmanship_lua_aura or class({})
function modifier_drow_ranger_marksmanship_lua_aura:IsHidden() return self:GetParent()==self:GetCaster() end
function modifier_drow_ranger_marksmanship_lua_aura:IsPurgable() return false end
function modifier_drow_ranger_marksmanship_lua_aura:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_drow_ranger_marksmanship_lua_aura:OnCreated(kv)
	self.agility_multiplier = self:GetAbility():GetSpecialValueFor("agility_multiplier")
	self.agility_multiplier_ally = self:GetAbility():GetSpecialValueFor("agility_multiplier_ally")
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end
function modifier_drow_ranger_marksmanship_lua_aura:OnRefresh()
	self:OnCreated()
end
function modifier_drow_ranger_marksmanship_lua_aura:OnIntervalThink()
	self:GetParent():CalculateStatBonus(true)
end
function modifier_drow_ranger_marksmanship_lua_aura:GetModifierBonusStats_Agility()
	if self.lock1 then return end
	if self:GetParent() ~= self:GetCaster() then
		return (self:GetCaster():GetAgility()*self.agility_multiplier/100)*self.agility_multiplier_ally/100
	end
	self.lock1 = true
	local agility = self:GetCaster():GetAgility()
	self.lock1 = false
	return agility*self.agility_multiplier/100
end

modifier_drow_ranger_marksmanship_lua_proj = modifier_drow_ranger_marksmanship_lua_proj or class({})
function modifier_drow_ranger_marksmanship_lua_proj:IsHidden() return true end
function modifier_drow_ranger_marksmanship_lua_proj:IsPurgable() return false end
function modifier_drow_ranger_marksmanship_lua_proj:DeclareFunctions() return {MODIFIER_PROPERTY_PROJECTILE_NAME} end
function modifier_drow_ranger_marksmanship_lua_proj:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
function modifier_drow_ranger_marksmanship_lua_proj:OnCreated()
	if not IsServer() then return end
	local frost_arrows = self:GetParent():FindAbilityByName("drow_ranger_frost_arrows")
	self.projectile = (frost_arrows ~= nil and frost_arrows:GetAutoCastState()) and "particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf" or "particles/units/heroes/hero_drow/drow_marksmanship_attack.vpcf"
end
function modifier_drow_ranger_marksmanship_lua_proj:GetModifierProjectileName() return self.projectile end

modifier_drow_ranger_marksmanship_lua_reduction = modifier_drow_ranger_marksmanship_lua_reduction or class({})
function modifier_drow_ranger_marksmanship_lua_reduction:IsHidden() return true end
function modifier_drow_ranger_marksmanship_lua_reduction:IsPurgable() return false end
function modifier_drow_ranger_marksmanship_lua_reduction:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BASE_PERCENTAGE} end
function modifier_drow_ranger_marksmanship_lua_reduction:GetModifierPhysicalArmorBase_Percentage() return 0 end

modifier_drow_ranger_marksmanship_lua_scepter_reduction = modifier_drow_ranger_marksmanship_lua_scepter_reduction or class({})
function modifier_drow_ranger_marksmanship_lua_scepter_reduction:IsHidden() return true end
function modifier_drow_ranger_marksmanship_lua_scepter_reduction:IsPurgable() return false end
function modifier_drow_ranger_marksmanship_lua_scepter_reduction:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_drow_ranger_marksmanship_lua_scepter_reduction:OnCreated()
	self.reduction = -self:GetAbility():GetSpecialValueFor("damage_reduction_scepter")
end
function modifier_drow_ranger_marksmanship_lua_scepter_reduction:GetModifierBaseDamageOutgoing_Percentage() return self.reduction end