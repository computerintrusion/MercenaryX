local coreFoundation = {};

do
    local executor = identifyexecutor and identifyexecutor() or "unknown executor";
    local messagebox = messageboxasync or messagebox;
    local request = request or http_request;
    local loadstring = loadstring;

    coreFoundation.referenceCache = {};
    coreFoundation.isKicked = false;
    
    function coreFoundation:getService(name)
        local cache = self.referenceCache;
        local reference = cache[name];

        if (reference) then
            return reference;
        end

        reference = cloneref(game:FindService(name) or game:GetService(name));
        cache[name] = reference;

        return reference;
    end

    -- function coreFoundation:getServices(names)
    --     if (type(names) ~= "table") then
    --         warn(`getServices syntax error (1) - expected table type for names, got {type(names)}`)
    --         return;
    --     end

    --     local results = {};
    --     local getService = self.getService;

    --     for i = 1, #names do
    --         results[i] = getService(self, names[i]);
    --     end

    --     return unpack(results);
    -- end

    function coreFoundation:kickPlayer(reason)
        
        if (self.isKicked) then
            return;
        end

        self.isKicked = true;

        self:getService("Players").LocalPlayer:Kick(`[Mercenary X] {reason}`);

        return task.wait(9e9);
    end
    
    if (type(messagebox) ~= "function") then
        return coreFoundation:kickPlayer(`missing alias ( messagebox ) - unsupported executor [{executor}]`);
    end

    function coreFoundation:protectedMessagebox(body, title, id)

        local success, output = pcall(messagebox, body, title, id);
        if (success) then
            return output;
        end

        return self:kickPlayer(`messagebox failed - {body}`);
    end

    if (type(loadstring) ~= "function") then
        return coreFoundation:protectedMessagebox(`missing alias ( loadstring ) - unsupported executor`, `[{executor}]`, 48);
    elseif (type(request) ~= "function") then
        return coreFoundation:protectedMessagebox(`missing alias ( request ) - unsupported executor`, `[{executor}]`, 48);
    end

    function coreFoundation:protectedLoad(url, ...)

        if (type(url) ~= "string") then
            self:protectedMessagebox(`protectedLoad syntax error (1) - expected string type for url, got {type(url)}`, `[{executor}]`, 48);
            return task.wait(9e9);
        end

        local success, response = pcall(request, { Url = url, Method = "GET" });
        if (not success) then
            self:protectedMessagebox(`protectedLoad failed (1) - request error\n\nurl: {url}`, `[{executor}]`, 48);
            return task.wait(9e9);
        elseif (type(response.Body) ~= "string" or response.StatusCode ~= 200) then
            self:protectedMessagebox(`protectedLoad failed (2) - bad response\n\nurl: {url}`, `[{executor}]`, 48);
            return task.wait(9e9);
        end

        local loader = loadstring(response.Body);
        if (not loader) then
            self:protectedMessagebox(`protectedLoad failed (3) - syntax error\n\nurl: {url}`, `[{executor}]`, 48);
            return task.wait(9e9);
        end

        return loader(...);
    end
end

table.freeze(coreFoundation);
return coreFoundation;
