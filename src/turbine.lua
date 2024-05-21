local component = require("component")
local config = require("config")

local Turbine = {}
Turbine.new = function(wirelessFrequency, totalEuCapacity)
    local self = {}

    self.wirelessFrequency = wirelessFrequency
    self.totalEuCapacity = totalEuCapacity
    self.enabled = true

    component.redstone.setWirelessFrequency(wirelessFrequency)
    component.redstone.setWirelessOutput(false)

    function self.updateTurbine(totalEUStored)
        if not self.enabled then
            return
        end
            
        local euPercentage = (totalEUStored / self.totalEuCapacity) * 100
            
        if euPercentage < minPowerPercentageThreshold then
            component.redstone.setWirelessOutput(true)
        elseif euPercentage > maxPowerPercentageThreshold then
            component.redstone.setWirelessOutput(false)
        end
    end

    function self.changeFrequency(newFrequency)
        self.wirelessFrequency = newFrequency
        component.redstone.setWirelessFrequency(newFrequency)
    end

    return self
end

return { Turbine = Turbine }
