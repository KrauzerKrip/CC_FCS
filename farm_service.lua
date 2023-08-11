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
    turtle.digDown("right")
end

function removeDownBlock() 
    turtle.digDown("left")
    turtle.digDown("right")
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
	print("go")
    local isBlocked, data = turtle.inspect()
    while isBlocked == false do
    	print("forward")
        turtle.forward()
        isBlocked, data = turtle.inspect()
    end
    print("blocked")
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
	print("maintain")
    if goMaintainUntilBlocked() == wallBlockId then
    	print("blocked by cobblestone")
        if turnsCounter == (farmLength-1) then
        	print("go home")
            returnHome()
        else
        	print("wanna turn")
            turn()
            maintainFarm()
        end
    end
end

function checkTool(toolSlot, toolId) 
    turtle.select(toolSlot)
    local itemData = turtle.getItemDetail()
    if itemData == nil then
        turtle.equipRight()
        if turtle.getItemDetail().name ~= toolId then
            error("Error: I don`t have tool "..toolId "or it`s slot isn`t right. Place a diamond hoe on the first slote, and a diamond shovel on the second.")
        end
        turtle.equipRight()
    else
        if itemData.name == toolId then 
            turtle.equipRight()
        else
            turtle.drop()
            turtle.equipRight()
            if turtle.getItemDetail().name ~= toolId then
                error("Error: I don`t have tool "..toolId "or it`s slot isn`t right. Place a diamond hoe on the first slote, and a diamond shovel on the second.")
            end
            turtle.equipRight()
        end
    end
end

function prepare() 
    turtle.select(16)
    turtle.refuel()
    turtle.select(1)

    checkTool(slotHoe, hoeId)
    checkTool(slotShovel, shovelId)
end

prepare()
maintainFarm()

