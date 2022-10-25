local client = {};

---@param pos Vector3 Camera position
---@param rot Vector3 Camera rotation
pings["lcamera$move"] = function (pos, rot)
    if (not host:isHost()) then
        models.camera.WORLD:setPos(pos);
        models.camera.WORLD.RotPoint:setRot(rot);
    end
end

if (not host:isHost()) then
    local nicknameTask = models.camera.WORLD.addText();
    nicknameTask:pos(0,16,0);

    events.ENTITY_INIT:register(function ()
        nicknameTask.text(player:getName());
    end)
end

return client;