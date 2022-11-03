if (not host:isHost()) then return end 
if (not require("dependency_checker")) then return end;

local Timeline = require("timeline");
local TextComponent = require("textComponent");
local camera = require("camera");
local commandsManager = require("commandsManager");
local regex = lutils.regex;

local tickCounter = 0;

---@type table<string, table<string, Timeline>>
local transformTimelines = {
    pos = {
        x=Timeline(), y=Timeline(), z=Timeline()
    },
    rot = {
        x=Timeline(), y=Timeline(), z=Timeline()
    }
};
local main = {playTime = 0};

events.RENDER:register(function()
    local xPos = transformTimelines.pos.x[main.playTime];
    local yPos = transformTimelines.pos.y[main.playTime];
    local zPos = transformTimelines.pos.z[main.playTime];

    local xRot = transformTimelines.rot.x[main.playTime];
    local yRot = transformTimelines.rot.y[main.playTime];
    local zRot = transformTimelines.rot.z[main.playTime];
    
    local pos = vec(0,0,0);
    local rot = vec(0,0,0);

    if (xPos ~= nil) then pos.x = xPos else pos.x = 0 end
    if (yPos ~= nil) then pos.y = yPos else pos.y = 0 end
    if (zPos ~= nil) then pos.z = zPos else pos.z = 0 end

    if (xRot ~= nil) then rot.x = xRot else rot.x = 0 end
    if (yRot ~= nil) then rot.y = yRot else rot.y = 0 end
    if (zRot ~= nil) then rot.z = zRot else rot.z = 0 end

    camera:setAnimationPosition(pos);
    camera:setAnimationRotation(rot);
    models.camera.WORLD:setPos(pos*16);
    models.camera.WORLD.RotPoint:setRot((rot*vec(-1,-1,0))+vec(0, 180, 0));
    local p = camera:getCurrentPosition();
    local o = math.clamp((pos-p):length()/2, 0, 1);
    models.camera:setOpacity(o);
    models.camera:setVisible(camera:getMode() ~= "ANIMATED");
end)

events.TICK:register(function()
    if (tickCounter == 0) then
        pings["lcamera$move"](models.camera.WORLD:getPos(), models.camera.WORLD.RotPoint:getRot());
    end
    tickCounter = (tickCounter + 1) % 5;
end)

function commandsManager.commands.offset(_, param, ...)
    local timelineContainer = transformTimelines[param];
    if (timelineContainer == nil) then 
        local c = TextComponent:text("No timeline group with name "):Color("red")
        :append(TextComponent:text(param):Color("green")):build();
        printJson(c); 
        return 
    end
    local vals = table.pack(...);
    local axisTable = regex:split(",", vals[1]);
    local offsetsTable = regex:split(",", vals[2]);
    if (#axisTable ~= #offsetsTable) then 
        printJson(TextComponent:text("Axes count and offset values count should be same"):Color("red"):build()); 
        return 
    end
    local offsets = {};
    for i, v in ipairs(axisTable) do
        local n = tonumber(offsetsTable[i]);
        if (n == nil) then
            printJson(TextComponent:text("All values have to be numbers"):Color("red"):build());
            return;
        end
        offsets[v] = n;
    end
    for axis, offset in pairs(offsets) do
        local timeline = timelineContainer[axis];
        if (timeline ~= nil) then
            local keyframes = timeline:getKeyframes();
            for _, keyframe in pairs(keyframes) do
                keyframe.value = keyframe.value + offset;
            end
        end
    end
    printJson(TextComponent:text("Done"):Color("gold"):build());
end

function commandsManager.commands.go_to(_, timecode)
    local v = tonumber(timecode);
    if (v ~= nil) then
        main.playTime = v;
        return;
    else
        printJson(TextComponent:text("Timecode should be number"):Color("red"):build());
    end
end

main.timelines = transformTimelines;
return main;