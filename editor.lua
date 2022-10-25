if (not require("dependency_checker")) then return end;

local main = require("main")

local editor = {}

local timelines = {
    [0]=main.timelines.pos.x,
    [1]=main.timelines.pos.y,
    [2]=main.timelines.pos.z,
    [3]=main.timelines.rot.x,
    [4]=main.timelines.rot.y,
    [5]=main.timelines.rot.z,
};

function editor:selectNextTimeline()
    for index = 0, 5, 1 do
        local value = timelines[index];
        if (value == editor.selectedLine) then
            local ind = (index + 1) % 6;
            editor.selectedLine = timelines[ind];
            break;
        end
    end
end

function editor:selectPrevTimeline()
    for index = 0, 5, 1 do
        local value = timelines[index];
        if (value == editor.selectedLine) then
            local ind = (index - 1) % 6;
            editor.selectedLine = timelines[ind];
            break;
        end
    end
end

---@type Keyframe
editor.selectedKeyframe = nil;
---@type number
editor.selectedKeyframeTimecode = nil;
---@type Timeline
editor.selectedLine = main.timelines.pos.x;

return editor;