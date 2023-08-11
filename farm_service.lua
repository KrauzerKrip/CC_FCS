require "math"

turtle.select(16)
turtle.refuel()
turtle.select(1)

local slotHoe = 1
local slotShovel = 2
local turnsCounter = 0
local farmLength = 25
local agricultureId = "minecraft:wheat"
local wallBlockId = "minecraft:cobblestone"


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

-- function goTillOnPlantsLevel()
--     local isBlockedOnPlantsLevel = false
    
--     while not isBlockedOnPlantsLevel do
--         till()
--         isBlockedOnPlantsLevel = not turtle.forward()
--     end

--     local _, data = turtle.inspect()
--     return data.name
-- end

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

print("cat")
print(turtle.getFuelLevel())

if (turtle.getItemDetail(slotHoe).name == "minecraft:diamond_hoe") and (turtle.getItemDetail(slotShovel).name == "minecraft:diamond_shovel") then 
    turtle.select(slotHoe)
    turtle.equipRight()
    turtle.select(slotShovel)
    turtle.equipLeft()
    turtle.select(16)
else
     print("Error: I don`t have instruments or their order isn`t right. Place a diamond hoe on the first slote, and a diamond shovel on the second.")
end

maintainFarm()
--returnHome()
