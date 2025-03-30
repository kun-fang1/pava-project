struct RestartNotFoundException <: Exception end

# Constants
const HANDLERS_LIST = [] # FIFO: list of lists
const RESTARTS_LIST = [] # FIFO: list of restarts

# Functions
function to_escape(func)
    escaped_value = nothing
    try
        func((x) -> (escaped_value = x; throw(:escaped)))
    catch
        escaped_value
    end
end

macro handler_case(body, handlers...)
    return esc(quote
        handling(() -> $body, $(handlers...))
    end)
end

function handling(func, handlers...)
    pushfirst!(HANDLERS_LIST, handlers)
    try
        return func()
    catch e
        for (e_type, handler) in handlers
            if isa(e, e_type)
                result = handler(e)
                if result !== nothing
                    return result
                end
                break
            end
        end
        rethrow()
    finally
        popfirst!(HANDLERS_LIST)
    end
end

macro restart_case(body, restarts...)
    return esc(quote
        with_restart(() -> $body, $(restarts...))
    end)
end

function with_restart(func, restarts...)
    pushfirst!(RESTARTS_LIST, restarts...)
    ret = func()

    for _ in 1:length(restarts)
        popfirst!(RESTARTS_LIST)
    end
    return ret
end

function available_restart(name)
    for (token, func) in RESTARTS_LIST
        if token == name
            return true
        end
    end
    return false
end

function invoke_restart(name, args...)
    if (length(RESTARTS_LIST) == 0)
        throw(RestartNotFoundException())
    end

    println(stderr, "\nRESTARTS:")
    i = 1
    for (token, func) in RESTARTS_LIST
        println(stderr, "   $i: [$token]")
        i += 1
    end

    print(stderr, "options [1-$(length(RESTARTS_LIST))]: ")
    i = parse(Int, readline())

    while (i <= 0 || i > length(RESTARTS_LIST))
        println(stderr, "That option doesn't exists, try again!")
        print(stderr, "Options [1-$(length(RESTARTS_LIST))]: ")
        i = parse(Int, readline())
    end

    (token, func) = RESTARTS_LIST[i]
    func(args...)
end

function signal(exception)
    for handlers in HANDLERS_LIST
        for (e_type, func) in handlers
            if isa(exception, e_type)
                func(exception)
            end
        end
    end
end

function error(exception)
    throw(exception)
end