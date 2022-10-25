if (not host:isHost()) then return false end 
if (not require("dependency_checker")) then return end;

local Timeline = require("timeline");
local camera = require("camera");

local transformTimelines = {
    pos = {
        x=Timeline(), y=Timeline(), z=Timeline()
    },
    rot = {
        x=Timeline(), y=Timeline(), z=Timeline()
    }
};
local main = {};
main.playTime = 0;

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
end)

events.TICK:register(function()
    pings["lcamera$move"](models.camera.WORLD:getPos(), models.camera.WORLD.RotPoint:getRot());
end)

main.timelines = transformTimelines;
return main;