# Constants
const HANDLERS = []
const RESTARTS = []

# Exceptions
struct RestartException <: Exception
    name::Symbol
    args::Tuple
    value
end

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
        func()
    catch e
        for (exception_type, handler) in handlers
            if isa(e, exception_type)
                try
                    handler(e)
                catch e
                    if isa(e, RestartException)
                        return e.value
                    else
                        rethrow()
                    end
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
    func()
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
    println("invoke_restart $name $args")
    for restart in RESTARTS
        if haskey(restart, name)
            throw(RestartException(name, args, restart[name](args...)))
        end
    end
end

function signal(exception)
    for (exception_type, handler) in HANDLERS
        if isa(exception, exception_type)
            handler(exception)
        end
    end
end

function error(exception)
    throw(exception)
end