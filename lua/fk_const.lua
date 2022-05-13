local const = {}


-- To be used by event trackers' BroadcastPlugin/OnPluginBroadcast
-- functions as the numeric message type.
const.EVENT_TYPE = {
    ["LOGIN"] = 0,

    -- eg, standing, sitting, meditating...
    ["POSITION"] = 1,

    ["COMBAT"] = 2,

    ["COMMUNICATION"] = 3,

    -- eg, combatmode, killmode, speed...
    ["CONFIG"] = 4,

    -- Regaining spells, daily abilities, etc.
    ["RECOVERY"] = 5,

    -- eg, wearing eq, putting items into containers.
    ["INVENTORY"] = 6,

    -- Skill gains and level-ups.
    ["IMPROVEMENT"] = 7,

    -- Invitations, followers, etc.
    ["GROUP"] = 8,

    -- Hunger, thirst, drunkenness.
    ["HUNGER"] = 9,

    ["WEATHER"] = 10,
}


-- FK-specific plugin ids indexed by name, excluding the 'FK_'.
const.PLUGIN = {
    EVENT_HANDLER = "35365d0a213358e5f89e11cd",
}


-- Character classes.
const.CLASS = {
    ABJURER = "Abjurer",
    BARD = "Bard",
    CLERIC = "Cleric",
    CONJURER = "Conjurer",
    DRUID = "Druid",
    ENCHANTER = "Enchanter",
    EVOKER = "Evoker",
    FIGHTER = "Fighter",
    ILLUSIONIST = "Illusionist",
    MAGE = "Mage",
    NECROMANCER = "Necromancer",
    PALADIN = "Paladin",
    RANGER = "Ranger",
    THIEF = "Thief",
    TRANSMUTER = "Transmuter",
}


-- Cleric domains.
const.DOMAIN = {
    CHARM = "Charm",
    DARKNESS = "Darkness",
    DESTRUCTION = "Destruction",
    DROW = "Drow",
    EARTH = "Earth",
    ELF = "Elf",
    FATE = "Fate",
    FIRE = "Fire",
    GNOME = "Gnome",
    HALFLING = "Halfling",
    HATRED = "Hatred",
    ILLUSION = "Illusion",
    KNOWLEDGE = "Knowledge",
    MAGIC = "Magic",
    MOON = "Moon",
    NATURE = "Nature",
    OCEAN = "Ocean",
    PLANNING = "Planning",
    PROTECTION = "Protection",
    PROWESS = "Prowess",
    RENEWAL = "Renewal",
    RETRIBUTION = "Retribution",
    STORMS = "Storms",
    SUFFERING = "Suffering",
    SUN = "Sun",
    TRADE = "Trade",
    TRAVEL = "Travel",
    TRICKERY = "Trickery",
    TYRANNY = "Tyranny",
}


-- Spell spheres.
const.SPELL_SPHERE = {
    ABJURATION = "Abjuration",
    CONJURATION = "Conjuration",
    DIVINATION = "Divination",
    ENCHANTMENT = "Enchantment",
    EVOCATION = "Evocation",
    ILLUSION = "Illusion",
    NECROMANCY = "Necromancy",
    TRANSMUTATION = "Transmutation",
}


-- Combat event types.
const.COMBAT_TYPE = {
    MELEE = "melee",
    SKILL = "skill",
    SPELL = "spell",
    DAMAGE = "damage",
    ENGAGE = "engage",
    DEATH = "death",
}


-- Damage types.
const.DAMTYPE = {
    ACID = "acid",
    BACKSTAB = "backstab",
    BASH = "bash",
    BITE = "bite",
    BREATH = "breath",
    CLAW = "claw",
    COLD = "cold",
    DEATH = "death",
    DRAIN = "drain",
    EARTH = "earth",
    ELECTRICITY = "electricity",
    FIRE = "fire",
    HIT = "hit",
    KICK = "kick",
    MAGIC = "magic",
    PIERCE = "pierce",
    PUNCH = "punch",
    SLASH = "slash",
    TAIL = "tail",
    TENTACLE = "tentacle",
    VARIANT = "variant",
    WATER = "water",
    WING = "wing",
}


-- Points of view in combat.
const.COMBAT_POSITION = {
    -- The current char is doing the attacking.
    OFFENSE = "offense",
    -- The current char is being attacked.
    DEFENSE = "defense",
    -- The current char is neither attacker nor defender.
    OBSERVANT = "observant",
}


--------------------------------------------------
-- Combat messages.

-- Note that it is recommended to set the sequence of triggers that
--     use messages with the OBSERVANT position to be higher than
--     those that use OFFENSE/DEFENSE position messages, as there can
--     be some overlap with the regexes.
--------------------------------------------------

const.COMBAT_MSG = {
    -- Damage
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=1, regex="^(?<defender>.+) is slightly scratched\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=2, regex="^(?<defender>.+) has a few small cuts\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=3, regex="^(?<defender>.+) is badly bruised\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=4, regex="^(?<defender>.+) has several minor wounds\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=5, regex="^(?<defender>.+) has a couple of severe gashes\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=6, regex="^(?<defender>.+) is covered in cuts and bruises\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=7, regex="^(?<defender>.+) is badly injured\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=8, regex="^(?<defender>.+) is bleeding from several injuries\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=9, regex="^(?<defender>.+) is bleeding freely\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=10, regex="^(?<defender>.+) has several traumatic wounds\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=11, regex="^(?<defender>.+) has blood gushing from several grievous wounds\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=12, regex="^(?<defender>.+) is leaking heart-blood\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=13, regex="^(?<defender>.+) has suffered mortal injury\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=14, regex="^(?<defender>.+) is slowly bleeding to death\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=15, regex="^(?<defender>.+) is close to death\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=16, regex="^(?<defender>.+) is stunned, but will probably recover\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.DAMAGE, order=17, regex="^(?<defender>.+) is mortally wounded, and will die soon, if not aided\\.$"},

    -- Offense engage
    {position=const.COMBAT_POSITION.OFFENSE, type=const.COMBAT_TYPE.ENGAGE, regex="^(?<offender>You) (?<approach>approach|surprise) (?<defender>.+) and prepare to engage (?:him|her|it) in combat!$"},

    -- Offense skill
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.SKILL, damtype=const.DAMTYPE.VARIANT, name="opportunist", regex="^As .+ hits their target, (?<offender>you) take the opportunity to strike!$"},

    -- Offense backstab
    {position=const.COMBAT_POSITION.OFFENSE, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=1, regex="^(?<defender>.+) quickly turns to avoid (?<offender>you)r sneak attack!$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=2, regex="^(?<defender>.+) quickly avoids your attempt to flank \\w+ and turns to face (?<offender>you)!$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=1, regex="^(?<defender>.+) makes a strange sound as (?<offender>you) land a sneak attack with .+!$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=2, regex="^(?<offender>You) circle around (?<defender>.+) and attack \\w+ while \\w+ is distracted!$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=3, regex="^(?<defender>.+) is suddenly very silent as (?<offender>you) land .+ in a critical spot\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=4, regex="^(?<defender>.+) goes down as (?<offender>you)r attack on \\w+ inflicts a fatal wound\\.$"},

    -- Offense bash
    {position=const.COMBAT_POSITION.OFFENSE, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=1, regex="^(?<defender>.+) evades (?<offender>you)r crushing attack\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=1, regex="^(?<offender>You)r crush grazes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=2, regex="^(?<offender>You)r crush hits (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=3, regex="^(?<offender>You)r crush skillfully hits (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=4, regex="^(?<offender>You)r crush deftly hits (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=5, regex="^(?<offender>You)r crush violently hits (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=6, regex="^(?<offender>You)r crush crushes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=7, regex="^(?<offender>You)r crush skillfully crushes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=8, regex="^(?<offender>You)r crush deftly crushes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=9, regex="^(?<offender>You)r crush violently crushes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=10, regex="^With a bonecrunching sound (?<offender>you)r crush smashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=11, regex="^With a bonecrunching sound (?<offender>you)r crush skillfully smashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=12, regex="^With a bonecrunching sound (?<offender>you)r crush deftly smashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=13, regex="^With a bonecrunching sound (?<offender>you)r crush violently smashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=14, regex="^(?<offender>You)r crush shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=15, regex="^(?<offender>You)r crush skillfully shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=16, regex="^(?<offender>You)r crush deftly shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=17, regex="^(?<offender>You)r crush violently shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=18, regex="^(?<offender>You)r crush beats (?<defender>.+) to a bloody pulp\\.$"},

    -- Offense pierce
    {position=const.COMBAT_POSITION.OFFENSE, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=1, regex="^(?<defender>.+) sidesteps (?<offender>you)r piercing attack\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=1, regex="^(?<offender>You)r pierce bruises (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=2, regex="^(?<offender>You)r pierce nicks (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=3, regex="^(?<offender>You)r pierce scratches (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=4, regex="^(?<offender>You)r pierce shallowly cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=5, regex="^(?<offender>You)r pierce cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=6, regex="^(?<offender>You)r pierce deeply cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=7, regex="^(?<offender>You)r pierce shallowly penetrates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=8, regex="^(?<offender>You)r pierce penetrates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=9, regex="^(?<offender>You)r pierce deeply penetrates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=10, regex="^With a sickening sound (?<offender>you)r pierce perforates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=11, regex="^With a sickening sound (?<offender>you)r pierce deeply perforates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=12, regex="^With a sickening sound (?<offender>you)r pierce shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=13, regex="^With a sickening sound (?<offender>you)r pierce violently shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=14, regex="^(?<offender>You)r pierce tears open (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=15, regex="^(?<offender>You)r pierce tears wounds into (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=16, regex="^(?<offender>You)r pierce tears a gaping wound into (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=17, regex="^(?<offender>You)r pierce minces (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=18, regex="^(?<offender>You)r pierce nearly bisects (?<defender>.+)'s .+\\.$"},

    -- Offense slash
    {position=const.COMBAT_POSITION.OFFENSE, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=1, regex="^(?<defender>.+) ducks under (?<offender>you)r slashing attack\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=1, regex="^(?<offender>You)r slash cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=2, regex="^(?<offender>You)r slash skillfully cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=3, regex="^(?<offender>You)r slash viciously cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=4, regex="^(?<offender>You)r slash slashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=5, regex="^(?<offender>You)r slash viciously slashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=6, regex="^(?<offender>You)r slash skillfully slashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=7, regex="^(?<offender>You)r slash powerfully slashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=8, regex="^(?<offender>You)r slash lays open (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=9, regex="^(?<offender>You)r slash deeply gashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=10, regex="^With a sickening sound (?<offender>you)r slash shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=11, regex="^With a sickening sound (?<offender>you)r slash skillfully shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=12, regex="^With a sickening sound (?<offender>you)r slash deftly shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=13, regex="^With a sickening sound (?<offender>you)r slash violently shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=14, regex="^(?<offender>You)r slash tears open (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=15, regex="^(?<offender>You)r slash lacerates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=16, regex="^(?<offender>You)r slash tears a gaping wound into (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=17, regex="^(?<offender>You)r slash minces (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OFFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=18, regex="^(?<offender>You)r slash nearly bisects (?<defender>.+)'s .+\\.$"},

    -- Defense engage
    {position=const.COMBAT_POSITION.DEFENSE, type=const.COMBAT_TYPE.ENGAGE, regex="^(?<offender>.+) (?<approach>approaches|surprises) (?<defender>you) and prepares to engage you in combat!$"},

    -- Defense skill
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.SKILL, damtype=const.DAMTYPE.VARIANT, name="uncanny", regex="^(?<defender>You)r uncanny reflexes sense an incoming attack from (?<offender>.+)!$"},

    -- Defense bash
    {position=const.COMBAT_POSITION.DEFENSE, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=1, regex="^(?<defender>You) evade (?<offender>.+)'s crushing attack\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=1, regex="^(?<offender>.+)'s crush grazes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=2, regex="^(?<offender>.+)'s crush hits (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=3, regex="^(?<offender>.+)'s crush skillfully hit (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=4, regex="^(?<offender>.+)'s crush deftly hits (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=5, regex="^(?<offender>.+)'s crush violently hits (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=6, regex="^(?<offender>.+)'s crush crushes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=7, regex="^(?<offender>.+)'s crush skillfully crushes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=8, regex="^(?<offender>.+)'s crush deftly crushes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=9, regex="^(?<offender>.+)'s crush violently crushes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=10, regex="^With a bonecrunching sound (?<offender>.+)'s crush smashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=11, regex="^With a bonecrunching sound (?<offender>.+)'s crush skillfully smashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=12, regex="^With a bonecrunching sound (?<offender>.+)'s crush deftly smashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=13, regex="^With a bonecrunching sound (?<offender>.+)'s crush violently smashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=14, regex="^(?<offender>.+)'s crush shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=15, regex="^(?<offender>.+)'s crush skillfully shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=16, regex="^(?<offender>.+)'s crush deftly shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=17, regex="^(?<offender>.+)'s crush violently shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=18, regex="^(?<offender>.+)'s crush beats (?<defender>you) to a bloody pulp\\.$"},

    -- Defense pierce
    {position=const.COMBAT_POSITION.DEFENSE, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=1, regex="^(?<defender>You) sidestep (?<offender>.+)'s piercing attack\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=1, regex="^(?<offender>.+)'s pierce bruises (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=2, regex="^(?<offender>.+)'s pierce nicks (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=3, regex="^(?<offender>.+)'s pierce scratches (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=4, regex="^(?<offender>.+)'s pierce shallowly cuts (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=5, regex="^(?<offender>.+)'s pierce cuts (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=6, regex="^(?<offender>.+)'s pierce deeply cuts (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=7, regex="^(?<offender>.+)'s pierce shallowly penetrates (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=8, regex="^(?<offender>.+)'s pierce penetrates (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=9, regex="^(?<offender>.+)'s pierce deeply penetrates (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=10, regex="^With a sickening sound (?<offender>.+)'s pierce perforates (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=11, regex="^With a sickening sound (?<offender>.+)'s pierce deeply perforates (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=12, regex="^With a sickening sound (?<offender>.+)'s pierce shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=13, regex="^With a sickening sound (?<offender>.+)'s pierce violently shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=14, regex="^(?<offender>.+)'s pierce tears open (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=15, regex="^(?<offender>.+)'s pierce tears wounds into (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=16, regex="^(?<offender>.+)'s pierce tears a gaping wound into (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=17, regex="^(?<offender>.+)'s pierce minces (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=18, regex="^(?<offender>.+)'s pierce nearly bisects (?<defender>you)r .+\\.$"},

    -- Defense slash
    {position=const.COMBAT_POSITION.DEFENSE, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=1, regex="^(?<defender>You) duck under (?<offender>.+)'s slashing attack\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=1, regex="^(?<offender>.+)'s slash cuts (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=2, regex="^(?<offender>.+)'s slash skillfully cuts (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=3, regex="^(?<offender>.+)'s slash viciously cuts (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=4, regex="^(?<offender>.+)'s slash slashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=5, regex="^(?<offender>.+)'s slash viciously slashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=6, regex="^(?<offender>.+)'s slash skillfully slashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=7, regex="^(?<offender>.+)'s slash powerfully slashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=8, regex="^(?<offender>.+)'s slash lays open (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=9, regex="^(?<offender>.+)'s slash deeply gashes (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=10, regex="^With a sickening sound (?<offender>.+)'s slash shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=11, regex="^With a sickening sound (?<offender>.+)'s slash skillfully shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=12, regex="^With a sickening sound (?<offender>.+)'s slash deftly shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=13, regex="^With a sickening sound (?<offender>.+)'s slash violently shreds (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=14, regex="^(?<offender>.+)'s slash tears open (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=15, regex="^(?<offender>.+)'s slash lacerates (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=16, regex="^(?<offender>.+)'s slash tears a gaping wound into (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=17, regex="^(?<offender>.+)'s slash minces (?<defender>you)r .+\\.$"},
    {position=const.COMBAT_POSITION.DEFENSE, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=18, regex="^(?<offender>.+)'s slash nearly bisects (?<defender>you)r .+\\.$"},

    -- Death
    {position=const.COMBAT_POSITION.OBSERVANT, type=const.COMBAT_TYPE.DEATH, regex="^(?<defender>.+) is DE(?:AD|STROYED)!$"},

    -- Observant engage
    {position=const.COMBAT_POSITION.OBSERVANT, type=const.COMBAT_TYPE.ENGAGE, regex="^(?<offender>.+) (?<approach>approaches|surprises) (?<defender>.+) and prepares to engage (?:him|her|it) in combat!$"},

    -- Observant skill
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.SKILL, damtype=const.DAMTYPE.VARIANT, name="uncanny", regex="^(?<defender>.+) somehow senses that (?<offender>.+) is about to attack \\w+!$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.SKILL, damtype=const.DAMTYPE.VARIANT, name="opportunist", regex="^(?<offender>.+) attempts an opportunistic strike on (?<defender>.+)!$"},

    -- Observant backstab
    {position=const.COMBAT_POSITION.OBSERVANT, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=1, regex="^(?<offender>.+) tries to sneak attack (?<defender>.+) but misses!$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=2, regex="^(?<offender>.+) tries to circle \\w+ victim but (?<defender>.+) turns to face \\w+!$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=1, regex="^(?<defender>.+) makes a strange sound as (?<offender>.+) lands a sneak attack with .+!$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=2, regex="^(?<offender>.+) circles around (?<defender>.+) and attacks \\w+ whilst \\w+ attention is elsewhere!$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BACKSTAB, order=3, regex="^(?<offender>.+) sneak attacks (?<defender>.+), leaving a corpse\\.$"},

    -- Observant bash
    {position=const.COMBAT_POSITION.OBSERVANT, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=1, regex="^(?<defender>.+) evades (?<offender>.+)'s crushing attack\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=1, regex="^(?<offender>.+)'s crush grazes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=2, regex="^(?<offender>.+)'s crush hits (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=3, regex="^(?<offender>.+)'s crush skillfully hits (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=4, regex="^(?<offender>.+)'s crush deftly hits (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=5, regex="^(?<offender>.+)'s crush violently hits (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=6, regex="^(?<offender>.+)'s crush crushes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=7, regex="^(?<offender>.+)'s crush skillfully crushes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=8, regex="^(?<offender>.+)'s crush deftly crushes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=9, regex="^(?<offender>.+)'s crush violently crushes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=10, regex="^With a bonecrunching sound (?<offender>.+)'s crush smashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=11, regex="^With a bonecrunching sound (?<offender>.+)'s crush skillfully smashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=12, regex="^With a bonecrunching sound (?<offender>.+)'s crush deftly smashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=13, regex="^With a bonecrunching sound (?<offender>.+)'s crush violently smashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=14, regex="^(?<offender>.+)'s crush shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=15, regex="^(?<offender>.+)'s crush skillfully shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=16, regex="^(?<offender>.+)'s crush deftly shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=17, regex="^(?<offender>.+)'s crush violently shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.BASH, order=18, regex="^(?<offender>.+)'s crush beats (?<defender>.+) to a bloody pulp\\.$"},

    -- Observant pierce
    {position=const.COMBAT_POSITION.OBSERVANT, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=1, regex="^(?<defender>.+) sidesteps (?<offender>.+)'s piercing attack\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=1, regex="^(?<offender>.+)'s pierce bruises (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=2, regex="^(?<offender>.+)'s pierce nicks (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=3, regex="^(?<offender>.+)'s pierce scratches (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=4, regex="^(?<offender>.+)'s pierce shallowly cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=5, regex="^(?<offender>.+)'s pierce cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=6, regex="^(?<offender>.+)'s pierce deeply cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=7, regex="^(?<offender>.+)'s pierce shallowly penetrates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=8, regex="^(?<offender>.+)'s pierce penetrates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=9, regex="^(?<offender>.+)'s pierce deeply penetrates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=10, regex="^With a sickening sound (?<offender>.+)'s pierce perforates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=11, regex="^With a sickening sound (?<offender>.+)'s pierce deeply perforates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=12, regex="^With a sickening sound (?<offender>.+)'s pierce shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=13, regex="^With a sickening sound (?<offender>.+)'s pierce violently shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=14, regex="^(?<offender>.+)'s pierce tears open (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=15, regex="^(?<offender>.+)'s pierce tears wounds into (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=16, regex="^(?<offender>.+)'s pierce tears a gaping wound into (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=17, regex="^(?<offender>.+)'s pierce minces (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.PIERCE, order=18, regex="^(?<offender>.+)'s pierce nearly bisects (?<defender>.+)'s .+\\.$"},

    -- Observant slash
    {position=const.COMBAT_POSITION.OBSERVANT, success=false, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=1, regex="^(?<defender>.+) ducks under (?<offender>.+)'s slashing attack\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=1, regex="^(?<offender>.+)'s slash cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=2, regex="^(?<offender>.+)'s slash skillfully cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=3, regex="^(?<offender>.+)'s slash viciously cuts (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=4, regex="^(?<offender>.+)'s slash slashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=5, regex="^(?<offender>.+)'s slash viciously slashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=6, regex="^(?<offender>.+)'s slash skillfully slashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=7, regex="^(?<offender>.+)'s slash powerfully slashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=8, regex="^(?<offender>.+)'s slash lays open (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=9, regex="^(?<offender>.+)'s slash deeply gashes (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=10, regex="^With a sickening sound (?<offender>.+)'s slash shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=11, regex="^With a sickening sound (?<offender>.+)'s slash skillfully shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=12, regex="^With a sickening sound (?<offender>.+)'s slash deftly shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=13, regex="^With a sickening sound (?<offender>.+)'s slash violently shreds (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=14, regex="^(?<offender>.+)'s slash tears open (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=15, regex="^(?<offender>.+)'s slash lacerates (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=16, regex="^(?<offender>.+)'s slash tears a gaping wound into (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=17, regex="^(?<offender>.+)'s slash minces (?<defender>.+)'s .+\\.$"},
    {position=const.COMBAT_POSITION.OBSERVANT, success=true, type=const.COMBAT_TYPE.MELEE, damtype=const.DAMTYPE.SLASH, order=18, regex="^(?<offender>.+)'s slash nearly bisects (?<defender>.+)'s .+\\.$"},
}


return const
