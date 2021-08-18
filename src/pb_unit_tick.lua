-- Put values in L. L = kL times 1000.
-- Tier 1 Limits
IronLimit = 0 --export:
AlumLimit = 0 --export:
CarbLimit = 0 --export:
SiliLimit = 0 --export:

-- Tier 2 Limits
SodiLimit = 0 --export:
ChromLimit = 0 --export:
CalcLimit = 0 --export:
CoppLimit = 0 --export:

-- Tier 3 Limits
SulfLimit = 0 --export:
SilvLimit = 0 --export:
NickLimit = 0 --export:
LithLimit = 0 --export:

-- Tier 4 Limits
CobaLimit = 0 --export:
FlouLimit = 0 --export:
ScanLimit = 0 --export:
GoldLimit = 0 --export:

-- Tier 5 Limits
NiobLimit = 0 --export:
TitaLimit = 0 --export:
MangLimit = 0 --export:
VanaLimit = 0 --export:


local oreData = {
    {
        {name = "Iron", ore = "Hematite", limit = IronLimit},
        {name = "Aluminium", ore = "Bauxite", limit = AlumLimit},
        {name = "Carbon", ore = "Coal", limit = CarbLimit},
        {name = "Silicon", ore = "Quartz", limit = SiliLimit}
    },
    {
        {name = "Sodium", ore = "Natron", limit = SodiLimit},
        {name = "Chromium", ore = "Chromite", limit = ChromLimit},
        {name = "Calcium", ore = "Limestone", limit = CalcLimit},
        {name = "Copper", ore = "Malachite", limit = CoppLimit}
    },
    {
        {name = "Sulfur", ore = "Pyrite", limit = SulfLimit},
        {name = "Silver", ore = "Acanthite", limit = SilvLimit},
        {name = "Nickel", ore = "Garnierite", limit = NickLimit},
        {name = "Lithium", ore = "Petalite", limit = LithLimit}
    },
    {
        {name = "Cobalt", ore = "Cobaltite", limit = CobaLimit},
        {name = "Flourine", ore = "Cryolite", limit = FlouLimit},
        {name = "Scandium", ore = "Kolbeckite", limit = ScanLimit},
        {name = "Gold", ore = "Gold Nuggets", limit = GoldLimit}
    },
    {
        {name = "Niobium", ore = "Columbite", limit = NiobLimit},
        {name = "Titanium", ore = "Illmenite", limit = TitaLimit},
        {name = "Manganese", ore = "Rhodonite", limit = MangLimit},
        {name = "Vanadium", ore = "Vanadinite", limit = VanaLimit}
    }
}

-- func
function prettyStr (x)
    if type(x) == 'table' then
        local elems = {}
        for k, v in pairs(x) do
            table.insert(elems, string.format('%s = %s', prettyStr(k), prettyStr(v)))
        end
        return string.format('{%s}', table.concat(elems, ', '))
    else
        return tostring(x)
    end
end

-- processing
local json = require('dkjson')
local params = {}

local maxContVol = hub1.getMaxVolume()
local currContVol = hub1.getItemsVolume()

if not storageAcq and not storeCall then
    system.print("Acquiring Storage...")
    hub1.acquireStorage()
    storeCall = true
else
    local function str_split(input_string)
            local t={}
            for k, v in string.gmatch(input_string, "\"(%w+)\":(%d)") do
                system.print("k: "..k.." v:"..v)
            t[k] = tonumber(v)
            end
            return t
    end
    jData = json.decode(screen1.getScriptOutput()) or {}
    if type(jData) == "string" then
        params = str_split(jData)
    elseif type(jData) == "table" then
        params = jData
    end
    if params["ore"] and params["ore"] > 0 then
        system.print("Received Data...")
        system.print(prettyStr(params).." Type: "..type(params))
        screen1.clearScriptOutput()
    end
end

if params["ore"] and params["ore"] > 0 then
    local container = json.decode(hub1.getItemsList())
    local tier = params["tier"]
    local ore = params["ore"]
    system.print("tier: "..prettyStr(tier))
    system.print("ore: "..prettyStr(ore))
    system.print("container: "..prettyStr(container))
    if tier and ore then
        local oreName = oreData[tier][ore]["ore"]
        local oreLimit = oreData[tier][ore]["limit"]
        local output = {}

        if currContVol == maxContVol then
            output = { Full = true, empty = false, reqL = 0, currentL = 0 }
        else
            if container then
                local match = false
                system.print("container: "..prettyStr(container))
                for i,item in ipairs(container) do
                    system.print("Item Name: "..prettyStr(string.lower(container[i]["name"])))
                    system.print("Ore Name: "..prettyStr(string.lower(oreName)))
                    if string.lower(container[i]["name"]) == string.lower(oreName) then
                        output = { Full = false, empty = false, reqL = oreLimit, currentL = container[i]["quantity"] }
                        match = true
                    end
                end
                if not match then
                    output = { Full = false, empty = true, reqL = oreLimit, currentL = 0 }
                end
            end
        end
        if output ~= {} then
            local message = json.encode(output)
            system.print("output: "..prettyStr(output))
            system.print("message: "..prettyStr(message))
            screen1.setScriptInput(message)
            params = {}
        end
    end
end