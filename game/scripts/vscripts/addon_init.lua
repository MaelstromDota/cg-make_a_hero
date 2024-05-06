LinkLuaModifier("modifier_orb_effect_lua", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invulnerable_lua", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fake_invulnerable", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fake_invulnerable_both", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dummy_unit", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invisible_lua", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_indicator_lua", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_taunted_lua", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_truesight_aura_lua", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_unselectable_lua", "lib/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_arc_lua", "lib/modifiers", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_generic_leashed_lua", "lib/modifiers", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_summon_extra_health_lua", "lib/modifiers", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_primary_attribute_lua", "lib/modifiers", LUA_MODIFIER_MOTION_BOTH)

LinkLuaModifier("modifier_fountain_aura_lua", "main/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fountain_buff_lua", "main/modifiers", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_test_lua", "main/modifiers", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_item_third_eye_lua", "items/third_eye", LUA_MODIFIER_MOTION_NONE)

require("lib/client")
require("lib/abilities")