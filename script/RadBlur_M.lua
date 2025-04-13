local RadBlur_M = {}

-- define local function
local function script_path()
    return debug.getinfo(1).source:match("@?(.*[/\\])")
end
----

local GLShaderKit = require "GLShaderKit"

local shader_path = script_path().."RadBlur_M.frag"

if GLShaderKit.isInitialized() then
    RadBlur_M.RadBlur_M = function(x, y, amount, keep_size, quality, reload)

        if amount == 0 then
            return
        end

        ----------------------------------------
        local data, w, h
        w, h = obj.getpixel()

        local max_w, max_h = obj.getinfo("image_max")
        local cx = w / 2 + x
        local cy = h / 2 + y
        local wh = math.floor(math.sqrt(w * w + h * h) + 0.5) -- round
        local inv_amount = 1000 - amount * 10

        local pixel_range = math.max(math.abs(cx), math.abs(cy))
        pixel_range = math.max(pixel_range, math.abs(w - cx))
        pixel_range = math.max(pixel_range, math.abs(h - cy))
        pixel_range = math.max(pixel_range, wh)
        pixel_range = (inv_amount * pixel_range) / 1000 + pixel_range / 2

        local obj_cx = math.min(cx * (1 - 1000 / inv_amount), 0)
        local obj_cy = math.min(cy * (1 - 1000 / inv_amount), 0)

        local result_max_x = math.max((cx - w) * (1 - 1000 / inv_amount), 0) + w
        local result_max_y = math.max((cy - h) * (1 - 1000 / inv_amount), 0) + h

        -- ここは最適化した
        local overflow_w = result_max_x - obj_cx - max_w
        if 0 < overflow_w then
            local overflow_obj_cx = math.min(overflow_w, w - result_max_x - obj_cx)
            if 0 < overflow_obj_cx then
                obj_cx = obj_cx + overflow_obj_cx
                overflow_w = overflow_w - overflow_obj_cx
            end
            if 0 < overflow_w then
                overflow_w = overflow_w / 2
                obj_cx = obj_cx + math.floor(overflow_w)
                result_max_x = result_max_x - math.floor(overflow_w + 0.5)
            end
        end
        local overflow_h = result_max_y - obj_cy - max_h
        if 0 < overflow_h then
            local overflow_obj_cy = math.min(overflow_h, h - result_max_y - obj_cy)
            if 0 < overflow_obj_cy then
                obj_cy = obj_cy + overflow_obj_cy
                overflow_h = overflow_h - overflow_obj_cy
            end
            if 0 < overflow_h then
                overflow_h = overflow_h / 2
                obj_cy = obj_cy + math.floor(overflow_h)
                result_max_y = result_max_y - math.floor(overflow_h + 0.5)
            end
        end
        ----------------------------------------

        data, w, h = obj.getpixeldata()

        if keep_size then
            obj_cx = 0
            obj_cy = 0
            result_max_x = w
            result_max_y = h
        end

        GLShaderKit.activate()
        GLShaderKit.setPlaneVertex(1)
        GLShaderKit.setShader(shader_path, reload)
        GLShaderKit.setFloat("quality", quality)
        GLShaderKit.setInt("rb_pixel_range", pixel_range)
        GLShaderKit.setFloat("src_size", w, h)
        GLShaderKit.setFloat("dst_size", result_max_x - obj_cx, result_max_y - obj_cy)
        GLShaderKit.setFloat("blur_center", cx, cy)
        GLShaderKit.setFloat("obj_center", obj_cx, obj_cy)
        GLShaderKit.setInt("amount", amount * 10)
        GLShaderKit.setInt("pixel_range", pixel_range)
        GLShaderKit.setTexture2D(0, data, w, h)

        if not keep_size then
            -- ここでサイズ変更を行う必要がある
            obj.cx = obj.cx + (w - result_max_x - obj_cx) / 2
            obj.cy = obj.cy + (h - result_max_y - obj_cy) / 2
            obj.setoption("drawtarget", "tempbuffer", result_max_x - obj_cx, result_max_y - obj_cy)
            obj.copybuffer("obj", "tmp")
        end

        data, w, h = obj.getpixeldata()
        GLShaderKit.draw("TRIANGLES", data, w, h)
        GLShaderKit.deactivate()

        obj.putpixeldata(data)
    end
else
    RadBlur_M.RadBlur_M = function(x, y, amount, keep_size, quality, reload)
        obj.setfont("MS UI Gothic", amount + 30)
        obj.load("text", "RadBlur_M is not available on this device.\nRadBlur_Mはこのデバイスでは使用できません。")
        obj.draw()
    end
end

return RadBlur_M