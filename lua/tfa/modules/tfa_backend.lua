local string = string
local math = math
local table = table
local ipairs = ipairs
local http = http
local hook = hook
local CurTime = CurTime
local IsValid = IsValid
local LocalPlayer = LocalPlayer

hook.Add("HUDPaint", "TFA_TRIGGERCLIENTLOAD", function()
    if IsValid(LocalPlayer()) then
        hook.Call("TFA_ClientLoad")
        hook.Remove("HUDPaint", "TFA_TRIGGERCLIENTLOAD")
    end
end)

local MEMBERCOUNT_STRING_START = "<memberCount>"
local MEMBERCOUNT_STRING_END = "</memberCount>"

local MEMBER_STRING_START = "<members>"
local MEMBER_STRING_END = "</members>"

local GROUPID_STRING_START = "<groupID64>"
local GROUPID_STRING_END = "</groupID64>"

local PRIVACY_STRING_START = "<privacyState>"
local PRIVACY_STRING_END = "</privacyState>"

local function XML_GetMembers(xml)
    local memberStart = string.find(xml, MEMBER_STRING_START) + #MEMBER_STRING_START
    local memberEnd = string.find(xml, MEMBER_STRING_END) - 1
    local res = string.sub(xml, memberStart, memberEnd)
    local resTbl = string.Explode("<steamID64>", res)

    table.remove(resTbl, 1)
    for k, v in ipairs(resTbl) do
        v = string.Replace(v, "</steamID64>", "")
        v = string.Trim(v)
        resTbl[k] = v
    end

    return resTbl
end

function TFA.GetGroupMembers(groupname, callback)
    local async_count = 0

    http.Fetch("http://steamcommunity.com/groups/" .. groupname .. "/memberslistxml/?xml=1&p=" .. (async_count + 1) .. "&time=" .. math.Round(CurTime()),
        function(bodytext)
            async_count = async_count + 1

            local memberStart = string.find(bodytext, MEMBERCOUNT_STRING_START) + #MEMBERCOUNT_STRING_START
            local memberEnd = string.find(bodytext, MEMBERCOUNT_STRING_END) - 1
            local memberCount = tonumber(string.sub(bodytext, memberStart, memberEnd))

            local pageCount = math.ceil(memberCount / 1000)
            local members = XML_GetMembers(bodytext)

            if async_count == pageCount then
                callback(members)
                return
            end

            for i = 2, pageCount do
                http.Fetch("http://steamcommunity.com/groups/" .. groupname .. "/memberslistxml/?xml=1&p=" .. i .. "&time=" .. math.Round(CurTime()),
                    function(bodytext2)
                        async_count = async_count + 1
                        local memberOuter = XML_GetMembers(bodytext2)

                        for _, v in ipairs(memberOuter) do
                            table.insert(members, v)
                        end

                        if async_count == pageCount then
                            callback(members)
                        end
                    end
                )
            end
        end
    )
end

function TFA.GetUserInGroup(groupname, steamid64, callback)
    http.Fetch("http://steamcommunity.com/groups/" .. groupname .. "/memberslistxml/?xml=1&p=" .. math.Round(CurTime()),
        function(bodytext)
            local memberStart = string.find(bodytext, GROUPID_STRING_START) + #GROUPID_STRING_START
            local memberEnd = string.find(bodytext, GROUPID_STRING_END) - 1
            local groupid = string.sub(bodytext, memberStart, memberEnd)

            http.Fetch("http://steamcommunity.com/profiles/" .. tostring(steamid64) .. "/?xml=1",
                function(profileText)
                    local psStart = string.find(profileText, PRIVACY_STRING_START) + #PRIVACY_STRING_START
                    local psEnd = string.find(profileText, PRIVACY_STRING_END) - 1
                    local privacyStr = string.sub(profileText, psStart, psEnd)
                    privacyStr = string.Trim(privacyStr)

                    if privacyStr ~= "public" then
                        TFA.GetGroupMembers(groupname, function(members)
                            if table.HasValue(members, LocalPlayer():SteamID64()) then
                                callback(true)
                            else
                                callback(false)
                            end
                        end)
                        return
                    end

                    if string.find(profileText, groupid, 1, true) then
                        callback(true)
                    else
                        callback(false)
                    end
                end
            )
        end
    )
end
