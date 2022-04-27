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


--------------------------------------------------
-- Melee combat messages as regex
-- 
-- Structure: MELEE.<POSITION>.<ACTION>.<DAMTYPE>[index]
-- Position: Either OFFENSE (the current char is the offender),
--     DEFENSE (the current char is the defender), or OBSERVANT (the
--     current char is neither offender nor defender). Recommended to
--     set the sequence of triggers using OBSERVANT messages to be
--     higher than those of OFFENSE and DEFENSE, as there are some
--     instances of duplicate match strings.
-- Action: HIT or MISS.
-- Damtype: BASH, BITE, CLAW, PIERCE, PUNCH, SLASH, etc. This might
--     return nil if no messages are yet implemented for that damtype.
-- Index: Numeric starting from 1.
--------------------------------------------------

const.MELEE = {}


const.MELEE.OFFENSE = {}

const.MELEE.OFFENSE.MISS = {}
const.MELEE.OFFENSE.MISS.BASH = {"^(?<defender>.+) evades (?<offender>you)r crushing attack\\.$"}
const.MELEE.OFFENSE.MISS.PIERCE = {"^(?<defender>.+) sidesteps (?<offender>you)r piercing attack\\.$"}
const.MELEE.OFFENSE.MISS.SLASH = {"^(?<defender>.+) ducks under (?<offender>you)r slashing attack\\.$"}

const.MELEE.OFFENSE.HIT = {}
const.MELEE.OFFENSE.HIT.BASH = {
    "^(?<offender>You)r crush grazes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush hits (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush skillfully hits (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush deftly hits (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush violently hits (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush crushes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush skillfully crushes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush deftly crushes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush violently crushes (?<defender>.+)'s .+\\.$",
    "^With a bonecrunching sound (?<offender>you)r crush smashes (?<defender>.+)'s .+\\.$",
    "^With a bonecrunching sound (?<offender>you)r crush skillfully smashes (?<defender>.+)'s .+\\.$",
    "^With a bonecrunching sound (?<offender>you)r crush deftly smashes (?<defender>.+)'s .+\\.$",
    "^With a bonecrunching sound (?<offender>you)r crush violently smashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush skillfully shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush deftly shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush violently shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r crush beats (?<defender>.+) to a bloody pulp\\.$",
}
const.MELEE.OFFENSE.HIT.PIERCE = {
    "^(?<offender>You)r pierce bruises (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce nicks (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce scratches (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce shallowly cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce deeply cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce shallowly penetrates (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce penetrates (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce deeply penetrates (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>you)r pierce perforates (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>you)r pierce deeply perforates (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>you)r pierce shreds (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>you)r pierce violently shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce tears open (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce tears wounds into (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce tears a gaping wound into (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce minces (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r pierce nearly bisects (?<defender>.+)'s .+\\.$",
}
const.MELEE.OFFENSE.HIT.SLASH = {
    "^(?<offender>You)r slash cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash skillfully cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash viciously cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash slashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash viciously slashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash skillfully slashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash powerfully slashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash lays open (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash deeply gashes (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>you)r slash shreds (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>you)r slash skillfully shreds (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>you)r slash deftly shreds (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>you)r slash violently shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash tears open (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash lacerates (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash tears a gaping wound into (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash minces (?<defender>.+)'s .+\\.$",
    "^(?<offender>You)r slash nearly bisects (?<defender>.+)'s .+\\.$",
}


const.MELEE.DEFENSE = {}

const.MELEE.DEFENSE.MISS = {}
const.MELEE.DEFENSE.MISS.BASH = {"^(?<defender>You) evade (?<offender>.+)'s crushing attack\\.$"}
const.MELEE.DEFENSE.MISS.PIERCE = {"^(?<defender>You) sidestep (?<offender>.+)'s piercing attack\\.$"}
const.MELEE.DEFENSE.MISS.SLASH = {"^(?<defender>You) duck under (?<offender>.+)'s slashing attack\\.$"}

const.MELEE.DEFENSE.HIT = {}
const.MELEE.DEFENSE.HIT.BASH = {
    "^(?<offender>.+)'s crush grazes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush hits (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush skillfully hits (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush deftly hits (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush violently hits (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush crushes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush skillfully crushes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush deftly crushes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush violently crushes (?<defender>you)r .+\\.$",
    "^With a bonecrunching sound (?<offender>.+)'s crush smashes (?<defender>you)r .+\\.$",
    "^With a bonecrunching sound (?<offender>.+)'s crush skillfully smashes (?<defender>you)r .+\\.$",
    "^With a bonecrunching sound (?<offender>.+)'s crush deftly smashes (?<defender>you)r .+\\.$",
    "^With a bonecrunching sound (?<offender>.+)'s crush violently smashes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush shreds (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush skillfully shreds (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush deftly shreds (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush violently shreds (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s crush beats (?<defender>you) to a bloody pulp\\.$",
}
const.MELEE.DEFENSE.HIT.PIERCE = {
    "^(?<offender>.+)'s pierce bruises (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce nicks (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce scratches (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce shallowly cuts (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce cuts (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce deeply cuts (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce shallowly penetrates (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce penetrates (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce deeply penetrates (?<defender>you)r .+\\.$",
    "^With a sickening sound (?<offender>.+)'s pierce perforates (?<defender>you)r .+\\.$",
    "^With a sickening sound (?<offender>.+)'s pierce deeply perforates (?<defender>you)r .+\\.$",
    "^With a sickening sound (?<offender>.+)'s pierce shreds (?<defender>you)r .+\\.$",
    "^With a sickening sound (?<offender>.+)'s pierce violently shreds (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce tears open (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce tears wounds into (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce tears a gaping wound into (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce minces (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s pierce nearly bisects (?<defender>you)r .+\\.$",
}
const.MELEE.DEFENSE.HIT.SLASH = {
    "^(?<offender>.+)'s slash cuts (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash skillfully cuts (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash viciously cuts (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash slashes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash viciously slashes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash skillfully slashes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash powerfully slashes (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash lays open (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash deeply gashes (?<defender>you)r .+\\.$",
    "^With a sickening sound (?<offender>.+)'s slash shreds (?<defender>you)r .+\\.$",
    "^With a sickening sound (?<offender>.+)'s slash skillfully shreds (?<defender>you)r .+\\.$",
    "^With a sickening sound (?<offender>.+)'s slash deftly shreds (?<defender>you)r .+\\.$",
    "^With a sickening sound (?<offender>.+)'s slash violently shreds (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash tears open (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash lacerates (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash tears a gaping wound into (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash minces (?<defender>you)r .+\\.$",
    "^(?<offender>.+)'s slash nearly bisects (?<defender>you)r .+\\.$",
}


const.MELEE.OBSERVANT = {}

const.MELEE.OBSERVANT.MISS = {}
const.MELEE.OBSERVANT.MISS.BASH = {"^(?<defender>.+) evades (?<offender>.+)'s crushing attack\\.$"}
const.MELEE.OBSERVANT.MISS.PIERCE = {"^(?<defender>.+) sidesteps (?<offender>.+)'s piercing attack\\.$"}
const.MELEE.OBSERVANT.MISS.SLASH = {"^(?<defender>.+) ducks under (?<offender>.+)'s slashing attack\\.$"}

const.MELEE.OBSERVANT.HIT = {}
const.MELEE.OBSERVANT.HIT.BASH = {
    "^(?<offender>.+)'s crush grazes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush hits (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush skillfully hits (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush deftly hits (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush violently hits (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush crushes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush skillfully crushes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush deftly crushes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush violently crushes (?<defender>.+)'s .+\\.$",
    "^With a bonecrunching sound (?<offender>.+)'s crush smashes (?<defender>.+)'s .+\\.$",
    "^With a bonecrunching sound (?<offender>.+)'s crush skillfully smashes (?<defender>.+)'s .+\\.$",
    "^With a bonecrunching sound (?<offender>.+)'s crush deftly smashes (?<defender>.+)'s .+\\.$",
    "^With a bonecrunching sound (?<offender>.+)'s crush violently smashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush skillfully shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush deftly shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush violently shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s crush beats (?<defender>.+) to a bloody pulp\\.$",
}
const.MELEE.OBSERVANT.HIT.PIERCE = {
    "^(?<offender>.+)'s pierce bruises (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce nicks (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce scratches (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce shallowly cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce deeply cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce shallowly penetrates (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce penetrates (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce deeply penetrates (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>.+)'s pierce perforates (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>.+)'s pierce deeply perforates (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>.+)'s pierce shreds (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>.+)'s pierce violently shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce tears open (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce tears wounds into (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce tears a gaping wound into (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce minces (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s pierce nearly bisects (?<defender>.+)'s .+\\.$",
}
const.MELEE.OBSERVANT.HIT.SLASH = {
    "^(?<offender>.+)'s slash cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash skillfully cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash viciously cuts (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash slashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash viciously slashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash skillfully slashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash powerfully slashes (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash lays open (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash deeply gashes (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>.+)'s slash shreds (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>.+)'s slash skillfully shreds (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>.+)'s slash deftly shreds (?<defender>.+)'s .+\\.$",
    "^With a sickening sound (?<offender>.+)'s slash violently shreds (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash tears open (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash lacerates (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash tears a gaping wound into (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash minces (?<defender>.+)'s .+\\.$",
    "^(?<offender>.+)'s slash nearly bisects (?<defender>.+)'s .+\\.$",
}


return const
