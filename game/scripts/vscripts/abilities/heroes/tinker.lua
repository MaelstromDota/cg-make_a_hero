tinker_rearm_lua = tinker_rearm_lua or class(ability_lua_base)
function tinker_rearm_lua:GetCastAnimation() return ACT_DOTA_TINKER_REARM1 end
function tinker_rearm_lua:OnSpellStart()
	self:GetCaster():EmitSound("Hero_Tinker.Rearm")
	self.cast_main_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.cast_main_pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.cast_main_pfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	self.cast_pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm_b.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.cast_pfx1, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	self.cast_pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm_b.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.cast_pfx2, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack3", self:GetCaster():GetAbsOrigin(), true)
	self.cast_sparkle_pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm_c.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.cast_sparkle_pfx1, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	self.cast_sparkle_pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm_c.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.cast_sparkle_pfx2, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack3", self:GetCaster():GetAbsOrigin(), true)
	if self:GetLevel() == 1 then
		self:GetCaster():StartGesture(ACT_DOTA_TINKER_REARM1)
	elseif self:GetLevel() == 2 then
		self:GetCaster():StartGesture(ACT_DOTA_TINKER_REARM2)
	elseif self:GetLevel() == 3 then
		self:GetCaster():StartGesture(ACT_DOTA_TINKER_REARM3)
	else
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_TINKER_REARM3, self:GetLevel()*0.4)
	end
end
function tinker_rearm_lua:OnChannelFinish(bInterrupted)
	self:GetCaster():StopSound("Hero_Tinker.Rearm")
	self:GetCaster():FadeGesture(ACT_DOTA_TINKER_REARM1)
	self:GetCaster():FadeGesture(ACT_DOTA_TINKER_REARM2)
	self:GetCaster():FadeGesture(ACT_DOTA_TINKER_REARM3)
	ParticleManager:DestroyParticle(self.cast_main_pfx, false)
	ParticleManager:ReleaseParticleIndex(self.cast_main_pfx)
	ParticleManager:DestroyParticle(self.cast_pfx1, false)
	ParticleManager:ReleaseParticleIndex(self.cast_pfx1)
	ParticleManager:DestroyParticle(self.cast_pfx2, false)
	ParticleManager:ReleaseParticleIndex(self.cast_pfx2)
	ParticleManager:DestroyParticle(self.cast_sparkle_pfx1, false)
	ParticleManager:ReleaseParticleIndex(self.cast_sparkle_pfx1)
	ParticleManager:DestroyParticle(self.cast_sparkle_pfx2, false)
	ParticleManager:ReleaseParticleIndex(self.cast_sparkle_pfx2)
	if bInterrupted then return end
	local exceptions = {
		"item_aeon_disk",
		"item_arcane_boots",
		"item_black_king_bar",
		"item_hand_of_midas",
		-- "item_helm_of_the_dominator",
		-- "item_helm_of_the_overlord",
		"item_sphere",
		"item_meteor_hammer",
		"item_pipe",
		"item_refresher",
		"item_refresher_shard",
		"item_necronomicon",
		"item_necronomicon_2",
		"item_necronomicon_3",
		"doom_bringer_devour",
		"dark_willow_shadow_realm_lua",
		"invoker_sun_strike_ad",
		"life_stealer_rage",
		"juggernaut_blade_fury",
		"phantom_assassin_blur_lua",
		"spirit_breaker_bulldoze",
		"beastmaster_call_of_the_wild",
		"beastmaster_call_of_the_wild_boar",
		"beastmaster_call_of_the_wild_hawk",
		"broodmother_spawn_spiderlings",
		"enigma_demonic_conversion",
		"invoker_forge_spirit_ad",
		"furion_force_of_nature",
		"undying_tombstone",
		"skeleton_king_vampiric_aura",
		"dark_troll_warlord_raise_dead",
		"pugna_nether_ward",
		"venomancer_plague_ward",
		"zuus_cloud",
	}
	for i=0, DOTA_MAX_ABILITIES-1 do
		local ability = self:GetCaster():GetAbilityByIndex(i)
		if ability and (not table.contains({ABILITY_TYPE_ATTRIBUTES, ABILITY_TYPE_ULTIMATE}, ability:GetAbilityType()) or ability == self) and ability:IsRefreshable() and not table.contains(exceptions, ability:GetAbilityName()) then
			ability:RefreshCharges()
			ability:EndCooldown()
		end
	end
	for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
		local item = self:GetCaster():GetItemInSlot(i)
		if item then
			if item:GetPurchaser() == self:GetCaster() and not table.contains(exceptions, item:GetName()) and item:IsRefreshable() then
				item:EndCooldown()
			end
		end
	end
	local tpscroll = self:GetCaster():GetItemInSlot(DOTA_ITEM_TP_SCROLL)
	if tpscroll then
		if tpscroll:GetPurchaser() == self:GetCaster() and not table.contains(exceptions, tpscroll:GetName()) and tpscroll:IsRefreshable() then
			tpscroll:EndCooldown()
		end
	end
end