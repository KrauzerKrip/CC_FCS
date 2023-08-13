require "math"

local slotHoe = 1
local slotShovel = 2
local turnsCounter = 0
local farmLength = 25
local agricultureId = "minecraft:wheat"
local wallBlockId = "minecraft:cobblestone"
local hoeId = "minecraft:diamond_hoe"
local shovelId = "minecraft:diamond_shovel"


function till()
    if (turtle.getItemDetail().name == hoeId) then
        turtle.equipRight()
    end
    turtle.digDown("right")
end

function removeDownBlock()
    if (turtle.getItemDetail().name == shovelId) then
        turtle.equipRight()
    end
    turtle.digDown("right")
    till()
end

function maintainDownBlock() 
    local isBlockDown, dataDown = turtle.inspectDown()
    if isBlockDown then
        if dataDown.name ~= agricultureId then
            removeDownBlock()
        end
    else
        till()
    end
end

function turn()
    turnsCounter = turnsCounter + 1

    if (math.fmod(turnsCounter, 2) ~= 0) then
        turtle.turnLeft()
        turtle.forward()
        maintainDownBlock()
        turtle.turnLeft()
    else
        turtle.turnRight()
        turtle.forward()
        maintainDownBlock()
        turtle.turnRight()
    end
end

function goUntilBlocked()
    local isBlocked, data = turtle.inspect()
    while isBlocked == false do
        turtle.forward()
        isBlocked, data = turtle.inspect()
    end
    return data.name
end

function goMaintainUntilBlocked()
    local isBlocked = false;
    while not isBlocked do
        isBlocked = not turtle.forward()
        maintainDownBlock()
    end
    local _, data = turtle.inspect()
    return data.name
end

function returnHome()
    turtle.turnRight()

    if goUntilBlocked() == wallBlockId then
        turtle.turnRight()
    end

    if goUntilBlocked() == "minecraft:chest" then
        turtle.turnLeft()
        turtle.turnLeft()
    end
end

function maintainFarm()
    turtle.select(1)
    if goMaintainUntilBlocked() == wallBlockId then
        if turnsCounter == (farmLength-1) then
            returnHome()
        else
            turn()
            maintainFarm()
        end
    end
end

function checkTool(toolSlot, toolId, equip) 
    turtle.select(toolSlot)
    local itemData = turtle.getItemDetail()
    if itemData == nil then
        equip()
        if turtle.getItemDetail().name ~= toolId then
            error("Error: I don`t have tool "..toolId "or it`s slot isn`t right. Place a diamond hoe on the first slote, and a diamond shovel on the second.")
        end
         equip()
    else
        if itemData.name == toolId then 
             equip()
        else
            turtle.drop()
             equip()
            if turtle.getItemDetail().name ~= toolId then
                error("Error: I don`t have tool "..toolId "or it`s slot isn`t right. Place a diamond hoe on the first slote, and a diamond shovel on the second.")
            end
             equip()
        end
    end
end

function prepare() 
    turtle.select(16)
    turtle.refuel()
    turtle.select(1)

    --checkTool(slotHoe, hoeId, turtle.equipRight)
    --checkTool(slotShovel, shovelId, turtle.equipLeft)
end

if not rednet.isOpen() then 
    peripheral.find("modem", rednet.open)
end

rednet.host("fcs_wheat_farm_service", "device")

local id, message

while true do
    id, message = rednet.receive("fcs_wheat_farm_service")
    if message == "maintain" then 
        local status, error = pcall(prepare)
        if (not status) then 
            rednet.send(id, error, "fcs_wheat_farm_service")
        end

        status, error = pcall(maintainFarm)
        if (not status) then 
            rednet.send(id, error, "fcs_wheat_farm_service")
        end
        rednet.send(id, "finished", "fcs_wheat_farm_service")
    end 
end
