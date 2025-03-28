# Constants
const HANDLERS = []
const RESTARTS = []

# Functions
function to_escape(func)
    escaped_value = nothing
    try
        func(x -> begin
            escaped_value = x
            throw(:escaped)
        end)
    catch
        escaped_value
    end
end

function handling(func, handlers...)
    append!(HANDLERS, handlers)
    try
        return func()
    catch e
        for (exception_type, handler) in handlers
            if isa(e, exception_type)
                result = handler(e)
                if result !== nothing
                    return result
                end
                break
            end
        end
        rethrow()
    finally
        for _ in 1:length(handlers)
            pop!(HANDLERS)
        end
    end
end

function with_restart(func, restarts...)
    push!(RESTARTS, Dict{Symbol,Function}(restarts...))
    return func()
end

function available_restart(name)
    for restart in RESTARTS
        if haskey(restart, name)
            return true
        end
    end
    return false
end

function invoke_restart(name, args...)
    for restart in RESTARTS
        if haskey(restart, name)
            return restart[name](args...)
        end
    end
end

function signal(exception)
    for (exception_type, handler) in reverse(HANDLERS)
        if isa(exception, exception_type)
            handler(exception)
        end
    end
end

function error(exception)
    throw(exception)
end