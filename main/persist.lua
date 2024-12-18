local defsave = require("defsave.defsave")

local APP_NAME = "poke_the_truth"
local ANSWERS_KEY = "answers"
local FILE_NAME = "userdata"

local M = {}

function M.new()
    defsave.appname = APP_NAME

    local state = {}

    defsave.load(FILE_NAME)

    function state.save_answers(answers)
        defsave.set(FILE_NAME, ANSWERS_KEY, answers)
        defsave.save(FILE_NAME)
    end

    function state.load_answers()
        return defsave.get(FILE_NAME, ANSWERS_KEY)
    end

    return state
end

return M
