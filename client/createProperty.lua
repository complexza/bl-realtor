CreateProperty = {
    creating = false,
    label = "",
    description = "",
    for_sale = false,
    price = 0,
    shell = "",
    door_data = nil,
    garage_data = nil,

    StartCreating = function(self)
        self.creating = true
    end,

    CancelCreating = function(self)
        self.creating = false
        self.label = ""
        self.description = ""
        self.for_sale = false
        self.price = 0
        self.shell = ""
        self.door_data = nil
        self.garage_data = nil
        self.creating = false
    end,

    SetTextFields = function(self, data)
        self.label = data.label
        self.description = data.description
        self.for_sale = data.for_sale
        self.price = data.price
        self.shell = data.shell
    end,

    PlacingZone = function(self, type)
        local zoneDataPromise = promise.new()
        ZoneThread(type, zoneDataPromise)
        local zoneData = Citizen.Await(zoneDataPromise)
        if not zoneData then return end
        zoneData.x = math.floor(zoneData.x* 100) / 100
        zoneData.y = math.floor(zoneData.y* 100) / 100
        zoneData.z = math.floor(zoneData.z* 100) / 100
        zoneData.h = math.floor(zoneData.h* 100) / 100
        if type == "door" then
            self.door_data = zoneData
            self.door_data.locked = false
            self.door_data.length = 1.5
            self.door_data.width = 2.2
            SendNUIMessage({
                action = "createdDoor",
                data = true
            })
        elseif type == "garage" then
            self.garage_data = zoneData
            SendNUIMessage({
                action = "createdGarage",
                data = true
            })
        end
    end,

    RemoveGarage = function(self)
        self.garage_data = nil
        SendNUIMessage({
            action = "createdGarage",
            data = nil
        })
    end,

    CreateProperty = function(self)
        local data = {
            label = self.label,
            description = self.description,
            for_sale = self.for_sale,
            price = self.price,
            shell = self.shell,
            door_data = self.door_data,
            garage_data = self.garage_data,
        }
        TriggerServerEvent("bl-realtor:server:registerProperty", data)
        self:CancelCreating()
    end,
}

RegisterNUICallback("create:startCreating", function(data, cb)
    CreateProperty:StartCreating()
    cb("ok")
end)

RegisterNUICallback("create:cancelCreating", function(data, cb)
    CreateProperty:CancelCreating()
    cb("ok")
end)

RegisterNUICallback("create:setTextFields", function(data, cb)
    CreateProperty:SetTextFields(data)
    cb("ok")
end)

RegisterNUICallback("create:confirmListing", function(data, cb)
    CreateProperty:CreateProperty()
    cb("ok")
end)

RegisterNUICallback("create:createZone", function(data, cb)
    local type = data.type
    SetNuiFocus(false, false)
    CreateProperty:PlacingZone(type)
    cb("ok")
end)

RegisterNUICallback("create:removeGarage", function(data, cb)
    CreateProperty:RemoveGarage()
    cb("ok")
end)