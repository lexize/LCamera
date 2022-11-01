if (not require("dependency_checker")) then return end;

local file = lutils.file;
local json = lutils.json;
local main = require("main");
local editor = require("editor");
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
        printJson("Path with name '"..name.."' not found");
        return;
    end
    save_load.load(name);
    editor.selectedKeyframe = nil;
    editor.selectedKeyframeTimecode = nil;
    printJson("Path successfully loaded");
end

function commandManager.commands.save(_, name)
    if (file:exists(name .. ".lcm")) then
        printJson("Path with name '"..name.."' already exists. Use 'lc$force_save "..name.."' to rewrite file.");
        return;
    end
    save_load.save(name);
    printJson("Path successfully saved");
end

function commandManager.commands.force_save(_, name)
    save_load.save(name);
    printJson("Path successfully saved");
end

return save_load;