/**
 * Created by aimozg on 06.01.14.
 */
package classes.Scenes.Places
{
import classes.*;
import classes.GlobalFlags.kFLAGS;
import classes.Scenes.Areas.Lake.*;
import classes.Scenes.NPCs.BelisaFollower;
import classes.Scenes.NPCs.EtnaFollower;
import classes.Scenes.Places.Boat.*;
import classes.Scenes.SceneLib;

public class Boat extends AbstractLakeContent
	{
		public var sharkGirlScene:SharkGirlScene = new SharkGirlScene();
		public var marae:MaraeScene = new MaraeScene();
		public var kaiju:Kaiju = new Kaiju();
		public var anemoneScene:AnemoneScene = new AnemoneScene();
		public function Boat() {}

		public function discoverBoat():void {
			player.createStatusEffect(StatusEffects.BoatDiscovery,0,0,0,0);
			clearOutput();
			outputText("You journey around the lake, seeking demons to fight");
			if(player.cor > 60) outputText(" or fuck");
			outputText(".  The air is fresh, and the grass is cool and soft under your feet.   Soft waves lap against the muddy sand of the lake-shore, as if radiating outward from the lake.   You pass around a few bushes carefully, being wary of hidden 'surprises', and come upon a small dock.  The dock is crafted from old growth trees lashed together with some crude rope.  Judging by the appearance of the rope, it is very old and has not been seen to in quite some time.  Tied to the dock is a small rowboat, only about seven feet long and three feet wide.   The boat appears in much better condition than the dock, and appears to be brand new.\n\n");
			outputText("<b>You have discovered the lake boat!</b>\n(You may return and use the boat to explore the lake's interior by using the 'places' menu.)");
			explorer.stopExploring();
			doNext(camp.returnToCampUseOneHour);
		}
		public function boatExplore():void
		{
			player.addStatusValue(StatusEffects.BoatDiscovery, 1, 1);
			//Belisa
			if (BelisaFollower.BelisaInGame && BelisaFollower.BelisaEncounternum == 1) {
				SceneLib.belisa.secondEncounter();
				//label : "Belisa",
				//kind  : 'npc',
				//unique: true,
				return;
			}
			//Etna
			if ((flags[kFLAGS.ETNA_FOLLOWER] < 1 || EtnaFollower.EtnaInfidelity == 2) && flags[kFLAGS.ETNA_TALKED_ABOUT_HER] == 2 && !player.hasStatusEffect(StatusEffects.EtnaOff) && rand(5) == 0 && (player.level >= 20)) {
				SceneLib.etnaScene.repeatYandereEnc();
				//label : "Etna",
				//kind  : 'npc',
				//unique: true,
				return;
			}
			clearOutput();
			outputText("You reach the dock without any incident and board the small rowboat.  The water is calm and placid, perfect for rowing.  ");
			if (flags[kFLAGS.FACTORY_SHUTDOWN] == 2) {
				outputText("The water appears somewhat muddy and has a faint pungent odor.  ");
				if (player.inte > 40) outputText("You realize what it smells like – sex.  ");
			}
			//3% chance of finding lost daughters
			if (rand(100) <= 3 && flags[kFLAGS.IZMA_KIDS_IN_THE_WILD] > 0 && SceneLib.izmaScene.izmaFollower()) {
				SceneLib.izmaScene.findLostIzmaKids();
				//label : "Lost daughter",
				//kind  : 'event',
				//unique: true,
				return;
			}
			outputText("You set out, wondering if you'll find any strange islands or creatures in the lake.\n\n");
			//Marae
			if (rand(3) == 0 && flags[kFLAGS.MARAE_ISLAND] < 1 && !isNightTime) {
				marae.encounterMarae();
				//label : "Marae",
				//kind  : 'npc',
				//unique: true,
				return;
			}
			
			//BUILD LIST OF CHOICES
			var choice:Array = [0, 1, 2, 3, 4];
			if (player.hasKeyItem("Fishing Pole") >= 0) choice[choice.length] = 5;
			if (player.level >= 5 && flags[kFLAGS.KAIJU_DISABLED] == 0 && !player.hasStatusEffect(StatusEffects.VenusOff)) choice[choice.length] = 6; //moved kaiju here
			//MAKE YOUR CHOICE
			var selector:Number = choice[rand(choice.length)];
			//RUN CHOSEN EVENT
			switch (selector) {
				case 0:
					if (rand(2) == 0) outputText("You row for nearly an hour, until your arms practically burn with exhaustion from all the rowing.");
					else outputText("You give up on finding anything interesting, and decide to go check up on your camp.");
					//if (rand(2) == 0 && player.str < 100) {
					//	outputText("Despite the exaustion, you feel like you have become stronger.");
					//	dynStats("str", .5);
					//}
					//chance:  0.25,
					//label:'Walk',
					//kind:'walk'
					doNext(camp.returnToCampUseOneHour);
					return;
				case 1:
					sharkGirlScene.sharkGirlEncounter();
					//label : "Shark girl",
					//kind  : 'monster',
					return;
				case 2:
					flags[kFLAGS.ANEMONE_OR_SEA_ANEMONE] = 1;
					anemoneScene.mortalAnemoneeeeee();
					//label : "Anemone",
					//kind  : 'monster',
					return;
				case 3:
				case 4:
					if (flags[kFLAGS.FACTORY_SHUTDOWN] > 0 && player.level > 2 && player.hasStatusEffect(StatusEffects.FetishOn) && !isNightTime) {
					lake.fetishZealotScene.zealotBoat();
					//label : "Fetish Zealot",
					//kind  : 'monster',
					//night : false,
					}
					else {
					sharkGirlScene.sharkGirlEncounter();
					//label : "Shark girl",
					//kind  : 'monster',
					}
					return;
				case 5:
					outputText("This is a calm day at the lake, you managed to hold your boat in place and, while you found nothing of note, couldn’t help yourself but to enjoy a few hour using your newly acquired fishing pole. You even spotted Calu in the distance doing the same thing from her usual sitting spot.\n\n");
					outputText("<b>You got a fish!</b>");
					inventory.takeItem(consumables.FREFISH, camp.returnToCampUseOneHour);
					//label : "Fishing",
					//kind  : 'event',
					//unique: true,
					return;
				case 6:
					kaiju.kaijuMeeting();
					//label : "Venus",
					//kind  : 'npc',
					//unique: true,
					return;
			}
		}
	}
}
