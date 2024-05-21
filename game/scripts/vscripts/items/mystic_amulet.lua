LinkLuaModifier("modifier_item_mystic_amulet_lua", "items/mystic_amulet", LUA_MODIFIER_MOTION_NONE)

item_mystic_amulet_lua = item_mystic_amulet_lua or class(ability_lua_base)
function item_mystic_amulet_lua:Spawn()
	self.charges = self:GetCurrentCharges()
end
function item_mystic_amulet_lua:GetIntrinsicModifierName() return "modifier_item_mystic_amulet_lua" end
function item_mystic_amulet_lua:OnRuneActivated(rune)
	self:SetCurrentCharges(math.min(self:GetCurrentCharges() + 1, self:GetSpecialValueFor("max_charges")))
end
function item_mystic_amulet_lua:OnLotusPickup(lotus_pool)
	self:SetCurrentCharges(math.min(self:GetCurrentCharges() + 2, self:GetSpecialValueFor("max_charges")))
end
function item_mystic_amulet_lua:OnWatcherCaptured(watcher, captured)
	if not captured then return end
	if watcher:GetUnitName() == "npc_dota_lantern_flying_large" then return end
	self:SetCurrentCharges(math.min(self:GetCurrentCharges() + 1, self:GetSpecialValueFor("max_charges")))
end
function item_mystic_amulet_lua:OnDeath()
	self:SetCurrentCharges(math.max(math.floor(self:GetCurrentCharges()/2), 0))
end
function item_mystic_amulet_lua:OnChargeCountChanged()
	self.charges = self:GetCurrentCharges()
end
function item_mystic_amulet_lua:OnSpellStart()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetEffectiveCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damage = self:GetSpecialValueFor("active_damage") + (math.min(self:GetSpecialValueFor("active_damage_pct") * self:GetCurrentCharges(), self:GetSpecialValueFor("max_active_damage_pct"))*enemy:GetMaxHealth()/100)
		ApplyDamage({attacker=self:GetCaster(), victim=enemy, damage=damage, damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
		local fx = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_RENDERORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(fx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), false)
		ParticleManager:SetParticleControl(fx, 2, Vector(800, 0, 0))
		ParticleManager:ReleaseParticleIndex(fx)
	end
	if #enemies > 0 then
		self:GetCaster():EmitSound("DOTA_Item.Dagon.Activate")
	end
end

modifier_item_mystic_amulet_lua = modifier_item_mystic_amulet_lua or class({})
function modifier_item_mystic_amulet_lua:IsHidden() return true end
function modifier_item_mystic_amulet_lua:IsPurgable() return false end
function modifier_item_mystic_amulet_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_item_mystic_amulet_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") + (self:GetAbility():GetSpecialValueFor("bonus_intellect_per_charge") * self:GetAbility():GetCurrentCharges()) end

LinkLuaModifier("modifier_item_alaron_amulet_lua", "items/mystic_amulet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_alaron_amulet_unique_lua", "items/mystic_amulet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_alaron_amulet_active_lua", "items/mystic_amulet", LUA_MODIFIER_MOTION_NONE)

item_alaron_amulet_lua = item_alaron_amulet_lua or class(item_mystic_amulet_lua)
item_alaron_amulet_lua.GetIntrinsicModifierName = ability_lua_base.GetIntrinsicModifierName
function item_alaron_amulet_lua:GetIntrinsicModifiers() return {"modifier_item_alaron_amulet_lua", "modifier_item_alaron_amulet_unique_lua"} end
function item_alaron_amulet_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_alaron_amulet_active_lua", {duration=self:GetSpecialValueFor("active_duration")})
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetEffectiveCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damage = self:GetSpecialValueFor("active_damage") + (math.min(self:GetSpecialValueFor("active_damage_pct") * self:GetCurrentCharges(), self:GetSpecialValueFor("max_active_damage_pct"))*enemy:GetMaxHealth()/100)
		ApplyDamage({attacker=self:GetCaster(), victim=enemy, damage=damage, damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
		local fx = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_RENDERORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(fx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), false)
		ParticleManager:SetParticleControl(fx, 2, Vector(800, 0, 0))
		ParticleManager:ReleaseParticleIndex(fx)
	end
	self:GetCaster():EmitSound("DOTA_Item.Bloodstone.Cast")
	if #enemies > 0 then
		self:GetCaster():EmitSound("DOTA_Item.Dagon.Activate")
	end
end

modifier_item_alaron_amulet_lua = modifier_item_alaron_amulet_lua or class(modifier_item_mystic_amulet_lua)
function modifier_item_alaron_amulet_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_item_alaron_amulet_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_alaron_amulet_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_alaron_amulet_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") + self:GetAbility():GetSpecialValueFor("bonus_intellect") + (self:GetAbility():GetSpecialValueFor("bonus_intellect_per_charge") * self:GetAbility():GetCurrentCharges()) end
function modifier_item_alaron_amulet_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_alaron_amulet_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_alaron_amulet_lua:GetModifierMPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("mana_regen_amplify_pct") end

modifier_item_alaron_amulet_unique_lua = modifier_item_alaron_amulet_unique_lua or class({})
function modifier_item_alaron_amulet_unique_lua:IsHidden() return true end
function modifier_item_alaron_amulet_unique_lua:IsPurgable() return false end
function modifier_item_alaron_amulet_unique_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_AOE_BONUS_CONSTANT} end
function modifier_item_alaron_amulet_unique_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.inflictor == nil or UnitFilter(kv.unit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	local spell_lifesteal = self:GetParent():HasModifier("modifier_item_alaron_amulet_active_lua") and self:GetAbility():GetSpecialValueFor("active_spell_lifesteal") or self:GetAbility():GetSpecialValueFor("spell_lifesteal")
	kv.attacker:Lifesteal(spell_lifesteal, kv.damage, self:GetAbility(), true, false)
end
function modifier_item_alaron_amulet_unique_lua:GetModifierAoEBonusConstant() return self:GetAbility():GetSpecialValueFor("aoe_bonus") end

modifier_item_alaron_amulet_active_lua = modifier_item_alaron_amulet_active_lua or class({})
function modifier_item_alaron_amulet_active_lua:IsPurgable() return false end
function modifier_item_alaron_amulet_active_lua:OnCreated()
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/items_fx/bloodstone_heal.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(fx, false, false, -1, false, true)
end