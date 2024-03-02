local function ticksToHHMMSS(ticks)
    local seconds = math.floor(ticks / 20)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds - (hours * 3600)) / 60)
    local seconds = seconds - (hours * 3600) - (minutes * 60)
    return hours, minutes, seconds
end

local function choice(c, t, f)
    return c and t or f
end

---Transforms a number into a "Scientific-like" notation, in the sense that values can actually be greater than 1, the limit is 1000
---@param n number
---@return number
---@return string
local function numToAdaptedScientificNotation(n)
    local exponents = { " ", "K", "M", "G", "T", "P", "E", "Z", "Y", "R", "Q" }
    local expId = 1
    while (n >= 1000) do
        expId = expId + 1
        n = n / 1000
    end
    return n, exponents[expId]
end