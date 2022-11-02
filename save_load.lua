if (not require("dependency_checker")) then return end;

local file = lutils.file;
local json = lutils.json;
local main = require("main");
local editor = require("editor");
local TextComponent = require("textComponent");
local commandManager = require("commandsManager");

file:init("LCamera");

local save_load = {};

function save_load.save(name)
    local saveData = {};

    local timelines = main.timelines;

    for key, timelineGroup in pairs(timelines) do
        local timelinesData = {};
        for axis, timeline in pairs(timelineGroup) do
            local kfs = {};
            for timecode, keyframe in pairs(timeline:getKeyframes()) do
                kfs[tostring(timecode)] = keyframe;
            end
            timelinesData[axis] = kfs;
        end
        saveData[key] = timelinesData;
    end

    file:writeText(name .. ".lcm", json:toJson(saveData));
end

function save_load.load(name)
    local fileContent = file:readText(name .. ".lcm");
    local timelineData = json:fromJson(fileContent);

    local timelines = main.timelines;
    for _, group in pairs(timelines) do
        for _, timeline in pairs(group) do
            timeline:clear();
        end
    end

    for timelineGroupName, timelineGroup in pairs(timelineData) do
        for timelineName, timelineKeyframes in pairs(timelineGroup) do
            for timecode, keyframe in pairs(timelineKeyframes) do
                local tc = tonumber(timecode);
                timelines[timelineGroupName][timelineName]:addKeyframe(tc, keyframe.value, keyframe.easing);
            end
        end
    end
end

function commandManager.commands.load(_, name)
    if (not file:exists(name .. ".lcm")) then
        printJson(TextComponent:text("Path with name "):Color("red"):append(
            TextComponent:text(name):Color("green")
        ):append(TextComponent:text(" not found")):build());
        return;
    end
    save_load.load(name);
    editor.selectedKeyframe = nil;
    editor.selectedKeyframeTimecode = nil;
    printJson(TextComponent:text("Path successfully loaded"):Color("green"):build());
end

function commandManager.commands.save(_, name)
    if (file:exists(name .. ".lcm")) then
        local c = TextComponent:text("Path with name "):Color("red"):append(
            TextComponent:text(name):Color("green")
        ):append(
            TextComponent:text(" already exists.\n")
        ):append(
            TextComponent:text("Use "):Color("white"):append(
                TextComponent:text("lc$force_save "):Color("green"):append(
                    TextComponent:text(name):Color("gold"):Bold(true)
                )
            ):append(
                TextComponent:text(" to rewrite file.")
            )
        ):build();
        printJson(c);
        return;
    end
    commandManager.commands.force_save(_, name);
end

function commandManager.commands.force_save(_, name)
    save_load.save(name);
    printJson(TextComponent:text("Path successfully saved"):Color("green"):build());
end

return save_load;