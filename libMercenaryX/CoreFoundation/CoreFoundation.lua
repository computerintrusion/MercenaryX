--[[
    Foundation/CoreFoundation.lua

    Core Utility functions for Mercenary X

    By computerintrusion, March 6th 2026

    Version 1.10
]]

local coreFoundation = {};

function coreFoundation:safeConnection(event, callback)
    local currentCallback = callback;
    local connection;

    local function protectedCallback(...)
        local success, err = pcall(currentCallback, ...);
        if (not success) then
            warn("[safeConnection] callback error:", err);
        end
    end

    local function connect()
        connection = event:Connect(protectedCallback);
    end

    connect();

    return {
        disconnect = function()
            if (connection and connection.Connected) then
                connection:Disconnect();
            end
        end,

        reconnect = function(newCallback)
            if (connection and connection.Connected) then
                connection:Disconnect();
            end

            currentCallback = newCallback or currentCallback;
            connect();
        end,

        isConnected = function()
            return connection and connection.Connected or false;
        end
    }
end

return coreFoundation;
