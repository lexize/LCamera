if (not host:isHost()) then return false end 
if (not require("dependency_checker")) then return end;

local regex = lutils.regex;

local commandsManager = {};

---@type table<string, function>
commandsManager.commands = {};

---@type string
commandsManager.prefix = "lc\\$";

local commandMatcher = "^" .. commandsManager.prefix .. "(\\S+)(?: (.+))?$";

local function commandExecutor(message_text)
    local matches = regex:matches(commandMatcher, message_text);
    if (#matches > 0) then
        local commandMatch = matches[1];
        local commandGroups = commandMatch:groups();

        local f = commandsManager.commands[commandGroups[1]:content()];
        
        if (f ~= nil) then
            local argsText = commandGroups[2]:content();
            local args = {};
            if (argsText ~= nil) then
                args = regex:split(" ", argsText);
            end
            f(commandMatch,table.unpack(args));
            host:appendChatHistory(message_text);
            return nil;
        end
    end
    return message_text;
end

events.CHAT_SEND_MESSAGE:register(commandExecutor);

return commandsManager;