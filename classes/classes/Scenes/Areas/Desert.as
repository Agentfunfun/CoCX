/**
 * Created by aimozg on 06.01.14.
 */
package classes.Scenes.Areas
{
import classes.*;
import classes.GlobalFlags.kFLAGS;
import classes.Scenes.API.Encounters;
import classes.Scenes.API.FnHelpers;
import classes.Scenes.API.GroupEncounter;
import classes.Scenes.Areas.Desert.*;
import classes.Scenes.Dungeons.DemonLab;
import classes.Scenes.SceneLib;

use namespace CoC;

	public class Desert extends BaseContent
	{
		public var antsScene:AntsScene = new AntsScene();
		public var nagaScene:NagaScene = new NagaScene();
		public var gorgonScene:GorgonScene = new GorgonScene();
		public var oasis:Oasis = new Oasis();
		public var sandTrapScene:SandTrapScene = new SandTrapScene();
		public var sandWormScene:SandWormScene = new SandWormScene();
		public var sandWitchScene:SandWitchScene = new SandWitchScene();
		public var wanderer:Wanderer = new Wanderer();
		//public var gorgonScene:GorgonScene = new GorgonScene();przenieść do deep desert potem
		
		public function Desert()
		{
			onGameInit(init);
		}
		
		private var _desertEncounter:GroupEncounter = null;
		public function get desertEncounter():GroupEncounter {
			return _desertEncounter;
		}
		private var _innerdesertEncounter:GroupEncounter = null;
		public function get innerdesertEncounter():GroupEncounter {
			return _innerdesertEncounter;
		}
		private function init():void {
            const fn:FnHelpers = Encounters.fn;
			_desertEncounter = Encounters.group("desert",
				{
					name: "discoverinnerdesert",
					when: function ():Boolean {
						return (player.level + combat.playerLevelAdjustment()) >= 10 && flags[kFLAGS.DISCOVERED_INNER_DESERT] == 0
					},
					chance: 30,
					call: discoverInnerDesert
				}, {
					name: "walk",
					call: walkingDesertStatBoost
				}, {
					name: "naga",
					when: fn.ifLevelMin(4),
					call: nagaScene.nagaEncounter
				}, {
					name  : "sandtrap",
					chance: 0.5,
					when  : fn.ifLevelMin(2),
					call  : sandTrapScene.encounterASandTarp
				}, {
					name: "sandwitch",
					night : false,
					when: function ():Boolean {
						return player.level >= 3 && flags[kFLAGS.SAND_WITCH_LEAVE_ME_ALONE] == 0;
					},
					call: sandWitchScene.encounter
				}, {
					name: "cumwitch",
					night : false,
					when: function ():Boolean {
						return flags[kFLAGS.CUM_WITCHES_FIGHTABLE] > 0;
					},
					call: SceneLib.dungeons.desertcave.fightCumWitch
				}, {
					name  : "wanderer",
					night : false,
					chance: 0.2,
					call  : wanderer.wandererRouter
				}, {
					name: "sw_preg",
					night : false,
					when: function ():Boolean {
						return sandWitchScene.pregnancy.event == 2;
					},
					call: sandWitchPregnancyEvent
				}, {
					name: "teladreDiscover",
					when: function ():Boolean
					{
						return (!player.hasStatusEffect(StatusEffects.TelAdre)) && (player.exploredDesert >= 3);
					},
					chance: 30,
					call: SceneLib.telAdre.discoverTelAdre
				}, {
					name: "teladreEncounter",
					when: function ():Boolean
					{
						return player.statusEffectv1(StatusEffects.TelAdre) == 0;
					},
					chance: 5,
					call: SceneLib.telAdre.discoverTelAdre
				}, {
					name  : "ants",
					night : false,
					when  : function ():Boolean {
						return player.level >= 9 && flags[kFLAGS.ANT_WAIFU] == 0 && flags[kFLAGS.ANTS_PC_FAILED_PHYLLA] == 0 && flags[kFLAGS.ANT_COLONY_KEPT_HIDDEN] == 0;
					},
					chance: phyllaAnthillChance,
					call  : antsScene.antColonyEncounter
				}, {
					name: "dungeon",
					when: function ():Boolean {
						return (player.level >= 4 || player.exploredDesert > 45)
							   && flags[kFLAGS.DISCOVERED_WITCH_DUNGEON] == 0;
					},
					call: SceneLib.dungeons.desertcave.enterDungeon
				}, {
					name: "wstaff",
					when: function ():Boolean {
						return flags[kFLAGS.FOUND_WIZARD_STAFF] == 0 && player.inte > 50;
					},
					call: wstaffEncounter
				}, {
					name: "desert eagle",
					when: function ():Boolean {
						return player.level >= 6 && player.hasStatusEffect(StatusEffects.TelAdreTripxiGuns1) && player.statusEffectv1(StatusEffects.TelAdreTripxiGuns1) == 0 && player.hasKeyItem("Desert Eagle") < 0;
					},
					chance: 30,
					call: partsofDesertEagle
				}, {
					name: "nails",
					when: function ():Boolean {
						return player.hasKeyItem("Carpenter's Toolbox") >= 0 && player.keyItemvX("Carpenter's Toolbox", 1) < 200;
					},
					call: nailsEncounter
				}, {
					name: "chest",
					when: function ():Boolean {
						return player.hasKeyItem("Camp - Chest") < 0
					},
					call: chestEncounter
				}, {
					name  : "bigjunk",
					chance: function ():Boolean
					{
						var chance:Number = 10 + (player.longestCockLength() - player.tallness) / 24 * 10;
						if ( chance > 30){chance = 30; }
						return (chance > rand(100) && player.longestCockLength() >= player.tallness && player.totalCockThickness() >= 12)
					},
					call  : SceneLib.exploration.bigJunkDesertScene
				}, {
					name  : "exgartuan",
					chance: 0.25,
					call  : SceneLib.exgartuan.fountainEncounter
				}, {
					name  : "mirage",
					night : false,
					chance: 0.25,
					when  : fn.ifLevelMin(2),
					call  : mirageDesert
				}, {
					name  : "oasis",
					night : false,
					chance: 0.25,
					when  : fn.ifLevelMin(2),
					call  : oasis.oasisEncounter
				}, {
					name: "etna",
					chance: 0.2,
					when: function ():Boolean
					{
						return (flags[kFLAGS.ETNA_FOLLOWER] < 1 && flags[kFLAGS.ETNA_TALKED_ABOUT_HER] == 2 && !player.hasStatusEffect(StatusEffects.EtnaOff) && (player.level >= 20));
					},
					call: SceneLib.etnaScene.repeatYandereEnc
				}, {
					//Helia monogamy fucks
					name  : "helcommon",
					night : false,
					call  : SceneLib.helScene.helSexualAmbush,
					chance: 0.2,
					when  : SceneLib.helScene.helSexualAmbushCondition
				}, {
					name: "mimic",
					chance: 0.25,
					when: fn.ifLevelMin(3),
					call: curry(SceneLib.mimicScene.mimicTentacleStart, 1)
				}, {
					name  : "desertloot",
					chance: 0.3,
					call  : findDesertLoot
				}/*, {
					name: "demonProjects",
					chance: 0.2,
					when: function ():Boolean {
						return DemonLab.MainAreaComplete >= 4;
					},
					call: SceneLib.exploration.demonLabProjectEncounters
				}*/);
			_innerdesertEncounter = Encounters.group("inner desert",
				{
					name: "gorgon",
					when: fn.ifLevelMin(14),
					call: gorgonScene.gorgonEncounter
				}, {
					name: "sandworm",
					night: false,
					call: sandWormScene.SandWormEncounter
				}, {
					name: "etna",
					chance: 0.2,
					when: function ():Boolean
					{
						return (flags[kFLAGS.ETNA_FOLLOWER] < 1 && flags[kFLAGS.ETNA_TALKED_ABOUT_HER] == 2 && !player.hasStatusEffect(StatusEffects.EtnaOff) && (player.level >= 20));
					},
					call: SceneLib.etnaScene.repeatYandereEnc
				}, {
					//Helia monogamy fucks
					name  : "helcommon",
					night : false,
					call  : SceneLib.helScene.helSexualAmbush,
					chance: 0.2,
					when  : SceneLib.helScene.helSexualAmbushCondition
				},{
					name: "electra",
					night : false,
					when: function():Boolean {
						return flags[kFLAGS.ELECTRA_FOLLOWER] < 2 && flags[kFLAGS.ELECTRA_AFFECTION] >= 2 && !player.hasStatusEffect(StatusEffects.ElectraOff) && (player.level >= 20);
					},
					chance:0.5,
					call: function ():void {
						if (flags[kFLAGS.ELECTRA_AFFECTION] == 100) {
							if (flags[kFLAGS.ELECTRA_FOLLOWER] == 1) SceneLib.electraScene.ElectraRecruitingAgain();
							else SceneLib.electraScene.ElectraRecruiting();
						}
						else SceneLib.electraScene.repeatDesertEnc();
					}
				}, {/*
					name: "lactoblasters",
					when: function ():Boolean {
						return player.hasStatusEffect(StatusEffects.TelAdreTripxiGuns5) && player.statusEffectv3(StatusEffects.TelAdreTripxiGuns2) == 0 && player.hasKeyItem("Lactoblasters") < 0;
					},
					chance: 30,
					call: partsofLactoBlasters
				}, {*/
					name: "ted",
					call: SceneLib.tedScene.introPostHiddenCave,
					when: SceneLib.tedScene.canEncounterTed
				}/*, {
					name: "demonProjects",
					chance: 0.2,
					when: function ():Boolean {
						return DemonLab.MainAreaComplete >= 4;
					},
					call: SceneLib.exploration.demonLabProjectEncounters
				}*/);
		}
		//Explore desert
		public function exploreDesert():void
		{
			clearOutput();
			doNext(camp.returnToCampUseOneHour);
			player.exploredDesert++;
			desertEncounter.execEncounter();
			flushOutputTextToGUI();
		}
		
		public function exploreInnerDesert():void
		{
			clearOutput();
			doNext(camp.returnToCampUseOneHour);
			flags[kFLAGS.DISCOVERED_INNER_DESERT]++;
			innerdesertEncounter.execEncounter();
			flushOutputTextToGUI();
		}

		private function discoverInnerDesert():void {
			clearOutput();
			outputText("While exploring the desert you notice that the sandy dunes begins to grow larger and more intimidating. The heat has also ramped up you will have to carry some waterskins on you. ");
			outputText("<b>It would seem you found the inner desert area!</b>");
			flags[kFLAGS.DISCOVERED_INNER_DESERT]++;
			doNext(camp.returnToCampUseTwoHours);
		}

		public function sandWitchPregnancyEvent():void {
			if (flags[kFLAGS.EGG_WITCH_TYPE] == PregnancyStore.PREGNANCY_DRIDER_EGGS) sandWitchScene.sammitchBirthsDriders();
			else sandWitchScene.witchBirfsSomeBees();
		}

		public function chestEncounter():void {
			clearOutput();
			outputText("While wandering the trackless sands of the desert, you break the silent monotony with a loud 'thunk'.\n"
				+ "You look down and realize you're standing on the lid of an old chest, somehow intact and buried in the sand. Overcome with curiosity, you dig it out, only to discover that it's empty.\n"
				+ "\n"
				+ "You decide to bring it back to your campsite.");
			for (var i:int = 0; i < 6; i++) {
				inventory.createStorage();
			}
			player.createKeyItem("Camp - Chest", 0, 0, 0, 0);
			outputText("\n\n<b>You now have six storage item slots at camp.</b>");
			doNext(camp.returnToCampUseOneHour);
		}
		
		public function phyllaAnthillChance():Number {
			var temp:Number = 1.5;
			if (flags[kFLAGS.PHYLLA_SAVED] == 1) temp += 1.5;
			if (flags[kFLAGS.PC_READY_FOR_ANT_COLONY_CHALLENGE] == 1) temp += 1.5;
			if (flags[kFLAGS.ANT_ARENA_WINS] > 0) temp += flags[kFLAGS.ANT_ARENA_WINS] * 1.5;
			return temp;
		}

		public function nailsEncounter():void {
			var extractedNail:int = 5 + rand(player.inte / 5) + rand(player.str / 10) + rand(player.tou / 10) + rand(player.spe / 20) + 5;
			flags[kFLAGS.ACHIEVEMENT_PROGRESS_SCAVENGER] += extractedNail;
			flags[kFLAGS.CAMP_CABIN_NAILS_RESOURCES] += extractedNail;
			outputText("While exploring the desert, you find the wreckage of a building. Judging from the debris, it's the remains of the library that was destroyed by the fire.\n"
				+ "\n"
				+ "You circle the wreckage for a good while and you can't seem to find anything to salvage until something shiny catches your eye. There are exposed nails! You take your hammer out of your toolbox and you spend time extracting "+extractedNail+" nails. Some of them are bent but others are in incredibly good condition. You could use these for construction.");
			outputText("\n\nNails: ");
			if (flags[kFLAGS.CAMP_CABIN_NAILS_RESOURCES] > SceneLib.campUpgrades.checkMaterialsCapNails()) flags[kFLAGS.CAMP_CABIN_NAILS_RESOURCES] = SceneLib.campUpgrades.checkMaterialsCapNails();
			outputText(flags[kFLAGS.CAMP_CABIN_NAILS_RESOURCES]+"/" + SceneLib.campUpgrades.checkMaterialsCapNails() + "");
		}

		public function wstaffEncounter():void {
			clearOutput();
			outputText("While exploring the desert, you see a plume of smoke rising in the distance.  You change direction and approach the soot-cloud carefully.  It takes a few moments, but after cresting your fourth dune, you locate the source.  You lie low, so as not to be seen, and crawl closer for a better look.\n\n");
			outputText("A library is burning up, sending flames dozens of feet into the air.  It doesn't look like any of the books will survive, and most of the structure has already been consumed by the hungry flames.  The source of the inferno is curled up next to it.  It's a naga!  She's tall for a naga, at least seven feet if she stands at her full height.  Her purplish-blue skin looks quite exotic, and she wears a flower in her hair.  The naga is holding a stick with a potato on the end, trying to roast the spud on the library-fire.  It doesn't seem to be going well, and the potato quickly lights up from the intense heat.\n\n");
			outputText("The snake-woman tosses the burnt potato away and cries, \"<i>Hora hora.</i>\"  She suddenly turns and looks directly at you.  Her gaze is piercing and intent, but she vanishes before you can react.  The only reminder she was ever there is a burning potato in the sand.   Your curiosity overcomes your caution, and you approach the fiery inferno.  There isn't even a trail in the sand, and the library is going to be an unsalvageable wreck in short order.   Perhaps the only item worth considering is the stick with the burning potato.  It's quite oddly shaped, and when you reach down to touch it you can feel a resonant tingle.  Perhaps it was some kind of wizard's staff?\n\n");
			flags[kFLAGS.FOUND_WIZARD_STAFF]++;
			inventory.takeItem(weapons.W_STAFF, camp.returnToCampUseOneHour);
		}
		
		public function partsofDesertEagle():void {
			clearOutput();
			outputText("As you explore the desert you run into what appears to be the half buried remains of some old contraption. Wait this might just be what that gun vendor was talking about! You proceed to dig up the items releasing this to indeed be the remains of a broken firearm.\n\n");
			outputText("You carefully put the pieces of the Desert Eagle in your back and head back to your camp.\n\n");
			player.addStatusValue(StatusEffects.TelAdreTripxi, 2, 1);
			player.createKeyItem("Desert Eagle", 0, 0, 0, 0);
			doNext(camp.returnToCampUseOneHour);
		}

		private function mirageDesert():void
		{
			clearOutput();
			outputText("While exploring the desert, you see a shimmering tower in the distance.  As you rush towards it, it vanishes completely.  It was a mirage!   You sigh, depressed at wasting your time.");
			dynStats("lus", -15, "scale", false);
			doNext(camp.returnToCampUseOneHour);
		}

		private function walkingDesertStatBoost():void
		{
			clearOutput();
			outputText("You walk through the shifting sands for an hour, finding nothing.\n\n");
			//Chance of boost == 50%
			if (rand(2) == 0) {
				//50/50 strength/toughness
				if (rand(2) == 0 && player.canTrain('str', 50)) {
					outputText("The effort of struggling with the uncertain footing has made you stronger.");
					player.trainStat("str", 1, 50);
					dynStats("str", .5);
				}
				//Toughness
				else if (player.canTrain('tou', 50)) {
					outputText("The effort of struggling with the uncertain footing has made you tougher.");
					player.trainStat("tou", 1, 50);
					dynStats("tou", .5);
				}
			}
			doNext(camp.returnToCampUseOneHour);
		}

		private function findDesertLoot():void {
			clearOutput();
			outputText("Miraculously, you spot a lone pouch lying in the sand. Opening it, you find a neatly wraped cake!\n");
			inventory.takeItem(consumables.HDEWCAK, camp.returnToCampUseOneHour);
		}
	}
}
