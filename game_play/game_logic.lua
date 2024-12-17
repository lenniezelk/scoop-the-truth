local M = {}

function M.new()
    local state = {
        fuel = 100,
        response_time = 5, -- seconds
        total_questions = 5,
        response_timer = nil,
        current_question = 1,
    }

    return state
end

local questions = {
    {
        question = "Answer is True",
        answer = true,
    },
    {
        question = "Answer is False",
        answer = false,
    },
    {
        question = "Answer is True",
        answer = true,
    },
    {
        question = "Answer is False",
        answer = false,
    },
    {
        question = "Answer is True",
        answer = true,
    },
}

return M
