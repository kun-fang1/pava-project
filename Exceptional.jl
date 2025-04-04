struct RestartNotFoundException <: Exception end

struct EscapeException <: Exception 
    sym::Symbol
    value::Any
end

struct RestartException <: Exception 
    token::Symbol
    args::Tuple
end

# Constants
const HANDLERS_LIST = [] # FIFO: list of tuples
const RESTARTS_LIST = [] # FIFO: list of tuples

# Functions
function to_escape(func)
    sym = gensym()
    try
        func((x) -> throw(EscapeException(sym, x)))
    catch e
        if isa(e, EscapeException) && e.sym == sym
            return e.value
        end
        rethrow()
    end
end

function handling(func, handlers...)
    pushfirst!(HANDLERS_LIST, handlers)

    ret = nothing
    try
        ret = func()
    catch e
        rethrow()
    finally
        popfirst!(HANDLERS_LIST)
    end
    return ret
end

function with_restart(func, restarts...)
    args = nothing
    callback = nothing
    ret = nothing
    
    pushfirst!(RESTARTS_LIST, restarts)
    try
        ret = func()
    catch e
        if isa(e, RestartException)
            for (token, f) in restarts
                if token == e.token
                    callback = f
                    args = e.args
                    break
                end
            end
        end

        # restart token not Found || is not a RestartException
        if callback === nothing
            rethrow()
        end
    finally
        popfirst!(RESTARTS_LIST)
        if callback !== nothing
            ret = callback(args...)
        end
    end

    return ret
end

function available_restart(name)
    for restarts in RESTARTS_LIST
        for (token, _) in restarts
            if token == name
                return true
            end
        end
    end
    return false
end

function invoke_restart(name, args...)
    for restarts in RESTARTS_LIST
        for (token, _) in restarts
            if token == name
                throw(RestartException(token, args))
                break
            end
        end
    end
end

function signal(exception)
    ret = nothing
    for handlers in HANDLERS_LIST
        for (e_type, func) in handlers
            if isa(exception, e_type)
                ret = func(exception)
                if ret !== nothing
                    return ret
                end
            end
        end
    end
end

function error(exception)
    ret = signal(exception)
    if ret !== nothing
        return ret
    end
    throw(exception)
end