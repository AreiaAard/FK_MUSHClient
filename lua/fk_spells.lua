require("commas")



--------------------------------------------------
-- Spell Class
--------------------------------------------------

Spell = {}
Spell.aliasFlags = alias_flag.Enabled + alias_flag.RegularExpression
    + alias_flag.IgnoreAliasCase


function Spell:new(obj)
    obj = obj or {}
    if (not obj.name) then
        error("No spell name given.", 2)
    end
    if not (obj.incantation or obj.phrase) then
        error("No spell match pattern given.", 2)
    end

    setmetatable(obj, self)
    self.__index = self

    obj.id = GetUniqueID()
    obj.aliasName = self:_format_alias_name(obj.name, obj.id)
    obj.aliasMatch = obj.incantation or self:_format_alias_match(obj.phrase)
    obj.response = obj.response or self:_format_alias_response(obj.name)
    obj.response = trim(obj.response)
    return obj
end


function Spell:_format_alias_name(name, id)
    name = name:lower():gsub("%s+", "")
    return string.format("alias_cast_%s_%s", name, id)
end


function Spell:_format_alias_match(phrase)
    return string.format("^%s(?<args> +.*)?$", phrase)
end


function Spell:_format_alias_response(name)
    -- '%%<args>' is intentional. Prevents string.format from trying
    -- to replace it here and rather allows the wildcard to be handled
    -- properly at alias runtime.
    local response = [[
        local cmd = "cast '%s'"
        local args = trim("%%<args>")
        if (args ~= "") then
            cmd = cmd .. " " .. args
        end
        Send(cmd)
    ]]
    return response:format(name)
end


function Spell:read()
    local code = AddAlias(
        self.aliasName, self.aliasMatch, self.response, self.aliasFlags
    )
    if (code ~= error_code.eOK) then
        local msg = "Failed to add alias %s:\n    %s."
        print(msg:format(self.aliasName, error_desc[code]))
    else
        SetAliasOption(self.aliasName, "send_to", sendto.script)
        SetAliasOption(self.aliasName, "group", "aliasg_cast_spell")
    end
    return code
end


function Spell:forget()
    local code = DeleteAlias(self.aliasName)
    if (code ~= error_code.eOK) then
        local msg = "Failed to remove alias %s:\n    %s."
        print(msg:format(self.aliasName, error_desc[code]))
    end
    return code
end


function Spell:is_available()
    return GetAliasOption(self.aliasName, "enabled") == 1
end



--------------------------------------------------
-- Spellbook Class
--------------------------------------------------

Spellbook = {}


function Spellbook:new(spells)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.index = spells or {}
    obj.isOpen = false
    return obj
end


function Spellbook:open()
    self:check_close()
    for _, spell in ipairs(self.index) do
        spell:read()
    end
    self.isOpen = true
end


function Spellbook:close()
    for _, spell in ipairs(self.index) do
        spell:forget()
    end
    self.isOpen = false
end


function Spellbook:check_close()
    if (self.isOpen) then
        self:close()
    end
end


function Spellbook:add(spell)
    self:check_close()
    if (getmetatable(spell) ~= Spell) then
        error("Only spells can be added to a spellbook.", 2)
    end
    local alreadyKnown = false
    for _, knownSpell in ipairs(self.index) do
        if (spell == knownSpell) then
            alreadyKnown = true
        end
    end
    if (not alreadyKnown) then
        table.insert(self.index, spell)
        table.sort(self.index, function(e1, e2) return e1.name < e2.name end)
    end
end


function Spellbook:remove(spell)
    self:check_close()
    if (getmetatable(spell) ~= Spell) then
        error("Only spells can be removed from a spellbook.", 2)
    end
    for i, knownSpell in ipairs(self.index) do
        if (spell == knownSpell) then
            table.remove(self.index, i)
        end
    end
end


function Spellbook:print()
    for _, spell in ipairs(self.index) do
        local msg = "%s (%s)"
        local available = spell:is_available() and "y" or "n"
        print(msg:format(spell.name, available))
    end
end



--------------------------------------------------
-- Master Spell List
--------------------------------------------------

spells = {}


spells.ACID_ARROW = Spell:new{name="acid arrow", phrase="aca"}
spells.ACID_BLAST = Spell:new{name="acid blast", phrase="acb"}
spells.ACID_FOG = Spell:new{name="acid fog", phrase="acf"}
spells.ACID_SPLASH = Spell:new{name="acid splash", phrase="acs"}
spells.ACIDSHIELD = Spell:new{name="acidshield", phrase="acshi"}
spells.AIR_WALK = Spell:new{name="air walk", phrase="air"}
spells.ALERTNESS = Spell:new{name="alertness", phrase="alert"}
spells.ANIMAL_GROWTH = Spell:new{name="animal growth", phrase="enlan"}
spells.ANIMATE_DEAD = Spell:new{name="animate dead", phrase="anim"}
spells.ANIMATE_OBJECT = Spell:new{name="animate object", phrase="animo"}
spells.ANTIMAGIC_SHELL = Spell:new{name="antimagic shell", phrase="amag"}
spells.ARCANE_EYE = Spell:new{name="arcane eye", phrase="eye"}
spells.ARMOR = Spell:new{name="armor", phrase="arm"}
spells.ARMOR_OF_DARKNESS = Spell:new{name="armor of darkness", phrase="darm"}
spells.ASTRAL_WALK = Spell:new{name="astral walk", phrase="astrwalk"}
spells.AURA_OF_VITALITY = Spell:new{name="aura of vitality", phrase="aura"}

spells.BANE = Spell:new{name="bane", phrase="bane"}
spells.BANISHMENT = Spell:new{name="banishment", phrase="ban"}
spells.BARKSKIN = Spell:new{name="barkskin", phrase="bs"}
spells.BEARS_ENDURANCE = Spell:new{name="bears endurance", phrase="con"}
spells.BLACK_TENTACLES = Spell:new{name="black tentacles", phrase="tent"}
spells.BLASPHEMY = Spell:new{name="blasphemy", phrase="evmaj"}
spells.BLAZEBANE = Spell:new{name="blazebane", phrase="fiv"}
spells.BLESS = Spell:new{name="bless", phrase="ble"}
spells.BLESS_WATER = Spell:new{name="bless water", phrase="blewat"}
spells.BLINDNESS = Spell:new{name="blindness", phrase="bl"}
spells.BOLT_OF_GLORY = Spell:new{name="bolt of glory", phrase="glory"}
spells.BREAK_ENCHANTMENT = Spell:new{name="break enchantment", phrase="bren"}
spells.BULLS_STRENGTH = Spell:new{name="bulls strength", phrase="str"}
spells.BURNING_HANDS = Spell:new{name="burning hands", phrase="fih"}
spells.BURROW = Spell:new{name="burrow", phrase="bur"}

spells.CALL_LIGHTNING = Spell:new{name="call lightning", phrase="ell"}
spells.CALL_LIGHTNING_STORM = Spell:new{name="call lightning storm", phrase="els"}
spells.CATS_GRACE = Spell:new{name="cats grace", phrase="dex"}
spells.CAUSE_CRITICAL = Spell:new{name="cause critical", phrase="cac"}
spells.CAUSE_LIGHT = Spell:new{name="cause light", phrase="cal"}
spells.CAUSE_MINOR = Spell:new{name="cause minor", phrase="cami"}
spells.CAUSE_MODERATE = Spell:new{name="cause moderate", phrase="cam"}
spells.CAUSE_SERIOUS = Spell:new{name="cause serious", phrase="cas"}
spells.CHAIN_LIGHTNING = Spell:new{name="chain lightning", phrase="elc"}
spells.CHAOS_HAMMER = Spell:new{name="chaos hammer", phrase="chmin"}
spells.CHARGED_BEACON = Spell:new{name="charged beacon", phrase="elv"}
spells.CHARIOT_OF_THE_SUN = Spell:new{name="chariot of the sun", phrase="sunch"}
spells.CHARM_ANIMAL = Spell:new{name="charm animal", phrase="charma"}
spells.CHARM_PERSON = Spell:new{name="charm person", phrase="charmp"}
spells.CHARM_MONSTER = Spell:new{name="charm monster", phrase="charmm"}
spells.CHILL_TOUCH = Spell:new{name="chill touch", phrase="ict"}
spells.CIRCLE_OF_DEATH = Spell:new{name="circle of death", phrase="cird"}
spells.CLAIRVOYANCE = Spell:new{name="clairvoyance", phrase="clair"}
spells.COLOR_SPRAY = Spell:new{name="color spray", phrase="col"}
spells.COMPREHEND_LANGUAGES = Spell:new{name="comprehend languages", phrase="comp"}
spells.CONE_OF_COLD = Spell:new{name="cone of cold", phrase="icc"}
spells.CONFUSION = Spell:new{name="confusion", phrase="conf"}
spells.CONJURE_ELEMENTAL = Spell:new{name="conjure elemental", phrase="conjele"}
spells.CONJURE_GREATER_ELEMENTAL = Spell:new{name="conjure greater elemental", phrase="gconjele"}
spells.CONTINUAL_LIGHT = Spell:new{name="continual light", phrase="clig"}
spells.CONTROL_UNDEAD = Spell:new{name="control undead", phrase="charmund"}
spells.CONTROL_WEATHER = Spell:new{name="control weather", phrase="controlweat"}
spells.CREATE_FOOD = Spell:new{name="create food", phrase="crefood"}
spells.CREATE_SPRING = Spell:new{name="create spring", phrase="crespr"}
spells.CREATE_WATER = Spell:new{name="create water", phrase="crewat"}
spells.CRUSHING_DESPAIR = Spell:new{name="crushing despair", phrase="crush"}
spells.CURE_BLINDNESS = Spell:new{name="cure blindness", phrase="cub"}
spells.CURE_CRITICAL = Spell:new{name="cure critical", phrase="cuc"}
spells.CURE_DISEASE = Spell:new{name="cure disease", phrase="cud"}
spells.CURE_LIGHT = Spell:new{name="cure light", phrase="cul"}
spells.CURE_MINOR = Spell:new{name="cure minor", phrase="cumi"}
spells.CURE_MODERATE = Spell:new{name="cure moderate", phrase="cum"}
spells.CURE_SERIOUS = Spell:new{name="cure serious", phrase="cus"}
spells.CURSE = Spell:new{name="curse", phrase="cur"}

spells.DARKVISION = Spell:new{name="darkvision", phrase="dvis"}
spells.DAZE = Spell:new{name="daze", phrase="daze"}
spells.DAZE_MONSTER = Spell:new{name="daze monster", phrase="dazm"}
spells.DEATH_WARD = Spell:new{name="death ward", phrase="dw"}
spells.DEEP_SLUMBER = Spell:new{name="deep slumber", phrase="dsleep"}
spells.DELAYED_BLAST_FIREBALL = Spell:new{name="delayed blast fireball", phrase="fid"}
spells.DESTRUCTION = Spell:new{name="destruction", phrase="dest"}
spells.DETECT_BURIED = Spell:new{name="detect buried", phrase="detb"}
spells.DETECT_CHAOS = Spell:new{name="detect chaos", phrase="detc"}
spells.DETECT_EVIL = Spell:new{name="detect evil", phrase="dete"}
spells.DETECT_GOOD = Spell:new{name="detect good", phrase="detg"}
spells.DETECT_HIDDEN = Spell:new{name="detect hidden", phrase="deth"}
spells.DETECT_INVIS = Spell:new{name="detect invis", phrase="deti"}
spells.DETECT_LAW = Spell:new{name="detect law", phrase="detl"}
spells.DETECT_MAGIC = Spell:new{name="detect magic", phrase="detm"}
spells.DETECT_POISON = Spell:new{name="detect poison", phrase="detp"}
spells.DICTUM = Spell:new{name="dictum", phrase="lamaj"}
spells.DIMENSIONAL_ANCHOR = Spell:new{name="dimensional anchor", phrase="anchor"}
spells.DISEASE = Spell:new{name="disease", phrase="dis"}
spells.DISINTEGRATE = Spell:new{name="disintegrate", phrase="dint"}
spells.DISMISSAL = Spell:new{name="dismissal", phrase="dism"}
spells.DISPEL_EVIL = Spell:new{name="dispel evil", phrase="de"}
spells.DISPEL_MAGIC = Spell:new{name="dispel magic", phrase="dm"}
spells.DISRUPT_UNDEAD = Spell:new{name="disrupt undead", phrase="disr"}
spells.DIVINE_FAVOR = Spell:new{name="divine favor", phrase="fav"}
spells.DIVINE_POWER = Spell:new{name="divine power", phrase="dpow"}
spells.DOMINATE_ANIMAL = Spell:new{name="dominate animal", phrase="doman"}
spells.DOMINATE_MONSTER = Spell:new{name="dominate monster", phrase="dommon"}
spells.DOMINATE_PERSON = Spell:new{name="dominate person", phrase="domper"}
spells.DROWN = Spell:new{name="drown", phrase="drown"}

spells.EAGLES_SPLENDOR = Spell:new{name="eagles splendor", phrase="cha"}
spells.EARTHQUAKE = Spell:new{name="earthquake", phrase="eaq"}
spells.EARTH_REAVER = Spell:new{name="earth reaver", phrase="ear"}
spells.ENERGY_DRAIN = Spell:new{name="energy drain", phrase="drain"}
spells.ENERVATION = Spell:new{name="enervation", phrase="ener"}
spells.ENLARGE_PERSON = Spell:new{name="enlarge person", phrase="enlper"}
spells.ENTANGLE = Spell:new{name="entangle", phrase="tang"}
spells.ETHEREAL_FLYER = Spell:new{name="ethereal flyer", phrase="efly"}

spells.FAERIE_FIRE = Spell:new{name="faerie fire", phrase="ffire"}
spells.FAERIE_FOG = Spell:new{name="faerie fog", phrase="ffog"}
spells.FAITHFUL_HOUND = Spell:new{name="faithful hound", phrase="hound"}
spells.FAMISH = Spell:new{name="famish", phrase="fam"}
spells.FARHEAL = Spell:new{name="farheal", phrase="hef"}
spells.FATIGUE = Spell:new{name="fatigue", phrase="fat"}
spells.FEAR = Spell:new{name="fear", phrase="fear"}
spells.FEEBLEMIND = Spell:new{name="feeblemind", phrase="feeb"}
spells.FIND_THE_PATH = Spell:new{name="find the path", phrase="findpath"}
spells.FIND_TRAPS = Spell:new{name="find traps", phrase="findtrap"}
spells.FINGER_OF_DEATH = Spell:new{name="finger of death", phrase="fing"}
spells.FIREBALL = Spell:new{name="fireball", phrase="fib"}
spells.FIRESHIELD = Spell:new{name="fireshield", phrase="fishi"}
spells.FIRESTORM = Spell:new{name="firestorm", phrase="fis"}
spells.FLAME_ARROW = Spell:new{name="flame arrow", phrase="fia"}
spells.FLAME_BLADE = Spell:new{name="flame blade", phrase="fiblade"}
spells.FLAMESTRIKE = Spell:new{name="flamestrike", phrase="fist"}
spells.FLARE = Spell:new{name="flare", phrase="flare"}
spells.FLENSING = Spell:new{name="flensing", phrase="flen"}
spells.FLOATING_DISC = Spell:new{name="floating disc", phrase="disc"}
spells.FLY = Spell:new{name="fly", phrase="fly"}
spells.FOXS_CUNNING = Spell:new{name="foxs cunning", phrase="int"}
spells.FREEDOM_OF_MOVEMENT = Spell:new{name="freedom of movement", phrase="free"}
spells.FUMBLE = Spell:new{name="fumble", phrase="fum"}
spells.FURY = Spell:new{name="fury", phrase="fury"}

spells.GATE = Spell:new{name="gate", phrase="gate"}
spells.GEMBOMB = Spell:new{name="gembomb", phrase="bomb"}
spells.GHOST_ARMOR = Spell:new{name="ghost armor", phrase="garm"}
spells.GLITTERDUST = Spell:new{name="glitterdust", phrase="glit"}
spells.GLOBE_OF_INVULNERABILITY = Spell:new{name="globe of invulnerability", phrase="globe"}
spells.GOLDEN_BARDING = Spell:new{name="golden barding", phrase="bard"}
spells.GOOD_FORTUNE = Spell:new{name="good fortune", phrase="gfort"}
spells.GOOD_HOPE = Spell:new{name="good hope", phrase="hope"}
spells.GREATER_CURSE = Spell:new{name="greater curse", phrase="gcur"}
spells.GREATER_HEROISM = Spell:new{name="greater heroism", phrase="gher"}
spells.GREATER_MAGIC_FANG = Spell:new{name="greater magic fang", phrase="gfang"}
spells.GREATER_SHADOW_EVOCATION = Spell:new{name="greater shadow evocation", phrase="shev"}
spells.GREATER_SHOUT = Spell:new{name="greater shout", phrase="gshout"}

spells.HALT_UNDEAD = Spell:new{name="halt undead", phrase="hu"}
spells.HARM = Spell:new{name="harm", phrase="ha"}
spells.HEAL = Spell:new{name="heal", phrase="he"}
spells.HEAL_ANIMAL_COMPANION = Spell:new{name="heal animal companion", phrase="hean"}
spells.HEAL_MOUNT = Spell:new{name="heal mount", phrase="hem"}
spells.HEROES_FEAST = Spell:new{name="heroes feast", phrase="feast"}
spells.HEROISM = Spell:new{name="heroism", phrase="her"}
spells.HOLD_ANIMAL = Spell:new{name="hold animal", phrase="han"}
spells.HOLD_MONSTER = Spell:new{name="hold monster", phrase="hm"}
spells.HOLD_PERSON = Spell:new{name="hold person", phrase="hp"}
spells.HOLY_SANCTITY = Spell:new{name="holy sanctity", phrase="msanc"}
spells.HOLY_SMITE = Spell:new{name="holy smite", phrase="gomin"}
spells.HOLY_SYMBOL = Spell:new{name="holy symbol", phrase="symbol"}
spells.HOLY_WORD = Spell:new{name="holy word", phrase="gomaj"}
spells.HORRID_WILTING = Spell:new{name="horrid wilting", phrase="wilt"}

spells.ICE_STORM = Spell:new{name="ice storm", phrase="ics"}
spells.ICESHIELD = Spell:new{name="iceshield", phrase="icshi"}
spells.IDENTIFY = Spell:new{name="identify", phrase="id"}
spells.ILL_FORTUNE = Spell:new{name="ill fortune", phrase="ifort"}
spells.ILLUSORY_PIT = Spell:new{name="illusory pit", phrase="pit"}
spells.INCENDIARY_CLOUD = Spell:new{name="incendiary cloud", phrase="fic"}
spells.INSANITY = Spell:new{name="insanity", phrase="insan"}
spells.INVIS = Spell:new{name="invis", phrase="inv"}
spells.INVIS_TO_UNDEAD = Spell:new{name="invis to undead", phrase="invu"}
spells.INVISIBILITY_PURGE = Spell:new{name="invisibility purge", phrase="invp"}
spells.IRONGUTS = Spell:new{name="ironguts", phrase="iron"}
spells.IRRESISTIBLE_DANCE = Spell:new{name="irresistible dance", phrase="dan"}

spells.KNOCK = Spell:new{name="knock", phrase="knock"}
spells.KNOW_ALIGNMENT = Spell:new{name="know alignment", phrase="know"}

spells.LEVITATE = Spell:new{name="levitate", phrase="lev"}
spells.LIGHT = Spell:new{name="light", phrase="lig"}
spells.LIGHTNING_BOLT = Spell:new{name="lightning bolt", phrase="elb"}
spells.LOCATE_OBJECT = Spell:new{name="locate object", phrase="loc"}

spells.MAGIC_CIRCLE = Spell:new{name="magic circle", phrase="circ"}
spells.MAGIC_FANG = Spell:new{name="magic fang", phrase="fang"}
spells.MAGIC_MIRROR = Spell:new{name="magic mirror", phrase="scry"}
spells.MAGIC_MISSILE = Spell:new{name="magic missile", phrase="mm"}
spells.MAGIC_VESTMENT = Spell:new{name="magic vestment", phrase="vest"}
spells.MAGIC_WEAPON = Spell:new{name="magic weapon", phrase="mweap"}
spells.MAJOR_IMAGE = Spell:new{name="major image", phrase="majim"}
spells.MAKE_WHOLE = Spell:new{name="make whole", phrase="whole"}
spells.MASS_ARMOR = Spell:new{name="mass armor", phrase="marm"}
spells.MASS_BEARS_ENDURANCE = Spell:new{name="mass bears endurance", phrase="mcon"}
spells.MASS_BULLS_STRENGTH = Spell:new{name="mass bulls strength", phrase="mstr"}
spells.MASS_CATS_GRACE = Spell:new{name="mass cats grace", phrase="mdex"}
spells.MASS_CAUSE_CRITICAL = Spell:new{name="mass cause critical", phrase="mcac"}
spells.MASS_CAUSE_LIGHT = Spell:new{name="mass cause light", phrase="mcal"}
spells.MASS_CAUSE_MODERATE = Spell:new{name="mass cause moderate", phrase="mcam"}
spells.MASS_CAUSE_SERIOUS = Spell:new{name="mass cause serious", phrase="mcas"}
spells.MASS_CHARM_MONSTER = Spell:new{name="mass charm monster", phrase="mcharmm"}
spells.MASS_CURE_CRITICAL = Spell:new{name="mass cure critical", phrase="mcuc"}
spells.MASS_CURE_LIGHT = Spell:new{name="mass cure light", phrase="mcul"}
spells.MASS_CURE_MODERATE = Spell:new{name="mass cure moderate", phrase="mcum"}
spells.MASS_CURE_SERIOUS = Spell:new{name="mass cure serious", phrase="mcus"}
spells.MASS_DEATH_WARD = Spell:new{name="mass death ward", phrase="mdw"}
spells.MASS_DROWN = Spell:new{name="mass drown", phrase="mdrown"}
spells.MASS_EAGLES_SPLENDOR = Spell:new{name="mass eagles splendor", phrase="mcha"}
spells.MASS_ENLARGE_PERSON = Spell:new{name="mass enlarge person", phrase="menlper"}
spells.MASS_FLY = Spell:new{name="mass fly", phrase="mfly"}
spells.MASS_FOXS_CUNNING = Spell:new{name="mass foxs cunning", phrase="mint"}
spells.MASS_HEAL = Spell:new{name="mass heal", phrase="mhe"}
spells.MASS_HOLD_MONSTER = Spell:new{name="mass hold monster", phrase="mhm"}
spells.MASS_HOLD_PERSON = Spell:new{name="mass hold person", phrase="mhp"}
spells.MASS_INVIS = Spell:new{name="mass invis", phrase="minv"}
spells.MASS_OWLS_WISDOM = Spell:new{name="mass owls wisdom", phrase="mwis"}
spells.MASS_REDUCE_PERSON = Spell:new{name="mass reduce person", phrase="mredper"}
spells.MASS_RESIST_ACID = Spell:new{name="mass resist acid", phrase="mresa"}
spells.MASS_RESIST_COLD = Spell:new{name="mass resist cold", phrase="mresc"}
spells.MASS_RESIST_ELECTRICITY = Spell:new{name="mass resist electricity", phrase="mrese"}
spells.MASS_RESIST_FIRE = Spell:new{name="mass resist fire", phrase="mresf"}
spells.MENDING = Spell:new{name="mending", phrase="mending"}
spells.METEOR_SWARM = Spell:new{name="meteor swarm", phrase="fisw"}
spells.MIND_BLANK = Spell:new{name="mind blank", phrase="mblank"}
spells.MINOR_GLOBE_OF_INVULNERABILITY = Spell:new{name="minor globe of invulnerability", phrase="mglobe"}
spells.MIRROR_IMAGE = Spell:new{name="mirror image", phrase="mir"}
spells.MONSTER_SUMMON = Spell:new{name="monster summon", phrase="monsum"}
spells.MOONBEAM = Spell:new{name="moonbeam", phrase="moonb"}
spells.MOONFIRE = Spell:new{name="moonfire", phrase="moonf"}

spells.NEUTRALISE_POISON = Spell:new{name="neutralise poison", phrase="neut"}
spells.NIGHTMARE = Spell:new{name="nightmare", phrase="nightmare"}
spells.NONDETECTION = Spell:new{name="nondetection", phrase="detn"}

spells.ORB_OF_ACID = Spell:new{name="orb of acid", phrase="aco"}
spells.ORB_OF_COLD = Spell:new{name="orb of cold", phrase="ico"}
spells.ORB_OF_FIRE = Spell:new{name="orb of fire", phrase="fio"}
spells.ORDERS_WRATH = Spell:new{name="orders wrath", phrase="lamin"}
spells.OWLS_WISDOM = Spell:new{name="owls wisdom", phrase="wis"}

spells.PASS_DOOR = Spell:new{name="pass door", phrase="pass"}
spells.PASS_PLANT = Spell:new{name="pass plant", phrase="plant"}
spells.PHANTASMAL_ARMOR = Spell:new{name="phantasmal armor", phrase="parm"}
spells.PHANTASMAL_KILLER = Spell:new{name="phantasmal killer", phrase="pk"}
spells.PHANTOM_STEED = Spell:new{name="phantom steed", phrase="steed"}
spells.PHOENIX_CLAW = Spell:new{name="phoenix claw", phrase="ficl"}
spells.PINK_FIREBALL = Spell:new{name="pink fireball", phrase="fip"}
spells.POISON = Spell:new{name="poison", phrase="pois"}
spells.POLAR_RAY = Spell:new{name="polar ray", phrase="icp"}
spells.POLYMORPH = Spell:new{name="polymorph", phrase="poly"}
spells.POWER_WORD_BLIND = Spell:new{name="power word blind", phrase="pwb"}
spells.POWER_WORD_KILL = Spell:new{name="power word kill", phrase="pwk"}
spells.POWER_WORD_STUN = Spell:new{name="power word stun", phrase="pws"}
spells.PRAYER = Spell:new{name="prayer", phrase="pray"}
spells.PRESERVATION = Spell:new{name="preservation", phrase="preserve"}
spells.PRODUCE_FLAME = Spell:new{name="produce flame", phrase="fipr"}
spells.PROTECTION = Spell:new{name="protection", phrase="prot"}

spells.RAISE_DEAD = Spell:new{name="raise dead", phrase="raise"}
spells.RAY_OF_FROST = Spell:new{name="ray of frost", phrase="icr"}
spells.READ_MAGIC = Spell:new{name="read magic", phrase="read"}
spells.REDUCE_ANIMAL = Spell:new{name="reduce animal", phrase="redan"}
spells.REDUCE_PERSON = Spell:new{name="reduce person", phrase="redper"}
spells.REFRESH = Spell:new{name="refresh", phrase="ref"}
spells.REGENERATE = Spell:new{name="regenerate", phrase="regen"}
spells.REJUVENATION = Spell:new{name="rejuvenation", phrase="rejuv"}
spells.REMOVE_CURSE = Spell:new{name="remove curse", phrase="rcur"}
spells.REMOVE_PARALYSIS = Spell:new{name="remove paralysis", phrase="rpar"}
spells.RESILIENCE = Spell:new{name="resilience", phrase="res"}
spells.RESIST_ACID = Spell:new{name="resist acid", phrase="resa"}
spells.RESIST_COLD = Spell:new{name="resist cold", phrase="resc"}
spells.RESIST_ELECTRICITY = Spell:new{name="resist electricity", phrase="rese"}
spells.RESIST_FIRE = Spell:new{name="resist fire", phrase="resf"}
spells.RESISTANCE = Spell:new{name="resistance", phrase="resist"}
spells.RESTORATION = Spell:new{name="restoration", phrase="restore"}
spells.RESURRECTION = Spell:new{name="resurrection", phrase="resur"}
spells.REVIVE = Spell:new{name="revive", phrase="rev"}
spells.RIGHTEOUS_FURY = Spell:new{name="righteous fury", phrase="fur"}

spells.SANCTUARY = Spell:new{name="sanctuary", phrase="sanc"}
spells.SANDSTORM = Spell:new{name="sandstorm", phrase="sand"}
spells.SCINTILLATING_PATTERN = Spell:new{name="scintillating pattern", phrase="scint"}
spells.SEARING_LIGHT = Spell:new{name="searing light", phrase="sear"}
spells.SHADOW_BINDING = Spell:new{name="shadow binding", phrase="bind"}
spells.SHADOW_WALK = Spell:new{name="shadow walk", phrase="shadwalk"}
spells.SHIELD = Spell:new{name="shield", phrase="shi"}
spells.SHIELD_OF_FAITH = Spell:new{name="shield of faith", phrase="fshi"}
spells.SHOCKING_GRASP = Spell:new{name="shocking grasp", phrase="elg"}
spells.SHOCKSHIELD = Spell:new{name="shockshield", phrase="elshi"}
spells.SHOUT = Spell:new{name="shout", phrase="shout"}
spells.SILENCE = Spell:new{name="silence", phrase="sil"}
spells.SKULK = Spell:new{name="skulk", phrase="skulk"}
spells.SLAY_LIVING = Spell:new{name="slay living", phrase="slay"}
spells.SLEEP = Spell:new{name="sleep", phrase="sleep"}
spells.SNOWBALL_SWARM = Spell:new{name="snowball swarm", phrase="icsw"}
spells.SORROW = Spell:new{name="sorrow", phrase="sorr"}
spells.SOUND_BURST = Spell:new{name="sound burst", phrase="burst"}
spells.SPEAK_WITH_DEAD = Spell:new{name="speak with dead", phrase="speakdead"}
spells.SPELL_RESISTANCE = Spell:new{name="spell resistance", phrase="sres"}
spells.SPIDER_CLIMB = Spell:new{name="spider climb", phrase="spid"}
spells.STARFLIGHT = Spell:new{name="starflight", phrase="sfly"}
spells.STONE_BODY = Spell:new{name="stone body", phrase="sb"}
spells.STONE_BONE = Spell:new{name="stone bone", phrase="sbone"}
spells.STONE_SKIN = Spell:new{name="stone skin", phrase="ss"}
spells.STONE_WALK = Spell:new{name="stone walk", phrase="stonewalk"}
spells.STORM_OF_VENGEANCE = Spell:new{name="storm of vengeance", phrase="veng"}
spells.SUMMON = Spell:new{name="summon", phrase="summon"}
spells.SUMMON_MONSTER_1 = Spell:new{name="summon monster 1", phrase="summon1"}
spells.SUMMON_MOUNT = Spell:new{name="summon mount", phrase="summount"}
spells.SUNBEAM = Spell:new{name="sunbeam", phrase="sunbe"}
spells.SUNBURST = Spell:new{name="sunburst", phrase="sunbu"}
spells.SUSTAIN = Spell:new{name="sustain", phrase="sust"}

spells.TELEPORT = Spell:new{name="teleport", phrase="tele"}
spells.THORN_SPRAY = Spell:new{name="thorn spray", phrase="thorn"}
spells.TIMESTOP = Spell:new{name="timestop", phrase="ts"}
spells.TONGUES = Spell:new{name="tongues", phrase="tong"}
spells.TOUCH_OF_JUSTICE = Spell:new{name="touch of justice", phrase="just"}
spells.TRANSPORT = Spell:new{name="transport", phrase="transp"}
spells.TREE_STRIDE = Spell:new{name="tree stride", phrase="tree"}
spells.TRUE_SIGHT = Spell:new{name="true sight", phrase="see"}
spells.TRUE_STRIKE = Spell:new{name="true strike", phrase="stri"}

spells.UNDEATH_TO_DEATH = Spell:new{name="undeath to death", phrase="utd"}
spells.UNDEATHS_ETERNAL_FOE = Spell:new{name="undeaths eternal foe", phrase="uef"}
spells.UNHOLY_BLIGHT = Spell:new{name="unholy blight", phrase="evmin"}

spells.VALIANCE = Spell:new{name="valiance", phrase="val"}
spells.VAMPIRIC_TOUCH = Spell:new{name="vampiric touch", phrase="vam"}
spells.VENTRILOQUISM = Spell:new{name="ventriloquism", phrase="vent"}

spells.WAIL_OF_THE_BANSHEE = Spell:new{name="wail of the banshee", phrase="wail"}
spells.WATER_BREATHING = Spell:new{name="water breathing", phrase="wat"}
spells.WAVE_OF_GRIEF = Spell:new{name="wave of grief", phrase="wgri"}
spells.WAVES_OF_EXHAUSTION = Spell:new{name="waves of exhaustion", phrase="wex"}
spells.WAVES_OF_FATIGUE = Spell:new{name="waves of fatigue", phrase="wfat"}
spells.WEAKEN = Spell:new{name="weaken", phrase="weak"}
spells.WEB = Spell:new{name="web", phrase="web"}
spells.WEIRD = Spell:new{name="weird", phrase="mpk"}
spells.WIND_WALK = Spell:new{name="wind walk", phrase="wind"}
spells.WINGED_MOUNT = Spell:new{name="winged mount", phrase="wing"}
spells.WINTER_MIST = Spell:new{name="winter mist", phrase="icv"}
spells.WITCH_LIGHT = Spell:new{name="witch light", phrase="wlig"}
spells.WORD_OF_CHAOS = Spell:new{name="word of chaos", phrase="chmaj"}
spells.WORD_OF_RECALL = Spell:new{name="word of recall", phrase="rec"}


spells.CHANGE_SEX = Spell:new{
    name="change sex",
    incantation = "^sex(?<sex>f|m|n)(?<target> +.*)?$",
    response = [[
        local sexes = {f="female", m="male", n="neuter"}
        local sex = sexes[string.lower("%<sex>")]
        local target = trim("%<target>")
        target = target == "" and "self" or target
        local cmd = "cast 'change sex' %s %s"
        Send(cmd:format(target, sex))
    ]],
}
spells.DRAGONSKIN = Spell:new{
    name = "dragonskin",
    incantation = "^ds(?<energy>a|c|e|f)(?<target> +.*)?$",
    response = [[
        local energies = {a="acid", c="cold", e="electricity", f="fire"}
        local energy = energies[string.lower("%<energy>")]
        local target = trim("%<target>")
        target = target == "" and "self" or target
        local cmd = "cast 'dragonskin' %s %s"
        Send(cmd:format(target, energy))
    ]],
}
spells.ENERGY_IMMUNITY = Spell:new{
    name = "energy immunity",
    incantation = "^im(?<energy>a|c|e|f)(?<target> +.*)?$",
    response = [[
        local energies = {a="acid", c="cold", e="electricity", f="fire"}
        local energy = energies[string.lower("%<energy>")]
        local target = trim("%<target>")
        target = target == "" and "self" or target
        local cmd = "cast 'energy immunity' %s %s"
        Send(cmd:format(target, energy))
    ]],
}
spells.WEAPON_OF_ENERGY = Spell:new{
    name = "weapon of energy",
    incantation = "^eweap(?<energy>c|e|f)(?<target> +.*)?$",
    response = [[
        local energies = {c="cold", e="electricity", f="fire"}
        local energy = energies[string.lower("%<energy>")]
        local target = trim("%<target>")
        local cmd = "cast 'weapon of energy' %s %s"
        Send(cmd:format(target, energy))
    ]],
}
