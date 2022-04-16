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
        Note(cmd)
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


spells.ARMOR = Spell:new{name="armor", phrase="arm"}
spells.STONE_SKIN = Spell:new{name="stone skin", phrase="ss"}


spells.ENERGY_IMMUNITY = Spell:new{
    name = "energy immunity",
    incantation = "^im(?<energy>a|c|e|f)(?<target> +.*)?$",
    response = [[
        local energies = {a="acid", c="cold", e="electricity", f="fire"}
        local energy = energies[string.lower("%<energy>")]
        local target = trim("%<target>")
        target = target == "" and "self" or target
        local cmd = "cast 'energy immunity' %s %s"
        Note(cmd:format(target, energy))
    ]],
}
