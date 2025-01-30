local table_length = require('main.table_length')
local questions = require('main.questions')
local persist = require('main.persist')


local M = {}

function M.new()
    local response_timer = nil
    local current_fuel = 100
    local previous_fuel = 100
    local total_questions = table_length.len(questions.questions)
    local current_question = 1
    local answers = {}
    local remaining_response_time = 10 -- seconds
    local total_fuel = 100
    local total_response_time = 10     -- seconds
    local fuel_usage_timer = nil
    local playing = false

    local state = {}
    local persist = persist.new()

    function decrease_fuel(delta)
        if (not delta) then
            delta = total_fuel / total_questions
        end

        previous_fuel = current_fuel
        current_fuel = current_fuel - delta
        if current_fuel < 0 then
            current_fuel = 0
        end
    end

    function increase_fuel(delta)
        if (not delta) then
            delta = total_fuel / total_questions
        end

        previous_fuel = current_fuel
        current_fuel = current_fuel + delta
        if current_fuel > 100 then
            current_fuel = 100
        end
    end

    function countdown()
        remaining_response_time = remaining_response_time - 1

        if remaining_response_time == 0 then
            game_over_or_continue()
        end

        set_response_countdown_text()

        rive.set_state_machine_input('#rivemodel', 'countdown', (remaining_response_time / total_response_time) * 100,
            "question countdown")
    end

    function start_timer()
        if response_timer then
            timer.cancel(response_timer)
        end
        response_timer = timer.delay(1, true, function()
            countdown()
        end)
    end

    function start_fuel_timer()
        if fuel_usage_timer then
            timer.cancel(fuel_usage_timer)
        end

        fuel_usage_timer = timer.delay(1, true, function()
            decrease_fuel(1)
            set_fuel_text()
        end)
    end

    function get_question()
        return questions.questions[current_question]
    end

    function set_question_text()
        local question = get_question()
        rive.set_text_run('#rivemodel', 'question', question.question)
    end

    function set_response_countdown_text()
        rive.set_text_run('#rivemodel', 'question countdown', string.format("%d", remaining_response_time),
            'question countdown')
    end

    state.start = function()
        set_response_countdown_text()
        set_question_text()
        start_timer()
        start_fuel_timer()
        playing = true
    end

    function game_over_or_continue()
        current_question = current_question + 1

        if current_question > total_questions or current_fuel <= 0 then
            playing = false

            if response_timer then
                timer.cancel(response_timer)
            end

            if fuel_usage_timer then
                timer.cancel(fuel_usage_timer)
            end

            persist.save_answers(answers)

            msg.post("main:/main_menu", "load_game_over", { proxy_name = "#gameplayproxy" })
        else
            set_question_text()
            start_timer()
            start_fuel_timer()
        end

        remaining_response_time = total_response_time
    end

    state.answer = function(answer)
        if not playing then
            return
        end

        local question = get_question()

        if question.answer == answer then
            increase_fuel()
        else
            decrease_fuel()
        end

        set_fuel_text()

        game_over_or_continue()

        answers[current_question] = answer
    end

    function set_fuel_text()
        rive.set_text_run('#rivemodel', 'fuel level', string.format("%d", current_fuel), "fuel tank")
    end

    state.update = function(dt)
        if not playing then
            return
        end

        local character_height = vmath.lerp(1, previous_fuel, current_fuel)
        rive.set_state_machine_input('#rivemodel', 'Character Fall', character_height)
        rive.set_state_machine_input('#rivemodel', 'fuel level', character_height, "fuel tank")
    end

    return state
end

return M
