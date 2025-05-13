Config = {}

local ESX, QBCore = nil
if Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
else
    QBCore = exports['qb-core']:GetCoreObject()
end

#

RegisterNetEvent('gary_garage:spawnVechicle')
AddEventHandler('gary_garage:spawnVechicle', function(vehicleData, plate, coords)
    local closestV, dist = QBCore.Functions.GetClosestVehicle(vector3(coords.x, coords.y, coords.z))
    local ped = PlayerPedId()
    if dist then
        if Config.Framework == "esx" then
            ESX.Game.SpawnVehicle(vehicleData.model, coords, function(veh)
                SetPedIntoVehicle(ped, veh, -1)
                SetVehicleCanLeakPetrol(veh, false)
                lib.setVehicleProperties(veh, vehicleData)
                TriggerServerEvent('gary_garage:server:setVehicleOut', plate, false)
                    Entity(veh).state.fuel = vehicleData.fuelLevel -- change to your custom fuel system export here
                    Entity(veh).state.owner = GetPlayerServerId(PlayerId()) -- change to your custom key system export here
            end)
        else
            QBCore.Functions.SpawnVehicle(vehicleData.model, function(veh)
                SetVehicleCanLeakPetrol(veh, false)
                QBCore.Functions.SetVehicleProperties(veh, vehicleData)
                TriggerServerEvent('gary_garage:server:setVehicleOut', plate, false)
                    Entity(veh).state.fuel = vehicleData.fuelLevel -- change to your custom fuel system export here
                    TriggerEvent("vehiclekeys:client:SetOwner", plate) -- change to your custom key system export here
                SetPedIntoVehicle(ped, veh, -1)
            end, coords ,true)
        end
    else
        TriggerEvent('gary_garage:notification', locale('vehicles_in_zone'), "error")
    end     
end)