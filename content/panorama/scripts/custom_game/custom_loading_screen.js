const KILL_LIMIT_OPTIONS = [
	["50", "50"],
	["75", "75"],
	["100", "100", true],
	["150", "150"],
	["200", "200"],
	["0", "  ∞  "],
]

function SelectOption(option, value, parent) {
	for (let i=0; i<parent.GetChildCount(); i++) {
		let child = parent.GetChild(i);
		child.checked = child.id == value;
	}
	GameEvents.SendEventToServer("loading_screen_choose_option", {option: option, value: value});
}

function Init() {
	PostInit();
	const kill_limit_options_panel = $("#KillLimit").FindChildTraverse("Options");
	kill_limit_options_panel.RemoveAndDeleteChildren();
	for (const limit_option of KILL_LIMIT_OPTIONS) {
		const option = $.CreatePanel("ToggleButton", kill_limit_options_panel, limit_option[0], {hittest: "true", text: limit_option[1]});
		option.SetPanelEvent("onactivate", () => {
			SelectOption("kill_limit", limit_option[0], kill_limit_options_panel);
		});
	}
	for (const limit_option of KILL_LIMIT_OPTIONS) {
		if (limit_option[2] == true) {
			SelectOption("kill_limit", limit_option[0], kill_limit_options_panel);
		}
	}
}

function PostInit() {
	const player_info = Game.GetLocalPlayerInfo();
	if (player_info == null) {
		$.Schedule(0.2, PostInit);
		return;
	}
	$.GetContextPanel().SetHasClass("IsHost", player_info["player_has_host_privileges"] == true);
	$.GetContextPanel().AddClass("Loaded");
}

GameEvents.Subscribe("game_rules_state_change", () => {
	if (Game.GetState() >= DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP ) {
		$.GetContextPanel().AddClass("AllLoaded");
	}
});

Init();
