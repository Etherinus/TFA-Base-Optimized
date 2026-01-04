local timer_Create = timer and timer.Create
local vector_origin = vector_origin
local angle_zero = angle_zero

if not timer_Create then
    return
end

timer_Create("tfa_base_vecorfix", 5, 0, function()
    if vector_origin then
        vector_origin.x = 0
        vector_origin.y = 0
        vector_origin.z = 0
    end

    if angle_zero then
        angle_zero.p = 0
        angle_zero.y = 0
        angle_zero.r = 0
    end
end)
