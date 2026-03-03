local PROJECT_NAME = "MercenaryX" -- this is the folder that everything will be downloaded to

local CacheManager = {}
CacheManager.__index = CacheManager

-- Cached Variables
local writefile, readfile, loadfile = writefile, readfile, loadfile or function(...)  -- make sure we have a safety net
    return (...)
end
local request = request or http_request 
local stringformat = string.format
local cloneref = cloneref or function(...)  -- make sure we have a safety net
    return (...)
end

local HttpService = cloneref(game:GetService("HttpService"))

--[[
    TryRequest

    Attempts to send an HTTP request to the specified URL.
    Returns the response body if successful, otherwise nil.
]]
local TryRequest = function(data)
    assert(data and (data.Url or data.URL),
        "(Mercenary X) [TryRequest] Missing URL")

    local exploit_request = request or http_request
    assert(exploit_request,
        "(Mercenary X) [TryRequest] No request function available in this executor")

    local url = data.Url or data.URL

    assert(type(url) == "string" and url ~= "",
        "(Mercenary X) [TryRequest] 'Url' must be a valid string")

    local request_response = exploit_request({
        Url = url,
        Method = data.Method or "GET",
        Headers = {
            ["User-Agent"] = data.UserAgent or "Mercenary-X",
        }
    })

    if not request_response or request_response.StatusCode ~= 200 then
        warn(string.format(
            "(Mercenary X) [TryRequest] Status Code: %s | Failed URL: %s",
            tostring(request_response and request_response.StatusCode or "No Response"),
            url
        ))
        return nil
    end

    return request_response.Body
end

local function RequireFromURL(url)
    local source = TryRequest({ Url = url })
    if not source then
        error("(Mercenary X) [RequireFromURL] Failed to download module.")
    end

    local chunk, loadError = loadstring(source)
    if not chunk then
        error("(Mercenary X) [RequireFromURL] Loadstring failed: " .. tostring(loadError))
    end

    local success, result = pcall(chunk)
    if not success then
        error("(Mercenary X) [RequireFromURL] Runtime error: " .. tostring(result))
    end

    return result
end

local HashLib = RequireFromURL("https://gist.githubusercontent.com/computerintrusion/af6e4f5cd1a24b40488ff94fd0825d8a/raw/7d20ac3ae874773cdd643faaacee7f7e5f4ecaf8/Cryptography-SHA.lua")
if not HashLib then
    print("HashLib failed to initialize.")
    return
end

function CacheManager:DownloadWithIntegrityCheck(url)
    assert(type(url) == "string",
        "(Mercenary X) [DownloadWithIntegrityCheck] parameter #1 must be a string.")

    assert(type(url) == "string" and url ~= "",
        "(Mercenary X) [DownloadWithIntegrityCheck] 'url' must be a non-empty string.")

    assert(url:match("^https?://"),
        "(Mercenary X) [DownloadWithIntegrityCheck] 'url' must be a valid HTTP/HTTPS URL.")

    local response = TryRequest({ 
        Url = url, 
        Method = "GET" 
    })

    if not response then
        return false
    end

    local success, manifest = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not success or type(manifest) ~= "table" then
        return false
    end

    for _, fileData in pairs(manifest) do
        if type(fileData) ~= "table" then
            return false
        end

        local signature = fileData.signature
        local fileUrl = fileData.file

        if type(signature) ~= "string" or type(fileUrl) ~= "string" then
            return false
        end

        local fileResponse = TryRequest({
            Url = fileUrl,
            Method = "GET"
        })

        if not fileResponse then
            return false
        end

        local computedHash = HashLib.sha256(fileResponse)

        if string.lower(computedHash) ~= string.lower(signature) then
            return false
        end

        writefile(PROJECT_NAME .. "/Modules/" .. computedHash, fileResponse)
    end

    return true
end

-- TODO: maybe can use setfenv ?
function CacheManager:Load(filePath)
    local chunk, error = loadfile(filePath)
    if not chunk then
        return nil, ("(Mercenary X) [Load] Failed to load file '%s': %s"):format(filePath, error)
    end

    local success, result = pcall(chunk)
    if not success then
        return nil, ("(Mercenary X) [Load] Error running file '%s': %s"):format(filePath, result)
    end

    return result
end

return CacheManager
