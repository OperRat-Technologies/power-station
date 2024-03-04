
local term = require("term")
local gpu = require("gpu")

---Class for controlling a printable parameter inside the interface
---@param row number
---@param col number
---@param length number
---@param format string
---@return table
function CIParam(row, col, length, format)
    local self = {
        row = row,
        col = col,
        length = length,
        format = format
    }

    local function setCursor()
        term.setCursor(col, row)
    end
    
    function self.print(...)
        self.setCursor()
        term.write(string.format(self.format, ...), false)
    end

    function self.clear()
        gpu.fill(self.col, self.row, self.length, 1, " ")
    end

    return self
end

---Class for holding the screen interface
---@param rows number
---@param cols number
---@param bgColor number
---@param fgColor number
---@param background string
function CIScreen(rows, cols, bgColor, fgColor, background)
    local self = {
        rows = rows,
        cols = cols,
        bgColor = bgColor,
        fgColor = fgColor,
        background = background,
        params = {}
    }

    gpu.setForeground(self.fgColor)
    gpu.setBackground(self.bgColor)
    gpu.setResolution(self.cols, self.rows)
    gpu.setViewport(self.cols, self.rows)

    function self.printBackground()
        term.setCursor(1, 1)
        term.write(background)
    end

    function self.registerParam(param)
        table.insert(self.params, param)
        return param
    end

    function self.clearAllParams()
        for i = 1, #self.params do
            self.params[i].clear()
        end
    end

    return self
end

return {
    Param = CIParam,
    Screen = CIScreen
}