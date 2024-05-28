local component = require("component")
local config = require("config")

local Turbine = {}
Turbine.new = function(totalEuCapacity)
    local self = {}

    self.totalEuCapacity = totalEuCapacity
    self.enabled = true

    component.redstone.setWirelessOutput(false)

    function self.updateTurbine(totalEUStored)
        if not self.enabled then
            return
        end
            
        local euPercentage = (totalEUStored / self.totalEuCapacity) * 100
            
        if euPercentage < config.minPowerPercentageThreshold then
            component.redstone.setOutput(4,10) -- Fix this later to MCU network signals
        elseif euPercentage > config.maxPowerPercentageThreshold then
            component.redstone.setOutput(4,0) -- Fix this later to MCU network signals
        end
    end

    return self
end

return { Turbine = Turbine }
