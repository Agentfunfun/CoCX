package classes.Items.Weapons
{
	import classes.Items.Weapon;
	import classes.PerkLib;
	/**
	 * ...
	 * @author Oxdeception
	 */
	public class LifehuntScythe extends Weapon
	{
		
		public function LifehuntScythe()
		{
			super("LifScyt", "L.Scythe", "lifehunt scythe", "a lifehunt scythe", "slash", 90, 14400,
					"This enchanted scythe is made of a white metal, and its surface is decorated with ruby gemstones and silver engravings depicting dragons. It seems to drink in the opponents blood use it to heal its user’s wounds.",
					"Large, Whirlwind, Bleed25", "Scythe, StaffPart"
			);
			withBuff('spellpower', +1.0);
		}
		
		override public function get attack():Number {
			var boost:int = 0;
			var scal:Number = 20;
			if (game.player.str >= 100) {
				boost += 20;
				scal -= 5;
			}
			if (game.player.str >= 50) {
				boost += 20;
				scal -= 5;
			}
			boost += Math.round((100 - game.player.cor) / scal);
			return (40 + boost);
		}
		override public function canEquip(doOutput:Boolean):Boolean {
			if (game.player.level >= 54) return super.canEquip(doOutput);
			if(doOutput) outputText("You try and wield the legendary weapon but to your disapointment the item simply refuse to stay in your hands. It would seem you yet lack the power and right to wield this item.");
			return false;
		}
	}

}
