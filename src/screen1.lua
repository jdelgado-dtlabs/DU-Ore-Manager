local title = "Ore Storage" -- export: Name your display.
local bgtext = "Welcome to Alioth Fuel Depot" -- export: Background text of your choice.
local bgPlanetImg = "assets.prod.novaquark.com/20368/954f3adb-3369-4ea9-854d-a14606334152.png" -- export: (Default: Alioth URL)
local tiers = 0 --export: Default is 0, or all tiers. If you set a tier (1-5), then only that tier will be displayed.

local params = {}
local fontCache = {}

local rx, ry = getResolution()

local bglayer = createLayer()
local oreLayer = createLayer()
local curlayer = createLayer()

local cx, cy = getCursor()
click = getCursorPressed()

local json = require('dkjson')

local baseFolder = "assets.prod.novaquark.com"

local oreImages = {
    {
        baseFolder.."/70186/4ff8e9b7-5ed8-4b62-9b02-219219081efa.png",
        baseFolder.."/70186/2a660dc9-9af6-4f4b-87d3-bba4defb1964.png",
        baseFolder.."/70186/edc9f97e-7359-454e-8ba9-8f960037ae9b.png",
        baseFolder.."/70186/a8d1c39e-d3d3-4a75-bce1-348036588108.png"
    },
    {
        baseFolder.."/70186/cec7c516-9f70-4b2b-9d60-6f9527ae36a8.png",
        baseFolder.."/70186/b7357f8d-43ce-4279-a7d3-75fb6fda4fcd.png",
        baseFolder.."/70186/dc16bf83-bc00-42b3-8f71-1683e8350efb.png",
        baseFolder.."/45824/36e5a9ca-c9f6-4e66-b2f4-fe64c9289224.png"
    },
    {
        baseFolder.."/70186/0423117d-8754-470c-873c-9b56bf3b9ae2.png",
        baseFolder.."/70186/e5246f30-14b3-4bf8-bfc1-9bf20a40ed6e.png",
        baseFolder.."/70186/b8a8443d-374d-4df2-b289-bfe69105a962.png",
        baseFolder.."/70186/3ce3c407-4cfc-4c90-9258-c7af0a5bcf97.png"
    },
    {
        baseFolder.."/70186/a1e3cbd0-c1c1-423d-abea-bf89fbbeb936.png",
        baseFolder.."/70186/54c5acf2-7c0c-4154-b38c-ffe22d349b80.png",
        baseFolder.."/70186/c4d32953-9bfb-4586-974d-de0a2ea0f954.png",
        baseFolder.."/70186/335baaee-7651-4b90-9e5a-290950ed0f5a.png"
    },
    {
        baseFolder.."/70186/891cbe02-e34c-4473-9cac-65ba67075e47.png",
        baseFolder.."/70186/13f64ee1-4c8d-40bb-9eff-605e6e6e681f.png",
        baseFolder.."/70186/a2f5af65-de9e-4b49-a752-a47a42eca4e9.png",
        baseFolder.."/70186/34804219-fcbb-4900-9358-77688ef535fe.png"
    }
}

local oreData = {
    {
        {"Iron", "Hematite"},
        {"Aluminium", "Bauxite"},
        {"Carbon", "Coal"},
        {"Silicon", "Quartz"}
    },
    {
        {"Sodium", "Natron"},
        {"Chromium", "Chromite"},
        {"Calcium", "Limestone"},
        {"Copper", "Malachite"}
    },
    {
        {"Sulfur", "Pyrite"},
        {"Silver", "Acanthite"},
        {"Nickel", "Garnierite"},
        {"Lithium", "Petalite"}
    },
    {
        {"Cobalt", "Cobaltite"},
        {"Flourine", "Cryolite"},
        {"Scandium", "Kolbeckite"},
        {"Gold", "Gold Nuggets"}
    },
    {
        {"Niobium", "Columbite"},
        {"Titanium", "Illmenite"},
        {"Manganese", "Rhodonite"},
        {"Vanadium", "Vanadinite"}
    }
}

function str_split(input_string)
    local t={}
    for k, v in string.gmatch(input_string, "\"Full\":(%w+)") do
    t["Full"] = string.lower(v)
    end
    for k, v in string.gmatch(input_string, "\"empty\":(%w+)") do
        t["empty"] = string.lower(v)
        end
    for k, v in string.gmatch(input_string, "\"(%w+)\":(%d)") do
    t[k] = tonumber(v)
    end
    return t
end

local jData = json.decode(getInput()) or {}
if type(jData) == "string" then
    params = str_split(jData)
elseif type(jData) == "table" then
    params = jData
end

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

if #params > 0 then 
    logMessage("Screen: "..prettyStr(params))
end

-- init
if not Init then
    Init = true
    if #params > 0 then
        Full = params["Full"]
    end
    if tiers == 0 then
        tierIndex = 1
    else
        tierIndex = tiers
    end
    oreIndex = 1
end


function getFont (font, size)
    local k = font .. '_' .. tostring(size)
    if not fontCache[k] then fontCache[k] = loadFont(font, size) end
    return fontCache[k]
end

function drawBackground ()
    local lcstartx = 0
    local ccstartx = rx/6
    local rcstartx = ((rx/6) *5) + 10
    local starty = ry/6
    local colWidth = (rx/6) - 10
    local cenWidth = (rx/6) *4
    local colHeight = (ry/6) *4

    local columns = { 
        { ccstartx, starty, cenWidth, colHeight },
        { lcstartx, starty, colWidth, colHeight },
        { rcstartx, starty, colWidth, colHeight },
    }

    for index, column in ipairs(columns) do
        setNextStrokeWidth(bglayer, 1)
        setNextStrokeColor(bglayer, 0, 1, 1, 1)
        setNextFillColor(bglayer, 0, 0, 0, 0)
        addBox(bglayer, column[1], column[2], column[3], column[4] )
    end
end

function drawBackgroundImage ()
    local cenImage = loadImage(bgPlanetImg)
    if isImageLoaded(cenImage) then
        setNextFillColor(bglayer, 1, 1, 1, .33)
        addImage(bglayer, cenImage, (rx/2) - (ry/6), ry/3, ry/3, ry/3)
    end
    local font = getFont('Play-Bold', 32)
    local sx, sy = getTextBounds(font, bgtext)
    sx, sy = sx + 32, sy + 16
    local x0 = rx/2 - sx/2
    local y0 = ry/2 - sy/2
    local x1 = x0 + sx
    local y1 = y0 + sy
    setNextFillColor(bglayer, 1, 1, 1, .33)
    addText(bglayer, font, bgtext, x0, y0)
end

function drawTitle ()
    local font = getFont("Play-Bold", 40)
    setNextTextAlign(bglayer, AlignH_Center, AlignV_Middle)
    addText(bglayer, font, title, rx/2, 40)
    if tiers > 0 and tiers <= 5 then
        local font = getFont("Play-Bold", 25)
        local subtitle = "Tier "..tiers.." only"
        setNextTextAlign(bglayer, AlignH_Center, AlignV_Middle)
        addText(bglayer, font, title, rx/2, 40+25)
    end
end

function drawCursor ()
    if cx < 0 then return end
    setNextFillColor(curlayer, 1, 1, 1, 1)
    addBox(curlayer, cx - 5, cy - 5, 10, 10)
end

function drawSep ()
    setNextStrokeWidth(bglayer, 1)
    setNextStrokeColor(bglayer, 0, 1, 1, 1)
    addLine(bglayer, rx/6, (ry/6)*4, (rx/6) * 5, (ry/6)*4 )
end

function oreBox (tier, ore)
    local ccstartx, starty = (rx/2) - (ry/3), (ry/6)*4
    local square = ry/6
    local column = ore - 1
    local startx = ccstartx + (column * square)
    setNextStrokeWidth(bglayer, 1)
    setNextStrokeColor(bglayer, 0, 1, 1, 1)
    setNextFillColor(bglayer, 0, 0, 0, 0)
    addBox(bglayer, startx, starty, square, square)
    local cenImage = loadImage(oreImages[tier][ore])
    if cx >= startx and cx <= startx + square and cy >= starty and cy <= starty + square then
        -- logMessage("in range "..tier..ore)
        if click then 
            local data = { tier = tier, ore = ore }
            message = json.encode(data)
            logMessage(prettyStr(data))
            setOutput(json.encode(message))
            logMessage(message)
            tierStatusIndex, oreStatusIndex = tier, ore
        end
        if isImageLoaded(cenImage) then
            addImage(oreLayer, cenImage, startx-10, starty-10, square+20, square+20)
        end
        oreTitle(tier, ore)
    else
        if isImageLoaded(cenImage) then
            addImage(oreLayer, cenImage, startx+10, starty+10, square-20, square-20)
        end
    end
end

function tierButton (text, startx, starty)
    local font = getFont('Play-Bold', 32)
    local sx, sy = getTextBounds(font, text)
    sx, sy = sx + 32, sy + 16
    local x0 = startx - sx/2
    local y0 = starty - sy/2
    local x1 = x0 + sx
    local y1 = y0 + sy
    local r, g, b = 0.3, 0.7, 1.0
    if cx >= x0 and cx <= x1 and cy >= y0 and cy <= y1 then
        -- logMessage("in range "..text)
        r, g, b = 1.0, 0.0, 0.4
        if click then
            if text == 'Previous' then
                if tierIndex == 1 then
                    tierIndex = 5
                else
                    tierIndex = tierIndex - 1
                end
            elseif  text == 'Next' then
                if tierIndex == 5 then
                    tierIndex = 1
                else
                    tierIndex = tierIndex + 1
                end
            end  
        end
    end
    setNextShadow(oreLayer, 64, r, g, b, 0.3)
    setNextFillColor(oreLayer, 0.1, 0.1, 0.1, 1)
    setNextStrokeColor(oreLayer, r, g, b, 1)
    setNextStrokeWidth(oreLayer, 2)
    addBoxRounded(oreLayer, startx - sx/2, starty - sy/2, sx, sy, 4)
    setNextFillColor(oreLayer, 1, 1, 1, 1)
    setNextTextAlign(oreLayer, AlignH_Center, AlignV_Middle)
    addText(oreLayer, font, text, startx, starty)
end

function oreTitle (tier, ore)
    local font = getFont('Play-Bold', 32)
    local sx, sy = getTextBounds(font, oreData[tier][ore][1])
    sx = sx + 32
    local x0 = rx/2 - sx/2
    addText(oreLayer, font, oreData[tier][ore][1], x0, ((ry/6) *5) - 32)
end

function oreStatus (tier, ore)
    if #params > 0 then
        return
    elseif Full then
        return
    else
        local startx = rx/4
        local starty = ry/6 + 15
        local square = ry/5
        local pgBarStartX = startx + square + 5
        local pgBarStartY = starty + 36 + 18 +5
        local pgBarEnd = (startx * 2) - square - 5
        local isEmpty = params["empty"]
        local reqL = params["reqL"] or 0
        local currentL = params["currentL"] or 0
        --logMessage(reqL..":"..currentL)
        local pct = 0
        if reqL == 0 and currentL == 0 then
            pct = 0
        end
        pct = currentL / reqL
        if pct > 1 then
            pct = 1
        end
        local title = getFont("Play-Bold", 36)
        local subtitle = getFont("Play-Bold", 18)
        setNextStrokeWidth(oreLayer, 1)
        setNextStrokeColor(oreLayer, 0, 1, 1, 1)
        setNextFillColor(oreLayer, 0, 0, 0, 0)
        addBox(oreLayer, startx, starty , square, square)
        local scannerImage = loadImage(oreImages[tier][ore])
        if isImageLoaded(scannerImage) then
            addImage(oreLayer, scannerImage, startx, starty , square, square)
        end
        addText(oreLayer, title, oreData[tier][ore][1], pgBarStartX, starty + 36)
        addText(oreLayer, subtitle, oreData[tier][ore][2], pgBarStartX, starty + 36 + 18)
        if pct == 1 then 
            addText(oreLayer, subtitle, "No more of this ore is needed.", pgBarStartX, pgBarStartY+12)
        elseif isEmpty then
            addText(oreLayer, subtitle, "This item is not in the inventory. "..(reqL/1000).."kL needed.", pgBarStartX, pgBarStartY+12)
        elseif pct == 0 then
            addText(oreLayer, subtitle, "Checking inventory...", pgBarStartX, pgBarStartY+12)
        else
            setNextStrokeWidth(oreLayer, 1)
            setNextStrokeColor(oreLayer, 0, 1, 0, 1)
            setNextFillColor(oreLayer, 0, 0, 0, 0)
            addBox(oreLayer, pgBarStartX, pgBarStartY, pgBarEnd , 10)
            setNextFillColor(oreLayer, 0, 1, 0, 1)
            addBox(oreLayer, pgBarStartX, pgBarStartY, pgBarEnd * pct , 10)
            addText(oreLayer, subtitle, "Current kL: "..currentL/1000, pgBarStartX, pgBarStartY+12+18)
            addText(oreLayer, subtitle, "Required kL: "..reqL/1000, pgBarStartX, pgBarStartY+12+36)
            addText(oreLayer, subtitle, "Remaining kL: "..(reqL-currentL)/1000, pgBarStartX, pgBarStartY+12+54)
        end
    end
end

function closedContainer (error)
    local font = getFont('Play-Bold', 32)
    local text = ""
    if error == "full" then
        text = "Container is Full"
    elseif error == "tiers" then
        text = "Tiers is "..tiers..". Set to 0 - 5."
    end
    local sx, sy = getTextBounds(font, text)
    sx, sy = sx + 32, sy + 16
    local x0 = rx/2 - sx/2
    local y0 = ry/2 - sy/2
    setNextFillColor(oreLayer, 1, 0, 0, 1)
    addText(oreLayer, font, text, x0, y0)
end

function main ()
    drawBackground()
    drawBackgroundImage()
    drawTitle()
    drawSep()
    for o=1,4 do
        oreBox(tierIndex, o)
    end
    if tierStatusIndex and oreStatusIndex then
        oreStatus(tierStatusIndex, oreStatusIndex)
    end
    if tiers == 0 then
        tierButton('Previous', (rx/6), (ry/6)*4)
        tierButton('Next', (rx/6)*5, (ry/6)*4)
    end
    drawCursor()
    requestAnimationFrame(5)
end

if tiers >= 0 and tiers <=5 then
    if #params > 0 and Full then
        closedContainer("full")
    else
        main()
    end
else
    closedContainer("tiers")
end