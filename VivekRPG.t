/* Battle Simulator
 Programmed by Vivek George
 This program is a skeleton of an Role Playing Game
 */
var name, charClass, location, action : string
var LVL, ATT, MATT, DEF, MDEF, MHP, MMP, HP, MP, EVN, splCost : int % Character Stats (MHP/MMP = Max Health/Mana Points, splCost - Spell cost
var aCost, sCost, maCost, mdCost : int := 20 % Upgrade costs, doubles after each purchase
var enemyName : string % Enemy name
var EXP, gold, AP, SP, MAP, MDP, hPots, mPots : int := 0 %EXP, gold,upgrades and potions (A - Armor, S- Sharpens(ATT), MA - Magic Attack, MD - Magic Defence, health and mana potions
gold := 100
var EEXP, EATT, EMATT, EDEF, EMDEF, EHP, EMHP, EMP, EMMP, EEVN, which, esplCost, col : int % Enemy Stats, which monster, colour of name
var aMod, dMod, eaMod, edMod : real := 1 %Attack, defence mods of player and enemy
var bleed, ebleed : int := 0 % HP lost each turn (certain spells use this e.g. poison, rend etc)
var magMod, dmg : int %Magnitude of hit(LMH) and actual dmg
var leave := false %Set to true when player wishes to leave location
var spellName, status, estatus : string %name of character's spell(determined by class) as well as status effects (e.g. Burn)
var report, move : string := "" %Report is the overall report of the player's action(damage dealt etc). Move is the specific move used(e.g. heavy attack).
var reflect : boolean := false %Used in the Reflection spell, to cancel enemy's turn
var file : int %Save File, used when reading/writing to save file
var haveQuest : boolean := false %Whether or not a quest is activated
var qMonster, numKills, total, qEXP : int := 0 %Quest Variables: Total number kills needed, which monster to kill, EXP quest gives, number of kills
var safeguardOn, onslaughtOn, rageOn, poisonOn, hardenOn, rendOn, lowerguardOn, tormentOn, caltropsOn, fireOn : boolean %Whether or not to display status effects
var newSave : boolean := false %Determines whether or not to start a new save
%*****STORE PROCEDURES*****
proc buyhPot %Buying Health Potion
    if gold >= 5 then
	gold -= 5
	hPots += 1
    end if
end buyhPot
proc buymPot %Buying Mana Potion
    if gold >= 5 then
	gold -= 5
	mPots += 1
    end if
end buymPot
proc buyAP %Armor Points(Improve phys. defence)
    if gold >= aCost then
	gold -= aCost
	AP += 1
	aCost *= 2
    end if
end buyAP
proc buySP %Sharpen Points(Improve phys. attack)
    if gold >= sCost then
	gold -= sCost
	SP += 1
	sCost *= 2
    end if
end buySP
proc buyMAP %Magic Attack Points (Improve magic attack)
    if gold >= maCost then
	gold -= maCost
	MAP += 1
	maCost *= 2
    end if
end buyMAP
proc buyMDP %Magic Defence Points (Improve magic defence)
    if gold >= mdCost then
	gold -= mdCost
	MDP += 1
	mdCost *= 2
    end if
end buyMDP
proc usehPot %Use Health Potion
    if hPots > 0 then
	hPots -= 1
	if MHP - HP >= 15 then
	    HP += 15
	else
	    HP += (MHP - HP)
	end if
    end if
end usehPot
proc usemPot %Use Mana Potion
    if mPots > 0 then
	mPots -= 1
	if MMP - MP >= 15 then
	    MP += 15
	else
	    MP += (MMP - MP)
	end if
    end if
end usemPot
proc showInventory %Show inventory/stats, used in "Store" location
    colour (red)
    put "HP:", HP, "/", MHP
    colour (blue)
    put "MP:", MP, "/", MMP
    colour (black)
    put "LEVEL:", LVL
    put "EXP:", EXP
    put "EXP needed to level up:", (2 * (LVL + 1) ** 2 - 2)
    colour (43)
    put "Gold:", gold
    colour (brightred)
    put "Health Potions(HP):", hPots
    colour (brightblue)
    put "Mana Potions(MP):", mPots
    colour (24)
    put "Armor Improvements(A)-", aCost, "g:", AP
    colour (15)
    put "Weapon Sharpens(S)-", sCost, "g:", SP
    colour (54)
    put "Apply Defensive Runes(MD)-", mdCost, "g:", MDP
    colour (55)
    put "Practice Magic Attacks(MA)-", maCost, "g:", MAP
    colour (black)
end showInventory
proc showBattleInfo %Show potions, stats, status, used in "Battle" location
    colour (red)
    put "HP:", HP, "/", MHP
    colour (blue)
    put "MP:", MP, "/", MMP
    colour (brightred)
    put "Health Potions(HP):", hPots
    colour (brightblue)
    put "Mana Potions(MP):", mPots
    colour (black)
    put "Status Effects:", status, " - ", bleed, " health lost every turn"
    colour (col)
    put enemyName ..
    colour (black)
    put "'s HP:", EHP, "/", EMHP
    colour (col)
    put enemyName ..
    colour (black)
    put "'s MP:", EMP, "/", EMMP
    colour (col)
    put enemyName ..
    colour (black)
    put " Status Effects:", estatus, " - ", ebleed, " health lost every turn"
    put report
    put "\nAttack(L/M/H)\t", spellName, "\nUse Potion\tRun"
    put "Action: " ..
end showBattleInfo
%*****SPELLS*****
%Each Class has a unique spell, with its own damage formula and move string (e.g. blitz - "used Blitz, self-inflicting 10 damage")
proc blitz % Berzerker Spell
    if Rand.Int (1, 10) > 3 then %Spell has 60% chance of hitting
	dmg := (ceil (((MATT + ceil (MAP div 2)) * aMod) div ((EMDEF) * edMod)) + Rand.Int (4, 6)) * 3 %High damage
	HP -= 10 %Hurts player character
	move := "used Blitz, self-inflicting 10 damage"
    end if
end blitz
proc safeguard %Knight Spell
    dMod *= MATT %Knight's MATT stat is low, so this is fair
    move := "Safeguards himself, improving his defence"
    if safeguardOn = false then
	status += " Safeguard "
	safeguardOn := true %So "Safeguard" only appears on that status bar only once
    end if
end safeguard
proc onslaught %Warrior Spell
    aMod *= ceil (MATT div 2)
    move := "prepared an Onslaught,improving his attack"
    if onslaughtOn = false then
	status += " Powerful "
	onslaughtOn := true
    end if
end onslaught
proc caltrops
    if Rand.Int (1, 10) > 3 then
	EEVN -= 2
	eaMod *= .5
	edMod *= .5
	EHP -= 15 %Rogue has otherwise low stats, so this is fair
	move := "dropped caltrops, reducing the enemy's stats"
	if caltropsOn = false then
	    estatus += " Injured "
	    caltropsOn := true
	end if
    end if
end caltrops
proc fire     %Mage Spell
    if Rand.Int (1, 10) > 3 then
	dmg := ceil ((((MATT + ceil (MAP div 2)) * aMod) div (EMDEF * edMod)) + Rand.Int (0, 5) * 1.5)
	ebleed += 3 %Every turn, enemy loses this much health
	move := "casted a Fire Ball"
	if fireOn = false then
	    estatus += " Burn "
	    fireOn := true
	end if
    end if
end fire
proc lock     %Ranger Spell
    dmg := (ceil (((MATT + ceil (MAP div 2)) * aMod) div (EMDEF * edMod)) + Rand.Int (0, 5)) * 3 %100% to land heavy hit
    move := "locked on his enemy"
end lock
proc reflection     %Sorceror Spell
    reflect := true
    dmg := ceil (((((ATT + floor ((MATT + MAP) div 2)) * aMod) div (EMDEF * edMod)) + Rand.Int (1, 3)) * 1.5) %uses enemy ATT skill
    move := "reflected the enemy's attack"
end reflection
proc poison
    bleed += 1
    move := "poisoned its enemy"
    if poisonOn = false then
	status += " Poison "
	poisonOn := true
    end if
end poison
proc bash
    if Rand.Int (1, 10) > 3 then
	dmg := (ceil (((EMATT) * eaMod) + Rand.Int (1, 3) div ((MDEF) * dMod))) * 3
	move := "bashed his enemy"
    end if
end bash
proc restore
    if EMHP - EHP >= 15 then
	EHP += 15
	move := "restored 15 health"
    else %In case HP lost during battle is less than 15
	move := "restored " + intstr (EMHP - EHP) + " health"
	EHP += (EMHP - EHP)
    end if
end restore
proc harden
    edMod *= 1.5
    move := "hardens its shell"
    if hardenOn = false then
	estatus += " Reinforced "
	hardenOn := true
    end if
end harden
proc rage
    eaMod *= 1.5
    move := "enrages itself"
    if rageOn = false then
	estatus += " Enraged "
	rageOn := true
    end if
end rage
proc pulverize
    if Rand.Int (1, 10) > 9 then     % terrible accuracy. since the dmg is very high
	dmg := (ceil (((EMATT) * eaMod) div ((MDEF) * dMod)) + Rand.Int (3, 5)) * 5  %High damage
	move := "pulverized his enemy"
    end if
end pulverize
proc absorb
    dmg := (ceil (((EMATT) * eaMod) div ((MDEF) * dMod)) + Rand.Int (1, 3)) * 3
    if EMHP - EHP >= dmg then
	EHP += dmg
    else
	EHP += (EMHP - HP)
    end if
    move := "absorbed"
end absorb
proc lowerguard
    aMod *= .75
    dMod *= .75
    move := "lowered his enemy's guard"
    if lowerguardOn = false then
	status += " Unwary "
	lowerguardOn := true
    end if
end lowerguard
proc torment
    bleed += 3
    dmg := EMATT div MDEF
    move := "torments his enemy"
    if tormentOn = false then
	status += " Tormented "
	tormentOn := true
    end if
end torment
proc rend
    bleed += 5
    dmg := EMATT div MDEF
    move := "rends his enemy"
    if rendOn = false then
	status += " Hemorrhage  "
	rendOn := true
    end if
end rend
% *****BATTLE PROCEDURES*****
proc damage (magnitude : string)
    reflect := false
    if magnitude not= "pot" then
	move := "missed"     %By default, miss
    end if
    magMod := 0     %By default, no damage
    dmg := 0
    case (magnitude) of
	label 'L' :
	    if Rand.Int (1, 20) > EEVN then     %Hit Chance
		magMod := 1
		move := "used a light attack"
	    end if
	label 'M' :
	    if Rand.Int (1, 15) > EEVN then     %Hit Chance,
		magMod := 2
		move := "used a medium attack"
	    end if
	label "H" :
	    if Rand.Int (1, 10) > EEVN then     %Hit Chance
		magMod := 3
		move := "used a heavy attack"
	    end if
	label "Blitz" :
	    blitz

	label "Safeguard" :
	    safeguard
	label "Onslaught" :
	    onslaught
	label "Caltrops" :
	    caltrops
	label "fire ball" :
	    fire
	label "Lock On" :
	    lock
	label "Reflection" :
	    reflection
	label "Run" :
	    move := "failed to run away"
	label :
    end case
    if magnitude = 'L' or magnitude = 'M' or magnitude = 'H' then
	dmg := (ceil (((ATT + ceil (SP div 2)) * aMod) div (EDEF * edMod)) + Rand.Int (0, 2)) * magMod + ebleed
    end if
    EHP -= dmg
    if magnitude not= 'X' then
	report := name + " " + move + " and dealt " + intstr (dmg) + " damage."
    end if
    if EHP > 0 and reflect not= true then
	var eHit : int := Rand.Int (1, 4)
	magMod := 0

	move := "missed"

	case (eHit) of
	    label 1 :
		if Rand.Int (1, 20) > EVN then     %Hit Chance
		    magMod := 1
		    move := "used a light attack"
		end if
	    label 2 :
		if Rand.Int (1, 15) > EVN then     %Hit Chance
		    magMod := 2
		    move := "used a medium attack"
		end if
	    label 3 :
		if Rand.Int (1, 10) > EVN then     %Hit Chance
		    magMod := 3
		    move := "used a heavy attack"
		end if
	    label 4 :
		if EMP >= esplCost then
		    case (which) of     %Determines which spell to use depending on which enemy you're facing
			label 1 :
			    poison
			label 2 :
			    bash
			label 3 :
			    restore
			label 4 :
			    harden
			label 5 :
			    rage
			label 6 :
			    pulverize
			label 7 :
			    absorb
			label 8 :
			    lowerguard
			label 9 :
			    torment
			label 10 :
			    rend
		    end case
		end if
	end case
	dmg := (ceil ((EATT * eaMod) div ((DEF + ceil (AP div 2)) * dMod)) + Rand.Int (0, 2)) * magMod + bleed
	HP -= dmg
	report += "\n" + enemyName + " " + move + " and dealt " + intstr (dmg) + " damage."
    end if
end damage
proc lvlUp
    loop
	cls
	exit when EXP < 2 * (LVL + 1) ** 2 - 2
	HP := MHP
	MP := MMP
	put "LEVEL UP\n", LVL, " => ", LVL + 1
	put "ATT: ", ATT, "\nMATT: ", MATT, "\nDEF: ", DEF, "\nMDEF: ", MDEF, "\nHP: ", MHP, "\nMP: ", MMP, "\nChoose a stat to upgrade: " ..
	get action

	case (action) of
	    label "ATT", "att" :
		ATT += Rand.Int (1, 2)
		LVL += 1     % Only level up when a stat is raised
	    label "MATT", "matt" :
		MATT += Rand.Int (1, 2)
		LVL += 1
	    label "DEF", "def" :
		DEF += Rand.Int (1, 2)
		LVL += 1
	    label "MDEF", "mdef" :
		MDEF += Rand.Int (1, 2)
		LVL += 1
	    label "HP", "hp" :
		MHP += Rand.Int (10, 15)
		LVL += 1
	    label "MP", "mp" :
		MMP += Rand.Int (10, 15)
		LVL += 1
	    label :
	end case
    end loop
end lvlUp
proc getEnemy (fRange, cRange : int)     %floor value, ceiling value for possible monsters
    randint (which, fRange, cRange)
    case (which) of
	label 1 :
	    enemyName := "Spider"
	    EEXP := 1
	    EATT := 1
	    EMATT := 1
	    EDEF := 1
	    EMDEF := 1
	    EMHP := 20
	    EMMP := 5
	    EEVN := 1
	    col := black
	    esplCost := 5
	label 2 :
	    enemyName := "Goblin"
	    EEXP := 5
	    EATT := 5
	    EMATT := 3
	    EDEF := 2
	    EMDEF := 1
	    EMHP := 30
	    EMMP := 10
	    EEVN := 2
	    col := 48
	    esplCost := 5
	label 3 :
	    enemyName := "Goblin Shaman"
	    EEXP := 10
	    EATT := 3
	    EMATT := 5
	    EDEF := 2
	    EMDEF := 4
	    EMHP := 50
	    EMMP := 15
	    EEVN := 1
	    col := 2
	    esplCost := 5
	label 4 :
	    enemyName := "Giant Turtle"
	    EEXP := 20
	    EATT := 4
	    EMATT := 4
	    EDEF := 10
	    EMDEF := 8
	    EMHP := 100
	    EMMP := 30
	    EEVN := 1
	    col := grey
	    esplCost := 6
	label 5 :
	    enemyName := "Hobgoblin"
	    EEXP := 40
	    EATT := 7
	    EMATT := 7
	    EDEF := 6
	    EMDEF := 6
	    EMHP := 80
	    EMMP := 10
	    EEVN := 4
	    col := 42
	    esplCost := 5
	label 6 :
	    enemyName := "Cave Troll"
	    EEXP := 60
	    EATT := 9
	    EMATT := 4
	    EDEF := 7
	    EMDEF := 4
	    EMHP := 150
	    EMMP := 5
	    EEVN := 3
	    col := blue
	    esplCost := 5
	label 7 :
	    enemyName := "Reaper"
	    EEXP := 100
	    EATT := 10
	    EMATT := 11
	    EDEF := 6
	    EMDEF := 6
	    EMHP := 200
	    EMMP := 40
	    EEVN := 5
	    col := black
	    esplCost := 5
	label 8 :
	    enemyName := "Imp"
	    EEXP := 200
	    EATT := 11
	    EMATT := 12
	    EDEF := 8
	    EMDEF := 10
	    EMHP := 300
	    EMMP := 60
	    EEVN := 6
	    col := red
	    esplCost := 10
	label 9 :
	    enemyName := "Wraith"
	    EEXP := 400
	    EATT := 11
	    EMATT := 13
	    EDEF := 9
	    EMDEF := 11
	    EMHP := 400
	    EMMP := 60
	    EEVN := 7
	    col := red
	    esplCost := 10
	label 10 :
	    enemyName := "Archdemon"
	    EEXP := 10000
	    EATT := 15
	    EMATT := 15
	    EDEF := 15
	    EMDEF := 15
	    EMHP := 500
	    EMMP := 500
	    EEVN := 5
	    esplCost := 10
	    col := brightred
    end case
end getEnemy
%**Class Generation**

proc makeStats
    LVL := 1
    get charClass
    case (charClass) of
	label "Warrior", "warrior" :
	    randint (ATT, 7, 9)
	    randint (MATT, 2, 4)
	    randint (DEF, 6, 8)
	    randint (MDEF, 2, 4)
	    randint (EVN, 1, 3)
	    HP := 102 + Rand.Int (1, 20)
	    MP := 15 + Rand.Int (1, 30)
	    spellName := "Onslaught"
	    splCost := 3
	label "Knight", "knight" :
	    randint (ATT, 6, 8)
	    MATT := 2     % Lowest possible value that'll allow Safeguard to be useful
	    randint (DEF, 7, 9)
	    randint (MDEF, 2, 4)
	    randint (EVN, 1, 2)
	    HP := 100 + Rand.Int (1, 40)
	    MP := 0 + Rand.Int (1, 20)
	    spellName := "Safeguard"
	    splCost := 2
	label "Berzerker" :
	    randint (ATT, 7, 9)
	    randint (MATT, 7, 9)
	    randint (DEF, 3, 5)
	    randint (MDEF, 1, 3)
	    randint (EVN, 1, 2)
	    HP := 80 + Rand.Int (1, 25)
	    MP := 25 + Rand.Int (1, 27)
	    spellName := "Blitz"
	    splCost := 4
	label "Mage", "mage" :
	    randint (ATT, 2, 4)
	    randint (MATT, 6, 8)
	    randint (DEF, 3, 5)
	    randint (MDEF, 7, 9)
	    randint (EVN, 1, 5)
	    HP := 60 + Rand.Int (1, 25)
	    MP := 50 + Rand.Int (1, 22)
	    spellName := "Reflection"
	    splCost := 5
	label "Sorceror", "sorceror" :
	    randint (ATT, 1, 3)
	    randint (MATT, 8, 10)
	    randint (DEF, 1, 2)
	    randint (MDEF, 6, 8)
	    randint (EVN, 1, 5)
	    HP := 55 + Rand.Int (1, 25)
	    MP := 50 + Rand.Int (1, 35)
	    spellName := "Fire Ball"
	    splCost := 5
	label "Ranger", "ranger" :
	    randint (ATT, 7, 9)
	    randint (MATT, 4, 6)
	    randint (DEF, 3, 5)
	    randint (MDEF, 2, 5)
	    randint (EVN, 1, 7)
	    HP := 55 + Rand.Int (1, 25)
	    MP := 45 + Rand.Int (1, 25)
	    MHP := 55 + Rand.Int (1, 25)
	    MMP := 45 + Rand.Int (1, 25)
	    spellName := "Lock On"
	    splCost := 4
	label "Rogue", "rogue" :
	    randint (ATT, 5, 7)
	    randint (MATT, 5, 7)
	    randint (DEF, 2, 4)
	    randint (MDEF, 3, 5)
	    randint (EVN, 1, 10)
	    HP := 45 + Rand.Int (1, 25)
	    MP := 55 + Rand.Int (1, 15)
	    spellName := "Caltrops"
	    splCost := 7
	label :
	    put "Unavailable class. Retry: " ..
	    makeStats
    end case
    MHP := HP
    MMP := MP
end makeStats
proc showStats
    cls
    put name, "'s Stats:"
    put "LVL:", LVL, "\nATT:", ATT, "\nMATT:", MATT, "\nDEF:", DEF, "\nMDEF:", MDEF, "\nHP:", MHP, "\nMP:", MMP, "\n"
    Input.Pause
end showStats
proc charCreate
    cls
    put "Hello, enter your name: " ..
    get name
    put "Hello, ", name,
	".\nWarrior - Balanced\nKnight - Defensive\nBerzerker - Offensive\nMage - Balanced Magic\nSorceror - Offensive Magic\nRanger - Fragile, Hard to Hit\nRogue - Weakest, Hardest to Hit\nEnter your class:"
	..
    makeStats
    showStats
end charCreate
%Location Methods
forward proc default
proc quest
    if haveQuest = false then
	cls
	put "Hello, ", name, ". Would you be interested in a quest(Y/N): " ..
	get action
	case (action) of
	    label 'Y', 'y', "Yes", "yes" :
		loop

		    randint (total, 2, 10)
		    getEnemy (1, Rand.Int (1, LVL))
		    qMonster := which
		    qEXP := EEXP * total + 20
		    put "How about ", total, " ", enemyName, "s: " ..
		    get action
		    case (action) of
			label 'Y', 'y', "Yes", "yes" :
			    haveQuest := true
			label 'N', 'n', "No", "no" :
			    cls
			    put "Hmmm. Alright. " ..
			label :
			    cls
			    put "I don't understand. " ..
		    end case
		    exit when haveQuest = true
		end loop
	    label 'N', 'n', "No", "no" :
		put "Alright. Come again if you're interested!"
		Input.Pause
	end case
    elsif numKills < total then
	cls
	getEnemy (qMonster, qMonster)     %To retrieve the monster's name
	put "Progress: ", numKills, " of the ", total, " ", enemyName, "s killed.\nReward EXP:", qEXP
	Input.Pause
	lvlUp
    elsif numKills >= total then
	numKills := 0
	total := 0
	qMonster := 0
	haveQuest := false
	cls
	put "You have completed your quest!\nRewards:\nEXP: ", qEXP
	EXP += qEXP
	Input.Pause
    end if
end quest
proc battle (fRange, cRange : int)
    leave := false
    report := ""     %Clearing any left over battle data
    status := ""
    safeguardOn := false
    onslaughtOn := false
    rageOn := false
    poisonOn := false
    hardenOn := false
    rendOn := false
    lowerguardOn := false
    tormentOn := false
    caltropsOn := false
    fireOn := false
    estatus := ""
    getEnemy (fRange, cRange)
    EHP := EMHP
    EMP := EMMP
    loop
	cls
	showBattleInfo
	get action
	case (action) of
	    label "l", "L", "light", "Light" :
		damage ('L')
	    label "m", "M", "medium", "Medium" :
		damage ('M')
	    label "h", "H", "heavy", "Heavy" :
		damage ('H')
	    label "use hp", "use HP", "hp", "HP" :
		if hPots > 0 then
		    usehPot
		    move := "used a health potion,restoring 15 health"
		    damage ("pot")     %No user LMH hit
		end if
	    label "use mp", "Use MP", "mp", "MP" :
		if mPots > 0 then
		    usemPot
		    move := "used a mana potion and restored 15 mana"
		    damage ("pot")
		end if
	    label "run", "Run" :
		if Rand.Int (1, 10) >= 5 then
		    leave := true
		else
		    damage ("Run")
		end if
	    label :
	end case
	if action = spellName or action = spellName (1) or action = chr (ord (spellName (1)) + 32) and (MP - splCost) >= 0 then
	    MP -= splCost
	    damage (spellName);
	end if
	exit when EHP <= 0 or HP <= 0 or leave = true
    end loop
    aMod := 1
    dMod := 1
    eaMod := 1
    edMod := 1
    bleed := 0
    ebleed := 0
    cls
    if EHP <= 0 then
	if which = qMonster then
	    numKills += 1
	end if
	EHP := 0
	EXP += EEXP
	showBattleInfo
	colour (green)
	put "You won!"
	colour (black)
	Input.Pause
	lvlUp
	gold += 5 + which * Rand.Int (1, which)
    elsif HP <= 0 then
	HP := 0
	showBattleInfo
	put "You ran away and dropped ", (gold div 2), "g!"
	gold div= 2
	Input.Pause
	HP := MHP div 2
    end if
end battle
proc shop
    leave := false
    loop
	cls
	showInventory
	put "\nPotions-5g\nEnter \"use hp\" to use health potion\nEnter \"use mp\" to use mana potion\nEnter \"leave\" to exit\nWhat would you like to buy:"
	    ..
	get action : *
	case (action) of
	    label "hp", "HP" :
		buyhPot
	    label "mp", "MP" :
		buymPot
	    label 's', 'S' :
		buySP
	    label 'a', 'A' :
		buyAP
	    label "ma", "MA" :
		buyMAP
	    label "md", "MD" :
		buyMDP
	    label "use hp", "use HP" :
		usehPot
	    label "use mp", "use MP" :
		usemPot
	    label "leave", "Leave" :
		leave := true
	    label :
	end case
	exit when leave
    end loop
end shop
body proc default
    loop
	cls
	put "Locations:"
	colour (113)
	put "Shop"
	colour (120)
	put "Forest - Low Level"
	colour (52)
	put "Mountains - Mid Level"
	colour (12)
	put "Oblivion - High Level"
	colour (black)
	put "Beyond - Final Boss\nStats\nSave\nDelete(Start Over)\nQuit\nQuest Giver\nWhere would you like to go:" ..
	get location
	case (location) of
	    label "shop", "Shop", 's', 'S' :
		shop
	    label "forest", "Forest", 'f', 'F' :
		battle (1, 3)
	    label "mountains", "Mountains", 'm', 'M' :
		battle (4, 6)
	    label "oblivion", "Oblivion", 'o', 'O' :
		battle (7, 9)
	    label "beyond", "Beyond", 'b', 'B' :
		battle (10, 10)
	    label "Stats", "stats" :
		showStats
	    label "quest giver", "Quest Giver", "Quest", "quest", 'q', 'Q' :
		quest
	    label "save", "Save" :
		open : file, "VivekRPGSave.txt", put
		put : file, name
		put : file, LVL
		put : file, EXP
		put : file, gold
		put : file, hPots
		put : file, mPots
		put : file, ATT
		put : file, spellName
		put : file, splCost
		put : file, DEF
		put : file, MATT
		put : file, MDEF
		put : file, MHP
		put : file, MMP
		put : file, HP
		put : file, MP
		put : file, AP
		put : file, SP
		put : file, MAP
		put : file, MDP
		put : file, EVN
		put : file, haveQuest
		put : file, qMonster
		put : file, numKills
		put : file, total
		put : file, qEXP
		close : file
	    label "Delete", "delete" :
		if File.Exists ("VivekRPGSave.txt") then
		    File.Delete ("VivekRPGSave.txt")
		end if
		charCreate
	    label "quit", "Quit" :
		return
	    label :
		put "Invalid Input:" ..
		Input.Pause
	end case
    end loop
end default
%ACTUAL PROGRAM
put "Welcome to  Generic RPG.\nBy Vivek\nPress anything to continue:" ..
Input.Pause
cls
if File.Exists ("VivekRPGSave.txt") then
    open : file, "VivekRPGSave.txt", get
    get : file, name
    get : file, LVL
    get : file, EXP
    get : file, gold
    get : file, hPots
    get : file, mPots
    get : file, ATT
    get : file, spellName
    get : file, splCost
    get : file, DEF
    get : file, MATT
    get : file, MDEF
    get : file, MHP
    get : file, MMP
    get : file, HP
    get : file, MP
    get : file, AP
    get : file, SP
    get : file, MAP
    get : file, MDP
    get : file, EVN
    get : file, haveQuest
    get : file, qMonster
    get : file, numKills
    get : file, total
    get : file, qEXP
    close : file
else
    charCreate
end if
showStats
default
