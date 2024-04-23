cast_unit = cast_unit or class(ability_lua_base)
function cast_unit:OnAbilityPhaseStart()
	local info = GetUnitKeyValuesByName(self:GetCursorTarget():GetUnitName())
	if self:GetCursorTarget():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		if info["CustomData"]["RightClickOpenEvent"] ~= nil then
			CustomGameEventManager:Send_ServerToPlayer(self:GetCaster():GetPlayerOwner(), info["CustomData"]["RightClickOpenEvent"], {})
		elseif self:GetCursorTarget():IsShrine() then
			self:GetCursorTarget():CastAbilityNoTarget(self:GetCursorTarget():FindAbilityByName("shrine_lua"), self:GetCaster():GetPlayerOwnerID())
		end
	end
	self:GetCaster():RemoveAbilityByHandle(self)
	return false
end