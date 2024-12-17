local M = {}

function M.new(resize_callback)
    local state = {
        wx = 0,
        wy = 0,
        resize_callback = resize_callback
    }

    local system_name = sys.get_sys_info().system_name

    state.wx, state.wy = window.get_size()

    if system_name ~= 'HTML5' then
        local display_id = defos.get_current_display_id()
        local modes = defos.get_display_modes(display_id)
        local dpr = modes[1].scaling_factor
        state.wx, state.wy = state.wx / dpr, state.wy / dpr
    end

    window.set_listener(function(self, event, data)
        if event == window.WINDOW_EVENT_RESIZED then
            state.wx, state.wy = data.width, data.height
            if state.resize_callback then
                state.resize_callback()
            end
        end
    end)

    function state.center_go_on_screen(go_path)
        go_path = go_path or '.'
        if state.wx == 0 or state.wy == 0 then
            return
        end
        local x = state.wx / 2
        local y = state.wy / 2
        go.set_position(vmath.vector3(x, y, 0), go_path)
    end

    function state.register_on_resize(callback)
        state.resize_callback = callback
    end

    return state
end

return M
