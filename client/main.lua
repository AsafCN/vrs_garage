local ESX, QBCore = nil
if Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
else
    QBCore = exports['qb-core']:GetCoreObject()
end

lib.locale()
local isBusy = false
local cam = nil
local zoneIndex = nil
local inZone = false
local previewVehicle = nil
local inPreviewMode = false
local PlayerJob = {}
local jobBlips = {}

if Config.Framework == "esx" then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
        ESX.PlayerData = xPlayer
    end)
else
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function(xPlayer, isNew, skin)
        local PlayerData = QBCore.Functions.GetPlayerData()
        PlayerJob = PlayerData.job
    end)
end

if Config.Framework == "esx" then
    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        ESX.PlayerData.job = job
        ManageJobsBlips()
    end)
else
    RegisterNetEvent('QBCore:Client:OnJobUpdate')
    AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
        PlayerJob = job
        ManageJobsBlips()
    end)
    RegisterNetEvent('onResourceStart', function()
        local PlayerData = QBCore.Functions.GetPlayerData()
        PlayerJob = PlayerData.job
        CreateGarages()
        CreateImpounds()
        CreateJobGarages()
        ManageJobsBlips()
    end)
end


function EnterPreviewMode(vehicleData, coords)
    inPreviewMode = true

    if Config.Framework == "esx" then
        ESX.Game.DeleteVehicle(previewVehicle)
    else
        QBCore.Functions.DeleteVehicle(currentVehicle)
    end
    previewVehicle = nil


    lib.callback('gary_garage:setPlayerRoutingBucket', false, function(canContinue)
        if canContinue then
            if Config.Framework == "esx" then
                ESX.Game.SpawnVehicle(vehicleData.model, coords, function(veh)
                    previewVehicle = veh
                    SetVehicleCanLeakPetrol(veh, false)
                    lib.setVehicleProperties(veh, vehicleData)
                    FreezeEntityPosition(veh, true)
                    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA',
                        GetOffsetFromEntityInWorldCoords(previewVehicle, -3.0, 3.0, 0.5), 0.0, 0.0, GetEntityHeading(veh) - 130.0,
                        60.0)
                    SetCamActive(cam, true)
                    RenderScriptCams(true, true, 1000, true, false)
                end)
            else
                QBCore.Functions.SpawnVehicle(vehicleData.model, function(veh)
                    previewVehicle = veh
                    SetVehicleCanLeakPetrol(veh, false)
                    QBCore.Functions.SetVehicleProperties(veh, vehicleData)
                    FreezeEntityPosition(veh, true)
                    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA',
                        GetOffsetFromEntityInWorldCoords(previewVehicle, -3.0, 3.0, 0.5), 0.0, 0.0, GetEntityHeading(veh) - 130.0,
                        60.0)
                    SetCamActive(cam, true)
                    RenderScriptCams(true, true, 1000, true, false)
                end, coords, true)
            end
        end
    end)
end

function ExitPreviewMode()
    if inPreviewMode then
        inPreviewMode = false
        RenderScriptCams(false, true, 1000, true, true)
        lib.callback('gary_garage:setPlayerRoutingBucket', false, function(canContinue)
            if canContinue then
                if previewVehicle then
                    alpha = 255
                    if Config.StoreIsAnimated == true then
                        while alpha > 0  do
                            Wait(5)
                                SetEntityAlpha(previewVehicle, alpha, true)
                            alpha = alpha - 1
                        end
                        
                        if Config.Framework == "esx" then
                            ESX.Game.DeleteVehicle(previewVehicle)
                        else
                            QBCore.Functions.DeleteVehicle(previewVehicle)
                        end
                    else
                        if Config.Framework == "esx" then
                            ESX.Game.DeleteVehicle(previewVehicle)
                        else
                            QBCore.Functions.DeleteVehicle(previewVehicle)
                        end
                        previewVehicle = nil
                    end
                end
            end
        end, 0)
    end
end

function GetVehicleName(model)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local name = GetLabelText(displayName)
    if name == 'NULL' then
        name = Config.VehiclesNames[string.lower(displayName)] or displayName
    end
    return name
end

function GetVehicleMetaData(vehicleData)
    local metadata = {}

    local fuelLevel = math.floor(vehicleData.fuelLevel)
    if vehicleData.fuelLevel then
        table.insert(metadata, {
            label = locale('fuel'),
            value =  fuelLevel .. '%',
            progress = fuelLevel
        })
    end

    local engineHealth = math.floor(vehicleData.engineHealth)
    if vehicleData.engineHealth then
        table.insert(metadata, {
            label = locale('engine'),
            value = engineHealth / 10 .. '%',
            progress = engineHealth / 10
        })
    end
    return metadata
end

function onEnter(self)
    zoneIndex = self.index
    if self.job then
        if Config.Framework == "esx" then
            if ESX.PlayerData.job.name == self.job then
                if Config.UseRadialMenu then
                    lib.addRadialItem({{
                        id = 'access-'.. self.name,
                        label = locale('radial-access-'.. self.name),
                        icon = self.icon,
                        onSelect = function()
                            TriggerEvent('gary_garage:access-' .. self.name, self)
                        end
                    }})
                else
                    TriggerEvent('gary_garage:showtextui')
                end
            end
        else
            
            Player = QBCore.Functions.GetPlayerData()
            jobName = Player.job.name
            if jobName == self.job then
                if Config.UseRadialMenu then
                    lib.addRadialItem({{
                        id = 'access-'.. self.name,
                        label = locale('radial-access-'.. self.name),
                        icon = self.icon,
                        onSelect = function()
                            TriggerEvent('gary_garage:access-' .. self.name, self)
                        end
                    }})
                else
                    TriggerEvent('gary_garage:showtextui', self.name)
                end
            end
        end
    else
        if Config.UseRadialMenu then
            lib.addRadialItem({{
                id = 'access-'.. self.name,
                label = locale('radial-access-'.. self.name),
                icon = self.icon,
                onSelect = function()
                    TriggerEvent('gary_garage:access-' .. self.name, self)
                end
            }})
        else
            TriggerEvent('gary_garage:showtextui', self.name)
        end
    end
end

function onExit(self)
    if zoneIndex then
        zoneIndex = nil
    end
    
    if Config.UseRadialMenu then
        lib.removeRadialItem('access-' ..self.name)
    else
        TriggerEvent('gary_garage:hidetextui')
    end
end

function inside(self)
    if IsControlJustReleased(0, 38) and not Config.UseRadialMenu and not isBusy then
        isBusy = true

        if Config.Framework == "esx" then
            if self.job then
                if ESX.PlayerData.job.name == self.job then
                    TriggerEvent('gary_garage:access-' .. self.name, self)
                end
            else
                TriggerEvent('gary_garage:access-' .. self.name, self)
            end
            Citizen.Wait(1000)
            isBusy = false
        else
            if self.job then
                if PlayerJob.name == self.job then
                    TriggerEvent('gary_garage:access-' .. self.name, self)
                end
            else
                TriggerEvent('gary_garage:access-' .. self.name, self)
            end
            Citizen.Wait(1000)
            isBusy = false
        end
    end
end

RegisterNetEvent('gary_garage:impoundVehicle', function()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local closestV, dist = QBCore.Functions.GetClosestVehicle(vec3(pedCoords.x , pedCoords.y, pedCoords.z))

    if dist < Config.ImpoundCommand.radius then
        if not IsPedInAnyVehicle(ped) then
            if lib.progressBar({
                duration = 8000,
                label = locale('impounding_progress'),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    combat = true,
                    car = true
                },
                anim = {
                    dict = 'mini@repair',
                    clip = 'fixing_a_ped'
                }
            }) then
                TriggerServerEvent('gary_garage:server:setVehicleImpound', GetVehicleNumberPlateText(closestV), true)
                SetEntityAsMissionEntity(closestV, true, false)
                Wait(1000)

                alpha = 255
                if Config.StoreIsAnimated == true then
                    while alpha > 0 do
                        Wait(5)
                        SetEntityAlpha(closestV, alpha, true)
                        alpha = alpha - 1
                    end
                    if Config.Framework == "esx" then
                        ESX.Game.DeleteVehicle(closestV)
                    else
                        QBCore.Functions.DeleteVehicle(closestV)
                    end
                else
                    if Config.Framework == "esx" then
                        ESX.Game.DeleteVehicle(closestV)
                    else
                        QBCore.Functions.DeleteVehicle(closestV)
                    end
                end
                TriggerEvent('gary_garage:notification', locale('vehicle_impounded'), 5500, "success")
            end
        end
    else
        TriggerEvent('gary_garage:notification', locale('no_vehicles_nearby'), 5500, "error")
    end
end)

RegisterNetEvent('gary_garage:takeOutVehicle', function(args)
    DoScreenFadeOut(200)
    Wait(500)
    ExitPreviewMode()
    lib.callback('gary_garage:server:getVehicle', false, function(vehicle)
        if Config.Framework == "esx" then
            if vehicle then
                if vehicle.stored then

                    local vehicleData
                    vehicleData = json.decode(vehicle.vehicle)

                    TriggerEvent('gary_garage:spawnVechicle', vehicleData, vehicle.plate, args.spawn)
                    TriggerEvent('gary_garage:notification', locale('vehicle_out'), 5500, "success")
                    TriggerServerEvent('gary_garage:server:setVehicleOut', vehicle.plate)

                else
                    TriggerEvent('gary_garage:notification', locale('vehicle_lost'), 5500, "error")
                end
            else
                TriggerEvent('gary_garage:notification', locale('vehicle_not_found'), 5500, "error")
            end
            Wait(500)
            DoScreenFadeIn(200)
        else
            if vehicle then
                if vehicle.state then

                    local vehicleData
                    vehicleData = json.decode(vehicle.mods)

                    TriggerEvent('gary_garage:spawnVechicle', vehicleData, vehicle.plate, args.spawn)
                    TriggerEvent('gary_garage:notification', locale('vehicle_out'), 5500, "success")
                    TriggerServerEvent('gary_garage:server:setVehicleOut', vehicle.plate)

                else
                    TriggerEvent('gary_garage:notification', locale('vehicle_lost'), 5500, "error")
                end
            else
                TriggerEvent('gary_garage:notification', locale('vehicle_not_found'), 5500, "error")
            end
            Wait(500)
            DoScreenFadeIn(200)
        end
    end, args.plate)
end)

RegisterNetEvent('gary_garage:sendVehicleImpound', function(targetPlate)
    TriggerServerEvent('gary_garage:server:setVehicleImpound', targetPlate, true)
    TriggerEvent('gary_garage:notification', locale('vehicle_sent_to_impounded'), 5500, "info")
    if Config.Framework == "esx" then
        local vehicles = ESX.Game.GetVehicles()
    else
        local vehicles =  QBCore.Functions.GetVehicles()
    end
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            if string.gsub(vehiclePlate, "%s+", "") == string.gsub(targetPlate, "%s+", "") then

                alpha = 255
                if Config.StoreIsAnimated == true then
                    while alpha > 0 do
                        Wait(5)
                        SetEntityAlpha(vehicle, alpha, true)
                        alpha = alpha - 1
                    end
                    if Config.Framework == "esx" then
                        ESX.Game.DeleteVehicle(vehicle)
                    else
                        QBCore.Functions.DeleteVehicle(vehicle)
                    end
                else
                    if Config.Framework == "esx" then
                        ESX.Game.DeleteVehicle(vehicle)
                    else
                        QBCore.Functions.DeleteVehicle(vehicle)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('gary_garage:findVehicle', function(targetPlate)
    if Config.Framework == "esx" then
        vehicles = ESX.Game.GetVehicles()
    else
        vehicles =  QBCore.Functions.GetVehicles()
    end

    local found = false

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            if string.gsub(vehiclePlate, "%s+", "") == string.gsub(targetPlate, "%s+", "") then
                SetNewWaypoint(vehicleCoords.x, vehicleCoords.y)
                found = true
                break
            end
        end
    end

    if found then
        TriggerEvent('gary_garage:notification', locale('vehicle_found'), 5500, "success")
    else
        TriggerEvent('gary_garage:notification', locale('vehicle_not_found'), 5500, "error")
    end
end)

RegisterNetEvent('gary_garage:transferVehicle', function(args)
    lib.callback('gary_garage:server:canPay', false, function(canPay)
        if canPay then
            TriggerServerEvent('gary_garage:server:setVehicleParking', args.plate, Config.Garages[args.zone].parking)
            TriggerEvent('gary_garage:notification', locale('vehicle_moved'), 5500, "success")
        else
            TriggerEvent('gary_garage:notification', locale('not_enought_money'), 5500, "error")
        end
    end, Config.TransferVehiclePrice[args.zone.type])
end)

RegisterNetEvent('gary_garage:access-garage-job', function(zone)
    local options = {}

    if Config.JobVehicleShopEnabled then
        table.insert(options, {
            title = locale('garage_shop'),
            icon = 'shop',
            menu = 'garage_shop_' ..zone.job,
            onExit = function()
                ExitPreviewMode()
            end
        })
    end

    table.insert(options, {
        title = locale('stored_vehicles'),
        icon = 'warehouse',
        arrow = true,
        onSelect = function()
            TriggerEvent('gary_garage:access-garage', zone)
        end,
        onExit = function()
            ExitPreviewMode()
        end
    })

    lib.registerContext({
        id = 'garage_job',
        title = locale(zone.index),
        options = options,
    })

    lib.showContext('garage_job')
end)

RegisterNetEvent('gary_garage:access-garage', function(zone)
    lib.callback('gary_garage:server:getVehicles', false, function(vehicles)
        local options = {}
        local vehicleData

        if #vehicles > 0 then
            for k, v in pairs(vehicles) do
                if v then
                    if Config.Framework == "esx" then
                        vehicleData = json.decode(v.vehicle)
                    else
                        vehicleData = json.decode(v.mods)
                    end
                    local vehicleTitle = GetVehicleName(vehicleData.model)
                    local iconColor = 'rgb(29 78 216)'
                    local icon = 'car'
                    local description = locale('plate', v.plate)
                    local metadata = GetVehicleMetaData(vehicleData)
                    
                    if Config.Framework == "esx" then
                        if v.stored == 0 or v.stored == false then
                            iconColor = 'rgb(250 204 21)' --Yellow
                        end
                    else
                        if v.state == 0 or v.state == false then
                            iconColor = 'rgb(250 204 21)' --Yellow
                        end                        
                    end 

                    if v.impound == 1 or v.impound == true then
                        iconColor = 'rgb(190 18 60)' --Red
                        vehicleTitle = vehicleTitle .. ' ' .. locale('impounded')
                    end

                    if Config.Framework == "esx" then
                        if v.parking ~= nil and v.parking ~= zone.index and (v.stored == 1 or v.stored == true) then
                            iconColor = 'rgb(96 165 250)'
                            description = description .. ', ' .. locale('parked_in') .. ' ' .. locale(v.parking)
                        end
                    else
                        if v.garage ~= nil and v.garage ~= zone.index and (v.state == 1 or v.state == true) then
                            iconColor = 'rgb(96 165 250)'
                            description = description .. ', ' .. locale('parked_in') .. ' ' .. locale(v.parking)
                        end
                    end

                    if zone.job then
                        table.insert(options, {
                            title = vehicleTitle .. ' ' .. locale('job'),
                            icon = icon,
                            iconColor = iconColor,
                            disabled = v.impound == 1 or v.impound == true,
                            description = description,
                            metadata = metadata,
                            arrow = true,
                            onSelect = function()
                                local options = {}
                                if Config.Framework == "esx" then
                                    if v.stored == 1 or v.stored == true then
                                        if v.parking ~= nil and v.parking ~= zone.index then
                                            table.insert(options, {
                                                title = locale('transfer_vehicle'),
                                                description = '',
                                                icon = 'right-from-bracket',
                                                args = {
                                                    plate = v.plate,
                                                    zone = zone
                                                },
                                                onExit = function()
                                                    ExitPreviewMode()
                                                end,
                                                event = 'gary_garage:transferVehicle'
                                            })
                                        else
                                            EnterPreviewMode(vehicleData,Config.JobGarages[zone.job].locations[zone.index].view)
                                            table.insert(options, {
                                                title = locale('take_out_vehicle'),
                                                icon = 'right-from-bracket',
                                                args = {
                                                    plate = v.plate,
                                                    zone = zone,
                                                    spawn = Config.JobGarages[zone.job].locations[zone.index].spawn
                                                },
                                                onExit = function()
                                                    ExitPreviewMode()
                                                end,
                                                event = 'gary_garage:takeOutVehicle'
                                            })
                                        end
                                    else
                                        ExitPreviewMode()
                                        table.insert(options, {
                                            title = locale('send_vehicle_to_impound'),
                                            icon = 'warehouse',
                                            args = v.plate,
                                            onExit = function()
                                                ExitPreviewMode()
                                            end,
                                            event = 'gary_garage:sendVehicleImpound'
                                        })

                                        table.insert(options, {
                                            title = locale('find_vehicle'),
                                            icon = 'location-dot',
                                            args = v.plate,
                                            onExit = function()
                                                ExitPreviewMode()
                                            end,
                                            event = 'gary_garage:findVehicle'
                                        })
                                    end
                                else
                                    if v.state == 1 or v.state == true then
                                        if v.garage ~= nil and v.garage ~= zone.index then
                                            table.insert(options, {
                                                title = locale('transfer_vehicle'),
                                                description = '',
                                                icon = 'right-from-bracket',
                                                args = {
                                                    plate = v.plate,
                                                    zone = zone
                                                },
                                                onExit = function()
                                                    ExitPreviewMode()
                                                end,
                                                event = 'gary_garage:transferVehicle'
                                            })
                                        else
                                            EnterPreviewMode(vehicleData,Config.JobGarages[zone.job].locations[zone.index].view)
                                            table.insert(options, {
                                                title = locale('take_out_vehicle'),
                                                icon = 'right-from-bracket',
                                                args = {
                                                    plate = v.plate,
                                                    zone = zone,
                                                    spawn = Config.JobGarages[zone.job].locations[zone.index].spawn
                                                },
                                                onExit = function()
                                                    ExitPreviewMode()
                                                end,
                                                event = 'gary_garage:takeOutVehicle'
                                            })
                                        end
                                    else
                                        ExitPreviewMode()
                                        table.insert(options, {
                                            title = locale('send_vehicle_to_impound'),
                                            icon = 'warehouse',
                                            args = v.plate,
                                            onExit = function()
                                                ExitPreviewMode()
                                            end,
                                            event = 'gary_garage:sendVehicleImpound'
                                        })

                                        table.insert(options, {
                                            title = locale('find_vehicle'),
                                            icon = 'location-dot',
                                            args = v.plate,
                                            onExit = function()
                                                ExitPreviewMode()
                                            end,
                                            event = 'gary_garage:findVehicle'
                                        })
                                    end
                                end
                                lib.registerContext({
                                    id = 'garage_vehicle_options',
                                    menu = 'garage_vehicles',
                                    title = vehicleTitle,
                                    options = options,
                                    canClose = false,
                                    onExit = function()
                                        ExitPreviewMode()
                                    end
                                })
                                lib.showContext('garage_vehicle_options')
                            end,
                            onExit = function()
                                ExitPreviewMode()
                            end
                        })
                    else
                        if not v.job then
                            table.insert(options, {
                                title = vehicleTitle,
                                icon = icon,
                                iconColor = iconColor,
                                disabled = v.impound == 1 or v.impound == true,
                                description = description,
                                metadata = metadata,
                                arrow = true,
                                onSelect = function()
                                    local options = {}
                                    
                                    if Config.Framework == "esx" then
                                        if v.stored == 1 or v.stored == true then
                                            if v.parking ~= nil and v.parking ~= zone.index then
                                                table.insert(options, {
                                                    title = locale('transfer_vehicle', Config.TransferVehiclePrice[zone.type]),
                                                    icon = 'right-from-bracket',
                                                    args = {
                                                        plate = v.plate,
                                                        zone = zone
                                                    },
                                                    onExit = function()
                                                        ExitPreviewMode()
                                                    end,
                                                    event = 'gary_garage:transferVehicle'
                                                })
                                            else
                                                EnterPreviewMode(vehicleData, Config.Garages[zone.index].view)
                                                table.insert(options, {
                                                    title = locale('take_out_vehicle'),
                                                    icon = 'right-from-bracket',
                                                    args = {
                                                        plate = v.plate,
                                                        zone = zone,
                                                        spawn = Config.Garages[zone.index].spawn
                                                    },
                                                    onExit = function()
                                                        ExitPreviewMode()
                                                    end,
                                                    event = 'gary_garage:takeOutVehicle'
                                                })
                                            end
                                        else
                                            table.insert(options, {
                                                title = locale('send_vehicle_to_impound'),
                                                icon = 'warehouse',
                                                args = v.plate,
                                                onExit = function()
                                                    ExitPreviewMode()
                                                end,
                                                event = 'gary_garage:sendVehicleImpound'
                                            })

                                            table.insert(options, {
                                                title = locale('find_vehicle'),
                                                icon = 'location-dot',
                                                args = v.plate,
                                                onExit = function()
                                                    ExitPreviewMode()
                                                end,
                                                event = 'gary_garage:findVehicle'
                                            })
                                        end
                                    else
                                        if v.state == 1 or v.state == true then
                                            if v.garage ~= nil and v.garage ~= zone.index then
                                                table.insert(options, {
                                                    title = locale('transfer_vehicle', Config.TransferVehiclePrice[zone.type]),
                                                    icon = 'right-from-bracket',
                                                    args = {
                                                        plate = v.plate,
                                                        zone = zone
                                                    },
                                                    onExit = function()
                                                        ExitPreviewMode()
                                                    end,
                                                    event = 'gary_garage:transferVehicle'
                                                })
                                            else
                                                EnterPreviewMode(vehicleData, Config.Garages[zone.index].view)
                                                table.insert(options, {
                                                    title = locale('take_out_vehicle'),
                                                    icon = 'right-from-bracket',
                                                    args = {
                                                        plate = v.plate,
                                                        zone = zone,
                                                        spawn = Config.Garages[zone.index].spawn
                                                    },
                                                    onExit = function()
                                                        ExitPreviewMode()
                                                    end,
                                                    event = 'gary_garage:takeOutVehicle'
                                                })
                                            end
                                        else
                                            table.insert(options, {
                                                title = locale('send_vehicle_to_impound'),
                                                icon = 'warehouse',
                                                args = v.plate,
                                                onExit = function()
                                                    ExitPreviewMode()
                                                end,
                                                event = 'gary_garage:sendVehicleImpound'
                                            })

                                            table.insert(options, {
                                                title = locale('find_vehicle'),
                                                icon = 'location-dot',
                                                args = v.plate,
                                                onExit = function()
                                                    ExitPreviewMode()
                                                end,
                                                event = 'gary_garage:findVehicle'
                                            })
                                        end
                                    end
                                    lib.registerContext({
                                        id = 'garage_vehicle_options',
                                        menu = 'garage_vehicles',
                                        title = vehicleTitle,
                                        options = options,
                                        canClose = false,
                                        onExit = function()
                                            ExitPreviewMode()
                                        end
                                    })
                                    lib.showContext('garage_vehicle_options')
                                end
                            })
                        end
                    end
                end
            end
        else
            table.insert(options, {
                title = locale('no_vehicles_found'),
                icon = 'x',
                disabled = true,
                onExit = function()
                    ExitPreviewMode()
                end,
            })
        end
        lib.registerContext({
            id = 'garage_vehicles',
            title = locale(zone.index),
            options = options,
            onExit = function()
                ExitPreviewMode()
            end
        })

        lib.showContext('garage_vehicles')
    end, zone.job, zone.type)
end)

RegisterNetEvent('gary_garage:access-store', function(zone)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local currentVehicle = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(currentVehicle, -1) == ped then
            local plate = GetVehicleNumberPlateText(currentVehicle)
            lib.callback('gary_garage:server:checkOwner', false, function(isOwner)
                if isOwner then
                    lib.callback('gary_garage:server:getVehicle', false, function(vehicle)
                        if vehicle then
                            if zone.job then
                                if zone.job == vehicle.job and zone.type == vehicle.type then
                                    vehicleProperties = json.encode(lib.getVehicleProperties(currentVehicle))
                                    TriggerServerEvent('gary_garage:server:updateVehicle', plate, vehicleProperties, zone.index, true)

                                    TaskLeaveVehicle(
                                        ped , 
                                        currentVehicle , 
                                        0 
                                    )

                                    alpha = 255
                                    if Config.StoreIsAnimated == true then
                                        while alpha > 0 do
                                            Wait(5)
                                            SetEntityAlpha(currentVehicle, alpha, true)
                                            alpha = alpha - 1
                                        end

                                        if Config.Framework == "esx" then
                                            ESX.Game.DeleteVehicle(currentVehicle)
                                        else
                                            QBCore.Functions.DeleteVehicle(currentVehicle)
                                        end
                                    else
                                        if Config.Framework == "esx" then
                                            ESX.Game.DeleteVehicle(currentVehicle)
                                        else
                                            QBCore.Functions.DeleteVehicle(currentVehicle)
                                        end
                                    end
                                    TriggerEvent('gary_garage:notification', locale('vehicle_stored'), 5500, "success")
                                else
                                    TriggerEvent('gary_garage:notification', locale('vehicle_not_allowed'), 5500, "error")
                                end
                            else
                                if not vehicle.job and zone.type == vehicle.type then
                                    local vehicleProperties = json.encode(lib.getVehicleProperties(currentVehicle))
                                    TriggerServerEvent('gary_garage:server:updateVehicle', plate, vehicleProperties, zone.index, true, zone.type)

                                    TaskLeaveVehicle(
                                        ped , 
                                        currentVehicle , 
                                        0 
                                    )
                                    
                                    alpha = 255
                                    if Config.StoreIsAnimated == true then
                                        while alpha > 0 do
                                            Wait(5)
                                            SetEntityAlpha(currentVehicle, alpha, true)
                                            alpha = alpha - 1
                                        end
                                        
                                        if Config.Framework == "esx" then
                                            ESX.Game.DeleteVehicle(currentVehicle)
                                        else
                                            QBCore.Functions.DeleteVehicle(currentVehicle)
                                        end
                                    else
                                        if Config.Framework == "esx" then
                                            ESX.Game.DeleteVehicle(currentVehicle)
                                        else
                                            QBCore.Functions.DeleteVehicle(currentVehicle)
                                        end
                                    end

                                    TriggerEvent('gary_garage:notification', locale('vehicle_stored'), 5500, "success")

                                else
                                    TriggerEvent('gary_garage:notification', locale('vehicle_not_allowed'), 5500, "error")
                                end
                            end
                        end
                    end, plate)
                else
                    TriggerEvent('gary_garage:notification', locale('not_owner'), 5500, "error")
                end
            end, plate)
        end
    else
        TriggerEvent('gary_garage:notification', locale('not_in_vehicle'), 5500, "error")
    end
end)

RegisterNetEvent('gary_garage:access-impound', function(zone)
    lib.callback('gary_garage:server:getImpoundedVehicles', false, function(vehicles)
        local options = {}
        local vehicleData
        ExitPreviewMode()

        if vehicles and #vehicles > 0 then
            for k, v in pairs(vehicles) do
                if Config.Framework == "esx" then
                    vehicleData = json.decode(v.vehicle)
                else
                    vehicleData = json.decode(v.mods)
                end
                local vehicleTitle = GetVehicleName(vehicleData.model)
                local iconColor = 'rgb(190 18 60)'
                local icon = 'car'
                local metadata = GetVehicleMetaData(vehicleData)

                table.insert(options, {
                    title = vehicleTitle,
                    icon = icon,
                    iconColor = iconColor,
                    description = locale('plate', v.plate),
                    metadata = metadata,
                    arrow = true,
                    onSelect = function()
                        local options = {}

                        EnterPreviewMode(vehicleData, Config.Impounds[zone.index].view)
                        table.insert(options, {
                            title = locale('recover_vehicle', Config.ImpoundFine[zone.type]),
                            icon = 'file-invoice',
                            args = {
                                plate = v.plate,
                                zone = zone
                            },
                            onExit = function()
                                ExitPreviewMode()
                            end,
                            event = 'gary_garage:recoverVehicle'
                        })
                        
                        lib.registerContext({
                            id = 'garage_vehicle_options',
                            title = vehicleTitle,
                            options = options,
                            onExit = function()
                                ExitPreviewMode()
                            end
                        })
                        lib.showContext('garage_vehicle_options')
                    end
                })
            end
        else
            table.insert(options, {
                title = locale('no_vehicles_found'),
                icon = 'x',
                disabled = true,
                onExit = function()
                    ExitPreviewMode()
                end,
            })
        end

        lib.registerContext({
            id = 'garage_vehicles',
            title = locale(zone.index),
            options = options,
            onExit = function()
                ExitPreviewMode()
            end
        })

        lib.showContext('garage_vehicles')
    end, zone.type)
end)

RegisterNetEvent('gary_garage:recoverVehicle', function(args)
    lib.callback('gary_garage:server:getVehicle', false, function(vehicle)
        local vehicleData
        if vehicle then
            if vehicle.impound then
                lib.callback('gary_garage:server:canPay', false, function(canPay)
                    if canPay == true then
                        if Config.Framework == "esx" then
                            vehicleData = json.decode(vehicle.vehicle)
                        else
                            vehicleData = json.decode(vehicle.mods)
                        end
                        
                        TriggerEvent('gary_garage:spawnVechicle', vehicleData, vehicle.plate, Config.Impounds[args.zone.index].spawn, args.type)
                        TriggerServerEvent('gary_garage:server:setVehicleOut', vehicle.plate, false)
                        TriggerEvent('gary_garage:notification', locale('recoverd_vehicle'), 5500, "success")
                    else
                        TriggerEvent('gary_garage:notification', locale('not_enought_money'), 5500, "error")
                    end
                    ExitPreviewMode()
                end, Config.ImpoundFine[args.zone.type])
            else
                TriggerEvent('gary_garage:notification', locale('vehicle_not_impound'), 5500, "error")
            end
        else
            TriggerEvent('gary_garage:notification', locale('vehicle_not_impound'), 5500, "error")
        end
    end, args.plate)
end)

RegisterNetEvent('gary_garage:server:buyVehicle', function(args)
    lib.callback('gary_garage:server:canPay', false, function(canPay)
        if canPay then
            local vehicle = lib.getVehicleProperties(previewVehicle)
            TriggerServerEvent('gary_garage:server:buyVehicle', vehicle.plate, vehicle, zoneIndex, args.job)
            ExitPreviewMode()
            TriggerEvent('gary_garage:notification', locale('vehicle_purchased'), 5500, "success")
        else
            ExitPreviewMode()
            TriggerEvent('gary_garage:notification', locale('not_enought_money'), 5500, "error")
        end
    end, args.price)
end)

function ManageJobsBlips()
    for k, v in pairs(jobBlips) do
        RemoveBlip(v)
        table.remove(jobBlips, k)
    end            
    if Config.Framework == "esx" then
        for job, v in pairs(Config.JobGarages) do
            if job == ESX.PlayerData.job.name then
                for k, v in pairs(v.locations) do 
                    if v.blip then
                        local blip = AddBlipForCoord(v.access.x, v.access.y)
                
                        SetBlipSprite(blip, v.blip.sprite)
                        SetBlipDisplay(blip, 4)
                        SetBlipScale(blip, v.blip.scale)
                        SetBlipColour(blip, v.blip.colour)
                        SetBlipAsShortRange(blip, true)
                
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentSubstringPlayerName(v.blip.label)
                        EndTextCommandSetBlipName(blip) 
                        table.insert(jobBlips, blip)
                    end
                end
            end
        end
    else
        for job, v in pairs(Config.JobGarages) do
            if job == PlayerJob.name then
                for k, v in pairs(v.locations) do 
                    if v.blip then
                        local blip = AddBlipForCoord(v.access.x, v.access.y)
                
                        SetBlipSprite(blip, v.blip.sprite)
                        SetBlipDisplay(blip, 4)
                        SetBlipScale(blip, v.blip.scale)
                        SetBlipColour(blip, v.blip.colour)
                        SetBlipAsShortRange(blip, true)
                
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentSubstringPlayerName(v.blip.label)
                        EndTextCommandSetBlipName(blip) 
                        table.insert(jobBlips, blip)
                    end
                end
            end
        end
    end
end 

function CreatePeds(ped, location, type)
    if Config.PedEnabled then
        local model = GetHashKey(Config.DefaultPed[type].model)
        local pedTask = Config.DefaultPed[type].task
        
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end

        local ped = CreatePed(0, model ,location, false, false)
        SetPedLodMultiplier(ped, 5.0) -- Increase LOD multiplier
        SetEntityLodDist(ped, 500) -- Set higher LOD distance
        SetEntityAlpha(ped, 255, false) -- Ensure fully visible
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, true)
        TaskStartScenarioInPlace(ped, pedTask, 0, true)
        FreezeEntityPosition(ped, true)
    end
end

function CreateGarages()
    for k, v in pairs(Config.Garages) do
        CreatePeds(v.ped, v.access, v.type)
        if v.blip then
            local blip = AddBlipForCoord(v.store.x, v.store.y)

            SetBlipSprite(blip, Config.GarageBlip[v.type].sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.GarageBlip[v.type].scale)
            SetBlipColour(blip, Config.GarageBlip[v.type].colour)
            SetBlipAsShortRange(blip, true)
    
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locale(v.type..'_garage_blip'))
            EndTextCommandSetBlipName(blip) 
        end

        RemoveVehiclesFromGeneratorsInArea(v.store.x - 20.0, v.store.y - 20.0, v.store.z - 20.0, v.store.x + 20.0, v.store.y + 20.0, v.store.z + 20.0)

        lib.points.new({
            index = k,
            type = v.type,
            name = 'garage',
            icon = 'warehouse',
            coords = v.access,
            distance = Config.AccessDistance,
            nearby = inside,
            onEnter = onEnter,
            onExit = onExit
        })

        lib.points.new({
            index = k,
            type = v.type,
            name = 'store',
            icon = 'square-parking',
            coords = v.store,
            distance = Config.StoreDistance,
            nearby = inside,
            onEnter = onEnter,
            onExit = onExit
        })
    end
end

function CreateImpounds()
    for k, v in pairs(Config.Impounds) do
        CreatePeds(v.ped, v.access, v.type)
        if v.blip then
            local blip = AddBlipForCoord(v.access.x, v.access.y)

            SetBlipSprite(blip, Config.ImpoundBlip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.ImpoundBlip.scale)
            SetBlipColour(blip, Config.ImpoundBlip.colour)
            SetBlipAsShortRange(blip, true)
    
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locale('impound_blip'))
            EndTextCommandSetBlipName(blip) 
        end

        RemoveVehiclesFromGeneratorsInArea(v.access.x - 20.0, v.access.y - 20.0, v.access.z - 20.0, v.access.x + 20.0, v.access.y + 20.0, v.access.z + 20.0)

        lib.points.new({
            index = k,
            type = v.type,
            name = 'impound',
            icon = 'building-shield',
            coords = v.access,
            distance = Config.AccessDistance,
            nearby = inside,
            onEnter = onEnter,
            onExit = onExit
        })
    end
end

RegisterNetEvent('gary_garage:notification')
AddEventHandler('gary_garage:notification', function(message, time, type)
	Config.Notification(message, time, type)
end)

RegisterNetEvent('gary_garage:showtextui')
AddEventHandler('gary_garage:showtextui', function(name)
	Config.ShowTextUi(name)
end)

RegisterNetEvent('gary_garage:hidetextui')
AddEventHandler('gary_garage:hidetextui', function()
	Config.HideTextUI()
end)


function CreateJobGarages()
    if Config.JobGaragesEnabled then
        for job, v in pairs(Config.JobGarages) do
            for garage, w in pairs(v.locations) do
                CreatePeds(v.ped, w.access, w.type)
                RemoveVehiclesFromGeneratorsInArea(w.store.x - 20.0, w.store.y - 20.0, w.store.z - 20.0, w.store.x + 20.0, w.store.y + 20.0, w.store.z + 20.0)

                lib.points.new({
                    index = garage,
                    type = w.type,
                    name = 'garage-job',
                    job = job,
                    icon = 'warehouse',
                    coords = w.access,
                    distance = Config.AccessDistance,
                    nearby = inside,
                    onEnter = onEnter,
                    onExit = onExit
                })

                lib.points.new({
                    index = garage,
                    type = w.type,
                    name = 'store',
                    job = job,
                    icon = 'square-parking',
                    coords = w.store,
                    distance = Config.StoreDistance,
                    nearby = inside,
                    onEnter = onEnter,
                    onExit = onExit
                })
            end
        end
    end
end

for job, vehicles in pairs(Config.JobVehicles) do
    local options = {}
    local menuName = 'garage_shop_' .. job
    for name, info in pairs(vehicles) do
        table.insert(options, {
            title = GetVehicleName(name) .. ' $' .. info.price,
            icon = 'car',
            arrow = true,
            onSelect = function()
                local vehicle = {
                    model = name
                }
                EnterPreviewMode(vehicle, Config.JobGarages[job].locations[zoneIndex].view)
                lib.registerContext({
                    id = 'garage_shop_buy',
                    menu = menuName,
                    canClose = false,
                    title = locale('garage_shop'),
                    onExit = function()
                        ExitPreviewMode()
                    end,
                    options = {{
                        title = locale('buy', info.price),
                        icon = 'money-bill',
                        args = {
                            price = info.price,
                            job = job,
                        },
                        event = 'gary_garage:server:buyVehicle',
                    }}
                })

                lib.showContext('garage_shop_buy')
            end
        })
    end
    lib.registerContext({
        id = menuName,
        title = locale('garage_shop'),
        options = options,
        onExit = function()
            ExitPreviewMode()
        end
    })
end

RegisterCommand('nomoreblack', function(source, args)
    DoScreenFadeIn(10)
end)

if Config.Framework == "esx" then
    Citizen.CreateThread(function()
        while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
        CreateGarages()
        CreateImpounds()
        CreateJobGarages()
        ManageJobsBlips()
    end)
else
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        CreateGarages()
        CreateImpounds()
        CreateJobGarages()
        ManageJobsBlips()
    end)
end