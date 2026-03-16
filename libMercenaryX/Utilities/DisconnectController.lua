if (not rawget(getgenv and getgenv(), "gethui")) then
    warn("[Mercenary X]: missing alias gethui, executor not supported");
    return;
end

local disconnectController = {};

do
    local players = cloneref(game:GetService("Players"));
    local localPlayer = players.LocalPlayer;

    local isKicked = false;

    local baseTitle = "Mercenary X";
    local baseMessage = "You have been disconnected from the experience.";

    local getHiddenGui = function()
        return gethui and gethui();
    end

    function disconnectController:overridePrompt()
        local coreGui = getHiddenGui();
        if (not coreGui) then
            return;
        end

        local promptGui = coreGui:FindFirstChild("RobloxPromptGui");
        if (not promptGui) then
            return;
        end

        local overlay = promptGui:FindFirstChild("promptOverlay");
        if (not overlay) then
            return;
        end

        local errorPrompt = overlay:FindFirstChild("ErrorPrompt");
        if (not errorPrompt) then
            return;
        end

        local titleFrame = errorPrompt:FindFirstChild("TitleFrame");
        if (titleFrame) then

            local errorTitle = titleFrame:FindFirstChild("ErrorTitle");
            if (errorTitle) then
                errorTitle.Text = baseTitle;
            end
        end

        local messageArea = errorPrompt:FindFirstChild("MessageArea");
        if (messageArea) then

            local errorFrame = messageArea:FindFirstChild("ErrorFrame");
            if (errorFrame) then

                local errorMessage = errorFrame:FindFirstChild("ErrorMessage")
                if (errorMessage) then
                    errorMessage.Text = baseMessage;
                end
            end
        end
    end

    function disconnectController:Kick(message)
        if (isKicked) then
            return;
        end

        isKicked = true;
        baseMessage = message or baseMessage;

        task.spawn(function()
            while (isKicked) do
                task.wait(0);

                pcall(function()
                    localPlayer:Kick(message);
                    disconnectController:overridePrompt();
                end)
            end
        end)
    end
end

return disconnectController;
