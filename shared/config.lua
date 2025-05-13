lib.locale()

Config = {}

Config.Framework = "qbcore" -- esx or qbcore

Config.Webhook = {
    ['transferVehicle'] = '',
    ['setVehicleOut'] = '',
    ['setVehicleParking'] = '',
    ['setVehicleImpound'] = '',
}

Config.Notification = function(message, time, type)
    if type == "success" then
        -- exports["vms_notify"]:Notification("MULTICHARACTERS", message, time, "#27FF09", "fa-solid fa-users")
        -- TriggerEvent('QBCore:Notify', message, 'success', time)
        exports['okokNotify']:Alert("Garage System", message, time, type)
        -- lib.notify({description = locale(message),type = 'success'})
    elseif type == "error" then
        -- exports["vms_notify"]:Notification("MULTICHARACTERS", message, time, "#FF0909", "fa-solid fa-users")
        -- TriggerEvent('QBCore:Notify', message, 'error', time)
        exports['okokNotify']:Alert("Garage System", message, time, type)
        -- lib.notify({description = locale(message),type = 'error'})
    elseif type == "info" then
        -- exports["vms_notify"]:Notification("MULTICHARACTERS", message, time, "#FF0909", "fa-solid fa-users")
        -- TriggerEvent('QBCore:Notify', message, 'error', time)
        exports['okokNotify']:Alert("Garage System", message, time, type)    
        -- lib.notify({description = locale(message),type = 'info'}) 
    end
end

Config.ShowTextUi = function(name)
    -- lib.showTextUI(locale('access-' .. name), {icon = icon})
    exports['okokTextUI']:Open('Press [E] To Access - ' .. name, 'darkgreen', 'right')
end

Config.HideTextUI = function()
    -- lib.hideTextUI()
    return exports['okokTextUI']:Close()
end

Config.UseRadialMenu = false

Config.AccessDistance = 3.0

Config.StoreDistance = 10.0

Config.StoreIsAnimated = true -- true = FadesOut or false = instantly disappearing

Config.MySQL = 'oxmysql' -- 'mysql-async', 'oxmysql', 'ghmattisql'

Config.FuelSystem = 'ox_fuel' -- 'LegacyFuel', 'ox_fuel', 'custom' (client/main.lua:98 to set a custom export)

Config.KeySystem = 'qb-vehiclekeys' -- qb-vehiclekeys or costum

Config.PedEnabled = true

Config.JobGaragesEnabled = true

Config.JobVehicleShopEnabled = true

Config.ImpoundCommandEnabled = true

Config.ImpoundTakeMoneyType = 'bank' -- bank or cash

Config.ImpoundCommand = {
    command = 'impound',
    radius = 2.0,
    jobs = { -- jobs with access to this command 
        'police'
    }
}

Config.ImpoundFine = {
    ['car'] = 5000,
    ['boat'] = 1000,
    ['plane'] = 3000,
}

Config.TransferVehiclePrice = {
    ['car'] = 200,
    ['boat'] = 10000,
    ['plane'] = 4000,
}

Config.DefaultPed = {
    ['car'] = {
        model = 'csb_prolsec',
        task = 'WORLD_HUMAN_CLIPBOARD' --animation https://gtaforums.com/topic/796181-list-of-scenarios-for-peds/
    },
    ['plane'] = {
        model = 's_m_y_airworker',
        task = 'WORLD_HUMAN_CLIPBOARD' --animation https://gtaforums.com/topic/796181-list-of-scenarios-for-peds/
    },
    ['boat'] = {
        model = 's_m_y_baywatch_01',
        task = 'WORLD_HUMAN_CLIPBOARD' --animation https://gtaforums.com/topic/796181-list-of-scenarios-for-peds/
    }
}

Config.GarageBlip = {
    ['car'] = {
        sprite = 357,
        scale = 0.8,
        colour = 18
    },
    ['plane'] = {
        sprite = 569,
        scale = 0.8,
        colour = 18
    },
    ['boat'] = {
        sprite = 473,
        scale = 0.8,
        colour = 18
    }
}

Config.ImpoundBlip = {
    sprite = 317,
    scale = 0.8,
    colour = 6
}

Config.VehiclesNames = {
    -- ['model'] = 'Vehicle Name',
}

Config.JobVehicles = {
    ['police'] = {
        ['police'] = {price = 1000},
        ['police2'] = {price = 1000},
        ['police3'] = {price = 1000},
    },
    ['ambulance'] = {
        ['ambulance'] = {price = 1000},
    },
    ['miner'] = {
        ['sadler'] = {price = 1000000},
    },
    ['taxi'] = {
        ['taxi'] = {price = 1000000},
    },
    ['mechanic'] = {
        ['towtruck'] = {price = 1000000},
    }
}

Config.JobGarages = {
    ['police'] = {
        ped = {
            model = 'csb_trafficwarden',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['vespucci_police'] = {
                blip = { -- only visible to those who have the job
                    label = locale('police_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 29
                },
                access = vec4(440.3128, -1013.3806, 27.6250, 152.6308),
                store = vec4(423.4687, -1021.6505, 28.9481, 88.9128),
                spawn = vec4(450.7397, -1019.5090, 28.4583, 92.3000),
                type = 'car'
            }
        }
    },
    ['ambulance'] = {
        ped = {
            model = 'csb_trafficwarden',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['strawberry_ambulance'] = {
                blip = {
                    label = locale('ambulance_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 6
                },
                access = vec4(353.1519, -603.6036, 27.7761, 267.1620),
                store = vec4(365.2415, -591.6791, 28.6921, 343.2072),
                spawn = vec4(380.5848, -585.6525, 28.6481, 201.6172),
                type = 'car'
            }
        }
    },
    ['miner'] = {
        ped = {
            model = 's_m_m_dockwork_01',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['orchardville_miner'] = {
                blip = {
                    label = locale('miner_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 5
                },
                access = vec4(870.4711, -2366.2339, 29.3462, 356.0012),
                store = vec4(880.8738, -2350.4807, 30.3312, 87.9480),
                spawn = vec4(843.8577, -2346.4854, 30.3346, 265.2579),
                type = 'car'
            }
        }
    },
    ['taxi'] = {
        ped = {
            model = 'u_m_y_proldriver_01',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['tangerine_taxi'] = {
                blip = {
                    label = locale('taxi_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 5
                },
                access = vec4(918.7134, -160.3715, 73.9114, 142.9251),
                store = vec4(910.5366, -177.4915, 74.2616, 237.7346),
                spawn = vec4(902.5016, -184.1103, 73.8883, 332.9777),
                type = 'car'
            }
        }
    },
    ['mechanic'] = {
        ped = {
            model = 's_m_m_dockwork_01',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['olympic_mechanic'] = {
                blip = {
                    label = locale('mechanic_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 39
                },
                access = vec4(-192.9804, -1290.3110, 30.2965, 272.3626),
                store = vec4(-182.0340, -1301.9659, 31.2965, 272.7176),
                spawn = vec4(-160.9252, -1301.6703, 31.3432, 89.9771),
                type = 'car'
            }
        }
    }
}

Config.Garages = {
    ['elgin'] = {
        access = vec4(214.5288, -807.0486, 29.8031, 342.1742),
        store = vec4(216.8447, -786.5744, 30.8161, 340.5844),
        spawn = vec4(218.8343, -796.9872, 30.2135, 68.5696),
        view = vec4(230.7546, -795.9514, 30.5859, 160.6045),
        type = 'car',
        blip = true
    },
    ['aguja'] = {
        access = vec4(-1183.1499, -1508.2714, 3.3797, 308.6074),
        store = vec4(-1191.9292, -1492.1295, 4.3797, 33.9222),
        spawn = vec4(-1191.8651, -1482.6228, 3.7098, 126.1869),
        view = vec4(-1177.7272, -1483.6582, 4.3797, 211.5811),
        type = 'car',
        blip = true
    },
    ['shambles'] = {
        access = vec4(996.9217, -2360.1174, 29.5, 351.5527),
        store = vec4(1015.7012, -2331.0493, 30.5096, 172.7233),
        spawn = vec4(1004.4929, -2367.5283, 29.8457, 351.4763),
        view = vec4(1013.7295, -2364.3025, 30.5096, 352.7007),
        type = 'car',
        blip = true
    },
    ['eclipse'] = {
        access = vec4(-570.7280, 310.9371, 83.4977, 355.5518),
        store = vec4(-567.1437, 329.4330, 84.4461, 84.1943),
        spawn = vec4(-577.1274, 314.1176, 83.9927, 353.8900),
        view = vec4(-607.3918, 337.1939, 85.1167, 263.8757),
        type = 'car',
        blip = true
    },
    ['great_ocean'] = {
        access = vec4(-200.1778, 6234.4956, 30.5027, 235.2995),
        store = vec4(-200.5813, 6214.3184, 31.4893, 45.7559),
        spawn = vec4(-201.1597, 6227.1968, 30.8226, 225.0204),
        view = vec4(-193.0426, 6225.6099, 31.4897, 141.6068),
        type = 'car',
        blip = true
    },
    ['panorama_drive'] = {
        access = vec4(1649.2954, 3567.1265, 34.3912, 45.3013),
        store = vec4(1634.6001, 3565.2202, 35.2683, 117.2702),
        spawn = vec4(1627.6442, 3556.0447, 34.5929, 296.8875),
        view = vec4(1608.8293, 3602.7205, 35.1463, 30.0080),
        type = 'car',
        blip = true
    },
    ['new_empire'] = {
        access = vec4(-942.2376, -2956.1157, 12.9451, 129.7652),
        store = vec4(-974.9199, -2997.5334, 13.9450, 240.2666),
        spawn = vec4(-956.1517, -3362.3677, 14.4880, 59.5662),
        spawn = vec4(-974.8014, -3298.9353, 14.0472, 65.6655),
        type = 'plane',
        blip = true
    }
}

Config.Impounds = {
    ['innocence'] = {
        access = vec4(409.2835, -1623.0498, 28.2919, 232.2472),
        view = vec4(407.1664, -1645.2323, 29.2919, 228.8734),
        spawn = vec4(395.9922, -1644.5226, 28.6207, 320.7308),
        type = 'car',
        blip = true
    },
    ['vespucci'] = {
        access = vec4(-1057.9415, -840.6771, 4.0427, 214.2390),
        spawn = vec4(-1053.1279, -846.0181, 4.1965, 216.4621),
        view = vec4(-1052.3311, -856.4564, 4.8715, 127.4942),
        type = 'car',
        blip = true
    },
    ['paleto'] = {
        access = vec4(-456.8438, 6017.9258, 30.4901, 38.0822),
        spawn = vec4(-467.4146, 6015.9771, 31.3405, 312.0559),
        type = 'car',
        blip = true
    },
    ['zancudo'] = {
        access = vec4(1852.5085, 3706.8975, 32.2539, 30.6991),
        spawn = vec4(1864.8422, 3700.9099, 33.5391, 214.8698),
        type = 'car',
        blip = true
    },
    ['pista_1'] = {
        access = vec4(-1229.4432, -3377.8064, 12.9450, 332.6432),
        spawn = vec4(-1270.8102, -3376.1331, 13.9401, 329.9285),
        type = 'plane',
        blip = true
    },
}
