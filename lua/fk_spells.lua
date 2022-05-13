require("commas")

local const = require("fk_const")



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


spells.ACIDSHIELD = Spell:new{name="acidshield", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=5}, noarg=true,
    phrase="acshi",
}
spells.ACID_ARROW = Spell:new{name="acid arrow", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=2},
    phrase="aca",
}
spells.ACID_BLAST = Spell:new{name="acid blast", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=5},
    phrase="acb",
}
spells.ACID_FOG = Spell:new{name="acid fog", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=6, [const.DOMAIN.OCEAN]=7},
    phrase="acf",
}
spells.ACID_SPLASH = Spell:new{name="acid splash", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=0},
    phrase="acs",
}
spells.AIR_WALK = Spell:new{name="air walk", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=4, [const.CLASS.DRUID]=4},
    phrase="air",
}
spells.ALERTNESS = Spell:new{name="alertness", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=3, [const.CLASS.MAGE]=3, [const.CLASS.PALADIN]=3, [const.DOMAIN.PLANNING]=2},
    phrase="alert",
}
spells.ANIMAL_GROWTH = Spell:new{name="animal growth", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=5, [const.CLASS.MAGE]=5, [const.CLASS.RANGER]=4, [const.DOMAIN.NATURE]=5},
    phrase="enlan",
}
spells.ANIMATE_DEAD = Spell:new{name="animate dead", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.MAGE]=3},
    phrase="anim",
}
spells.ANIMATE_OBJECT = Spell:new{name="animate object", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.CLASS.MAGE]=6},
    phrase="animo",
}
spells.ANTIMAGIC_SHELL = Spell:new{name="antimagic shell", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=8, [const.CLASS.MAGE]=6, [const.DOMAIN.PROTECTION]=6}, noarg=true,
    phrase="amag",
}
spells.ARCANE_EYE = Spell:new{name="arcane eye", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.MAGE]=8, [const.DOMAIN.KNOWLEDGE]=8, [const.DOMAIN.MAGIC]=8}, noarg=true,
    phrase="eye",
}
spells.ARMOR = Spell:new{name="armor", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=1},
    phrase="arm",
}
spells.ARMOR_OF_DARKNESS = Spell:new{name="armor of darkness", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.DOMAIN.DARKNESS]=4},
    phrase="darm",
}
spells.ASTRAL_WALK = Spell:new{name="astral walk", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=9, [const.CLASS.MAGE]=9, [const.DOMAIN.KNOWLEDGE]=9, [const.DOMAIN.MAGIC]=9, [const.DOMAIN.TRAVEL]=9},
    phrase="astrwalk",
}
spells.AURA_OF_VITALITY = Spell:new{name="aura of vitality", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=7},
    phrase="aura",
}

spells.BANE = Spell:new{name="bane", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.CLERIC]=1},
    phrase="bane",
}
spells.BANISHMENT = Spell:new{name="banishment", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=6, [const.CLASS.MAGE]=7},
    phrase="ban",
}
spells.BARKSKIN = Spell:new{name="barkskin", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=2, [const.CLASS.RANGER]=2, [const.DOMAIN.NATURE]=2},
    phrase="bs",
}
spells.BEARS_ENDURANCE = Spell:new{name="bears endurance", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.CLASS.RANGER]=2},
    phrase="con",
}
spells.BLACK_TENTACLES = Spell:new{name="black tentacles", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=4},
    phrase="tent",
}
spells.BLASPHEMY = Spell:new{name="blasphemy", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=7, [const.DOMAIN.DROW]=7, [const.DOMAIN.HATRED]=7},
    phrase="evmaj",
}
spells.BLAZEBANE = Spell:new{name="blazebane", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=3},
    phrase="fiv",
}
spells.BLESS = Spell:new{name="bless", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.CLERIC]=1, [const.CLASS.PALADIN]=1, [const.DOMAIN.HALFLING]=1},
    phrase="ble",
}
spells.BLESS_WATER = Spell:new{name="bless water", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=1, [const.CLASS.PALADIN]=1},
    phrase="blewat",
}
spells.BLINDNESS = Spell:new{name="blindness", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=3, [const.CLASS.MAGE]=2, [const.DOMAIN.DARKNESS]=2},
    phrase="bl",
}
spells.BOLT_OF_GLORY = Spell:new{name="bolt of glory", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=6},
    phrase="glory",
}
spells.BREAK_ENCHANTMENT = Spell:new{name="break enchantment", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=4, [const.CLASS.CLERIC]=5, [const.CLASS.MAGE]=5, [const.CLASS.PALADIN]=4, [const.DOMAIN.FATE]=5, [const.DOMAIN.MAGIC]=5},
    phrase="bren",
}
spells.BULLS_STRENGTH = Spell:new{name="bulls strength", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.CLASS.PALADIN]=2},
    phrase="str",
}
spells.BURNING_HANDS = Spell:new{name="burning hands", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.FIRE]=1, [const.DOMAIN.SUN]=1},
    phrase="fih",
}
spells.BURROW = Spell:new{name="burrow", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=1, [const.CLASS.RANGER]=1, [const.DOMAIN.EARTH]=1, [const.DOMAIN.TRAVEL]=1},
    phrase="bur",
}

spells.CALL_LIGHTNING = Spell:new{name="call lightning", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.DRUID]=3, [const.DOMAIN.STORMS]=4},
    phrase="ell",
}
spells.CALL_LIGHTNING_STORM = Spell:new{name="call lightning storm", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.DRUID]=5, [const.DOMAIN.STORMS]=6},
    phrase="els",
}
spells.CATS_GRACE = Spell:new{name="cats grace", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.CLASS.RANGER]=2, [const.DOMAIN.DROW]=2, [const.DOMAIN.ELF]=2, [const.DOMAIN.HALFLING]=2},
    phrase="dex",
}
spells.CAUSE_CRITICAL = Spell:new{name="cause critical", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=4},
    phrase="cac",
}
spells.CAUSE_LIGHT = Spell:new{name="cause light", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=1},
    phrase="cal",
}
spells.CAUSE_MINOR = Spell:new{name="cause minor", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=0},
    phrase="cami",
}
spells.CAUSE_MODERATE = Spell:new{name="cause moderate", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=2},
    phrase="cam",
}
spells.CAUSE_SERIOUS = Spell:new{name="cause serious", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=3},
    phrase="cas",
}
spells.CHAIN_LIGHTNING = Spell:new{name="chain lightning", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=6, [const.DOMAIN.STORMS]=8},
    phrase="elc",
}
spells.CHANGE_SEX = Spell:new{name="change sex", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.CLERIC]=3, [const.CLASS.MAGE]=3},
    phrase="sex", incantation="^sex(?<sex>f|m|n)(?<target> +.*)?$", response=[[
        local sexes = {f="female", m="male", n="neuter"}
        local sex = sexes[string.lower("%<sex>")]
        local target = trim("%<target>")
        target = target == "" and "self" or target
        local cmd = "cast 'change sex' %s %s"
        Send(cmd:format(target, sex))
    ]],
}
spells.CHAOS_HAMMER = Spell:new{name="chaos hammer", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=4},
    phrase="chmin",
}
spells.CHARGED_BEACON = Spell:new{name="charged beacon", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=3, [const.DOMAIN.STORMS]=3},
    phrase="elv",
}
spells.CHARIOT_OF_THE_SUN = Spell:new{name="chariot of the sun", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.DOMAIN.SUN]=8},
    phrase="sunch",
}
spells.CHARM_ANIMAL = Spell:new{name="charm animal", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.DRUID]=1, [const.CLASS.RANGER]=1},
    phrase="charma",
}
spells.CHARM_MONSTER = Spell:new{name="charm monster", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=4, [const.DOMAIN.CHARM]=5, [const.DOMAIN.GNOME]=5},
    phrase="charmm",
}
spells.CHARM_PERSON = Spell:new{name="charm person", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=1, [const.CLASS.MAGE]=1, [const.DOMAIN.CHARM]=1},
    phrase="charmp",
}
spells.CHILL_TOUCH = Spell:new{name="chill touch", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.DESTRUCTION]=1},
    phrase="ict",
}
spells.CIRCLE_OF_DEATH = Spell:new{name="circle of death", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=6, [const.CLASS.MAGE]=6},
    phrase="cird",
}
spells.CLAIRVOYANCE = Spell:new{name="clairvoyance", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=3, [const.DOMAIN.KNOWLEDGE]=3, [const.DOMAIN.PLANNING]=3},
    phrase="clair",
}
spells.COLOR_SPRAY = Spell:new{name="color spray", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.ILLUSION]=1},
    phrase="col",
}
spells.COMPREHEND_LANGUAGES = Spell:new{name="comprehend languages", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=1, [const.CLASS.CLERIC]=1, [const.CLASS.MAGE]=1}, noarg=true,
    phrase="comp",
}
spells.CONE_OF_COLD = Spell:new{name="cone of cold", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=5, [const.DOMAIN.OCEAN]=5},
    phrase="icc",
}
spells.CONFUSION = Spell:new{name="confusion", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=4, [const.DOMAIN.TRICKERY]=4},
    phrase="conf",
}
spells.CONJURE_ELEMENTAL = Spell:new{name="conjure elemental", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=5},
    phrase="conjele",
}
spells.CONJURE_GREATER_ELEMENTAL = Spell:new{name="conjure greater elemental", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=8, [const.DOMAIN.EARTH]=9, [const.DOMAIN.FIRE]=9, [const.DOMAIN.OCEAN]=9},
    phrase="gconjele",
}
spells.CONTINUAL_LIGHT = Spell:new{name="continual light", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=5, [const.CLASS.MAGE]=6},
    phrase="clig",
}
spells.CONTROL_UNDEAD = Spell:new{name="control undead", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=7},
    phrase="charmund",
}
spells.CONTROL_WEATHER = Spell:new{name="control weather", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=7, [const.CLASS.DRUID]=7, [const.CLASS.MAGE]=7, [const.DOMAIN.STORMS]=7},
    phrase="controlweat",
}
spells.CREATE_FOOD = Spell:new{name="create food", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=3}, noarg=true,
    phrase="crefood",
}
spells.CREATE_SPRING = Spell:new{name="create spring", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=2, [const.CLASS.RANGER]=2, [const.DOMAIN.OCEAN]=1}, noarg=true,
    phrase="crespr",
}
spells.CREATE_WATER = Spell:new{name="create water", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=0, [const.CLASS.DRUID]=0, [const.CLASS.PALADIN]=1},
    phrase="crewat",
}
spells.CRUSHING_DESPAIR = Spell:new{name="crushing despair", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=4, [const.DOMAIN.HATRED]=4},
    phrase="crush",
}
spells.CURE_BLINDNESS = Spell:new{name="cure blindness", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.PALADIN]=3},
    phrase="cub",
}
spells.CURE_CRITICAL = Spell:new{name="cure critical", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=4, [const.CLASS.CLERIC]=4, [const.CLASS.DRUID]=5},
    phrase="cuc",
}
spells.CURE_DISEASE = Spell:new{name="cure disease", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=3, [const.CLASS.RANGER]=3},
    phrase="cud",
}
spells.CURE_LIGHT = Spell:new{name="cure light", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=1, [const.CLASS.CLERIC]=1, [const.CLASS.DRUID]=1, [const.CLASS.PALADIN]=1, [const.CLASS.RANGER]=2},
    phrase="cul",
}
spells.CURE_MINOR = Spell:new{name="cure minor", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=0, [const.CLASS.DRUID]=0},
    phrase="cumi",
}
spells.CURE_MODERATE = Spell:new{name="cure moderate", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=2, [const.CLASS.DRUID]=3, [const.CLASS.PALADIN]=3, [const.CLASS.RANGER]=3},
    phrase="cum",
}
spells.CURE_SERIOUS = Spell:new{name="cure serious", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=4, [const.CLASS.PALADIN]=4, [const.CLASS.RANGER]=4},
    phrase="cus",
}
spells.CURSE = Spell:new{name="curse", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.MAGE]=4},
    phrase="cur",
}

spells.DARKVISION = Spell:new{name="darkvision", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=2, [const.CLASS.RANGER]=3},
    phrase="dvis",
}
spells.DAZE = Spell:new{name="daze", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=0, [const.CLASS.MAGE]=0},
    phrase="daze",
}
spells.DAZE_MONSTER = Spell:new{name="daze monster", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=2, [const.CLASS.MAGE]=2},
    phrase="dazm",
}
spells.DEATH_WARD = Spell:new{name="death ward", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=4, [const.CLASS.DRUID]=5, [const.CLASS.PALADIN]=4, [const.DOMAIN.HALFLING]=3, [const.DOMAIN.PROTECTION]=3},
    phrase="dw",
}
spells.DEEP_SLUMBER = Spell:new{name="deep slumber", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=3, [const.DOMAIN.DARKNESS]=3},
    phrase="dsleep",
}
spells.DELAYED_BLAST_FIREBALL = Spell:new{name="delayed blast fireball", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.FIRE]=6},
    phrase="fid",
}
spells.DESTRUCTION = Spell:new{name="destruction", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=7},
    phrase="dest",
}
spells.DETECT_BURIED = Spell:new{name="detect buried", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.DRUID]=2, [const.DOMAIN.EARTH]=2}, noarg=true,
    phrase="detb",
}
spells.DETECT_CHAOS = Spell:new{name="detect chaos", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.CLERIC]=1}, noarg=true,
    phrase="detc",
}
spells.DETECT_EVIL = Spell:new{name="detect evil", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.CLERIC]=1}, noarg=true,
    phrase="dete",
}
spells.DETECT_GOOD = Spell:new{name="detect good", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.CLERIC]=1}, noarg=true,
    phrase="detg",
}
spells.DETECT_HIDDEN = Spell:new{name="detect hidden", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=1, [const.CLASS.MAGE]=1, [const.DOMAIN.PLANNING]=1}, noarg=true,
    phrase="deth",
}
spells.DETECT_INVIS = Spell:new{name="detect invis", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=2, [const.DOMAIN.KNOWLEDGE]=2}, noarg=true,
    phrase="deti",
}
spells.DETECT_LAW = Spell:new{name="detect law", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.CLERIC]=1}, noarg=true,
    phrase="detl",
}
spells.DETECT_MAGIC = Spell:new{name="detect magic", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=0, [const.CLASS.CLERIC]=0, [const.CLASS.DRUID]=0, [const.CLASS.MAGE]=0}, noarg=true,
    phrase="detm",
}
spells.DETECT_POISON = Spell:new{name="detect poison", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.CLERIC]=0, [const.CLASS.DRUID]=0, [const.CLASS.MAGE]=0, [const.CLASS.PALADIN]=1, [const.CLASS.RANGER]=1},
    phrase="detp",
}
spells.DICTUM = Spell:new{name="dictum", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=7, [const.DOMAIN.RETRIBUTION]=7},
    phrase="lamaj",
}
spells.DIMENSIONAL_ANCHOR = Spell:new{name="dimensional anchor", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=4, [const.CLASS.MAGE]=4},
    phrase="anchor",
}
spells.DISEASE = Spell:new{name="disease", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.MAGE]=4},
    phrase="dis",
}
spells.DISINTEGRATE = Spell:new{name="disintegrate", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=6, [const.DOMAIN.DESTRUCTION]=8, [const.DOMAIN.HATRED]=8},
    phrase="dint",
}
spells.DISMISSAL = Spell:new{name="dismissal", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=4, [const.CLASS.MAGE]=5},
    phrase="dism",
}
spells.DISPEL_EVIL = Spell:new{name="dispel evil", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=5, [const.CLASS.PALADIN]=4},
    phrase="de",
}
spells.DISPEL_MAGIC = Spell:new{name="dispel magic", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=4, [const.CLASS.MAGE]=3, [const.CLASS.PALADIN]=3, [const.DOMAIN.MAGIC]=3},
    phrase="dm",
}
spells.DISRUPT_UNDEAD = Spell:new{name="disrupt undead", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=0},
    phrase="disr",
}
spells.DIVINE_FAVOR = Spell:new{name="divine favor", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=1, [const.CLASS.PALADIN]=1}, noarg=true,
    phrase="fav",
}
spells.DIVINE_POWER = Spell:new{name="divine power", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=4, [const.DOMAIN.PROWESS]=4}, noarg=true,
    phrase="dpow",
}
spells.DOMINATE_ANIMAL = Spell:new{name="dominate animal", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.DRUID]=3, [const.DOMAIN.NATURE]=3},
    phrase="doman",
}
spells.DOMINATE_MONSTER = Spell:new{name="dominate monster", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=9, [const.DOMAIN.CHARM]=9, [const.DOMAIN.FATE]=9, [const.DOMAIN.GNOME]=9, [const.DOMAIN.TRADE]=9, [const.DOMAIN.TYRANNY]=9},
    phrase="dommon",
}
spells.DOMINATE_PERSON = Spell:new{name="dominate person", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=4, [const.CLASS.MAGE]=5, [const.DOMAIN.CHARM]=6, [const.DOMAIN.FATE]=6, [const.DOMAIN.TYRANNY]=6},
    phrase="domper",
}
spells.DRAGONSKIN = Spell:new{name="dragonskin", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=3, [const.CLASS.MAGE]=3},
    phrase="ds", incantation="^ds(?<energy>a|c|e|f)(?<target> +.*)?$", response=[[
        local energies = {a="acid", c="cold", e="electricity", f="fire"}
        local energy = energies[string.lower("%<energy>")]
        local target = trim("%<target>")
        target = target == "" and "self" or target
        local cmd = "cast 'dragonskin' %s %s"
        Send(cmd:format(target, energy))
    ]],
}
spells.DROWN = Spell:new{name="drown", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=6, [const.DOMAIN.OCEAN]=6},
    phrase="drown",
}

spells.EAGLES_SPLENDOR = Spell:new{name="eagles splendor", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=2, [const.CLASS.MAGE]=2, [const.CLASS.PALADIN]=2, [const.DOMAIN.CHARM]=2},
    phrase="cha",
}
spells.EARTHQUAKE = Spell:new{name="earthquake", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=8, [const.CLASS.DRUID]=8, [const.DOMAIN.DESTRUCTION]=7, [const.DOMAIN.EARTH]=7, [const.DOMAIN.NATURE]=7},
    phrase="eaq",
}
spells.EARTH_REAVER = Spell:new{name="earth reaver", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=4, [const.CLASS.MAGE]=4, [const.DOMAIN.EARTH]=3},
    phrase="ear",
}
spells.ENERGY_DRAIN = Spell:new{name="energy drain", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=9, [const.CLASS.MAGE]=9},
    phrase="drain",
}
spells.ENERGY_IMMUNITY = Spell:new{name="energy immunity", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=6, [const.CLASS.MAGE]=7},
    phrase="im", incantation="^im(?<energy>a|c|e|f)(?<target> +.*)?$", response=[[
        local energies = {a="acid", c="cold", e="electricity", f="fire"}
        local energy = energies[string.lower("%<energy>")]
        local target = trim("%<target>")
        target = target == "" and "self" or target
        local cmd = "cast 'energy immunity' %s %s"
        Send(cmd:format(target, energy))
    ]],
}
spells.ENERVATION = Spell:new{name="enervation", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=4, [const.DOMAIN.DESTRUCTION]=4, [const.DOMAIN.SUFFERING]=4},
    phrase="ener",
}
spells.ENLARGE_PERSON = Spell:new{name="enlarge person", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.PROWESS]=1},
    phrase="enlper",
}
spells.ENTANGLE = Spell:new{name="entangle", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=1, [const.CLASS.RANGER]=1, [const.DOMAIN.NATURE]=1},
    phrase="tang",
}
spells.ETHEREAL_FLYER = Spell:new{name="ethereal flyer", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=3},
    phrase="efly",
}

spells.FAERIE_FIRE = Spell:new{name="faerie fire", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.DRUID]=1, [const.DOMAIN.MOON]=1},
    phrase="ffire",
}
spells.FAERIE_FOG = Spell:new{name="faerie fog", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.DRUID]=3, [const.DOMAIN.ELF]=3, [const.DOMAIN.MOON]=3},
    phrase="ffog",
}
spells.FAITHFUL_HOUND = Spell:new{name="faithful hound", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=5, [const.DOMAIN.HALFLING]=5, [const.DOMAIN.PLANNING]=5}, noarg=true,
    phrase="hound",
}
spells.FAMISH = Spell:new{name="famish", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.DOMAIN.SUFFERING]=3},
    phrase="fam",
}
spells.FARHEAL = Spell:new{name="farheal", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.DOMAIN.HALFLING]=9, [const.DOMAIN.RENEWAL]=9},
    phrase="hef",
}
spells.FATIGUE = Spell:new{name="fatigue", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=3},
    phrase="fat",
}
spells.FEAR = Spell:new{name="fear", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=4, [const.DOMAIN.HATRED]=5, [const.DOMAIN.TYRANNY]=5},
    phrase="fear",
}
spells.FEEBLEMIND = Spell:new{name="feeblemind", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=5, [const.DOMAIN.SUFFERING]=5},
    phrase="feeb",
}
spells.FIND_THE_PATH = Spell:new{name="find the path", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=6, [const.DOMAIN.KNOWLEDGE]=6, [const.DOMAIN.MOON]=6, [const.DOMAIN.TRAVEL]=6}, noarg=true,
    phrase="findpath",
}
spells.FIND_TRAPS = Spell:new{name="find traps", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.CLERIC]=2}, noarg=true,
    phrase="findtrap",
}
spells.FINGER_OF_DEATH = Spell:new{name="finger of death", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.DRUID]=8, [const.CLASS.MAGE]=7},
    phrase="fing",
}
spells.FIREBALL = Spell:new{name="fireball", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=3, [const.DOMAIN.FIRE]=3},
    phrase="fib",
}
spells.FIRESHIELD = Spell:new{name="fireshield", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=4, [const.DOMAIN.FIRE]=4, [const.DOMAIN.RETRIBUTION]=4, [const.DOMAIN.SUN]=4}, noarg=true,
    phrase="fishi",
}
spells.FIRE_STORM = Spell:new{name="fire storm", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=8, [const.CLASS.DRUID]=7, [const.DOMAIN.FIRE]=7},
    phrase="fis",
}
spells.FLAMESTRIKE = Spell:new{name="flamestrike", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=5, [const.CLASS.DRUID]=4, [const.DOMAIN.FIRE]=5},
    phrase="fist",
}
spells.FLAME_ARROW = Spell:new{name="flame arrow", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=3},
    phrase="fia",
}
spells.FLAME_BLADE = Spell:new{name="flame blade", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.DRUID]=5}, noarg=true,
    phrase="fiblade",
}
spells.FLARE = Spell:new{name="flare", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.BARD]=0, [const.CLASS.DRUID]=0, [const.CLASS.MAGE]=0},
    phrase="flare",
}
spells.FLENSING = Spell:new{name="flensing", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=8, [const.DOMAIN.SUFFERING]=7},
    phrase="flen",
}
spells.FLOATING_DISC = Spell:new{name="floating disc", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=1}, noarg=true,
    phrase="disc",
}
spells.FLY = Spell:new{name="fly", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=3, [const.DOMAIN.TRAVEL]=3},
    phrase="fly",
}
spells.FOXS_CUNNING = Spell:new{name="foxs cunning", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.MAGE]=2, [const.DOMAIN.MAGIC]=2},
    phrase="int",
}
spells.FREEDOM_OF_MOVEMENT = Spell:new{name="freedom of movement", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=4, [const.CLASS.CLERIC]=4, [const.CLASS.DRUID]=4, [const.CLASS.RANGER]=4, [const.DOMAIN.FATE]=4, [const.DOMAIN.HALFLING]=4},
    phrase="free",
}
spells.FUMBLE = Spell:new{name="fumble", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=2},
    phrase="fum",
}
spells.FURY = Spell:new{name="fury", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=2, [const.CLASS.MAGE]=3, [const.DOMAIN.HATRED]=3},
    phrase="fury",
}

spells.GATE = Spell:new{name="gate", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=9, [const.CLASS.MAGE]=9},
    phrase="gate",
}
spells.GEMBOMB = Spell:new{name="gembomb", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.DOMAIN.GNOME]=3, [const.DOMAIN.TRADE]=3},
    phrase="bomb",
}
spells.GHOST_ARMOR = Spell:new{name="ghost armor", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.DOMAIN.ILLUSION]=5},
    phrase="garm",
}
spells.GLITTERDUST = Spell:new{name="glitterdust", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.MAGE]=2},
    phrase="glit",
}
spells.GLOBE_OF_INVULNERABILITY = Spell:new{name="globe of invulnerability", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.MAGE]=6}, noarg=true,
    phrase="globe",
}
spells.GOLDEN_BARDING = Spell:new{name="golden barding", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.PALADIN]=1},
    phrase="bard",
}
spells.GOOD_FORTUNE = Spell:new{name="good fortune", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.DOMAIN.FATE]=2, [const.DOMAIN.GNOME]=2, [const.DOMAIN.TRADE]=2},
    phrase="gfort",
}
spells.GOOD_HOPE = Spell:new{name="good hope", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=3, [const.DOMAIN.CHARM]=4, [const.DOMAIN.MOON]=4, [const.DOMAIN.TRADE]=4},
    phrase="hope",
}
spells.GREATER_CURSE = Spell:new{name="greater curse", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=7, [const.CLASS.MAGE]=8, [const.DOMAIN.FATE]=7},
    phrase="gcur",
}
spells.GREATER_HEROISM = Spell:new{name="greater heroism", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=5, [const.CLASS.MAGE]=6},
    phrase="gher",
}
spells.GREATER_MAGIC_FANG = Spell:new{name="greater magic fang", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=3, [const.CLASS.RANGER]=3},
    phrase="gfang",
}
spells.GREATER_SHADOW_EVOCATION = Spell:new{name="greater shadow evocation", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=8},
    phrase="shev",
}
spells.GREATER_SHOUT = Spell:new{name="greater shout", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.BARD]=6},
    phrase="gshout",
}

spells.HALT_UNDEAD = Spell:new{name="halt undead", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=3},
    phrase="hu",
}
spells.HARM = Spell:new{name="harm", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=6, [const.DOMAIN.DESTRUCTION]=6, [const.DOMAIN.HATRED]=6, [const.DOMAIN.SUFFERING]=6},
    phrase="ha",
}
spells.HEAL = Spell:new{name="heal", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=7, [const.DOMAIN.RENEWAL]=5},
    phrase="he",
}
spells.HEAL_ANIMAL_COMPANION = Spell:new{name="heal animal companion", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=5, [const.CLASS.RANGER]=3},
    phrase="hean",
}
spells.HEAL_MOUNT = Spell:new{name="heal mount", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.PALADIN]=3},
    phrase="hem",
}
spells.HEROES_FEAST = Spell:new{name="heroes feast", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.DOMAIN.PLANNING]=6}, noarg=true,
    phrase="feast",
}
spells.HEROISM = Spell:new{name="heroism", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=2, [const.CLASS.MAGE]=3, [const.DOMAIN.PROWESS]=2},
    phrase="her",
}
spells.HOLD_ANIMAL = Spell:new{name="hold animal", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.DRUID]=2, [const.CLASS.RANGER]=2},
    phrase="han",
}
spells.HOLD_MONSTER = Spell:new{name="hold monster", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=4, [const.CLASS.MAGE]=5},
    phrase="hm",
}
spells.HOLD_PERSON = Spell:new{name="hold person", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=2, [const.CLASS.MAGE]=3, [const.DOMAIN.TYRANNY]=2},
    phrase="hp",
}
spells.HOLY_SANCTITY = Spell:new{name="holy sanctity", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=5, [const.DOMAIN.MOON]=5},
    phrase="msanc",
}
spells.HOLY_SMITE = Spell:new{name="holy smite", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=4},
    phrase="gomin",
}
spells.HOLY_SYMBOL = Spell:new{name="holy symbol", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=9, [const.CLASS.DRUID]=9}, noarg=true,
    phrase="symbol",
}
spells.HOLY_WORD = Spell:new{name="holy word", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=7, [const.DOMAIN.GNOME]=7},
    phrase="gomaj",
}
spells.HORRID_WILTING = Spell:new{name="horrid wilting", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=8, [const.DOMAIN.SUFFERING]=9},
    phrase="wilt",
}
spells.ICESHIELD = Spell:new{name="iceshield", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=4, [const.DOMAIN.OCEAN]=4}, noarg=true,
    phrase="icshi",
}
spells.ICE_STORM = Spell:new{name="ice storm", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.DRUID]=4, [const.CLASS.MAGE]=4, [const.DOMAIN.STORMS]=5},
    phrase="ics",
}
spells.IDENTIFY = Spell:new{name="identify", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=1, [const.CLASS.MAGE]=1, [const.DOMAIN.KNOWLEDGE]=1, [const.DOMAIN.MAGIC]=1, [const.DOMAIN.TRADE]=1},
    phrase="id",
}
spells.ILLUSORY_PIT = Spell:new{name="illusory pit", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=6, [const.DOMAIN.ILLUSION]=6, [const.DOMAIN.TRICKERY]=6},
    phrase="pit",
}

spells.ILL_FORTUNE = Spell:new{name="ill fortune", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.DOMAIN.FATE]=3},
    phrase="ifort",
}
spells.INCENDIARY_CLOUD = Spell:new{name="incendiary cloud", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=8, [const.DOMAIN.FIRE]=8},
    phrase="fic",
}
spells.INSANITY = Spell:new{name="insanity", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.CHARM]=7, [const.DOMAIN.MOON]=7, [const.DOMAIN.TRICKERY]=7},
    phrase="insan",
}
spells.INVIS = Spell:new{name="invis", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.MAGE]=2, [const.DOMAIN.ILLUSION]=2, [const.DOMAIN.TRICKERY]=2},
    phrase="inv",
}
spells.INVISIBILITY_PURGE = Spell:new{name="invisibility purge", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=3},
    phrase="invp",
}
spells.INVIS_TO_UNDEAD = Spell:new{name="invis to undead", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=1},
    phrase="invu",
}
spells.IRONGUTS = Spell:new{name="ironguts", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.MAGE]=1},
    phrase="iron",
}
spells.IRRESISTIBLE_DANCE = Spell:new{name="irresistible dance", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=6, [const.CLASS.MAGE]=8, [const.DOMAIN.GNOME]=8},
    phrase="dan",
}

spells.KNOCK = Spell:new{name="knock", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=2},
    phrase="knock",
}
spells.KNOW_ALIGNMENT = Spell:new{name="know alignment", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.PALADIN]=1},
    phrase="know",
}

spells.LEVITATE = Spell:new{name="levitate", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=2, [const.DOMAIN.STORMS]=2},
    phrase="lev",
}
spells.LIGHT = Spell:new{name="light", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.BARD]=0, [const.CLASS.CLERIC]=0, [const.CLASS.DRUID]=0, [const.CLASS.MAGE]=0},
    phrase="lig",
}
spells.LIGHTNING_BOLT = Spell:new{name="lightning bolt", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=3},
    phrase="elb",
}
spells.LOCATE_OBJECT = Spell:new{name="locate object", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=3, [const.CLASS.MAGE]=2, [const.DOMAIN.TRAVEL]=2},
    phrase="loc",
}

spells.MAGIC_CIRCLE = Spell:new{name="magic circle", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.PALADIN]=3, [const.DOMAIN.CHARM]=3},
    phrase="circ",
}
spells.MAGIC_FANG = Spell:new{name="magic fang", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=1, [const.CLASS.RANGER]=1},
    phrase="fang",
}
spells.MAGIC_MIRROR = Spell:new{name="magic mirror", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=4, [const.CLASS.CLERIC]=4, [const.CLASS.DRUID]=4, [const.CLASS.MAGE]=4, [const.DOMAIN.KNOWLEDGE]=4},
    phrase="scry",
}
spells.MAGIC_MISSILE = Spell:new{name="magic missile", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=1},
    phrase="mm",
}
spells.MAGIC_VESTMENT = Spell:new{name="magic vestment", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=7},
    phrase="vest",
}
spells.MAGIC_WEAPON = Spell:new{name="magic weapon", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.MAGE]=3, [const.CLASS.PALADIN]=3},
    phrase="mweap",
}
spells.MAJOR_IMAGE = Spell:new{name="major image", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.BARD]=5, [const.CLASS.MAGE]=5}, noarg=true,
    phrase="majim",
}
spells.MAKE_WHOLE = Spell:new{name="make whole", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=4},
    phrase="whole",
}
spells.MASS_ARMOR = Spell:new{name="mass armor", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=3},
    phrase="marm",
}
spells.MASS_BEARS_ENDURANCE = Spell:new{name="mass bears endurance", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=6, [const.CLASS.MAGE]=6},
    phrase="mcon",
}
spells.MASS_BULLS_STRENGTH = Spell:new{name="mass bulls strength", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=6, [const.CLASS.MAGE]=6},
    phrase="mstr",
}
spells.MASS_CATS_GRACE = Spell:new{name="mass cats grace", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.DRUID]=6, [const.CLASS.MAGE]=6, [const.DOMAIN.DROW]=6, [const.DOMAIN.ELF]=6, [const.DOMAIN.HALFLING]=6},
    phrase="mdex",
}
spells.MASS_CAUSE_CRITICAL = Spell:new{name="mass cause critical", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=8},
    phrase="mcac",
}
spells.MASS_CAUSE_LIGHT = Spell:new{name="mass cause light", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=5},
    phrase="mcal",
}
spells.MASS_CAUSE_MODERATE = Spell:new{name="mass cause moderate", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=6},
    phrase="mcam",
}
spells.MASS_CAUSE_SERIOUS = Spell:new{name="mass cause serious", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=7},
    phrase="mcas",
}
spells.MASS_CHARM_MONSTER = Spell:new{name="mass charm monster", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=6, [const.CLASS.MAGE]=8, [const.DOMAIN.CHARM]=8},
    phrase="mcharmm",
}
spells.MASS_CURE_CRITICAL = Spell:new{name="mass cure critical", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=8, [const.CLASS.DRUID]=9},
    phrase="mcuc",
}
spells.MASS_CURE_LIGHT = Spell:new{name="mass cure light", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=5, [const.CLASS.CLERIC]=5, [const.CLASS.DRUID]=6},
    phrase="mcul",
}
spells.MASS_CURE_MODERATE = Spell:new{name="mass cure moderate", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=7},
    phrase="mcum",
}
spells.MASS_CURE_SERIOUS = Spell:new{name="mass cure serious", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=7, [const.CLASS.DRUID]=8},
    phrase="mcus",
}
spells.MASS_DEATH_WARD = Spell:new{name="mass death ward", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=8, [const.CLASS.DRUID]=9, [const.DOMAIN.PROTECTION]=7},
    phrase="mdw",
}
spells.MASS_DROWN = Spell:new{name="mass drown", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=9},
    phrase="mdrown",
}
spells.MASS_EAGLES_SPLENDOR = Spell:new{name="mass eagles splendor", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=6, [const.CLASS.MAGE]=6, [const.DOMAIN.TRADE]=6},
    phrase="mcha",
}
spells.MASS_ENLARGE_PERSON = Spell:new{name="mass enlarge person", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=4},
    phrase="menlper",
}
spells.MASS_FLY = Spell:new{name="mass fly", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=5},
    phrase="mfly",
}
spells.MASS_FOXS_CUNNING = Spell:new{name="mass foxs cunning", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.MAGE]=6, [const.DOMAIN.KNOWLEDGE]=7},
    phrase="mint",
}
spells.MASS_HEAL = Spell:new{name="mass heal", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=9, [const.DOMAIN.RENEWAL]=8},
    phrase="mhe",
}
spells.MASS_HOLD_MONSTER = Spell:new{name="mass hold monster", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=9},
    phrase="mhm",
}
spells.MASS_HOLD_PERSON = Spell:new{name="mass hold person", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.TYRANNY]=7},
    phrase="mhp",
}
spells.MASS_INVIS = Spell:new{name="mass invis", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.ILLUSION]=7},
    phrase="minv",
}
spells.MASS_OWLS_WISDOM = Spell:new{name="mass owls wisdom", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=6, [const.CLASS.MAGE]=6},
    phrase="mwis",
}
spells.MASS_REDUCE_PERSON = Spell:new{name="mass reduce person", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=4},
    phrase="mredper",
}
spells.MASS_RESIST_ACID = Spell:new{name="mass resist acid", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.MAGE]=6},
    phrase="mresa",
}
spells.MASS_RESIST_COLD = Spell:new{name="mass resist cold", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.MAGE]=6},
    phrase="mresc",
}
spells.MASS_RESIST_ELECTRICITY = Spell:new{name="mass resist electricity", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.MAGE]=6},
    phrase="mrese",
}
spells.MASS_RESIST_FIRE = Spell:new{name="mass resist fire", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.MAGE]=6},
    phrase="mresf",
}
spells.MENDING = Spell:new{name="mending", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=0, [const.CLASS.CLERIC]=0, [const.CLASS.DRUID]=0, [const.CLASS.MAGE]=0},
    phrase="mending",
}
spells.METEOR_SWARM = Spell:new{name="meteor swarm", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=9},
    phrase="fisw",
}
spells.MIND_BLANK = Spell:new{name="mind blank", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.MAGE]=8, [const.DOMAIN.FATE]=8, [const.DOMAIN.PROTECTION]=8, [const.DOMAIN.TRADE]=8},
    phrase="mblank",
}
spells.MINOR_GLOBE_OF_INVULNERABILITY = Spell:new{name="minor globe of invulnerability", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.MAGE]=4, [const.DOMAIN.PROTECTION]=4}, noarg=true,
    phrase="mglobe",
}
spells.MIRROR_IMAGE = Spell:new{name="mirror image", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.MAGE]=2, [const.DOMAIN.ILLUSION]=3}, noarg=true,
    phrase="mir",
}
spells.MONSTER_SUMMON = Spell:new{name="monster summon", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=6, [const.CLASS.CLERIC]=6, [const.CLASS.MAGE]=6}, noarg=true,
    phrase="monsum",
}
spells.MOONBEAM = Spell:new{name="moonbeam", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.DOMAIN.MOON]=2}, noarg=true,
    phrase="moonb",
}
spells.MOONFIRE = Spell:new{name="moonfire", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.DOMAIN.MOON]=8},
    phrase="moonf",
}

spells.NEUTRALISE_POISON = Spell:new{name="neutralise poison", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=4, [const.CLASS.CLERIC]=4, [const.CLASS.DRUID]=3, [const.CLASS.PALADIN]=4, [const.CLASS.RANGER]=3},
    phrase="neut",
}
spells.NIGHTMARE = Spell:new{name="nightmare", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.BARD]=5, [const.CLASS.MAGE]=5, [const.DOMAIN.DARKNESS]=6},
    phrase="nightmare",
}
spells.NONDETECTION = Spell:new{name="nondetection", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.MAGE]=3, [const.CLASS.RANGER]=4, [const.DOMAIN.TRICKERY]=3},
    phrase="detn",
}

spells.ORB_OF_ACID = Spell:new{name="orb of acid", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=4},
    phrase="aco",
}
spells.ORB_OF_COLD = Spell:new{name="orb of cold", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=4},
    phrase="ico",
}
spells.ORB_OF_FIRE = Spell:new{name="orb of fire", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=4},
    phrase="fio",
}
spells.ORDERS_WRATH = Spell:new{name="orders wrath", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=4, [const.DOMAIN.RETRIBUTION]=3},
    phrase="lamin",
}
spells.OWLS_WISDOM = Spell:new{name="owls wisdom", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.CLASS.PALADIN]=2, [const.CLASS.RANGER]=2},
    phrase="wis",
}

spells.PASS_DOOR = Spell:new{name="pass door", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=5, [const.DOMAIN.DROW]=4, [const.DOMAIN.EARTH]=4, [const.DOMAIN.TRAVEL]=4}, noarg=true,
    phrase="pass",
}
spells.PASS_PLANT = Spell:new{name="pass plant", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=6, [const.DOMAIN.ELF]=8, [const.DOMAIN.NATURE]=8},
    phrase="plant",
}
spells.PHANTASMAL_ARMOR = Spell:new{name="phantasmal armor", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=5}, noarg=true,
    phrase="parm",
}
spells.PHANTASMAL_KILLER = Spell:new{name="phantasmal killer", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=4, [const.DOMAIN.ILLUSION]=4},
    phrase="pk",
}
spells.PHANTOM_STEED = Spell:new{name="phantom steed", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=6}, noarg=true,
    phrase="steed",
}
spells.PHOENIX_CLAW = Spell:new{name="phoenix claw", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.DOMAIN.SUN]=5},
    phrase="ficl",
}
spells.PINK_FIREBALL = Spell:new{name="pink fireball", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=3},
    phrase="fip",
}
spells.POISON = Spell:new{name="poison", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=4, [const.CLASS.DRUID]=3},
    phrase="pois",
}
spells.POLAR_RAY = Spell:new{name="polar ray", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=8, [const.DOMAIN.OCEAN]=8},
    phrase="icp",
}
spells.POLYMORPH = Spell:new{name="polymorph", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=9, [const.CLASS.MAGE]=4, [const.DOMAIN.MOON]=9, [const.DOMAIN.NATURE]=9},
    phrase="poly",
}
spells.POWER_WORD_BLIND = Spell:new{name="power word blind", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.DARKNESS]=8, [const.DOMAIN.DROW]=8, [const.DOMAIN.PROWESS]=8},
    phrase="pwb",
}
spells.POWER_WORD_KILL = Spell:new{name="power word kill", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=9, [const.DOMAIN.DARKNESS]=9, [const.DOMAIN.DROW]=9, [const.DOMAIN.PROWESS]=9, [const.DOMAIN.RETRIBUTION]=9},
    phrase="pwk",
}
spells.POWER_WORD_STUN = Spell:new{name="power word stun", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.MAGE]=8, [const.DOMAIN.PROWESS]=7},
    phrase="pws",
}
spells.PRAYER = Spell:new{name="prayer", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.PALADIN]=3},
    phrase="pray",
}
spells.PRESERVATION = Spell:new{name="preservation", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.MAGE]=3},
    phrase="preserve",
}
spells.PRODUCE_FLAME = Spell:new{name="produce flame", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=1, [const.DOMAIN.FIRE]=2, [const.DOMAIN.SUN]=2}, noarg=true,
    phrase="fipr",
}
spells.PROTECTION = Spell:new{name="protection", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=1, [const.CLASS.PALADIN]=1},
    phrase="prot",
}

spells.RAISE_DEAD = Spell:new{name="raise dead", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=5, [const.CLASS.DRUID]=5},
    phrase="raise",
}
spells.RAY_OF_FROST = Spell:new{name="ray of frost", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=0},
    phrase="icr",
}
spells.READ_MAGIC = Spell:new{name="read magic", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=0, [const.CLASS.CLERIC]=0, [const.CLASS.DRUID]=0, [const.CLASS.MAGE]=0, [const.CLASS.PALADIN]=1, [const.CLASS.RANGER]=1}, noarg=true,
    phrase="read",
}
spells.REDUCE_ANIMAL = Spell:new{name="reduce animal", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=2, [const.CLASS.RANGER]=3},
    phrase="redan",
}
spells.REDUCE_PERSON = Spell:new{name="reduce person", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.HATRED]=1},
    phrase="redper",
}
spells.REFRESH = Spell:new{name="refresh", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=1, [const.CLASS.CLERIC]=1, [const.CLASS.DRUID]=1, [const.CLASS.PALADIN]=1, [const.CLASS.RANGER]=1},
    phrase="ref",
}
spells.REGENERATE = Spell:new{name="regenerate", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=7, [const.CLASS.DRUID]=9, [const.DOMAIN.RENEWAL]=6},
    phrase="regen",
}
spells.REJUVENATION = Spell:new{name="rejuvenation", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.DOMAIN.RENEWAL]=7},
    phrase="rejuv",
}
spells.REMOVE_CURSE = Spell:new{name="remove curse", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.CLERIC]=3, [const.CLASS.MAGE]=4, [const.CLASS.PALADIN]=3},
    phrase="rcur",
}
spells.REMOVE_PARALYSIS = Spell:new{name="remove paralysis", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.PALADIN]=2},
    phrase="rpar",
}
spells.RESILIENCE = Spell:new{name="resilience", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=3, [const.CLASS.MAGE]=3, [const.CLASS.PALADIN]=2, [const.DOMAIN.PROTECTION]=2, [const.DOMAIN.RENEWAL]=2},
    phrase="res",
}
spells.RESISTANCE = Spell:new{name="resistance", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=0, [const.CLASS.CLERIC]=0, [const.CLASS.DRUID]=0, [const.CLASS.MAGE]=0, [const.CLASS.PALADIN]=1},
    phrase="resist",
}
spells.RESIST_ACID = Spell:new{name="resist acid", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.CLASS.PALADIN]=2, [const.CLASS.RANGER]=1},
    phrase="resa",
}
spells.RESIST_COLD = Spell:new{name="resist cold", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.CLASS.PALADIN]=2, [const.CLASS.RANGER]=1},
    phrase="resc",
}
spells.RESIST_ELECTRICITY = Spell:new{name="resist electricity", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.CLASS.PALADIN]=2, [const.CLASS.RANGER]=1},
    phrase="rese",
}
spells.RESIST_FIRE = Spell:new{name="resist fire", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.CLASS.PALADIN]=2, [const.CLASS.RANGER]=1},
    phrase="resf",
}
spells.RESTORATION = Spell:new{name="restoration", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=4, [const.CLASS.PALADIN]=4, [const.DOMAIN.RENEWAL]=3},
    phrase="restore",
}
spells.RESURRECTION = Spell:new{name="resurrection", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=9, [const.DOMAIN.SUN]=9},
    phrase="resur",
}
spells.REVIVE = Spell:new{name="revive", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=3, [const.DOMAIN.RENEWAL]=1},
    phrase="rev",
}
spells.RIGHTEOUS_FURY = Spell:new{name="righteous fury", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.PALADIN]=3, [const.DOMAIN.PROWESS]=3}, noarg=true,
    phrase="fur",
}

spells.SANCTUARY = Spell:new{name="sanctuary", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=1},
    phrase="sanc",
}
spells.SANDSTORM = Spell:new{name="sandstorm", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=6},
    phrase="sand",
}
spells.SCINTILLATING_PATTERN = Spell:new{name="scintillating pattern", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=8, [const.DOMAIN.ILLUSION]=8},
    phrase="scint",
}
spells.SEARING_LIGHT = Spell:new{name="searing light", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=3, [const.DOMAIN.SUN]=3},
    phrase="sear",
}
spells.SHADOW_BINDING = Spell:new{name="shadow binding", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=3},
    phrase="bind",
}
spells.SHADOW_WALK = Spell:new{name="shadow walk", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.BARD]=5, [const.CLASS.MAGE]=6, [const.DOMAIN.DARKNESS]=7, [const.DOMAIN.HALFLING]=7},
    phrase="shadwalk",
}
spells.SHIELD = Spell:new{name="shield", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.GNOME]=1, [const.DOMAIN.PROTECTION]=1, [const.DOMAIN.RETRIBUTION]=1}, noarg=true,
    phrase="shi",
}
spells.SHIELD_OF_FAITH = Spell:new{name="shield of faith", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=1},
    phrase="fshi",
}
spells.SHOCKING_GRASP = Spell:new{name="shocking grasp", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.STORMS]=1},
    phrase="elg",
}
spells.SHOCKSHIELD = Spell:new{name="shockshield", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=4}, noarg=true,
    phrase="elshi",
}
spells.SHOUT = Spell:new{name="shout", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.BARD]=3},
    phrase="shout",
}
spells.SILENCE = Spell:new{name="silence", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=2, [const.DOMAIN.HATRED]=2},
    phrase="sil",
}
spells.SKULK = Spell:new{name="skulk", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=4}, noarg=true,
    phrase="skulk",
}
spells.SLAY_LIVING = Spell:new{name="slay living", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=5},
    phrase="slay",
}
spells.SLEEP = Spell:new{name="sleep", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=1, [const.CLASS.MAGE]=1, [const.DOMAIN.DARKNESS]=1},
    phrase="sleep",
}
spells.SNOWBALL_SWARM = Spell:new{name="snowball swarm", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.MAGE]=2},
    phrase="icsw",
}
spells.SORROW = Spell:new{name="sorrow", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=1, [const.CLASS.CLERIC]=1},
    phrase="sorr",
}
spells.SOUND_BURST = Spell:new{name="sound burst", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=2, [const.DOMAIN.DESTRUCTION]=2},
    phrase="burst",
}
spells.SPEAK_WITH_DEAD = Spell:new{name="speak with dead", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=3}, noarg=true,
    phrase="speakdead",
}
spells.SPELL_RESISTANCE = Spell:new{name="spell resistance", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=5},
    phrase="sres",
}
spells.SPIDER_CLIMB = Spell:new{name="spider climb", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=2, [const.CLASS.MAGE]=2, [const.DOMAIN.DROW]=1},
    phrase="spid",
}
spells.STARFLIGHT = Spell:new{name="starflight", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.DOMAIN.MAGIC]=4},
    phrase="sfly",
}
spells.STONE_BODY = Spell:new{name="stone body", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=8, [const.CLASS.DRUID]=7, [const.CLASS.MAGE]=8, [const.DOMAIN.EARTH]=8}, noarg=true,
    phrase="sb",
}
spells.STONE_BONE = Spell:new{name="stone bone", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=2, [const.CLASS.MAGE]=2},
    phrase="sbone",
}
spells.STONE_SKIN = Spell:new{name="stone skin", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.DRUID]=5, [const.CLASS.MAGE]=4, [const.DOMAIN.EARTH]=5, [const.DOMAIN.ELF]=5, [const.DOMAIN.PROTECTION]=5, [const.DOMAIN.PROWESS]=5},
    phrase="ss",
}
spells.STONE_WALK = Spell:new{name="stone walk", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.DOMAIN.EARTH]=6, [const.DOMAIN.GNOME]=6},
    phrase="stonewalk",
}
spells.STORM_OF_VENGEANCE = Spell:new{name="storm of vengeance", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=9, [const.CLASS.DRUID]=9, [const.DOMAIN.STORMS]=9},
    phrase="veng",
}
spells.SUMMON = Spell:new{name="summon", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.HALFLING]=8, [const.DOMAIN.PLANNING]=8},
    phrase="summon",
}
spells.SUMMON_MONSTER_1 = Spell:new{name="summon monster 1", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=1, [const.CLASS.MAGE]=1}, noarg=true,
    phrase="summon1",
}
spells.SUMMON_MONSTER_2 = Spell:new{name="summon monster 2", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=2}, noarg=true,
    phrase="summon2",
}
spells.SUMMON_MONSTER_3 = Spell:new{name="summon monster 3", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=3}, noarg=true,
    phrase="summon3",
}
spells.SUMMON_MONSTER_4 = Spell:new{name="summon monster 4", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=4}, noarg=true,
    phrase="summon4",
}
spells.SUMMON_MONSTER_5 = Spell:new{name="summon monster 5", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=5}, noarg=true,
    phrase="summon5",
}
spells.SUMMON_MONSTER_6 = Spell:new{name="summon monster 6", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=6}, noarg=true,
    phrase="summon6",
}
spells.SUMMON_MONSTER_7 = Spell:new{name="summon monster 7", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=7}, noarg=true,
    phrase="summon7",
}
spells.SUMMON_MONSTER_8 = Spell:new{name="summon monster 8", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=8}, noarg=true,
    phrase="summon8",
}
spells.SUMMON_MONSTER_9 = Spell:new{name="summon monster 9", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=9}, noarg=true,
    phrase="summon9",
}
spells.SUMMON_MOUNT = Spell:new{name="summon mount", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=2}, noarg=true,
    phrase="summount",
}
spells.SUNBEAM = Spell:new{name="sunbeam", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.DRUID]=7, [const.DOMAIN.NATURE]=6, [const.DOMAIN.SUN]=6},
    phrase="sunbe",
}
spells.SUNBURST = Spell:new{name="sunburst", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.DRUID]=8, [const.DOMAIN.ELF]=7, [const.DOMAIN.SUN]=7},
    phrase="sunbu",
}
spells.SUSTAIN = Spell:new{name="sustain", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.DOMAIN.PLANNING]=4, [const.DOMAIN.RENEWAL]=4},
    phrase="sust",
}

spells.TELEPORT = Spell:new{name="teleport", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.TRAVEL]=8},
    phrase="tele",
}
spells.THORN_SPRAY = Spell:new{name="thorn spray", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.DRUID]=4},
    phrase="thorn",
}
spells.TIMESTOP = Spell:new{name="timestop", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.MAGE]=9, [const.DOMAIN.PLANNING]=9, [const.DOMAIN.TRICKERY]=9},
    phrase="ts",
}
spells.TONGUES = Spell:new{name="tongues", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=4, [const.CLASS.MAGE]=3, [const.DOMAIN.GNOME]=4},
    phrase="tong",
}
spells.TOUCH_OF_JUSTICE = Spell:new{name="touch of justice", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.DOMAIN.RETRIBUTION]=8},
    phrase="just",
}
spells.TRANSPORT = Spell:new{name="transport", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.MAGIC]=7, [const.DOMAIN.PLANNING]=7, [const.DOMAIN.TRADE]=7, [const.DOMAIN.TRAVEL]=7},
    phrase="transp",
}
spells.TREE_STRIDE = Spell:new{name="tree stride", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.DRUID]=5, [const.CLASS.RANGER]=4, [const.DOMAIN.ELF]=4, [const.DOMAIN.NATURE]=4},
    phrase="tree",
}
spells.TRUE_SIGHT = Spell:new{name="true sight", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.CLERIC]=5, [const.CLASS.DRUID]=7, [const.CLASS.MAGE]=6, [const.DOMAIN.KNOWLEDGE]=5, [const.DOMAIN.TRADE]=5}, noarg=true,
    phrase="see",
}
spells.TRUE_STRIKE = Spell:new{name="true strike", sphere=const.SPELL_SPHERE.DIVINATION,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.ELF]=1, [const.DOMAIN.FATE]=1},
    phrase="stri",
}

spells.UNDEATHS_ETERNAL_FOE = Spell:new{name="undeaths eternal foe", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.CLERIC]=9, [const.DOMAIN.ELF]=9, [const.DOMAIN.PROTECTION]=9},
    phrase="uef",
}
spells.UNDEATH_TO_DEATH = Spell:new{name="undeath to death", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.CLERIC]=6, [const.CLASS.MAGE]=6, [const.DOMAIN.RETRIBUTION]=5},
    phrase="utd",
}
spells.UNHOLY_BLIGHT = Spell:new{name="unholy blight", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=4, [const.DOMAIN.TYRANNY]=4},
    phrase="evmin",
}

spells.VALIANCE = Spell:new{name="valiance", sphere=const.SPELL_SPHERE.ABJURATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=3, [const.CLASS.MAGE]=3},
    phrase="val",
}
spells.VAMPIRIC_TOUCH = Spell:new{name="vampiric touch", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=3},
    phrase="vam",
}
spells.VENTRILOQUISM = Spell:new{name="ventriloquism", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.BARD]=1, [const.CLASS.MAGE]=1, [const.DOMAIN.TRICKERY]=1},
    phrase="vent",
}

spells.WAIL_OF_THE_BANSHEE = Spell:new{name="wail of the banshee", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=9, [const.DOMAIN.DESTRUCTION]=9, [const.DOMAIN.HATRED]=9},
    phrase="wail",
}
spells.WATER_BREATHING = Spell:new{name="water breathing", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=3, [const.CLASS.MAGE]=3, [const.DOMAIN.OCEAN]=3},
    phrase="wat",
}
spells.WAVES_OF_EXHAUSTION = Spell:new{name="waves of exhaustion", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=7, [const.DOMAIN.SUFFERING]=8, [const.DOMAIN.TRICKERY]=8},
    phrase="wex",
}
spells.WAVES_OF_FATIGUE = Spell:new{name="waves of fatigue", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=5, [const.DOMAIN.TRICKERY]=5},
    phrase="wfat",
}
spells.WAVE_OF_GRIEF = Spell:new{name="wave of grief", sphere=const.SPELL_SPHERE.ENCHANTMENT,
    levels={[const.CLASS.BARD]=2, [const.CLASS.CLERIC]=2, [const.DOMAIN.SUFFERING]=2},
    phrase="wgri",
}
spells.WEAKEN = Spell:new{name="weaken", sphere=const.SPELL_SPHERE.NECROMANCY,
    levels={[const.CLASS.MAGE]=1, [const.DOMAIN.SUFFERING]=1, [const.DOMAIN.TYRANNY]=1},
    phrase="weak",
}
spells.WEAPON_OF_ENERGY = Spell:new{name="weapon of energy", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=7, [const.CLASS.MAGE]=7, [const.DOMAIN.MAGIC]=6},
    phrase="eweap", incantation="^eweap(?<energy>c|e|f)(?<target> +.*)?$", response=[[
        local energies = {c="cold", e="electricity", f="fire"}
        local energy = energies[string.lower("%<energy>")]
        local target = trim("%<target>")
        local cmd = "cast 'weapon of energy' %s %s"
        Send(cmd:format(target, energy))
    ]],
}
spells.WEB = Spell:new{name="web", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.MAGE]=2, [const.DOMAIN.DROW]=3},
    phrase="web",
}
spells.WEIRD = Spell:new{name="weird", sphere=const.SPELL_SPHERE.ILLUSION,
    levels={[const.CLASS.MAGE]=9, [const.DOMAIN.ILLUSION]=9},
    phrase="mpk",
}
spells.WIND_WALK = Spell:new{name="wind walk", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=7, [const.DOMAIN.TRAVEL]=5},
    phrase="wind",
}
spells.WINGED_MOUNT = Spell:new{name="winged mount", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.PALADIN]=4},
    phrase="wing",
}
spells.WINTER_MIST = Spell:new{name="winter mist", sphere=const.SPELL_SPHERE.TRANSMUTATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.MAGE]=3, [const.DOMAIN.OCEAN]=2},
    phrase="icv",
}
spells.WITCH_LIGHT = Spell:new{name="witch light", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.BARD]=3, [const.CLASS.CLERIC]=3, [const.CLASS.DRUID]=3, [const.CLASS.MAGE]=3, [const.CLASS.PALADIN]=3}, noarg=true,
    phrase="wlig",
}
spells.WORD_OF_CHAOS = Spell:new{name="word of chaos", sphere=const.SPELL_SPHERE.EVOCATION,
    levels={[const.CLASS.CLERIC]=7},
    phrase="chmaj",
}
spells.WORD_OF_RECALL = Spell:new{name="word of recall", sphere=const.SPELL_SPHERE.CONJURATION,
    levels={[const.CLASS.CLERIC]=6, [const.CLASS.DRUID]=6}, noarg=true,
    phrase="rec",
}
