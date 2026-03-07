--[[
    Foundation/CoreFoundation.lua

    Core Utility functions for Mercenary X

    By computerintrusion, March 6th 2026

    Version 1.00
]]

local CoreFoundation = {}

-- private:
    CoreFoundation.__index = CoreFoundation
    CoreFoundation.ReferenceCache = {}
    CoreFoundation.StarterGui = cloneref(game:GetService("StarterGui"))
    CoreFoundation.RawGame = cloneref(game)

--public:
    function CoreFoundation:GetSafeReference(name)
        local cache = self.ReferenceCache
        local reference = cache[name]

        if reference then
            return reference
        end

        reference = cloneref(self.RawGame:FindService(name) or self.RawGame:GetService(name))
        cache[name] = reference

        return reference
    end

    function CoreFoundation:ClearReferenceCache()
        self.ReferenceCache = {}
    end

    function CoreFoundation.PrintDebug(string) 
        print("[MercenaryX::DEBUG]: "..string) 
    end
    function CoreFoundation.PrintInfo(string) 
        print("[MercenaryX::INFO]: "..string) 
    end
    function CoreFoundation.PrintWarn(string) 
        warn("[MercenaryX::WARN]: "..string) 
    end
    function CoreFoundation.PrintError(string) 
        warn("[MercenaryX::ERROR]: "..string) 
    end

    function CoreFoundation:SendNotification(message, duration) 
        self.StarterGui:SetCore("SendNotification", {
            Title = "Mercenary X",
            Text = message,
            Duration = duration,
        })
    end

return CoreFoundation
