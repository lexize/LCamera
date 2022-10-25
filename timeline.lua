---@meta timeline

---@class Keyframe
---@field easing string Easing name that keyframe uses
---@field value number Value of keyframe

local easings = require("easings");

local easingNames = {};
for key, _  in pairs(easings) do
    easingNames[key] = key;
end

function timelineSortFunction(a,b)
    return a < b;
end
function getSortedKeys(tbl)
    local keyset = {};
    for k, _ in pairs(tbl) do
        keyset[#keyset+1] = k;
    end
    table.sort(keyset);
    return keyset;
end

function sortByKeys(tbl)
    local out = {};
    local keys = getSortedKeys(tbl);
    for index, value in ipairs(keys) do
        out[value] = tbl[value];
    end
    return out;
end

---@class Timeline
local Timeline = {};

local TimelineMetatable = {}

---@return Timeline
function Timeline_construct()
    
    local self = {};
    local metatable = {}
    self.keyframes = {};
    for key, value in pairs(Timeline) do
        self[key] = value;
    end
    return setmetatable(self, TimelineMetatable);
end

function TimelineMetatable.__index(self, key)
    local keyframes = rawget(self, "keyframes");
    if (type(key) == "number") then
        local timecodes = getSortedKeys(keyframes);
        if (#timecodes < 1) then return end
        if (key <= timecodes[1]) then return keyframes[timecodes[1]].value
        elseif (key >= timecodes[#timecodes]) then return keyframes[timecodes[#timecodes]].value end
        for index, timecode in ipairs(timecodes) do
            if (key <= timecode) then
                local tc1 = timecodes[index-1];
                local tc2 = timecode;
                local kf1 = keyframes[tc1];
                local kf2 = keyframes[tc2];
                local progress = (key - tc1) / (tc2 - tc1);
                return math.lerp(kf1.value, kf2.value, easings[kf1.easing](progress))
            end
        end
    end
end

---@param self Timeline
---@param timecode number Timecode of keyframe
---@param value number Value of keyframe
---@param easing string Easing type of keyframe
---@return Keyframe Added keyframe 
function Timeline.addKeyframe(self, timecode, value, easing) 
    local keyframes = rawget(self, "keyframes");
    if (easing == nil) or (easings[easing] == nil) then easing = "linear" end
    if (type(timecode) ~= "number") then error("Timecode should be number") end
    if (type(value) ~= "number") then error("Value should be number") end
    keyframes[timecode] = {value = value, easing = easing};
    rawset(self, "keyframes", sortByKeys(keyframes));
    return keyframes[timecode];
end

---@param self Timeline
---@param timecode number Timecode of keyframe
function Timeline.removeKeyframe(self, timecode)
    local keyframes = rawget(self, "keyframes");
    keyframes[timecode] = nil;
end

---@param self Timeline
---@return table<number, Keyframe>
function Timeline.getKeyframes(self)
    return rawget(self, "keyframes");
end

---@param self Timeline
---@param timecode number Timecode to get keyframe
---@return {keyframe: Keyframe, timecode: number}|nil Returned keyframe. NIL if dont found any;
function Timeline.getKeyframeBefore(self, timecode)
    local keyframes = rawget(self, "keyframes") --[[@as table<number, Keyframe>]];
    local timecodes = getSortedKeys(keyframes);
    local prevValue;
    local tc;
    for _, key in pairs(timecodes) do
        if (key >= timecode) then break end;
        prevValue = keyframes[key];
        tc = key;
    end
    if (prevValue ~= nil) then return {keyframe=prevValue, timecode=tc} end
end

---@param self Timeline
---@param timecode number Timecode to get keyframe
---@return {keyframe: Keyframe, timecode: number}|nil Returned keyframe. NIL if dont found any;
function Timeline.getKeyframeAfter(self, timecode)
    local keyframes = rawget(self, "keyframes") --[[@as table<number, Keyframe>]];
    local timecodes = getSortedKeys(keyframes);
    for _, key in pairs(timecodes) do
        if (key > timecode) then
            return {keyframe=keyframes[key], timecode=key};
        end
    end
end

---@param self Timeline
---@return number Timecode
function Timeline.getLenght(self)
    local keyframes = rawget(self, "keyframes");
    local timecodes = getSortedKeys(keyframes);
    if (#timecodes < 1) then return 0 end
    return timecodes[#timecodes];
end

function TimelineMetatable.__newindex(self, key, value)
    
end

return Timeline_construct;