isMenuOpened = false

RegisterNetEvent('kSocietyGarage:OpenMenu')
AddEventHandler('kSocietyGarage:OpenMenu', function(garageData)
    isMenuOpened = true
    local garageMenu = RageUI.CreateMenu("Garage d'entreprise", "Selectionnez un vehicle")
    garageMenu:SetStyleSize(75)
    garageMenu:DisplayGlare(false)

    garageMenu.Closed = function()
        isMenuOpened = false
        RageUI.Visible(garageMenu, false)
    end

    RegisterNetEvent('kSocietyGarage:UpdateGarageData')
    AddEventHandler('kSocietyGarage:UpdateGarageData', function(newGarageData)
        garageData = newGarageData
    end)


    RageUI.Visible(garageMenu, true)
    Citizen.CreateThread(function()
        while isMenuOpened do
            RageUI.IsVisible(garageMenu, function()
                if #garageData <= 0 then 
                    RageUI.Separator("")
                    RageUI.Separator("              ~r~Ce garage ne contient aucun véhicule.")
                    RageUI.Separator("")
                else 
                    for k, v in pairs(garageData) do 
                        local vehicle = v.vehicle
                        local vehicleLabel = GetLabelText(GetDisplayNameFromVehicleModel(vehicle.model))

                        local vehicleHealth = vehicle.engineHealth / 10
                        if vehicleHealth > 75 then 
                            vehicleHealth = "~g~" .. vehicleHealth .. "%"
                        elseif vehicleHealth > 30 then
                            vehicleHealth = "~r~" .. vehicleHealth .. "%"
                        else 
                            vehicleHealth = "~o~" .. vehicleHealth .. "%"
                        end
                        local speed = GetVehicleModelMaxSpeed(vehicle.model)*3.6
                        local speed = speed/220
                        local accel = GetVehicleModelAcceleration(vehicle.model)*3.6
                        local accel = accel/220
                        local seats = GetVehicleModelNumberOfSeats(vehicle.model)
                        local braking = GetVehicleModelMaxBraking(vehicle.model)/2
                        RageUI.Button(vehicleLabel .. " - " .. vehicle.plate, "Véhicule: ~b~" .. vehicleLabel .. "\n~s~Plaque: ~b~" .. vehicle.plate .. "\n~s~Santé: " .. vehicleHealth .. "\n~s~Niveau d'essence: " .. vehicle.fuelLevel .. "%" .. "\n~s~Places: ~b~" .. seats, {RightLabel = v.is_stored and "~g~Rentrée" or "~r~Sortie"},not serverInteraction, {
                            onSelected = function()
                                if not vehicle.is_stored then 
                                    if ESX.Game.IsSpawnPointClear(Config.Garages[v.job].SpawnPosition.coords, 5.0) then 
                                        serverInteraction = true
                                        ESX.TriggerServerCallback('kSocietyGarage:SetVehicleOut', function(result)
                                            if result then 
                                                ESX.Game.SpawnVehicle(vehicle.model, Config.Garages[v.job].SpawnPosition.coords, Config.Garages[v.job].SpawnPosition.heading, function(spawnedVehicle)
                                                    local playerPed = PlayerPedId()
                                                    ESX.Game.SetVehicleProperties(spawnedVehicle, vehicle)

                                                    SetVehicleEngineHealth(spawnedVehicle, vehicle.engineHealth + 0.0)
                                                    SetVehiclePetrolTankHealth(spawnedVehicle, vehicle.tankHealth + 0.0)
                                                    SetVehicleFuelLevel(spawnedVehicle, vehicle.fuelLevel + 0.0)
                                                    SetVehicleBodyHealth(spawnedVehicle, vehicle.bodyHealth + 0.0)
                                                    for k, v in pairs(vehicle.windowsBroken) do
                                                        if v then
                                                            SmashVehicleWindow(spawnedVehicle, tonumber(k))
                                                        end
                                                    end
                                                    for k, v in pairs(vehicle.doorsBroken) do
                                                        if v then
                                                            SetVehicleDoorBroken(spawnedVehicle, tonumber(k), true)
                                                        end
                                                    end
                                                    for k, v in pairs(vehicle.tyreBurst) do
                                                        if v then
                                                            SetVehicleTyreBurst(spawnedVehicle, tonumber(k), true, 1000.0)
                                                        end
                                                    end
                                                    SetPedIntoVehicle(playerPed, spawnedVehicle, -1)
                                                end)
                                            end
                                        end, v.job, vehicle)
                                    else 
                                        ESX.ShowNotification("~r~Il y a un véhicule à cet endroit.")
                                    end
                                else 
                                    ESX.ShowNotification("~r~Ce véhicule est déjà sorti.")
                                end
                            end
                        })
                        RageUI.StatisticPanel(speed, "Vitesse maximale", k)
                        RageUI.StatisticPanel(accel*100, "Accélération", k)
                        RageUI.StatisticPanel(braking, "Freinage", k)
                        RageUI.StatisticPanel(vehicle.fuelLevel / 100, "Niveau d'essence", k)
                        RageUI.StatisticPanel(vehicle.engineHealth / 1000, "Santé du moteur", k)
                    end
                end
            end)
            Wait(1)
        end
    end)
end)

RegisterNetEvent('kSocietyGarage:OpenShopMenu')
AddEventHandler('kSocietyGarage:OpenShopMenu', function(jobName, job2Name)
    isMenuOpened = true
    local shopMenu = RageUI.CreateMenu("Véhicules d'entreprise", "Selectionnez un vehicle")
    shopMenu:SetStyleSize(75)
    shopMenu:DisplayGlare(false)

    shopMenu.Closed = function()
        isMenuOpened = false
        RageUI.Visible(shopMenu, false)
    end

    RageUI.Visible(shopMenu, true)
    Citizen.CreateThread(function()
        while isMenuOpened do
            RageUI.IsVisible(shopMenu, function()
                if jobName then 
                    RageUI.Separator("                  Métier principal")
                    for k, v in pairs(Config.Garages[jobName].Vehicles) do 
                        RageUI.Button(v.label, "Acheter ~b~x1 " .. v.label .. "~s~ pour ~b~" .. v.price .. "$~s~.", {RightLabel = "~g~" .. v.price .. "$"}, not serverInteraction, {
                            onSelected = function()
                                if ESX.Game.IsSpawnPointClear(Config.Shop.SpawnPosition.coords, 5.0) then 
                                    ESX.TriggerServerCallback('kSocietyGarage:BuyVehicle', function(result)
                                        if result then 
                                            local vehPlate = GenerateSocietyVehiclePlate(jobName)
                                            ESX.Game.SpawnVehicle(v.model, Config.Shop.SpawnPosition.coords, Config.Shop.SpawnPosition.heading, function(vehicle)
                                                SetVehicleNumberPlateText(vehicle, vehPlate)
                                                serverInteraction = true
                                                TriggerServerEvent('kSocietyGarage:AddVehicleToSocietyGarage', jobName, ESX.Game.GetVehicleProperties(vehicle))
                                            end)
                                        else 
                                            ESX.ShowNotification("~r~L'entreprise n'a pas assez d'argent.")
                                        end
                                    end, v.model, jobName)
                                else 
                                    ESX.ShowNotification("~r~Il y a un véhicule à cet endroit.")
                                end
                            end
                        })
                    end
                end 
                if job2Name then 
                    RageUI.Separator("                  Métier secondaire")
                    for k, v in pairs(Config.Garages[job2Name].Vehicles) do 
                        RageUI.Button(v.label, "Acheter ~b~x1 " .. v.label .. "~s~ pour ~b~" .. v.price .. "$~s~.", {RightLabel = "~g~" .. v.price .. "$"}, not serverInteraction, {
                            onSelected = function()
                                ESX.TriggerServerCallback('kSocietyGarage:BuyVehicle', function(result)
                                    if result then 
                                        local vehPlate = GenerateSocietyVehiclePlate(job2Name)
                                        ESX.Game.SpawnVehicle(v.model, Config.Shop.SpawnPosition.coords, Config.Shop.SpawnPosition.heading, function(vehicle)
                                            SetVehicleNumberPlateText(vehicle, vehPlate)
                                            serverInteraction = true
                                            TriggerServerEvent('kSocietyGarage:AddVehicleToSocietyGarage', job2Name, ESX.Game.GetVehicleProperties(vehicle))
                                        end)
                                    else 
                                        ESX.ShowNotification("~r~L'entreprise n'a pas assez d'argent.")
                                    end
                                end, v.model, job2Name)
                            end
                        })
                    end
                end
            end)
            Wait(1)
        end
    end)
end)