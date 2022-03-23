local fkColors = {}


fkColors.CODES = {
    ["BLACK"] = "{00}", ["RED"] = "{10}",
    ["GREEN"] = "{20}", ["YELLOW"] = "{30}",
    ["BLUE"] = "{40}", ["MAGENTA"] = "{50}",
    ["CYAN"] = "{60}", ["GREY"] = "{70}",
    ["BBLACK"] = "{80}", ["BRED"] = "{90}",
    ["BGREEN"] = "{A0}", ["BYELLOW"] = "{B0}",
    ["BBLUE"] = "{C0}", ["BMAGENTA"] = "{D0}",
    ["BCYAN"] = "{E0}", ["BGREY"] = "{F0}"
}


fkColors.CODES_TO_ANSI = {
    [fkColors.CODES.BLACK] = ANSI(22, 30, 40), [fkColors.CODES.RED] = ANSI(22, 31, 40),
    [fkColors.CODES.GREEN] = ANSI(22, 32, 40), [fkColors.CODES.YELLOW] = ANSI(22, 33, 40),
    [fkColors.CODES.BLUE] = ANSI(22, 34, 40), [fkColors.CODES.MAGENTA] = ANSI(22, 35, 40),
    [fkColors.CODES.CYAN] = ANSI(22, 36, 40), [fkColors.CODES.GREY] = ANSI(22, 37, 40),
    [fkColors.CODES.BBLACK] = ANSI(1, 30, 40), [fkColors.CODES.BRED] = ANSI(1, 31, 40),
    [fkColors.CODES.BGREEN] = ANSI(1, 32, 40), [fkColors.CODES.BYELLOW] = ANSI(1, 33, 40),
    [fkColors.CODES.BBLUE] = ANSI(1, 34, 40), [fkColors.CODES.BMAGENTA] = ANSI(1, 35, 40),
    [fkColors.CODES.BCYAN] = ANSI(1, 36, 40), [fkColors.CODES.BGREY] = ANSI(1, 37, 40)
}


function fkColors.to_ANSI(str)
    for color, code in pairs(fkColors.CODES) do
        str = str:gsub(code, fkColors.CODES_TO_ANSI)
    end
    return str
end


return fkColors
