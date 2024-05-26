LinkLuaModifier("modifier_item_ring_of_the_void_lua", "items/boss/ring_of_the_void", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ring_of_the_void_debuff_stack_lua", "items/boss/ring_of_the_void", LUA_MODIFIER_MOTION_NONE)

item_ring_of_the_void_lua = item_ring_of_the_void_lua or class(ability_lua_base)
function item_ring_of_the_void_lua:GetIntrinsicModifierName() return "modifier_item_ring_of_the_void_lua" end

modifier_item_ring_of_the_void_lua = modifier_item_ring_of_the_void_lua or class({})
function modifier_item_ring_of_the_void_lua:IsHidden() return true end
function modifier_item_ring_of_the_void_lua:IsPurgable() return false end
function modifier_item_ring_of_the_void_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_MODIFIER_ADDED} end
function modifier_item_ring_of_the_void_lua:OnCreated()
	if not IsServer() then return end
	self.block_trigger = {}
end
function modifier_item_ring_of_the_void_lua:TriggerDebuff(unit, ability)
	if self.block_trigger[tostring(ability:entindex().."_"..unit:entindex())] ~= nil then
		self.block_trigger[tostring(ability:entindex().."_"..unit:entindex())] = nil
		return
	end
	self.block_trigger[tostring(ability:entindex().."_"..unit:entindex())] = true
	Timers:CreateTimer({endTime=FrameTime(), callback=function()
		if self.block_trigger ~= nil then
			self.block_trigger[tostring(ability:entindex().."_"..unit:entindex())] = nil
		end
	end}, nil, self)
	unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_ring_of_the_void_debuff_stack_lua", {duration=self:GetAbility():GetSpecialValueFor("duration")})
end
function modifier_item_ring_of_the_void_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.inflictor == nil or UnitFilter(kv.unit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS or kv.inflictor == self:GetAbility() or kv.inflictor:GetIntrinsicModifierName() == self:GetName() or (kv.inflictor.GetIntrinsicModifiers ~= nil and table.contains(kv.inflictor:GetIntrinsicModifiers(), self:GetName())) then return end
	self:TriggerDebuff(kv.unit, kv.inflictor)
end
function modifier_item_ring_of_the_void_lua:OnModifierAdded(kv)
	if not IsServer() then return end
	if kv.added_buff:GetCaster() ~= self:GetParent() or kv.added_buff:GetAbility() == nil or UnitFilter(kv.unit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, kv.added_buff:GetCaster():GetTeamNumber()) ~= UF_SUCCESS or kv.added_buff:GetAbility() == self:GetAbility() or kv.added_buff:GetAbility():GetIntrinsicModifierName() == self:GetName() or (kv.added_buff:GetAbility().GetIntrinsicModifiers ~= nil and table.contains(kv.added_buff:GetAbility():GetIntrinsicModifiers(), self:GetName())) then return end
	self:TriggerDebuff(kv.unit, kv.added_buff:GetAbility())
end

modifier_item_ring_of_the_void_debuff_stack_lua = modifier_item_ring_of_the_void_debuff_stack_lua or class({})
function modifier_item_ring_of_the_void_debuff_stack_lua:IsPurgable() return true end
function modifier_item_ring_of_the_void_debuff_stack_lua:GetStatusEffectName() return "particles/status_fx/status_effect_stickynapalm.vpcf" end
function modifier_item_ring_of_the_void_debuff_stack_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_item_ring_of_the_void_debuff_stack_lua:OnCreated()
	self:OnRefresh()
	if not IsServer() then return end
	self.fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(self.fx, 1, Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	self:AddParticle(self.fx, false, false, -1, false, false)
end
function modifier_item_ring_of_the_void_debuff_stack_lua:OnRefresh()
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct")
	if not IsServer() then return end
	self:IncrementStackCount()
	Timers:CreateTimer({endTime=self:GetDuration(), callback=function()
		if not self or self:IsNull() then return end
		self:DecrementStackCount()
	end}, nil, self)
end
function modifier_item_ring_of_the_void_debuff_stack_lua:OnStackCountChanged(iStackCount)
	if not IsServer() then return end
	if self.fx then
		ParticleManager:SetParticleControl(self.fx, 1, Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	end
end
function modifier_item_ring_of_the_void_debuff_stack_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetCaster() or kv.unit ~= self:GetParent() or kv.inflictor == nil or kv.inflictor == self:GetAbility() then return end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf", PATTACH_ABSORIGIN, kv.unit)
	ParticleManager:ReleaseParticleIndex(fx)
	ApplyDamage({attacker=kv.attacker, victim=kv.unit, damage=kv.unit:GetHealth()*(self.damage_pct*math.min(self.max_stacks, self:GetStackCount()) / 100), damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
end