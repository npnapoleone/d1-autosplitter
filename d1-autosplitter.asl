state("Dishonored")
{

}

state("Dishonored", "1.2")
{
	float x : 0xFCCBDC, 0xC4;
	int levelNumber : 0xFB7838, 0x2C0, 0x314, 0x0, 0x38;
	string32 movie : 0xCB30400, 0x10;
	bool cutsceneActive : 0xFB51CC, 0x744;
	//int missionsStatsScreenFlags : 0xFDEB08, 0x24, 0x41C, 0x2E0, 0xC4;
	bool isLoading : "binkw32.dll", 0x312F4;
}

state("Dishonored", "1.4 Reloaded")
{
	
}

state("Dishonored", "1.4 Steam")
{
	
}

startup {
	vars.autoSplits = new Tuple<string, string, bool>[] {
		Tuple.Create("Coldridge Prison", "L_Prison_P", true),
		Tuple.Create("Dunwall Sewers", "L_PrsnSewer_P", true),
		Tuple.Create("Meeting Piero", "L_Pub_Day_P", true),
		Tuple.Create("Somehwere Else...", "L_OutsiderDream_P", true),
		Tuple.Create("Brief - High Overseer Campbell", "L_Pub_Dusk_P", true),
		Tuple.Create("To Holger Square", "L_Streets1_P", true),
		Tuple.Create("High Overseer's Office", "L_Ovrsr_P", true),
		Tuple.Create("The Backyard", "L_Ovrsr_Back_P", true),
		Tuple.Create("Debrief - High Overseer Campbell", "L_Pub_Morning_P", true),
		Tuple.Create("Brief - The Golden Cat", "L_Pub_Day_P", true),
		Tuple.Create("To The Golden Cat", "L_Streets2_P", true),
		Tuple.Create("The House of Pleasure", "L_Brothel_P", true),
		Tuple.Create("Under the Bridge", "L_Streets2_P", true),
		Tuple.Create("Debrief & Brief", "L_Pub_Dusk_P", true),
		Tuple.Create("Southside Gate", "L_Bridge_Part1a_P", true),
		Tuple.Create("Drawbridge Way", "L_Bridge_Part1b_P", true),
		Tuple.Create("Midrow Substation", "L_Bridge_Part1c_P", true),
		Tuple.Create("North End", "L_Bridge_Part2_P", true),
		Tuple.Create("Debrief - The Royal Physician", "L_Pub_Night_P", true),
		Tuple.Create("Brief - Lady Boyle's Last Party", "L_Pub_Day_P", true),
		Tuple.Create("Into the Party", "L_Boyle_Ext_P", true),
		Tuple.Create("Boyle Manor", "L_Boyle_Int_P", true),
		Tuple.Create("Escape the Party", "L_Boyle_Ext_P", true),
		Tuple.Create("Debrief & Brief", "L_Pub_Morning_P", true),
		Tuple.Create("Get to the Tower", "L_TowerRtrn_Yard_P", true),
		Tuple.Create("Alert the Guards", "L_TowerRtrn_Int_P", true),
		Tuple.Create("Kill the Regent", "L_TowerRtrn_Yard_P", true),
		Tuple.Create("Debrief - Return to the Tower", "L_Pub_Dusk_P", true),
		Tuple.Create("Meeting Daud", "L_Flooded_FIntro_P", true),
		Tuple.Create("Rudshore Waterfront", "L_Flooded_FStreets_P", true),
		Tuple.Create("Central Rudshore", "L_Flooded_FAssassins_P", true),
		Tuple.Create("Rudshore Gate", "L_Flooded_FGate_P", true),
		Tuple.Create("Old Port District", "L_Streetsewer_P", true),
		Tuple.Create("Loyalists", "L_Pub_Assault_P", true),
		Tuple.Create("Kingsparrow Fort", "L_Isl_LowChaos_P", true),
		Tuple.Create("The Lighthouse", "L_LightH_LowChaos_P", true),
	};

	int i = 0;
	foreach  (var autoSplit in vars.autoSplits) {
		settings.Add("autosplit_" + i.ToString(), autoSplit.Item3, "Split on \"" + autoSplit.Item1 + "\" start");
		++i;
	}
	settings.Add("autosplit_end", true, "Split on End");

	vars.autoSplitIndex = -1;
}

init {
	version = "1.2";

	if (vars.autoSplitIndex == -1) {
		for (vars.autoSplitIndex = 0; vars.autoSplitIndex < vars.autoSplits.Length; ++vars.autoSplitIndex) {
			if (settings["autosplit_" + vars.autoSplitIndex.ToString()]) {
				break;
			}
		}
	}
}

exit {
	timer.IsGameTimePaused = true;
}

isLoading {
	return current.isLoading;
}

update {
	const double posX = 9826.25f, delta = 0.25f;
	if (old.isLoading || current.isLoading) {
		int levelNum = current.levelNumber * 4;
		string levelName = new DeepPointer(0xFA3624, levelNum, 0x10).DerefString(game, 32);
		print("LiveSplit level update: " + levelName);
		vars.runStarting = levelName.StartsWith("l_tower_p")
			&& posX - delta < current.x
			&& posX + delta > current.x;

		if (vars.runStarting) {
			for (vars.autoSplitIndex = 0; vars.autoSplitIndex < vars.autoSplits.Length; ++vars.autoSplitIndex) {
				if (settings["autosplit_" + vars.autoSplitIndex.ToString()]) {
					break;
				}
			}
		}
	} else {
		vars.runStarting = false;
	}
}

reset {
	return current.isLoading && vars.runStarting;
}

start {
	return !current.isLoading && vars.runStarting;
}

split {
	if (vars.autoSplitIndex < vars.autoSplits.Length) {
		int levelNum = current.levelNumber * 4;
		string levelName = new DeepPointer(0xFA3624, levelNum, 0x10).DerefString(game, 32);
		if (current.isLoading && levelName.StartsWith(vars.autoSplits[vars.autoSplitIndex].Item2)) {
			for (++vars.autoSplitIndex; vars.autoSplitIndex < vars.autoSplits.Length; ++vars.autoSplitIndex) {
				if (settings["autosplit_" + vars.autoSplitIndex.ToString()]) {
					break;
				}
			}
			return true;
		}
	} else if (vars.autoSplitIndex == vars.autoSplits.Length && settings["autosplit_end"]) {
		// TBD
		return true;
	}

	return false;
}