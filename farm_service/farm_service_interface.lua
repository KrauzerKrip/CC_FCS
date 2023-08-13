if not rednet.isOpen() then 
    peripheral.find("modem", rednet.open)
end

rednet.host("fcs_wheat_farm_service", "interface")
id = rednet.lookup("fcs_wheat_farm_service", "device")
rednet.send(id, "maintain", "fcs_wheat_farm_service")

local id, message

while true do 
    id, message = rednet.receive("fcs_wheat_farm_service")
    if message == "finished" then 
        io.write("Maintanance finished.")
        break
    else
        io.write(message)
        break
    end 
end
