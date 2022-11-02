if (not require("dependency_checker")) then return end;

local main = require("main");
local camera = require("camera");
local commandsManager = require("commandsManager");
local TextComponent = require("textComponent");
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
---@type boolean
editor.playing = false;
---@type Timeline
editor.selectedLine = main.timelines.pos.x;

function commandsManager.commands.set(_, val)
    local sk = editor.selectedKeyframe;
    if (sk == nil) then printJson(TextComponent:text("No selected keyframe"):Color("red"):build()); return end
    local v = tonumber(val);
    if (v == nil) then printJson(TextComponent:text("Value should be number"):Color("red"):build()); return end
    sk.value = v;
end

function commandsManager.commands.add(_, val)
    local sk = editor.selectedKeyframe;
    if (sk == nil) then printJson(TextComponent:text("No selected keyframe"):Color("red"):build()); return end
    local v = tonumber(val);
    if (v == nil) then printJson(TextComponent:text("Value should be number"):Color("red"):build()); return end
    sk.value = sk.value + v;
end

function commandsManager.commands.sub(_, val)
    local sk = editor.selectedKeyframe;
    if (sk == nil) then printJson(TextComponent:text("No selected keyframe"):Color("red"):build()); return end
    local v = tonumber(val);
    if (v == nil) then printJson(TextComponent:text("Value should be number"):Color("red"):build()); return end
    sk.value = sk.value - v;
end

function commandsManager.commands.clear(_)
    local tls = main.timelines;
    for _, group in pairs(tls) do
        for _, timeline in pairs(group) do
            timeline:clear();
        end
    end
    editor.selectedKeyframe = nil;
    editor.selectedKeyframeTimecode = nil;
    printJson(TextComponent:text("All keyframes was deleted"):Color("green"):build());
end

events.RENDER:register(function(delta)
    if (editor.playing) then
        local maxLength = 0;
        for _, timelineGroup in pairs(main.timelines) do
            for _, timeline in pairs(timelineGroup) do
                maxLength = math.max(maxLength, timeline:getLenght());
            end
        end
        if (main.playTime < maxLength) then
            main.playTime = main.playTime + (delta / 20);
        else
            editor.playing = false;
        end
    end
    editor.playing = editor.playing and camera:getMode() == "ANIMATED";
end)

return editor;