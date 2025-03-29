# Constants
const HANDLERS_LIST = [] # FIFO: list of lists
const RESTARTS_LIST = [] # FIFO: list of lists

# Functions
function to_escape(func)
    escaped_value = nothing
    try
        func((x) -> (escaped_value = x; throw(:escaped)))
    catch
        escaped_value
    end
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

function with_restart(func, restarts...)
    pushfirst!(RESTARTS_LIST, restarts)
    ret = func()
    popfirst!(RESTARTS_LIST)
    return ret
end

function available_restart(name)
    for restarts in RESTARTS_LIST
        for (token, func) in restarts
            if token == name
                return true
            end
        end
    end
    return false
end

function invoke_restart(name, args...)
    for restarts in RESTARTS_LIST
        for (token, func) in restarts
            if token == name
                return func(args...)
            end
        end
    end
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