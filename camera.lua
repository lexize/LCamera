if (not require("dependency_checker")) then return end;
local camera = {}

local editCameraPosition = vec(0,0,0);
local editCameraRotation = vec(0,0,0);
local animatedCameraPosition = vec(0,0,0);
local animatedCameraRotation = vec(0,0,0);

local cameraMode = "NORMAL";

---@enum CameraMore
local cameraModes = {
    NORMAL = 0,
    EDIT = 1,
    ANIMATED = 2
}

camera.cameraModes = cameraModes;

local cameraModesToTransform = {
    NORMAL = {
        pos = nil, rot = nil
    },
    EDIT = {
        pos = editCameraPosition, rot = editCameraRotation
    },
    ANIMATED = {
        pos = animatedCameraPosition, rot = animatedCameraRotation
    }
}
local f5ForwardOffset = -4;

events.RENDER:register(function(delta)
    if (not renderer:isFirstPerson()) then
        if (cameraMode ~= "NORMAL") then
            renderer:setCameraPos(0,0,f5ForwardOffset);
        else
            renderer:setCameraPos(nil);
        end
    else
        renderer:setCameraPos(0,0,0);
    end
    renderer:setCameraPivot(cameraModesToTransform[cameraMode].pos);
    renderer:setCameraRot(cameraModesToTransform[cameraMode].rot);
end)

function camera:getCurrentPosition()
    if (cameraMode == "NORMAL") then
        local p = player:getPos();
        p.y = player:getEyeY();
        return p;
    else 
        return cameraModesToTransform[cameraMode].pos;
    end
end

---@param mode CameraMore
function camera:setMode(mode)
    if (cameraModes[mode] ~= nil) then
        cameraMode = mode;
    else
        cameraMode = 0;
    end
end

---@return CameraMore
function camera:getMode()
    return cameraMode;
end

---@return Vector3
function camera:getEditPosition()
    return editCameraPosition;
end

---@return Vector3
function camera:getEditRotation()
    return editCameraRotation;
end

---@param pos Vector3
function camera:setEditPosition(pos)
    if (pos.xyz ~= nil) then editCameraPosition.xyz = pos.xyz end
end

---@param rot Vector3
function camera:setEditRotation(rot)
    if (rot.xyz ~= nil) then editCameraRotation.xyz = rot.xyz end
end

---@return Vector3
function camera:getAnimationPosition()
    return animatedCameraPosition;
end

---@return Vector3
function camera:getAnimationRotation()
    return animatedCameraRotation;
end

---@param pos Vector3
function camera:setAnimationPosition(pos)
    if (pos.xyz ~= nil) then animatedCameraPosition.xyz = pos.xyz end
end

---@param rot Vector3
function camera:setAnimationRotation(rot)
    if (rot.xyz ~= nil) then animatedCameraRotation.xyz = rot.xyz end
end

return camera;