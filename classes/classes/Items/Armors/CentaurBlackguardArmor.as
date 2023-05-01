package classes.Items.Armors
{
	import classes.Items.Armor;
	import classes.Scenes.NPCs.CelessScene;
	/**
	 * ...
	 * @author Liadri
	 */
	public class CentaurBlackguardArmor extends Armor
	{
		
		public function CentaurBlackguardArmor()
		{
			super("TaurBAr","Taur B. Armor","some taur blackguard armor","a set of taur blackguard armor",40,20,1698,"A suit of blackguard's armor for centaurs.","Heavy")
		}
		override public function canEquip(doOutput:Boolean):Boolean {
			if (game.player.isTaur() && game.player.level >= 54) return super.canEquip(doOutput)
			if (doOutput) {
				if (game.player.level >= 54) outputText("You try and wear the legendary armor but to your disapointment the item simply refuse to stay on your body. It would seem you yet lack the power and right to wield this item.");
				else outputText("The blackguard's armor is designed for centaurs, so it doesn't really fit you. You place the armor back in your inventory");
			}
			return false;
		}
		
		override public function equipText():void{
			outputText(CelessScene.instance.Name+" helps you put on the barding and horseshoes. Wow, taking a look at yourself, you think your intimidating appearance alone will scare the hell out of most opponents.");
		}
		
		override public function unequipText():void{
			outputText(CelessScene.instance.Name+ "help you remove the centaur armor. Whoa you forgot what carrying light weight was.");
		}
		
		override public function get def():Number{
			var mod:int = game.player.cor/5;
			return 20 + mod;
		}
		override public function get mdef():Number{
			var mod:int = game.player.cor/10;
			return 10 + mod;
		}
	}

}
