sange_yasha_kaya = sange_yasha_kaya or class(ability_lua_base)
function sange_yasha_kaya:Disarm(target)
	target:Disarm(self:GetCaster(), self, self:GetSpecialValueFor("disarm_duration"), {fx="particles/items2_fx/heavens_halberd.vpcf", pattach=PATTACH_ABSORIGIN_FOLLOW})
	target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
end
function sange_yasha_kaya:CreateIllusions()
	self:GetCaster():Dispell(self:GetCaster(), false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_yasha_2_cast_lua", {duration=self:GetSpecialValueFor("invuln_duration")})
	self:GetCaster():EmitSound("DOTA_Item.Manta.Activate")
end
function sange_yasha_kaya:EtherealBlade(target)
	ProjectileManager:CreateTrackingProjectile({
		Target=target,
		Source=self:GetCaster(),
		Ability=self,
		EffectName="particles/items_fx/ethereal_blade.vpcf",
		iMoveSpeed=self:GetSpecialValueFor("projectile_speed"),
		vSourceLoc=self:GetCaster():GetAbsOrigin(),
		bDrawsOnMinimap=false,
		bDodgeable=true,
		bIsAttack=false,
		bVisibleToEnemies=true,
		bReplaceExisting=false,
		flExpireTime=GameRules:GetGameTime()+20,
		bProvidesVision = false
	})
	self:GetCaster():EmitSound("DOTA_Item.EtherealBlade.Activate")
end
function sange_yasha_kaya:OnProjectileHit(target, location)
	if not target or target:IsMagicImmune() then return end
	if target:TriggerSpellAbsorb(self) then return false end
	target:AddNewModifier(self:GetCaster(), self, "modifier_item_kaya_2_debuff_lua", {duration=self:GetSpecialValueFor("duration")})
	target:EmitSound("DOTA_Item.EtherealBlade.Target")
	if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
	ApplyDamage({victim=target, attacker=self:GetCaster(), damage=(self:GetCaster():IsHero() and self:GetCaster():GetPrimaryStatValue() or 0)*self:GetSpecialValueFor("blast_agility_multiplier")+self:GetSpecialValueFor("blast_damage_base"), damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
end

LinkLuaModifier("modifier_item_sange_2_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sange_2_bonus_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)

item_sange_2_lua = item_sange_2_lua or class(sange_yasha_kaya)
function item_sange_2_lua:GetIntrinsicModifiers() return {"modifier_item_sange_2_lua", "modifier_item_sange_2_bonus_lua"} end
function item_sange_2_lua:OnSpellStart()
	if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end
	self:Disarm(self:GetCursorTarget())
end

modifier_item_sange_2_lua = modifier_item_sange_2_lua or class({})
function modifier_item_sange_2_lua:IsHidden() return true end
function modifier_item_sange_2_lua:IsPurgable() return false end
function modifier_item_sange_2_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_sange_2_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_sange_2_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_sange_2_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_sange_2_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_sange_2_lua:GetModifierEvasion_Constant() return self:GetAbility():GetSpecialValueFor("bonus_evasion") end
function modifier_item_sange_2_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_sange_2_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end

modifier_item_sange_2_bonus_lua = modifier_item_sange_2_bonus_lua or class({})
function modifier_item_sange_2_bonus_lua:IsHidden() return true end
function modifier_item_sange_2_bonus_lua:IsPurgable() return false end
function modifier_item_sange_2_bonus_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE} end
function modifier_item_sange_2_bonus_lua:GetModifierStatusResistanceStacking() return self:GetAbility():GetSpecialValueFor("status_resistance") end
function modifier_item_sange_2_bonus_lua:GetModifierHPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end
function modifier_item_sange_2_bonus_lua:GetModifierLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end

LinkLuaModifier("modifier_item_yasha_2_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_yasha_2_cast_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)

item_yasha_2_lua = item_yasha_2_lua or class(sange_yasha_kaya)
function item_yasha_2_lua:GetIntrinsicModifierName() return "modifier_item_yasha_2_lua" end
function item_yasha_2_lua:OnSpellStart()
	self:CreateIllusions()
end

modifier_item_yasha_2_lua = modifier_item_yasha_2_lua or class({})
function modifier_item_yasha_2_lua:IsHidden() return true end
function modifier_item_yasha_2_lua:IsPurgable() return false end
function modifier_item_yasha_2_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_yasha_2_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_yasha_2_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_yasha_2_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_yasha_2_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_yasha_2_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_yasha_2_lua:GetModifierMoveSpeedBonus_Percentage_Unique() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_yasha_2_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

modifier_item_yasha_2_cast_lua = modifier_item_yasha_2_cast_lua or class({})
function modifier_item_yasha_2_cast_lua:IsHidden() return true end
function modifier_item_yasha_2_cast_lua:IsPurgable() return false end
function modifier_item_yasha_2_cast_lua:GetEffectName() return "particles/items2_fx/manta_phase.vpcf" end
function modifier_item_yasha_2_cast_lua:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_item_yasha_2_cast_lua:OnDestroy()
	if not IsServer() or not self:GetParent():IsAlive() or not self:GetAbility() then return end
	self:GetParent():Stop()
	AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("vision_radius"), 0.1, true)
	for _, mod in pairs(self:GetParent():FindAllModifiersByName(self:GetAbility():GetIntrinsicModifierName())) do
		if mod:GetAbility() and mod:GetAbility().manta_illusions then
			for _, illusion in pairs(mod:GetAbility().manta_illusions) do
				if illusion and not illusion:IsNull() then
					illusion:ForceKill(false)
				end
			end
		end
	end
	self:GetAbility().manta_illusions = CreateIllusions(self:GetParent(), self:GetParent():GetOwner():GetAssignedHero(), {
		outgoing_damage=self:GetAbility():GetSpecialValueFor("damage_outgoing_"..(not self:GetParent():IsRangedAttacker() and "melee" or "ranged"))-100,
		incoming_damage=self:GetAbility():GetSpecialValueFor("damage_incoming_total_pct")-100,
		bounty_base=self:GetParent():GetLevel()*2, bounty_growth=0,
		outgoing_damage_structure=nil, outgoing_damage_roshan=nil,
		duration=self:GetAbility():GetSpecialValueFor("illusion_duration")
	}, self:GetAbility():GetSpecialValueFor("images_count"), self:GetParent():GetHullRadius() <= 8 and 72 or 108, true, true)
end

LinkLuaModifier("modifier_item_kaya_2_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_kaya_2_bonus_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_kaya_2_debuff_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)

item_kaya_2_lua = item_kaya_2_lua or class(sange_yasha_kaya)
function item_kaya_2_lua:GetIntrinsicModifiers() return {"modifier_item_kaya_2_lua", "modifier_item_kaya_2_bonus_lua"} end
function item_kaya_2_lua:OnSpellStart()
	self:EtherealBlade(self:GetCursorTarget())
end

modifier_item_kaya_2_lua = modifier_item_kaya_2_lua or class({})
function modifier_item_kaya_2_lua:IsHidden() return true end
function modifier_item_kaya_2_lua:IsPurgable() return false end
function modifier_item_kaya_2_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_kaya_2_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_item_kaya_2_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_kaya_2_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_kaya_2_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_kaya_2_lua:GetModifierSpellLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_lifesteal_amp") end
function modifier_item_kaya_2_lua:GetModifierMPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("mana_regen_multiplier") end

modifier_item_kaya_2_bonus_lua = modifier_item_kaya_2_bonus_lua or class({})
function modifier_item_kaya_2_bonus_lua:IsHidden() return true end
function modifier_item_kaya_2_bonus_lua:IsPurgable() return false end
function modifier_item_kaya_2_bonus_lua:DeclareFunctions() return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_item_kaya_2_bonus_lua:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp") end

modifier_item_kaya_2_debuff_lua = class({})
function modifier_item_kaya_2_debuff_lua:IsDebuff() if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then return true end end
function modifier_item_kaya_2_debuff_lua:GetStatusEffectName() return "particles/status_fx/status_effect_ghost.vpcf" end
function modifier_item_kaya_2_debuff_lua:CheckState() return {[MODIFIER_STATE_ATTACK_IMMUNE] = true, [MODIFIER_STATE_DISARMED] = true}end
function modifier_item_kaya_2_debuff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_item_kaya_2_debuff_lua:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.ethereal_damage_bonus = self:GetAbility():GetSpecialValueFor("ethereal_damage_bonus")
	self.blast_movement_slow = self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and self:GetAbility():GetSpecialValueFor("blast_movement_slow") or 0
end
function modifier_item_kaya_2_debuff_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_kaya_2_debuff_lua:GetModifierMagicalResistanceBonus() return self.ethereal_damage_bonus end
function modifier_item_kaya_2_debuff_lua:GetModifierMoveSpeedBonus_Percentage() return self.blast_movement_slow end
function modifier_item_kaya_2_debuff_lua:GetAbsoluteNoDamagePhysical() return 1 end

LinkLuaModifier("modifier_item_sange_and_yasha_2_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)
item_sange_and_yasha_2_lua = item_sange_and_yasha_2_lua or class(sange_yasha_kaya)
function item_sange_and_yasha_2_lua:GetIntrinsicModifiers() return {"modifier_item_sange_and_yasha_2_lua", "modifier_item_sange_2_bonus_lua"} end
function item_sange_and_yasha_2_lua:OnSpellStart()
	if self:GetCursorTarget():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		self:Disarm(self:GetCursorTarget())
	end
	self:CreateIllusions()
end

modifier_item_sange_and_yasha_2_lua = modifier_item_sange_and_yasha_2_lua or class({})
function modifier_item_sange_and_yasha_2_lua:IsHidden() return true end
function modifier_item_sange_and_yasha_2_lua:IsPurgable() return false end
function modifier_item_sange_and_yasha_2_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_sange_and_yasha_2_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_sange_and_yasha_2_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_sange_and_yasha_2_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_sange_and_yasha_2_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_sange_and_yasha_2_lua:GetModifierEvasion_Constant() return self:GetAbility():GetSpecialValueFor("bonus_evasion") end
function modifier_item_sange_and_yasha_2_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_sange_and_yasha_2_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_item_sange_and_yasha_2_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_sange_and_yasha_2_lua:GetModifierMoveSpeedBonus_Percentage_Unique() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_sange_and_yasha_2_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

LinkLuaModifier("modifier_item_kaya_and_sange_2_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)
item_kaya_and_sange_2_lua = item_kaya_and_sange_2_lua or class(sange_yasha_kaya)
function item_kaya_and_sange_2_lua:GetIntrinsicModifiers() return {"modifier_item_kaya_and_sange_2_lua", "modifier_item_sange_2_bonus_lua", "modifier_item_kaya_2_bonus_lua"} end
function item_kaya_and_sange_2_lua:OnSpellStart()
	if self:GetCursorTarget():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		self:Disarm(self:GetCursorTarget())
	end
	self:EtherealBlade(self:GetCursorTarget())
end

modifier_item_kaya_and_sange_2_lua = modifier_item_kaya_and_sange_2_lua or class({})
function modifier_item_kaya_and_sange_2_lua:IsHidden() return true end
function modifier_item_kaya_and_sange_2_lua:IsPurgable() return false end
function modifier_item_kaya_and_sange_2_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_kaya_and_sange_2_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_item_kaya_and_sange_2_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_kaya_and_sange_2_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_kaya_and_sange_2_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_kaya_and_sange_2_lua:GetModifierEvasion_Constant() return self:GetAbility():GetSpecialValueFor("bonus_evasion") end
function modifier_item_kaya_and_sange_2_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_kaya_and_sange_2_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_item_kaya_and_sange_2_lua:GetModifierSpellLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_lifesteal_amp") end
function modifier_item_kaya_and_sange_2_lua:GetModifierMPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("mana_regen_multiplier") end

LinkLuaModifier("modifier_item_yasha_and_kaya_2_lua", "items/sange_yasha_kaya", LUA_MODIFIER_MOTION_NONE)
item_yasha_and_kaya_2_lua = item_yasha_and_kaya_2_lua or class(sange_yasha_kaya)
function item_yasha_and_kaya_2_lua:GetIntrinsicModifiers() return {"modifier_item_yasha_and_kaya_2_lua", "modifier_item_kaya_2_bonus_lua"} end
function item_yasha_and_kaya_2_lua:OnSpellStart()
	self:CreateIllusions()
	self:EtherealBlade(self:GetCursorTarget())
end

modifier_item_yasha_and_kaya_2_lua = modifier_item_yasha_and_kaya_2_lua or class({})
function modifier_item_yasha_and_kaya_2_lua:IsHidden() return true end
function modifier_item_yasha_and_kaya_2_lua:IsPurgable() return false end
function modifier_item_yasha_and_kaya_2_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_yasha_and_kaya_2_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_item_yasha_and_kaya_2_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_yasha_and_kaya_2_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_yasha_and_kaya_2_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_yasha_and_kaya_2_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_yasha_and_kaya_2_lua:GetModifierMoveSpeedBonus_Percentage_Unique() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_yasha_and_kaya_2_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_yasha_and_kaya_2_lua:GetModifierSpellLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_lifesteal_amp") end
function modifier_item_yasha_and_kaya_2_lua:GetModifierMPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("mana_regen_multiplier") end