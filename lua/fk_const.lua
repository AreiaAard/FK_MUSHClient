local const = {}


-- To be used by event trackers' BroadcastPlugin/OnPluginBroadcast
-- functions as the numeric message type.
const.EVENT_TYPE = {
    -- eg, standing, sitting, meditating...
    ["POSITION"] = 1,

    ["COMBAT"] = 2,

    ["COMMUNICATION"] = 3,

    -- eg, walking, running...
    ["SPEED"] = 4,

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


return const
