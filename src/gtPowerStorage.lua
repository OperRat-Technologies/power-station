
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
        local number_with_commas = string.match(raw_capacity, "%d[%d,]*")
        if number_with_commas == nil then
            error(string.format("Failed to extract total capacity for %s", self.proxy.getName()))
        end
        return self.extractNumberFromInformationString(number_with_commas)
    end

    function self.getEUAverageInput()
        local raw_input = self.searchSensorInformation(self.nameInput)
        return self.extractNumberFromInformationString(raw_input)
    end

    function self.getEUAverageOutput()
    local raw_output = self.searchSensorInformation(self.nameOutput)
        return self.extractNumberFromInformationString(raw_output)
    end

    return self
end

return { GTPowerStorage = GTPowerStorage }