TFA = TFA or {}
local TFA = TFA

local strlow = string.lower
local table_concat = table.concat
local fread = file and file.Read
local istable = istable

local CHAR = {}
for i = 0, 255 do
    CHAR[i] = string.char(i)
end

local B_SLASH = 92
local B_T = 116
local B_N = 110
local B_R = 114

local B_Q1 = 34
local B_Q2 = 39

local B_WS1 = 32
local B_WS2 = 9
local B_WS3 = 13
local B_WS4 = 10

local B_TOPEN1 = 123
local B_TOPEN2 = 91
local B_TCLOSE1 = 125
local B_TCLOSE2 = 93

local B_COMMENT1 = 47
local B_COMMENT2 = 45

local function isWhitespaceByte(b)
    return b == B_WS1 or b == B_WS2 or b == B_WS3 or b == B_WS4
end

local function isNewlineByte(b)
    return b == B_WS3 or b == B_WS4
end

local function isStringByte(b)
    return b == B_Q1 or b == B_Q2
end

local function isTableOpenByte(b)
    return b == B_TOPEN1 or b == B_TOPEN2
end

local function isTableCloseByte(b)
    return b == B_TCLOSE1 or b == B_TCLOSE2
end

local function isCommentStartByte(b)
    return b == B_COMMENT1 or b == B_COMMENT2
end

function TFA.ParseKeyValues(fn, path, use_escape, keep_key_case, invalid_escape_addslash, ordered)
    if use_escape == nil then use_escape = true end
    if keep_key_case == nil then keep_key_case = true end
    if invalid_escape_addslash == nil then invalid_escape_addslash = true end

    local KEY_CASE = keep_key_case
    local ORDERED = ordered and true or false

    local data = fread and fread(fn, path) or nil
    if not data or data == "" then
        return {}
    end

    local root = {}
    local focus = root

    local buffer = {}
    local blen = 0

    local value
    local lastvalue
    local ignore_next_pop = false
    local escape = false
    local stringtype
    local is_comment = false

    local function resetValues()
        lastvalue = nil
        value = nil
    end

    local function flushBuffer(write)
        if blen > 0 or stringtype then
            lastvalue = value
            if lastvalue and not KEY_CASE then
                lastvalue = strlow(lastvalue)
            end

            value = blen > 0 and table_concat(buffer, "", 1, blen) or ""
            blen = 0

            if focus and (write == nil or write) and lastvalue and value ~= nil then
                if ORDERED then
                    focus[#focus + 1] = { key = lastvalue, value = value }
                else
                    focus[lastvalue] = value
                end
                resetValues()
            end
        end
    end

    local function pushTable()
        flushBuffer(true)

        if value and not KEY_CASE then
            value = strlow(value)
        end

        if value and value ~= "" then
            if ORDERED then
                focus[#focus + 1] = { key = value, value = {} }
                local child = focus[#focus].value
                child.__par = focus
                focus = child
            else
                local child = focus[value]
                if not istable(child) then
                    child = {}
                    focus[value] = child
                end
                child.__par = focus
                focus = child
            end
            ignore_next_pop = false
        else
            ignore_next_pop = true
        end

        resetValues()
    end

    local function popTable()
        if not ignore_next_pop then
            flushBuffer(true)
            local parent = focus and focus.__par
            if parent then
                focus.__par = nil
                focus = parent
            end
        end

        ignore_next_pop = false
        resetValues()
    end

    local len = #data

    for i = 1, len do
        local b = data:byte(i)

        if is_comment then
            if isNewlineByte(b) then
                is_comment = false
            end
        elseif escape then
            if b == B_T then
                blen = blen + 1
                buffer[blen] = "\t"
            elseif b == B_N then
                blen = blen + 1
                buffer[blen] = "\n"
            elseif b == B_R then
            else
                if invalid_escape_addslash then
                    blen = blen + 1
                    buffer[blen] = "\\"
                end
                blen = blen + 1
                buffer[blen] = CHAR[b]
            end
            escape = false
        elseif b == B_SLASH and use_escape then
            escape = true
        elseif isStringByte(b) then
            if not stringtype then
                flushBuffer()
                stringtype = b
            elseif stringtype == b then
                flushBuffer()
                stringtype = nil
            else
                blen = blen + 1
                buffer[blen] = CHAR[b]
            end
        elseif stringtype then
            blen = blen + 1
            buffer[blen] = CHAR[b]
        elseif isCommentStartByte(b) then
            local nb = (i < len) and data:byte(i + 1) or nil
            if nb == b then
                is_comment = true
            else
                blen = blen + 1
                buffer[blen] = CHAR[b]
            end
        elseif isWhitespaceByte(b) then
            if blen > 0 then
                flushBuffer()
            end
        elseif isTableOpenByte(b) then
            pushTable()
        elseif isTableCloseByte(b) then
            popTable()
        else
            blen = blen + 1
            buffer[blen] = CHAR[b]
        end
    end

    flushBuffer()
    return root
end
