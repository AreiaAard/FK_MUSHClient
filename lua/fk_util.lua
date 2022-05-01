local const = require("fk_const")


local Util = {}


function Util.combat_messages(filter)
    -- Get a list of all combat messages which return true when passed
    -- to `filter`.
    local messages = {}
    for i, message in ipairs(const.COMBAT_MSG) do
        if (filter(message, i)) then
            messages[i] = message
        end
    end
    return messages
end


return Util
