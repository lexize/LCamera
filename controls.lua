if (not require("dependency_checker")) then return end;

local main = require("main");
local controls = {}
local chatWasOpenOnPrevFrame = false;

local camera = require("camera");
local path_renderer = require("path_renderer");
local editor        = require("editor");
local easings       = require("easings");

function lockDefaultKB() 
    return true;
end;

local cameraModeNormal = keybind:create("Camera mode: NORMAL", "key.keyboard.1");
local cameraModeEdit = keybind:create("Camera mode: EDIT", "key.keyboard.2");
local cameraModeAnimated = keybind:create("Camera mode: ANIMATED", "key.keyboard.3");
local Slowdown = keybind:create("Slowdown", "key.keyboard.left.control");
local AdditionalAction = keybind:create("Additional action", "key.keyboard.left.alt");
local TimelineForward = keybind:create("Timeline forward", "key.keyboard.right");
local TimelineBackward = keybind:create("Timeline backward", "key.keyboard.left");

local PathToggleKeybind = keybind:create("Toggle path visibility", "key.keyboard.p");
PathToggleKeybind.onPress = function ()
    path_renderer.renderPath = not path_renderer.renderPath;
end

local keybinds = {}
keybinds.Slowdown = Slowdown;
keybinds.AdditionalAction = AdditionalAction;
keybinds.TimelineForward = TimelineForward;
keybinds.TimelineBackward = TimelineBackward;

for _, v in pairs(keybinds) do
    v.onPress = lockDefaultKB;
    v.enabled = false;
end

function cameraModeNormal.onPress ()
    camera:setMode("NORMAL");
    return true;
end

function cameraModeEdit.onPress ()
    local prevMode = camera:getMode();
    if (prevMode == "NORMAL") then
        local p = player:getPos();
        p.y = player:getEyeY();
        camera:setEditPosition(p);
    elseif (prevMode == "ANIMATED") then
        camera:setEditPosition(camera:getAnimationPosition());
        camera:setEditRotation(camera:getAnimationRotation());
    end
    camera:setMode("EDIT");
    return true;
end

function cameraModeAnimated.onPress ()
    camera:setMode("ANIMATED");
    return true;
end

local editModeKeybinds = {};

---@param camPosFunction fun(): Vector3
---@param timelines table<string, Timeline>
---@param coordinate string
function addKeyframe(camPosFunction, timelines, coordinate) 
    return function ()
        local pos = camPosFunction();
        local timeline = timelines[coordinate];
        local keyframe = timeline:getKeyframeBefore(main.playTime);
        local easing = "linear";
        if (keyframe ~= nil) then
            easing = keyframe.keyframe.easing;
        end
        local kf = timeline:addKeyframe(main.playTime, pos[coordinate], easing);
        editor.selectedKeyframe = kf;
        editor.selectedKeyframeTimecode = main.playTime;
        editor.selectedLine = timeline;
        return true;
    end
end

editModeKeybinds.CameraForw = keybind:create("Camera move forward", "key.keyboard.w");
editModeKeybinds.CameraBack = keybind:create("Camera move backward", "key.keyboard.s");
editModeKeybinds.CameraLeft = keybind:create("Camera move left", "key.keyboard.a");
editModeKeybinds.CameraRight = keybind:create("Camera move right", "key.keyboard.d");
editModeKeybinds.CameraUp = keybind:create("Camera move up", "key.keyboard.space");
editModeKeybinds.CameraDown = keybind:create("Camera move down", "key.keyboard.left.shift");
editModeKeybinds.CameraRollLeft = keybind:create("Camera roll left", "key.keyboard.q");
editModeKeybinds.CameraRollRight = keybind:create("Camera roll right", "key.keyboard.e");
editModeKeybinds.CameraRollReset = keybind:create("Camera roll reset", "key.keyboard.r");

editModeKeybinds.KeyframeAddPosX = keybind:create("Add keyframe POS X", "key.keyboard.u");
editModeKeybinds.KeyframeAddPosY = keybind:create("Add keyframe POS Y", "key.keyboard.i");
editModeKeybinds.KeyframeAddPosZ = keybind:create("Add keyframe POS Z", "key.keyboard.o");

editModeKeybinds.KeyframeAddRotX = keybind:create("Add keyframe ROT X", "key.keyboard.j");
editModeKeybinds.KeyframeAddRotY = keybind:create("Add keyframe ROT Y", "key.keyboard.k");
editModeKeybinds.KeyframeAddRotZ = keybind:create("Add keyframe ROT Z", "key.keyboard.l");

editModeKeybinds.DeleteKeyframe = keybind:create("Delete selected keyframe", "key.keyboard.backspace");
editModeKeybinds.NextEasing = keybind:create("Next easing", "key.keyboard.period");
editModeKeybinds.PrevEasing = keybind:create("Prev easing", "key.keyboard.comma");

editModeKeybinds.SelectNext = keybind:create("Select next keyframe [timeline]", "key.keyboard.right.bracket");
editModeKeybinds.SelectPrevious = keybind:create("Select previous keyframe [timeline]", "key.keyboard.left.bracket");
editModeKeybinds.DeselectKeyframe = keybind:create("Deselect keyframe", "key.keyboard.backslash");
editModeKeybinds.SelectNearest = keybind:create("Select nearest keyframe", "key.keyboard.enter");


for _, v in pairs(editModeKeybinds) do
    v.onPress = lockDefaultKB;
    v.enabled = false;
end

editModeKeybinds.KeyframeAddPosX.onPress = addKeyframe(camera.getEditPosition, main.timelines.pos, "x");
editModeKeybinds.KeyframeAddPosY.onPress = addKeyframe(camera.getEditPosition, main.timelines.pos, "y");
editModeKeybinds.KeyframeAddPosZ.onPress = addKeyframe(camera.getEditPosition, main.timelines.pos, "z");

editModeKeybinds.KeyframeAddRotX.onPress = addKeyframe(camera.getEditRotation, main.timelines.rot, "x");
editModeKeybinds.KeyframeAddRotY.onPress = addKeyframe(camera.getEditRotation, main.timelines.rot, "y");
editModeKeybinds.KeyframeAddRotZ.onPress = addKeyframe(camera.getEditRotation, main.timelines.rot, "z");

function editModeKeybinds.CameraRollReset.onPress() 
    local r = camera:getEditRotation();
    camera:setEditRotation(vec(r.x,r.y,0));
    return true;
end

function editModeKeybinds.SelectNext.onPress()
    if (AdditionalAction:isPressed()) then
        editor:selectNextTimeline();
    else
        local tl = editor.selectedLine;
        local kf = tl:getKeyframeAfter(main.playTime);
        if (kf ~= nil) then
            editor.selectedKeyframe = kf.keyframe;
            editor.selectedKeyframeTimecode = kf.timecode;
            main.playTime = kf.timecode;
        end
    end
    return true
end

function editModeKeybinds.SelectPrevious.onPress()
    if (AdditionalAction:isPressed()) then
        editor:selectPrevTimeline();
    else
        local tl = editor.selectedLine;
        local kf = tl:getKeyframeBefore(main.playTime);
        if (kf ~= nil) then
            editor.selectedKeyframe = kf.keyframe;
            editor.selectedKeyframeTimecode = kf.timecode;
            main.playTime = kf.timecode;
        end
    end
    return true
end

function editModeKeybinds.SelectNearest.onPress()
    local tl = editor.selectedLine;
    local kf = tl:getKeyframes();
    local mD = nil;
    local lK = nil;
    local lT = nil;
    for key, value in pairs(kf) do
        local cD = math.abs(main.playTime - key);
        if (mD == nil or mD > cD) then mD = cD; lK = value; lT = key; end
    end
    if (lK ~= nil) then
        editor.selectedKeyframeTimecode = lT;
        editor.selectedKeyframe = lK;
        main.playTime = lT;
    end
    return true;
end

function editModeKeybinds.DeleteKeyframe.onPress()
    local tl = editor.selectedLine;
    if (editor.selectedKeyframeTimecode == null) then return end;
    tl:removeKeyframe(editor.selectedKeyframeTimecode);
    editor.selectedKeyframe = nil;
    editor.selectedKeyframeTimecode = nil;
    return true;
end

function editModeKeybinds.DeselectKeyframe.onPress()
    editor.selectedKeyframe = nil;
    editor.selectedKeyframeTimecode = nil;
    return true;
end

function editModeKeybinds.NextEasing.onPress()
    local kf = editor.selectedKeyframe;
    if (kf ~= nil) then
        local easingId = easings.easingsIds[kf.easing]-1;
        kf.easing = easings.easingsNames[((easingId+1) % #easings.easingsNames) + 1];
    end
    return true;
end

function editModeKeybinds.PrevEasing.onPress()
    local kf = editor.selectedKeyframe;
    if (kf ~= nil) then
        local easingId = easings.easingsIds[kf.easing]-1;
        kf.easing = easings.easingsNames[((easingId-1) % #easings.easingsNames) + 1];
    end
    return true;
end

local animatedModeKeybinds = {};
animatedModeKeybinds.TogglePlayback = keybind:create("Toggle playback", "key.keyboard.space");
animatedModeKeybinds.TogglePlayback.enabled = false;
function animatedModeKeybinds.TogglePlayback.onPress()
    editor.playing = not editor.playing;
    return true;
end


function editModeProcess(delta)
    local movementVector = vec(0,0,0);
    local position = camera:getEditPosition();
    local rotation = camera:getEditRotation();
    local speed = 2;
    if (editModeKeybinds.CameraForw:isPressed()) then movementVector.z = movementVector.z + 1 end
    if (editModeKeybinds.CameraBack:isPressed()) then movementVector.z = movementVector.z - 1 end
    if (editModeKeybinds.CameraRight:isPressed()) then movementVector.x = movementVector.x - 1 end
    if (editModeKeybinds.CameraLeft:isPressed()) then movementVector.x = movementVector.x + 1 end
    if (editModeKeybinds.CameraUp:isPressed()) then movementVector.y = movementVector.y + 1 end
    if (editModeKeybinds.CameraDown:isPressed()) then movementVector.y = movementVector.y - 1 end
    if (Slowdown:isPressed()) then speed = speed / 16 end;
    if (editModeKeybinds.CameraRollLeft:isPressed()) then rotation.z = rotation.z - ((30 * delta) / speed) end
    if (editModeKeybinds.CameraRollRight:isPressed()) then rotation.z = rotation.z + ((30 * delta) / speed) end

    if (AdditionalAction:isPressed()) then speed = math.pow(speed, 2) end;


    local currentBodyRotation = player:getRot();
    rotation.xy = currentBodyRotation;
    local rotMat = matrices.rotation3(0, -rotation.y, 0);
    
    position = position + ((movementVector * delta * 5 * speed) * rotMat);
    camera:setEditPosition(position);
    camera:setEditRotation(rotation);

    local playtimeModifier = 1;
    if (Slowdown:isPressed()) then
        if (AdditionalAction:isPressed()) then playtimeModifier = 0.02
        else playtimeModifier = 0.2 end
    elseif (AdditionalAction:isPressed()) then playtimeModifier = 10 
    end

    if (TimelineForward:isPressed()) then main.playTime = main.playTime + (delta * playtimeModifier) end
    if (TimelineBackward:isPressed()) then main.playTime = math.max(main.playTime - (delta * playtimeModifier), 0) end
end

function animatedModeProcess(delta)
    local playtimeModifier = 1;
    if (Slowdown:isPressed()) then
        if (AdditionalAction:isPressed()) then playtimeModifier = 0.02
        else playtimeModifier = 0.2 end
    elseif (AdditionalAction:isPressed()) then playtimeModifier = 10 
    end

    if (TimelineForward:isPressed()) then main.playTime = main.playTime + (delta * playtimeModifier); editor.playing = false end
    if (TimelineBackward:isPressed()) then main.playTime = math.max(main.playTime - (delta * playtimeModifier), 0); editor.playing = false end
end

function setAllState(keybinds_table, state)
    for key, value in pairs(keybinds_table) do
        value.enabled = state;
    end
end

events.RENDER:register(function(delta)
    delta = delta / 20;
    local mode = camera:getMode();
    setAllState(editModeKeybinds, (mode == "EDIT") and not chatWasOpenOnPrevFrame);
    setAllState(keybinds, (mode == "EDIT" or mode == "ANIMATED") and not chatWasOpenOnPrevFrame);
    setAllState(animatedModeKeybinds, (mode == "ANIMATED") and not chatWasOpenOnPrevFrame);
    if (mode == "EDIT") then
        editModeProcess(delta);
    elseif (mode == "ANIMATED") then
        animatedModeProcess(delta);
    end
    chatWasOpenOnPrevFrame = host:isChatOpen();
end)

return controls;