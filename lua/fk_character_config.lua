require("commas")
require("json")
require("var")
require("wait")

local const = require("fk_const")
require("fk_event")
require("fk_note")



--------------------------------------------------
-- Config
--------------------------------------------------

Config = {}


function Config.initialize()
    Config.load()
    Combatmode.initialize()
    Config.add_broadcast_hooks()
end


function Config.default()
    local data = {
        combatmode = {},
        killmode = {},
    }
    return json.encode(data)
end


function Config.load()
    local strvar = var.config or Config.default()
    local data = json.decode(strvar)
    Config.data = data
end


function Config.save()
    var.config = json.encode(Config.data)
end


function Config.get(key)
    return Config.data[key]
end


function Config.set(key, val)
    Config.data[key] = val
    Config.save()
end


function Config.add_broadcast_hooks()
    local pluginOnPluginBroadcast = OnPluginBroadcast
    if (not pluginOnPluginBroadcast) then
        Utility.msg_major("Unable to add config OnPluginBroadcast hooks.")
        Utility.msg_minor("Plugin lacks callback function declaration.")
        return
    end
    OnPluginBroadcast = function(msg, id, name, text)
        Combatmode.OnPluginBroadcast(msg, id, name, text)
        pluginOnPluginBroadcast(msg, id, name, text)
    end
end



--------------------------------------------------
-- Combatmode
--------------------------------------------------

Combatmode = {}


Combatmode.INITIAL = {
    C = "cast",
    D = "defensive",
    E = "empower",
    H = "heighten",
    L = "enlarge",
    M = "Maximize",
    P = "power",
    Q = "quicken",
    R = "ranged",
    S = "search",
    T = "twin",
    X = "extend",
}


function Combatmode.add_aliases()
    local flags = alias_flag.Enabled + alias_flag.RegularExpression
        + alias_flag.IgnoreAliasCase
    local aliases = {
        {
            name = "alias_combatmode_set_" .. GetUniqueID(),
            match = "^cm(?<initial>[a-zA-Z])?(?<enable>[+-])?$",
            script = "Combatmode.set",
        }, {
            name = "alias_combatmode_default_" .. GetUniqueID(),
            match = "^cm +default +(?<mode>\\w+)$",
            script = "Combatmode.set_default",
        },
    }
    for _, alias in ipairs(aliases) do
        local code = AddAlias(alias.name, alias.match, "", flags, alias.script)
        if (code ~= error_code.eOK) then
            Utility.msg_major(string.format(
                "Failed to add alias %s:", alias.name
            ))
            Utility.msg_minor(error_desc[code])
        end
    end
end


function Combatmode.add_broadcast_hook()
end


function Combatmode.set(alias, line, wc)
    local initial = wc.initial:upper()
    local mode = Combatmode.INITIAL[initial]
    if (not mode) then
        mode = Config.get("combatmode").default or "defensive"
    end
    local enable = wc.enable
    if (enable == "") then
        enable = Config.get("combatmode")[mode] and "-" or "+"
    end
    local cmd = "combatmode %s%s"
    Send(cmd:format(enable, mode))
end


function Combatmode.set_default(alias, line, wc)
    local mode = wc.mode:lower()
    Config.get("combatmode").default = mode
    Config.save()
    local msg = "Set '%s' as default combatmode."
    Utility.msg_major(msg:format(mode))
end


function Combatmode.OnPluginBroadcast(msg, id, name, text)
    if not (id == const.PLUGIN.EVENT_HANDLER and text == "config.combatmode") then
        return
    end
    local combatmode = fk_event(text)
    local combatmodeConfigs = Config.get("combatmode")
    combatmodeConfigs[combatmode.mode] = combatmode.enabled
    Config.save()
end


function Combatmode.initialize()
    Combatmode.add_aliases()
end
