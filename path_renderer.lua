if (not require("dependency_checker")) then return end;

local main = require("main");

local path_renderer = {
    renderPath = false
}

events.RENDER:register(function()
    if (path_renderer.renderPath) then
        local maxLength = 0;
        for _, timeline in pairs(main.timelines.pos) do
            maxLength = math.max(timeline:getLenght(), maxLength);
        end

        local i = math.max(0, main.playTime - 2.5);

        while i < math.min(maxLength, main.playTime + 2.5) do
            local pos = vec(0,0,0);
            for coord, timeline in pairs(main.timelines.pos) do
                local v = timeline[i];
                if (v ~= nil) then
                    pos[coord] = v;
                end
            end
            particles:addParticle("dust 0.5 0.5 1.0 0.5", pos.x, pos.y, pos.z);
            i = i + 0.1;
        end
    end
end)

return path_renderer;