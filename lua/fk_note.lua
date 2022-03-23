local fkColors = require("fk_colors")


function fk_note(str)
    local colorStr = string.format("{70}%s{70}\n", str)
    AnsiNote(fkColors.to_ANSI(colorStr))
end
