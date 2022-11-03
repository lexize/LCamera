local prevPos = vec(0,0,0);
local newPos = vec(0,0,0);
local prevRot = vec(0,0,0);
local newRot = vec(0,0,0);
local moveProgress = 0;

---@param pos Vector3 Camera position
---@param rot Vector3 Camera rotation
pings["lcamera$move"] = function (pos, rot)
    if (not host:isHost()) then
        prevPos = models.camera.WORLD:getPos();
        prevRot = models.camera.WORLD.RotPoint:getRot();
        newPos = pos;
        newRot = rot;
        moveProgress = 0;
    end
end

local nicknameTask = models.camera.WORLD:addText(""):centered(true):scale(0.5,0.5,0.5);
nicknameTask:pos(0,16,0);

events.RENDER:register(function(delta)
    if (player ~= nil) then
        nicknameTask:text(player:getName());
    end
    local camPos = (models.camera.WORLD:getPos()/16)+vec(0,1,0);
    local clientCamPos = client:getCameraPos();
    local directionVec = (camPos - clientCamPos);
    local horizontalDir = directionVec.xz:normalized();
    local angle = math.deg(math.atan2(horizontalDir.x, horizontalDir.y));
    local fullDir = directionVec:normalized():transform(matrices.rotation3(0, -angle, 0));
    local vAngle = math.deg(math.atan2(fullDir.y, fullDir.z));
    nicknameTask:rot(-vAngle, angle,0);
    if (not host:isHost()) then
        models.camera.WORLD:setPos(math.lerp(prevPos, newPos, moveProgress));
        models.camera.WORLD.RotPoint:setRot(math.lerp(prevRot, newRot, moveProgress));
        moveProgress = math.min(moveProgress + ((delta / 20) * 4), 1);
    end
    nicknameTask:enabled(not host:isHost());
end)