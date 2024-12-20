
local GTPowerStorage = {}
GTPowerStorage.new = function(proxy, inStr, outStr, nameCapacity)
    local self = {}

    self.proxy = proxy
    self.sensorInfo = proxy.getSensorInformation()
    self.nameInput = inStr
    self.nameOutput = outStr
    self.nameCapacity = nameCapacity

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
        table.sort(self.sensorInfo)
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

     ---The current amount of energy stored on the machine
     ---@return number
    function self.getEUStored()
        return self.proxy.getEUStored()
    end

    ---The maximum amount of energy that the machine can store
    ---@return number
    function self.getEUCapacity()
        local raw_capacity = self.searchSensorInformation(self.nameCapacity)
        return self.extractNumberFromInformationString(
            self.clearSensorInformationString(raw_capacity)
        )
    end

    function self.getEUAverageInput()
        return self.extractNumberFromInformationString(
            self.clearSensorInformationString(
                self.searchSensorInformation(self.nameInput)
            )
        )
    end

    function self.getEUAverageOutput()
        return self.extractNumberFromInformationString(
            self.clearSensorInformationString(
                self.searchSensorInformation(self.nameOutput)
            )
        )
    end

    return self
end

return { GTPowerStorage = GTPowerStorage }