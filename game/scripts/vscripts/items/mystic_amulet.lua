LinkLuaModifier("modifier_item_mystic_amulet_lua", "items/mystic_amulet", LUA_MODIFIER_MOTION_NONE)

item_mystic_amulet_lua = item_mystic_amulet_lua or class(ability_lua_base)
function item_mystic_amulet_lua:GetIntrinsicModifierName() return "modifier_item_mystic_amulet_lua" end
function item_mystic_amulet_lua:OnRuneActivated(rune)
	self:SetCurrentCharges(self:GetCurrentCharges() + 1)
end
function item_mystic_amulet_lua:OnLotusPickup(lotus_pool)
	self:SetCurrentCharges(self:GetCurrentCharges() + 2)
end
function item_mystic_amulet_lua:OnWatcherCaptured(watcher, captured)
	if not captured then return end
	if watcher:GetUnitName() == "npc_dota_lantern_flying_large" then return end
	self:SetCurrentCharges(self:GetCurrentCharges() + 1)
end
function item_mystic_amulet_lua:OnDeath()
	self:SetCurrentCharges(math.max(math.floor(self:GetCurrentCharges()/2), 0))
end
function item_mystic_amulet_lua:OnSpellStart()
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
	if #enemies > 0 then
		self:GetCaster():EmitSound("DOTA_Item.Dagon.Activate")
	end
end

modifier_item_mystic_amulet_lua = modifier_item_mystic_amulet_lua or class({})
function modifier_item_mystic_amulet_lua:IsHidden() return true end
function modifier_item_mystic_amulet_lua:IsPurgable() return false end
function modifier_item_mystic_amulet_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_item_mystic_amulet_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") + (self:GetAbility():GetSpecialValueFor("bonus_intellect_per_charge") * self:GetAbility():GetCurrentCharges()) end