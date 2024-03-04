
function AverageValue(count)
    local self = {
        count = count,
        avg = 0,
        values = {}
    }

    function self.calculateAverage()
        local sum = 0
        for i = 1, #self.values do
            sum = sum + self.values[i]
        end
        self.avg = sum / #self.values
    end

    function self.add(value)
        table.insert(self.values, value)
        if (#self.values > self.count) then
            table.remove(self.values, 1)
        end
        self.calculateAverage()
    end

    return self
end

return {
    AverageValue = AverageValue
}