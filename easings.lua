--[[
    Copy-pasted and rewriten to lua from easings.net
]]

local easings = {};

function easings.linear(x)
    return x;
end

function easings.step(x)
    if (x < 1) then return 0 else return 1 end
end


--#region Sine easings
function easings.easeInSine(x)
    return 1 - math.cos((x * math.pi) / 2);
end

function easings.easeOutSine(x)
    return math.sin((x * math.pi) / 2);
end

function easings.easeInOutSine(x)
    return -(math.cos(math.pi * x) - 1) / 2;
end
--#endregion

--#region Quad easings
function easings.easeInQuad(x)
    return x * x;
end

function easings.easeOutQuad(x)
    return 1 - (1 - x) * (1 - x);
end

function easings.easeInOutQuad(x)
    if (x < 0.5) then
        return 2 * x * x;
    else
        return 1 - math.pow(-2 * x + 2, 2) / 2;
    end
end
--#endregion

--#region Cubic easings
function easings.easeInCubic(x)
    return x*x*x;
end

function easings.easeOutCubic(x)
    return 1 - math.pow(1 - x, 3);
end

function easings.easeInOutCubic(x)
    if (x < 0.5) then
       return 4 * x * x * x
    else
        return 1 - math.pow(-2 * x + 2, 3) / 2;
    end
end
--#endregion

--#region Quart easings
function easings.easeInQuart(x)
    return x*x*x*x;
end

function easings.easeOutQuart(x)
    return 1 - math.pow(1 - x, 4);
end

function easings.easeInOutQuart(x)
    if (x < 0.5) then
        return 8 * x * x * x * x;
    else
        return 1 - math.pow(-2 * x + 2, 4) / 2
    end
end
--#endregion

--#region Quint easings
function easings.easeInQuint(x)
    return x*x*x*x*x;
end

function easings.easeOutQuint(x)
    return 1 - math.pow(1 - x, 5);
end

function easings.easeInOutQuint(x)
    if (x < 0.5) then
        return 16 * x * x * x * x * x;
    else
        return 1 - math.pow(-2 * x + 2, 5) / 2;
    end
end
--#endregion

--#region Expo easings
function easings.easeInExpo(x)
    if (x == 0) then return 0 end
    return math.pow(2, 10 * x - 10);
end

function easings.easeOutExpo(x)
    if (x == 1) then return 1 end
    return 1 - math.pow(2, -10 * x);
end

function easings.easeInOutExpo(x)
    if (x == 0) then return 0;
    elseif (x == 1) then return 1;
    elseif (x < 0.5) then return math.pow(2, 20 * x - 10) / 2;
    else return (2 - math.pow(2, -20 * x + 10)) / 2; end
end
--#endregion

--region Circ easings
function easings.easeInCirc(x)
    return 1 - math.sqrt(1 - math.pow(x, 2));
end

function easings.easeOutCirc(x)
    return math.sqrt(1 - math.pow(x - 1, 2));
end

function easings.easeInOutCirc(x) 
    if (x < 0.5) then
        return (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2;
    else
        return (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2;
    end
end
--#endregion

--#region Back easings
function easings.easeInBack(x) 
    local c1 = 1.70158;
    local c3 = c1 + 1;

    return c3 * x * x * x - c1 * x * x;
end

function easings.easeOutBack(x)
    local c1 = 1.70158;
    local c3 = c1 + 1;

    return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2);
end

function easings.easeInOutBack(x)
    local c1 = 1.70158;
    local c2 = c1 * 1.525;

    if (x < 0.5) then
        return (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2;
    else
        return (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
    end
end
--#endregion

--#region Elastic easings
function easings.easeInElastic(x)
    local c4 = (2 * math.pi) / 3;

    if (x == 0) then return 0 elseif (x == 1) then return 1 else
        return -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * c4);
    end
end

function easings.easeOutElastic(x)
    local c4 = (2 * math.pi) / 3;

    if (x == 0) then return 0 elseif (x == 1) then return 1 else
        return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
    end
end

function easings.easeInOutElastic(x)

    local c5 = (2 * math.pi) / 4.5;

    if (x == 0) then
        return 0;
    elseif (x == 1) then
        return 1;
    elseif (x < 0.5) then
        return -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2;
    else
        return (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1;
    end
end
--#endregion

--#region Bounce easings
function easings.easeInBounce(x)
    return 1 - easings.easeOutBounce(x);
end

function easings.easeOutBounce(x)
    local n1 = 7.5625;
    local d1 = 2.75;

    if (x < 1 / d1) then
        return n1 * x * x;
    elseif (x < 2 / d1) then
        x = x - 1.5 / d1;
        return n1 * (x) * x + 0.75;
    elseif (x < 2.5 / d1) then
        x = x - 2.25 / d1;
        return n1 * (x) * x + 0.9375;
    else 
        x = x - 2.625 / d1;
        return n1 * (x) * x + 0.984375;
    end
end

function easings.easeInOutBounce(x) 
    if (x < 0.5) then
        return (1 - easings.easeOutBounce(1 - 2 * x)) / 2
    else
        return  (1 + easings.easeOutBounce(2 * x - 1)) / 2;
    end
end
--#endregion

local easingsIds = {
    linear = 1,
    step = 2,
    easeInSine = 3,
    easeOutSine = 4,
    easeInOutSine = 5,
    easeInQuad = 6,
    easeOutQuad = 7,
    easeInOutQuad = 8,
    easeInCubic = 9,
    easeOutCubic = 10,
    easeInOutCubic = 11,
    easeInQuart = 12,
    easeOutQuart = 13,
    easeInOutQuart = 14,
    easeInQuint = 15,
    easeOutQuint = 16,
    easeInOutQuint = 17,
    easeInExpo = 18,
    easeOutExpo = 19,
    easeInOutExpo = 20,
    easeInCirc = 21,
    easeOutCirc = 22,
    easeInOutCirc = 23,
    easeInBack = 24,
    easeOutBack = 25,
    easeInOutBack = 26,
    easeInElastic = 27,
    easeOutElastic = 28,
    easeInOutElastic = 29,
    easeInBounce = 30,
    easeOutBounce = 31,
    easeInOutBounce = 32,
};
local easingsNames = {}

for easing, index in pairs(easingsIds) do
    easingsNames[index] = easing;
end

easings.easingsIds = easingsIds;
easings.easingsNames = easingsNames;

return easings;