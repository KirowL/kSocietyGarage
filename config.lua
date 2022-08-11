Config = {
    StoreVehiclesOnReboot = true, -- All the vehicles come back to the garage on every reboot. 
    Garages = {
        ["police"] = {
            GaragePosition = {coords = vector3(-1077.032959, -862.114258, 4.864502), radius = 1.5},
            SpawnPosition = {coords = vector3(-1071.072510, -863.947266, 4.864502), heading = 218.26},
            DeletePoint = {coords = vector3(-1075.041748, -868.720886, 4.847656), radius = 3.0},
            Vehicles = {
                {model = "police", label = "Police", price = 15000},
                {model = "police2", label = "Police 2", price = 50000},
                {model = "police3", label = "Police 3", price = 30},
                {model = "police4", label = "Police 4", price = 1},
            }
        },
        ["ambulance"] = {
            GaragePosition = {coords = vector3(-1058.347290, -857.037354, 4.864502), radius = 1.5},
            SpawnPosition = {coords = vector3(-1060.048340, -862.971436, 4.898193), heading = 218.26},
            DeletePoint = {coords = vector3(-1060.457153, -862.549438, 4.881348), radius = 3.0},
            Vehicles = {
                {model = "ambulance", label = "L'ambulance loooo", price = 15000},
            }
        }
    },
    Shop = {
        ShopPosition = {coords = vector3(-1056.250488, -880.391235, 5.032959), radius = 1.5},
        SpawnPosition = {coords = vector3(-1058.967041, -886.351624, 4.645386), heading = 155.90},
    },
    GenericJobPlate = {
        ["police"] = "LSPD",
        ["ambulance"] = "EMS"
    }
}