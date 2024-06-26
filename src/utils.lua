local function ticksToHHMMSS(ticks)
    local seconds = math.floor(ticks / 20)

    local days = math.floor(seconds / 86400)
    seconds = seconds - (days * 86400)

    local hours = math.floor(seconds / 3600)
    seconds = seconds - (hours * 3600)

    local minutes = math.floor(seconds / 60)
    seconds = seconds - (minutes * 60)

    return days, hours, minutes, seconds
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
    while (math.abs(n) >= 1000) do
        expId = expId + 1
        n = n / 1000
    end
    return n, exponents[expId]
end

---Format a string for it to be centralized
---@param formattedString string
---@param width number
---@param emptyChar string
---@return string
local function centeredString(formattedString, width, emptyChar)
    -- Calculate padding
    local totalPadding = width - #formattedString
    local leftPadding = math.floor(totalPadding / 2)
    local rightPadding = totalPadding - leftPadding

    -- Construct the centered string
    return string.rep(emptyChar, leftPadding) .. formattedString .. string.rep(emptyChar, rightPadding)
end

return {
    ticksToHHMMSS = ticksToHHMMSS,
    choice = choice,
    numToAdaptedScientificNotation = numToAdaptedScientificNotation,
    centeredString = centeredString
}
