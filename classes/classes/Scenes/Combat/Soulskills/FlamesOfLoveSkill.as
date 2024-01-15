package classes.Scenes.Combat.Soulskills {
import classes.Scenes.Combat.AbstractSoulSkill;
import classes.StatusEffects;
import classes.Monster;
import classes.Scenes.Combat.Combat;
import classes.internals.SaveableState;
import classes.PerkLib;

public class FlamesOfLoveSkill extends AbstractSoulSkill implements SaveableState {
	private var uses:int = 0;
	private var skillIcon:String = "I_FOLBMAN";
    public function FlamesOfLoveSkill() {
        super(
            "Flames of Love",
            "Enfuse your magic with your burning lust, transfering it to your enemy as a barrage of flames.",
            TARGET_ENEMY,
            TIMING_INSTANT,
            [TAG_DAMAGING, TAG_FIRE, TAG_RECOVERY, TAG_MAGICAL],
            StatusEffects.KnowsFlamesOfLove
        )
		lastAttackType = Combat.LAST_ATTACK_SPELL;
		baseSFCost = 100;
    }

	public function loadFromObject(o:Object, ignoreErrors:Boolean):void
    {
    	if (o) {
			uses = o["uses"];
		} else {
			resetState();
		}
    }

	public function saveToObject():Object
    {
    	return {
			"uses": uses 
		}
    }

    public function stateObjectName():String
    {
    	return "FlamesOfLove";
    }

    public function resetState():void
    {
    	uses = 0;
    }

	override protected function usabilityCheck():String {
        var uc:String =  super.usabilityCheck();
        if (uc) return uc;

        if (player.lust < 50) {
			return "Your current lust is too low.";
		}

        return "";
    }

	override public function describeEffectVs(target:Monster):String {
		var lustRestore: Number = calcLustRestore();
		return "~" + numberFormat(calcDamage(target, lustRestore)) + " fire damage, restores ~" + numberFormat(lustRestore) + " lust";
	}

	override public function get description():String {
		var desc:String = super.description;
		var currentLevel:int = player.statusEffectv1(knownCondition);

		switch (currentLevel) {
			case 1: desc += "\nRank: Rankless";
					break;
			case 2: desc += "Effective against groups.\nRank: Low Rank";
					break;
			case 3: desc += "Highly effective against groups.\nRank: High Rank";
					break;
		}

		return desc;
	} 

	override public function presentTags():Array {
        var result:Array = super.presentTags();
        var currentLevel:int = player.statusEffectv1(knownCondition);
        if (currentLevel > 1) result.push(TAG_AOE);

        return result;
    }

    override public function hasTag(tag:int):Boolean {
		var currentLevel:int = player.statusEffectv1(knownCondition);
        return super.hasTag(tag) || (currentLevel > 1 && (tag == TAG_AOE));
    }

	override public function calcCooldown():int {
		return  Math.round(player.statusEffectv1(StatusEffects.KnowsFlamesOfLove));
	}

	override public function sfCost():int {
		var currentLevel:int = player.statusEffectv1(knownCondition);
		var cost:int = baseSFCost;

		cost *= Math.pow(2, currentLevel - 1);

		cost *= soulskillCost() * soulskillcostmulti();
		return Math.round(cost);
	}

	private function calcLustRestore():Number {
		var restoreAmount:Number = 0;
		var restoreMult:Number = Math.pow(2, player.statusEffectv1(StatusEffects.KnowsFlamesOfLove) - 1);
		restoreAmount += Math.round(player.lust * (restoreMult * 0.1));
		return restoreAmount;
	}

	public function calcDamage(monster:Monster, baseDamage: Number):Number {
		var currentLevel:int = player.statusEffectv1(knownCondition);
		var damage:Number = baseDamage * (5 * currentLevel);

		if (currentLevel > 1) {
			damage += scalingBonusWisdom() * 0.5;

			damage *= soulskillMagicalMod();
		}
		
		//group enemies bonus
		if (monster && monster.plural) {
			if (currentLevel > 2) {
				damage *= 5;
			} else if (currentLevel > 1) {
				damage *= 2;
			}
		}

		damage *= combat.fireDamageBoostedByDao();
		return Math.round(damage);
	}

    override public function doEffect(display:Boolean = true):void {
		var lustRestore:Number = calcLustRestore();
		player.lust -= lustRestore;

		var damage:Number = calcDamage(monster, lustRestore);

		if (display) {
			outputText("You concentrate on the lust flowing in your body, your veins heating up rapidly. With every beat of your heart, the heat rises, the heat in your groin transfering to the palm of your hands. \n\n");
			outputText("With almost orgasmic joy, you send a wave of flames toward [themonster]. ");
		}
		doFireDamage(damage, true, display);
		if (display) outputText("\n\n");
		levelUpCheck(true, display);
    }

    private function levelUpCheck(increment:Boolean = true, display:Boolean = true):void {
		var currentLevel:int = player.statusEffectv1(knownCondition);
		var nextLevelUp:int = (currentLevel == 2)? 20: 5;
		var maxLevel:int = 3;
		if (currentLevel <= 0 || currentLevel >= maxLevel) return;

		if (increment && uses < nextLevelUp) uses++;

		if (isFinite(nextLevelUp)) {
            notificationView.popupProgressBar2(skillIcon,skillIcon,
                    name + " Mastery", (uses-1)/nextLevelUp, uses/nextLevelUp);
        }

		if (currentLevel == 1 && uses >= nextLevelUp && player.hasPerk(PerkLib.SoulApprentice)) {
			if (display) {
				outputText("Your skill at using the \"" + name + "\" soulskill has progressed!\n");
				outputText("<b>\"" + name + " rank has increased from (Rankless) to (Low Rank)!</b>\n\n");
			}
			player.changeStatusValue(knownCondition, 1, 2);
			uses = 0;
		}

		if (currentLevel == 2 && uses >= nextLevelUp && player.hasPerk(PerkLib.SoulScholar)) {
			if (display) {
				outputText("Your skill at using the \"" + name + "\" soulskill has progressed!\n");
				outputText("<b>\"" + name + " rank has increased from (Low Rank) to (High Rank)!</b>\n\n");
			}
			player.changeStatusValue(knownCondition, 1, 3);
			uses = 0;
		}
	}
}
}