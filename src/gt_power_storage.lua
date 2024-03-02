
local GTPowerStorage = {}
GTPowerStorage.new = function(proxy, inStr, outStr)
    local self = {}

    self.proxy = proxy
    self.sensorInfo = proxy.getSensorInformation()
    self.inStr = inStr
    self.outStr = outStr

    function self.searchSensorInformation(searchStr)
        for _, v in ipairs(self.sensorInfo) do
            if string.find(v, searchStr) then
                return v
            end
        end
        return ""
    end

    function self.updateSensorInfo()
        self.sensorInfo = proxy.getSensorInformation()
    end

    ---Clears colored strings
    ---@param str string
    ---@return string
    function self.clearSensorInformationString(str)
        local result, _ = string.gsub(str, "§.", "")
        return result
    end

    function self.extractNumberFromInformationString(str)
        local result = string.gsub(str, ",", "")
        local _, _, number = string.find(result, "(%d+)")
        return tonumber(number)
    end

    function self.getEUStored()
        return self.proxy.getEUStored()
    end

    function self.getEUCapacity()
        return self.proxy.getEUCapacity()
    end

    function self.getEUAverageInput()
        return self.extractNumberFromInformationString(self.clearSensorInformationString(self.searchSensorInformation(
            self.inStr)))
    end

    function self.getEUAverageOutput()
        return self.extractNumberFromInformationString(self.clearSensorInformationString(self.searchSensorInformation(
            self.outStr)))
    end

    return self
end