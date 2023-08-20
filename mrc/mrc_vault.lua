local modemSystemSide = "back"
local modemNetworkSide = "top"

local modemSystem = peripheral.wrap(modemSystemSide)
local modemNetwork = peripheral.wrap(modemNetworkSide)

local digitalAdapterLeft = peripheral.wrap("digital_adapter_")
local digitalAdapterRight = peripheral.wrap("digital_adapter_")
local digitalAdapterBridge = peripheral.wrap("digital_adapter_")

local redstoneSideVault = "right"
local redstoneSideBridge = "left"

local vaultState = {OPENED = 0, CLOSED = 1, ERROR = 2}
local bridgeState = {EXTENDED = 10, RETRACTED = 11}

function getPistonStateLeft() 
    return digitalAdapterLeft.getPistonDistance("bottom")
end

function getPistonStateRight() 
    return digitalAdapterRight.getPistonDistance("bottom")
end

function getPistonStateBridge()
    return digitalAdapterBridge.getPistonDistance("east")
end

function getVaultState()
    if (getPistonStateLeft() == 0) and (getPistonStateRight() == 0) then 
        return vaultState.OPENED
    elseif (getPistonStateLeft() == 0) or (getPistonStateRight() == 0) then
        return vaultState.ERROR
    else
        return vaultState.CLOSED
    end
end

function getBridgeState()
    if getPistonStateBridge() == 0 then
        return bridgeState.RETRACTED
    else
        return bridgeState.EXTENDED
    end
end

function openVault()
    redstone.setOutput(redstoneSideVault, false)
end

function closeVault()
    redstone.setOutput(redstoneSideVault, true)
end

function extendBridge()
    redstone.setOutput(redstoneSideBridge, true)
end

function retractBridge()
    redstone.setOutput(redstoneSideBridge, false)
end

function open()
    if getVaultState() == vaultState.CLOSED then
        openVault()
        repeat 
            sleep(5)
        until (getVaultState() == vaultState.OPENED)
        extendBridge()
    elseif getVaultState() == vaultState.OPENED then
        -- do nothing
    end
end

function close()
    print("close")
    if getVaultState() == vaultState.OPENED then 
        print("vault opened")
        if getBridgeState() == bridgeState.EXTENDED then
            print("bridge extended")
            retractBridge()
            repeat 
                sleep(5)
            until (getBridgeState() == bridgeState.RETRACTED)
            print("close")
            closeVault()
        elseif getBridgeState() == bridgeState.RETRACTED then
            print("bridge RETRACTED")
            print("close")
            closeVault()
        end
    elseif getVaultState() == vaultState.CLOSED then
        print("vault closed")
        -- do nothing
    end
end

if not rednet.isOpen(modemNetworkSide) then 
    rednet.open(modemNetworkSide)
end

rednet.host("fcs_mrc_vault_control", "interface")

while true do
    id, message = rednet.receive("fcs_mrc_vault_control")
    if message == "open" then 
        local status, error = pcall(open)
        if (status) then 
            rednet.send(id, "done", "fcs_mrc_vault_control")
        else
            rednet.send(id, error, "fcs_mrc_vault_control")
        end
    elseif message == "close" then 
        local status, error = pcall(close)
        if (status) then 
            rednet.send(id, "done", "fcs_mrc_vault_control")
        else
            rednet.send(id, error, "fcs_mrc_vault_control")
        end
    elseif message == "getState" then
        if (status) then 
            rednet.send(id, "done", "fcs_mrc_vault_control")
        else
            rednet.send(id, error, "fcs_mrc_vault_control")
        end
    else
        rednet.send(id, "400 Bad Request", "fcs_mrc_vault_control") 
    end
end
