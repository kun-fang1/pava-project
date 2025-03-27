# Constants
const HANDLERS = []

# Macros
macro to_escape_impl(func)
    esc_name = gensym(:esc)

    quote
        escaped = false
        escaped_value = nothing

        $esc_name = x -> begin
            escaped = true
            escaped_value = x
        end

        try
            result = $(esc(func))($esc_name)
            return escaped ? escaped_value : result
        catch
            return escaped_value
        end
    end
end

# Functions
# to_escape function
function to_escape(func)
    @to_escape_impl func
end

# handling function
function handling(func, handlers...)
    append!(HANDLERS, handlers)

    try
        func()
    catch e
        for (exception_type, handler) in handlers
            if isa(e, exception_type)
                handler(e)
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

# with_restart function
function with_restart(func, restarts...)
    try
        func()
    catch e
        for (restart_name, restart_func) in restarts
            if available_restart(restart_name)
                return restart_func()
            end
        end
        rethrow()
    end
end

# available_restart function
function available_restart(name)
    # Here you can implement specific logic as needed
    true
end

# invoke_restart function
function invoke_restart(name, args...)
    # Here you can implement specific logic as needed
    println("Invoking restart: ", name)
end

# signal function
function signal(exception)
    for (exception_type, handler) in HANDLERS
        if isa(exception, exception_type)
            handler(exception)
            break
        end
    end
end

# error function
function error(exception)
    throw(exception)
end