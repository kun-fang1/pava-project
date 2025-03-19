struct DivisionByZero <: Exception end
struct LineEndLimit <: Exception end

# to_escape function
function to_escape(func)
    try
        func()
    catch e
        println("Escaped with exception: ", e)
    end
end

# handling function
function handling(func, handlers...)
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
    println("Signaling exception: ", exception)
end

# error function
function error(exception)
    throw(exception)
end



