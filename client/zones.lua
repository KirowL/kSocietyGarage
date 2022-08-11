function IsJobValid(jobNeeded)
    if (ESX.PlayerData.job and ESX.PlayerData.job.name == jobNeeded) or (ESX.PlayerData.job2 and ESX.PlayerData.job2.name == jobNeeded) then 
        return true
    end 
    return false
end

function IsBoss()
    return (ESX.PlayerData.job.grade_name == 'boss') or (ESX.PlayerData.job2.grade_name == 'boss')
end

Citizen.CreateThread(function()
    while true do 
        local timeout = 500 
        for jobName, garageData in pairs(Config.Garages) do 
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local x, y, z = table.unpack(garageData.GaragePosition.coords)
            local dist1 = #(playerCoords - garageData.GaragePosition.coords)
            if dist1 <= 7.5 and IsJobValid(jobName) then 
                timeout = 1
                DrawMarker(6, x, y, z - 0.99, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, true, 2, false, nil, nil, false)
                if dist1 <= 1.5 then 
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le ~b~garage~s~.")
                    if IsControlJustPressed(0, 38) then 
                        serverInteraction = true
                        TriggerServerEvent('kSocietyGarage:RequestOpenMenu', jobName)
                    end
                end
            end

            local x, y, z = table.unpack(garageData.DeletePoint.coords)
            local dist2 = #(playerCoords - garageData.DeletePoint.coords)
            if dist2 <= 7.5 and IsJobValid(jobName) and IsPedSittingInAnyVehicle(playerPed) then 
                timeout = 1
                DrawMarker(6, x, y, z - 0.99, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 3.0, 3.0, 3.0, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                if dist2 <= 1.5 then 
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le ~b~ranger le véhicule~s~.")
                    if IsControlJustPressed(0, 38) then 
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        serverInteraction = true
                        TriggerServerEvent('kSocietyGarage:StoreVehicle', jobName, ESX.Game.GetVehicleProperties(vehicle))
                        SetEntityAsMissionEntity(vehicle, true, true)
                        DeleteVehicle(vehicle)
                    end
                end
            end
        end
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local x, y, z = table.unpack(Config.Shop.ShopPosition.coords)
        local dist = #(playerCoords - Config.Shop.ShopPosition.coords)
        if dist <= 7.5 and IsBoss() then 
            timeout = 1
            DrawMarker(6, x, y, z - 0.99, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, true, 2, false, nil, nil, false)
            if dist <= 1.5 then 
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir la ~b~boutique de véhicules~s~.")
                if IsControlJustPressed(0, 38) then 
                    serverInteraction = true
                    TriggerServerEvent('kSocietyGarage:RequestOpenShopMenu')
                end
            end
        end
        Citizen.Wait(timeout)
    end
end)    