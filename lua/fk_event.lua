require("json")
local const = require("fk_const")


function fk_event(path)
    local retval, data = CallPlugin(
        const.PLUGIN.EVENT_HANDLER, "EventHandler.get_as_string", path
    )
    return retval == 0 and json.decode(data) or {}
end
