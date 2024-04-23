LinkLuaModifier("modifier_item_power_amulet_lua", "items/power_amulet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_power_amulet_debuff_lua", "items/power_amulet", LUA_MODIFIER_MOTION_NONE)

item_power_amulet_lua = item_power_amulet_lua or class(ability_lua_base)
function item_power_amulet_lua:GetIntrinsicModifierName() return "modifier_item_power_amulet_lua" end
function item_power_amulet_lua:OnRuneActivated(rune)
	self:SetCurrentCharges(self:GetCurrentCharges() + (self:GetCurrentCharges() < 5 and 2 or 1))
end
function item_power_amulet_lua:OnDeath()
	self:SetCurrentCharges(math.max(math.floor(self:GetCurrentCharges()/2), 0))
end
function item_power_amulet_lua:OnSpellStart()
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetEffectiveCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=self:GetSpecialValueFor("stun_per_charge")*self:GetCurrentCharges()})
	end
	self:GetCaster():HealWithParams(self:GetSpecialValueFor("heal")+self:GetSpecialValueFor("heal_per_charge")*self:GetCurrentCharges(), self, false, true, self:GetCaster(), false)
	self:GetCaster():EmitSound("DOTA_Item.UrnOfShadows.Activate")
end

modifier_item_power_amulet_lua = modifier_item_power_amulet_lua or class({})
function modifier_item_power_amulet_lua:IsHidden() return true end
function modifier_item_power_amulet_lua:IsPurgable() return false end
function modifier_item_power_amulet_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_item_power_amulet_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if self:GetParent() ~= kv.attacker then return end
	if self:GetParent():IsIllusion() then return end
	kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_item_power_amulet_debuff_lua", {duration=self:GetAbility():GetSpecialValueFor("armor_reduction_duration")})
end
function modifier_item_power_amulet_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") + (self:GetAbility():GetSpecialValueFor("bonus_damage_per_charge") * self:GetAbility():GetCurrentCharges()) end

modifier_item_power_amulet_debuff_lua = modifier_item_power_amulet_debuff_lua or class({})
function modifier_item_power_amulet_debuff_lua:IsDebuff() return true end
function modifier_item_power_amulet_debuff_lua:IsPurgable() return true end
function modifier_item_power_amulet_debuff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_power_amulet_debuff_lua:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction_per_charge") * self:GetAbility():GetCurrentCharges() * (-1)
end
function modifier_item_power_amulet_debuff_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_power_amulet_debuff_lua:GetModifierPhysicalArmorBonus() return self.armor_reduction end