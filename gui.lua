if (not require("dependency_checker")) then return end;

local main   = require("main");
local camera = require("camera");

local editor = require("editor");
local easings= require("easings");
local defaultColorScheme = {
    foregroundColor = vec(67, 63, 89, 255) / 255,
    backgroundColor = vec(47, 43, 69, 255)/255,

    timelineSublineXColor = vec(255,100,100,25) / 255,
    timelineSublineYColor = vec(100,255,100,25) / 255,
    timelineSublineZColor = vec(100,100,255,25) / 255,
    timelineSelectedSublineXColor = vec(255,150,150,50) / 255,
    timelineSelectedSublineYColor = vec(150,255,150,50) / 255,
    timelineSelectedSublineZColor = vec(150,150,255,50) / 255,

    timelineSublineXLabelColor = vec(255,100,100, 255) / 255,
    timelineSublineYLabelColor = vec(100,255,100, 255) / 255,
    timelineSublineZLabelColor = vec(100,100,255, 255) / 255,

    unselectedKeyframeColor = vec(1,1,1,1),
    selectedKeyframeColor = vec(0.75,0.5,1,1),

    pointerIconColor = vec(0.65,0.5,1,1),
    pointerLineColor = vec(0.65,0.5,1,1)
}

local hud = lutils.hud;


local keyframeRenders = {
    pos_timeline = {},
    rot_timeline = {}
};

local timelinesOffset = {
    x = 10,
    y = 20,
    z = 30
}

local timelineTextOffsets = {}

local renderElements = {};

function updateTimecode()
    local minutes = math.floor(main.playTime / 60);
    local seconds = math.floor(main.playTime) - (minutes * 60);
    local milliseconds = math.floor(main.playTime * 1000) % 1000;
    renderElements.timecode:text(fillNulls(minutes, 2) .. ":" .. fillNulls(seconds, 2) .. "." .. fillNulls(milliseconds, 3));
end

function updateKeyframeSidebar()
    local kf = editor.selectedKeyframe;
    local easingId = easings.easingsIds[kf.easing];
    local y = math.floor((easingId - 1) / 6);
    local x = ((easingId - 1) % 6) + 1;
    renderElements.keyframeSidebarEasingIcon:uv1(vec(x-1, y) / 6):uv2(vec(x, y+1) / 6);
    renderElements.keyframeSidebarEasingLabel:text("Easing: \n"..kf.easing);
    renderElements.keyframeSidebarValueLabel:text("Value: "..kf.value);
end

function fillNulls(number, nulls)
    local s = tostring(number);
    while #s < nulls do
        s = "0"..s;
    end
    return s;
end

events.ENTITY_INIT:register(function ()
    local textures = textures:getTextures();

    renderElements.timeline = hud:fill():color(defaultColorScheme.foregroundColor);
    renderElements.timelineBackground = hud:fill():color(defaultColorScheme.backgroundColor);

    renderElements.timecode = hud:text():size(1.75):shadow(true);
    updateTimecode();

    renderElements.sublinePosTitle = hud:text():text("Position"):shadow(true);
    renderElements.sublinePosXLabel = hud:text():text("Pos X"):color(defaultColorScheme.timelineSublineXLabelColor):shadow(true);
    renderElements.sublinePosX = hud:fill();
    renderElements.sublinePosYLabel = hud:text():text("Pos Y"):color(defaultColorScheme.timelineSublineYLabelColor):shadow(true);
    renderElements.sublinePosY = hud:fill();

    renderElements.sublinePosZLabel = hud:text():text("Pos Z"):color(defaultColorScheme.timelineSublineZLabelColor):shadow(true);
    renderElements.sublinePosZ = hud:fill();

    renderElements.sublineRotTitle = hud:text():text("Rotation"):shadow(true);
    renderElements.sublineRotXLabel = hud:text():text("Rot X"):color(defaultColorScheme.timelineSublineXLabelColor):shadow(true);
    renderElements.sublineRotX = hud:fill():color(defaultColorScheme.timelineSublineXColor);
    renderElements.sublineRotYLabel = hud:text():text("Rot Y"):color(defaultColorScheme.timelineSublineYLabelColor):shadow(true);
    renderElements.sublineRotY = hud:fill():color(defaultColorScheme.timelineSublineYColor);
    renderElements.sublineRotZLabel = hud:text():text("Rot Z"):color(defaultColorScheme.timelineSublineZLabelColor):shadow(true);
    renderElements.sublineRotZ = hud:fill():color(defaultColorScheme.timelineSublineZColor);

    timelineTextOffsets[1] = hud:getScaledStringWidth("Position", 1.0);
    timelineTextOffsets[2] = hud:getScaledStringWidth("POS X", 1.0);

    renderElements.modeIcon = hud:texture():texture("CUSTOM", textures[2]):size(vec(32,32)):uv1(vec(0,8)/64):uv2(vec(16,24)/64);
    renderElements.keyframeIcon = hud:texture():color(defaultColorScheme.unselectedKeyframeColor)
    :texture("CUSTOM", textures[2]):size(vec(10,10)):uv1(vec(0,0)):uv2(vec(8,8)/64);
    
    renderElements.pointerIcon = hud:texture():texture("CUSTOM", textures[2]):size(vec(10,10)):uv1(vec(8,0)/64):uv2(vec(16,8)/64):color(defaultColorScheme.pointerIconColor);
    renderElements.pointerLine = hud:fill():color(vec(1,1,1,0.25)):pos(vec(0,0,0)):size(vec(2,90)):color(defaultColorScheme.pointerLineColor);
    
    renderElements.timelineTimeHintPointer = hud:fill():color(vec(1,1,1,0.1)):pos(vec(0,0,0)):size(vec(1,90));
    renderElements.timelineTimeHintText = hud:text():color(vec(1,1,1,1)):size(0.75);

    renderElements.keyframeSidebar = hud:fill():color(defaultColorScheme.foregroundColor);
    renderElements.keyframeSidebarEasingShowcaseBackgound = hud:fill():color(defaultColorScheme.backgroundColor):size(vec(110,110));
    renderElements.keyframeSidebarEasingIcon = hud:texture():texture("CUSTOM", textures[1]):size(vec(100,100)):uv1(vec(0,0)):uv2(vec(1,1)/6);
    renderElements.keyframeSidebarValueLabel = hud:text():text("Value: ");
    renderElements.keyframeSidebarEasingLabel = hud:text():text("Easing: ");
end)

events.RENDER:register(function(delta)
    if (camera:getMode() == "NORMAL") then return end
    if (camera:getMode() == "EDIT") then
        renderElements.modeIcon:uv1(vec(0,8)/64):uv2(vec(16,24)/64);
    else
        renderElements.modeIcon:uv1(vec(16,8)/64):uv2(vec(32,24)/64);
    end

    local windowSize = client.getWindowSize() / client.getGuiScale();
    --#region Timeline
    renderElements.timeline:size(vec(windowSize.x, 110)):pos(vec(0, windowSize.y-110, 0));

    renderElements.timecode:pos(vec(2.5, windowSize.y-107.5, 0));
    updateTimecode();

    local sublineWidth = windowSize.x - (50);

    local sublineXOffset = 50;
    local sublineYOffset = windowSize.y- 90;
    renderElements.timelineBackground:size(vec(sublineWidth, 90)):pos(vec(sublineXOffset,sublineYOffset, 0));

    renderElements.sublinePosTitle:pos(vec(48-timelineTextOffsets[1], sublineYOffset, 0));
    renderElements.sublinePosX:size(vec(sublineWidth, 10)):pos(vec(sublineXOffset,sublineYOffset+10, 0));
    renderElements.sublinePosXLabel:pos(vec(48-timelineTextOffsets[2], sublineYOffset+10, 0));
    renderElements.sublinePosY:size(vec(sublineWidth, 10)):pos(vec(sublineXOffset,sublineYOffset+20, 0));
    renderElements.sublinePosYLabel:pos(vec(48-timelineTextOffsets[2], sublineYOffset+20, 0));
    renderElements.sublinePosZ:size(vec(sublineWidth, 10)):pos(vec(sublineXOffset,sublineYOffset+30, 0));
    renderElements.sublinePosZLabel:pos(vec(48-timelineTextOffsets[2], sublineYOffset+30, 0));

    renderElements.sublineRotTitle:pos(vec(48-timelineTextOffsets[1], sublineYOffset+40, 0));
    renderElements.sublineRotX:size(vec(sublineWidth, 10)):pos(vec(sublineXOffset,sublineYOffset+50, 0));
    renderElements.sublineRotXLabel:pos(vec(48-timelineTextOffsets[2], sublineYOffset+50, 0));
    renderElements.sublineRotY:size(vec(sublineWidth, 10)):pos(vec(sublineXOffset,sublineYOffset+60, 0));
    renderElements.sublineRotYLabel:pos(vec(48-timelineTextOffsets[2], sublineYOffset+60, 0));
    renderElements.sublineRotZ:size(vec(sublineWidth, 10)):pos(vec(sublineXOffset,sublineYOffset+70, 0));
    renderElements.sublineRotZLabel:pos(vec(48-timelineTextOffsets[2], sublineYOffset+70, 0));


    if (main.timelines.pos.x == editor.selectedLine) then
        renderElements.sublinePosX:color(defaultColorScheme.timelineSelectedSublineXColor);
    else
        renderElements.sublinePosX:color(defaultColorScheme.timelineSublineXColor);
    end
    if (main.timelines.pos.y == editor.selectedLine) then
        renderElements.sublinePosY:color(defaultColorScheme.timelineSelectedSublineYColor);
    else
        renderElements.sublinePosY:color(defaultColorScheme.timelineSublineYColor);
    end
    if (main.timelines.pos.z == editor.selectedLine) then
        renderElements.sublinePosZ:color(defaultColorScheme.timelineSelectedSublineZColor);
    else
        renderElements.sublinePosZ:color(defaultColorScheme.timelineSublineZColor);
    end

    if (main.timelines.rot.x == editor.selectedLine) then
        renderElements.sublineRotX:color(defaultColorScheme.timelineSelectedSublineXColor);
    else
        renderElements.sublineRotX:color(defaultColorScheme.timelineSublineXColor);
    end
    if (main.timelines.rot.y == editor.selectedLine) then
        renderElements.sublineRotY:color(defaultColorScheme.timelineSelectedSublineYColor);
    else
        renderElements.sublineRotY:color(defaultColorScheme.timelineSublineYColor);
    end
    if (main.timelines.rot.z == editor.selectedLine) then
        renderElements.sublineRotZ:color(defaultColorScheme.timelineSelectedSublineZColor);
    else
        renderElements.sublineRotZ:color(defaultColorScheme.timelineSublineZColor);
    end

    --#endregion
    --#region Keyframe sidebar
    local keyframeSidebarPos = vec(windowSize.x-125, windowSize.y - (110 + 170), 0);
    renderElements.keyframeSidebar:size(vec(125,160)):pos(keyframeSidebarPos);
    renderElements.keyframeSidebarEasingShowcaseBackgound:pos(keyframeSidebarPos+vec(7.5, 42.5,0));
    renderElements.keyframeSidebarEasingIcon:pos(keyframeSidebarPos+vec(12.5, 47.5,0));
    renderElements.keyframeSidebarValueLabel:pos(keyframeSidebarPos+vec(5,5,0));
    renderElements.keyframeSidebarEasingLabel:pos(keyframeSidebarPos+vec(5,16,0));
    --#endregion


    --#region Rendering timeline

    renderElements.timeline:draw();
    renderElements.timecode:draw();
    renderElements.timelineBackground:draw();

    renderElements.sublinePosTitle:draw();
    renderElements.sublinePosX:draw();
    renderElements.sublinePosXLabel:draw();
    renderElements.sublinePosY:draw();
    renderElements.sublinePosYLabel:draw();
    renderElements.sublinePosZ:draw();
    renderElements.sublinePosZLabel:draw();

    renderElements.sublineRotTitle:draw();
    renderElements.sublineRotX:draw();
    renderElements.sublineRotXLabel:draw();
    renderElements.sublineRotY:draw();
    renderElements.sublineRotYLabel:draw();
    renderElements.sublineRotZ:draw();
    renderElements.sublineRotZLabel:draw();

    --#endregion

    --#region Rendering keyframe sidebar
    if (editor.selectedKeyframe ~= null) then
        updateKeyframeSidebar();
        renderElements.keyframeSidebar:draw();
        renderElements.keyframeSidebarEasingShowcaseBackgound:draw();
        renderElements.keyframeSidebarEasingIcon:draw();
        renderElements.keyframeSidebarValueLabel:draw();
        renderElements.keyframeSidebarEasingLabel:draw();
    end
    --#endregion

    renderElements.modeIcon:draw();


    -- Timeline conten rendering
    hud:enableScissor(sublineXOffset, sublineYOffset, sublineWidth, 90);

    local visibleTime = sublineWidth / 50;
    local timelineXOffset = 0;
    if (main.playTime > (visibleTime / 2)) then
        timelineXOffset = main.playTime - (visibleTime / 2);
    end


    local posLine = 0;
    local baseKfPos = vec(sublineXOffset-5 - (timelineXOffset * 50), sublineYOffset,0);
    local baseHintPos = vec(sublineXOffset - (timelineXOffset * 50), sublineYOffset,0);

    -- Rendering pointer

    renderElements.pointerIcon:pos(baseKfPos + vec(main.playTime * 50, 0,0));
    renderElements.pointerLine:pos(baseHintPos + vec(main.playTime * 50, 0,0) - vec(1,0,0));

    renderElements.pointerIcon:draw();
    renderElements.pointerLine:draw();

    -- Rendering time hints

    for i = math.floor(timelineXOffset), math.ceil(visibleTime + timelineXOffset)-1, 1 do
        local minutes = math.floor(i / 60);
        local seconds = math.floor(i) - (minutes * 60);
        renderElements.timelineTimeHintPointer:pos(vec(i * 50, 0,0)+baseHintPos):draw(true);
        renderElements.timelineTimeHintText:pos(vec(i * 50, 0,0)+baseHintPos+vec(2,0,0));
        if (minutes > 0) then
            renderElements.timelineTimeHintText:text(minutes..":"..fillNulls(seconds, 2));
        else
            renderElements.timelineTimeHintText:text(tostring(seconds));
        end
        renderElements.timelineTimeHintText:draw(true);
    end

    -- Rendering position keyframes

    for lineName, timeline in pairs(main.timelines.pos) do
        for time, keyframe in pairs(timeline:getKeyframes()) do
            if time >= timelineXOffset and time <= visibleTime + timelineXOffset then
                local kf = renderElements.keyframeIcon;
                kf:pos(baseKfPos + vec(50*time, timelinesOffset[lineName],0));
                if (keyframe == editor.selectedKeyframe) then kf:color(defaultColorScheme.selectedKeyframeColor) else
                    kf:color(defaultColorScheme.unselectedKeyframeColor) end
                kf:draw(true);
            end
        end
        posLine = posLine + 1;
    end

    -- Rendering rotation keyframes
    for lineName, timeline in pairs(main.timelines.rot) do
        for time, keyframe in pairs(timeline:getKeyframes()) do
            if time >= timelineXOffset and time <= visibleTime + timelineXOffset then
                local kf = renderElements.keyframeIcon;
                kf:pos(baseKfPos + vec(50*time, timelinesOffset[lineName]+40,0));
                if (keyframe == editor.selectedKeyframe) then kf:color(defaultColorScheme.selectedKeyframeColor) else
                    kf:color(defaultColorScheme.unselectedKeyframeColor) end
                kf:draw(true);
            end
        end
        posLine = posLine + 1;
    end
end)