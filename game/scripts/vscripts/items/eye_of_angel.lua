LinkLuaModifier("modifier_item_eye_of_angel_lua", "items/eye_of_angel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eye_of_angel_unique_lua", "items/eye_of_angel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eye_of_angel_active_lua", "items/eye_of_angel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eye_of_angel_active_aura_lua", "items/eye_of_angel", LUA_MODIFIER_MOTION_NONE)

item_eye_of_angel_lua = item_eye_of_angel_lua or class(ability_lua_base)
function item_eye_of_angel_lua:GetIntrinsicModifiers() return {"modifier_item_eye_of_angel_lua", "modifier_item_eye_of_angel_unique_lua"} end
function item_eye_of_angel_lua:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_eye_of_angel_active_lua", {duration = self:GetSpecialValueFor("track_duration")})
	EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Hero_BountyHunter.Target", self:GetCaster())
end

modifier_item_eye_of_angel_lua = modifier_item_eye_of_angel_lua or class({})
function modifier_item_eye_of_angel_lua:IsHidden() return true end
function modifier_item_eye_of_angel_lua:IsPurgable() return false end
function modifier_item_eye_of_angel_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_eye_of_angel_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_eye_of_angel_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_eye_of_angel_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_eye_of_angel_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end

modifier_item_eye_of_angel_unique_lua = modifier_item_eye_of_angel_unique_lua or class({})
function modifier_item_eye_of_angel_unique_lua:IsHidden() return true end
function modifier_item_eye_of_angel_unique_lua:IsPurgable() return false end
function modifier_item_eye_of_angel_unique_lua:DeclareFunctions() return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING} end
function modifier_item_eye_of_angel_unique_lua:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_eye_of_angel_unique_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_eye_of_angel_unique_lua:OnIntervalThink()
	self.visible_enemies = table.length(table.filter(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false), function(_, unit) return unit:IsTrueHero() end))
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_item_eye_of_angel_unique_lua:AddCustomTransmitterData() return {visible_enemies = self.visible_enemies} end
function modifier_item_eye_of_angel_unique_lua:HandleCustomTransmitterData(kv)
	self.visible_enemies = kv.visible_enemies
end
function modifier_item_eye_of_angel_unique_lua:GetModifierCastRangeBonusStacking() return self:GetAbility():GetSpecialValueFor("cast_range_bonus") + self:GetAbility():GetSpecialValueFor("cast_range_bonus_per_enemy") * (self.visible_enemies or 0) end

modifier_item_eye_of_angel_active_lua = modifier_item_eye_of_angel_active_lua or class({})
function modifier_item_eye_of_angel_active_lua:IsHidden()
	if IsClient() then return GetLocalPlayerTeam(GetLocalPlayerID()) ~= self:GetCaster():GetTeamNumber() end
	return true
end
function modifier_item_eye_of_angel_active_lua:IsPurgable() return true end
function modifier_item_eye_of_angel_active_lua:IsAura() return true end
function modifier_item_eye_of_angel_active_lua:GetEffectName() if IsServer() or (IsClient() and GetLocalPlayerTeam(GetLocalPlayerID()) == self:GetCaster():GetTeamNumber()) then return "particles/items_fx/necronomicon_true_sight.vpcf" end end
function modifier_item_eye_of_angel_active_lua:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_item_eye_of_angel_active_lua:GetModifierAura() return "modifier_item_eye_of_angel_active_aura_lua" end
function modifier_item_eye_of_angel_active_lua:GetAuraDuration() return 0.5 end
function modifier_item_eye_of_angel_active_lua:GetAuraRadius() return FIND_UNITS_EVERYWHERE end
function modifier_item_eye_of_angel_active_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_eye_of_angel_active_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_item_eye_of_angel_active_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_eye_of_angel_active_lua:GetAuraEntityReject(hEntity) return hEntity:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() end
function modifier_item_eye_of_angel_active_lua:CheckState() return {[MODIFIER_STATE_INVISIBLE] = false} end
function modifier_item_eye_of_angel_active_lua:OnCreated()
	if not IsServer() then return end
	self:OnIntervalThink()
	self:StartIntervalThink(FrameTime())
end
function modifier_item_eye_of_angel_active_lua:OnIntervalThink()
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 32, FrameTime() * 1.2, false)
end

modifier_item_eye_of_angel_active_aura_lua = modifier_item_eye_of_angel_active_aura_lua or class({})
function modifier_item_eye_of_angel_active_aura_lua:IsHidden() return true end
function modifier_item_eye_of_angel_active_aura_lua:IsPurgable() return false end
function modifier_item_eye_of_angel_active_aura_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_eye_of_angel_active_aura_lua:DeclareFunctions() return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING} end
function modifier_item_eye_of_angel_active_aura_lua:GetModifierCastRangeBonusStacking(kv)
	if kv.target == nil or kv.target ~= self:GetAuraOwner() then return end
	return self:GetAbility():GetSpecialValueFor("active_cast_range_bonus")
end