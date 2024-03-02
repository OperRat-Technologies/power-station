local component = require("component")
local config = require("config")


local Alarm = {}
Alarm.new = function(wirelessFrequency, machine)
    local self = {}

    self.wirelessFrequency = wirelessFrequency
    self.machine = machine
    self.enabled = true

    component.redstone.setWirelessFrequency(wirelessFrequency)
    component.redstone.setWirelessOutput(false)

    function self.updateAlarm()
        if self.enabled then
            local psPercentage = (self.machine.getEUStored() / self.machine.getEUCapacity()) * 100
            component.redstone.setWirelessOutput(psPercentage < config.alarmPowerPercentageThreshold)
        end
    end

    function self.changeFrequency(newFrequency)
        self.wirelessFrequency = newFrequency
        component.redstone.setWirelessFrequency(newFrequency)
    end

    return self
end