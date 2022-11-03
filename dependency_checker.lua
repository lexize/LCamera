if (host:isHost()) then
    local noLutilsInstalled = "[\"\",{\"text\":\"You dont have \"},{\"text\":\"LUtils\",\"color\":\"gold\"},{\"text\":\" installed. You can download last version here: https://github.com/lexize/lutils\"}]";
    local hudSubmoduleTurnedOff = "[\"\",{\"text\":\"You dont have HUD submodule enabled. It is experimental submodule, so it is turned off by default. \",\"color\":\"red\"},{\"text\":\"To turn it on, go to minecraft directory, find file \\\"lutils_experimental_settings.json\\\", and set state of HUD submodule to \"},{\"text\":\"true\",\"color\":\"green\"},{\"text\":\".\"}]";
    if (lutils == nil) then
        printJson(noLutilsInstalled);
        return false;
    elseif (lutils.hud == nil) then
        printJson(hudSubmoduleTurnedOff);
        return false;
    end

    return true;
end
return false;