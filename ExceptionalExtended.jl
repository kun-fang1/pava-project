struct RestartNotFoundException <: Exception end

struct EscapeException <: Exception 
    sym::Symbol
    value::Any
end

struct RestartException <: Exception 
    token::Symbol
end

struct RestartStruct
    token::Symbol
    callback::Function

    test::Function
    interactive::Function
    report::Any
end

function Restart(
    token::Symbol, callback::Function;
    test::Function = () -> true, interactive::Function = () -> [], 
    report::Any = "No report available")
    RestartStruct(token, callback, test, interactive, report)
end

# Constants
const HANDLERS_LIST = [] # FIFO: list of lists
const RESTARTS_LIST = [] # FIFO: list of restarts

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

macro handler_case(body, handlers...)
    return esc(quote handling(() -> $body, $(handlers...)) end)
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

macro restart_case(body, restarts...)
    return esc(quote with_restart(() -> $body, $(restarts...)) end)
end

function with_restart(func, restarts...)
    restart_chosen = nothing
    ret = nothing
    
    pushfirst!(RESTARTS_LIST, restarts...)
    try
        ret = func()
    catch e
        if isa(e, RestartException)
            for restart in restarts
                if restart.token == e.token
                    restart_chosen = restart
                    break
                end
            end
        else
            rethrow()
        end
    finally
        for _ in 1:length(restarts)
            popfirst!(RESTARTS_LIST)
        end

        if restart_chosen !== nothing
            args = restart_chosen.interactive()
            ret = restart_chosen.callback(args...)
        end
    end

    return ret
end

function available_restart(name)
    for restart in RESTARTS_LIST
        if token == restart.token
            return true
        end
    end
    return false
end

function invoke_restart()
    valide_restarts = filter(restart -> restart.test(), RESTARTS_LIST)

    if (length(valide_restarts) == 0)
        throw(RestartNotFoundException())
    end

    println(stderr, ">> RESTARTS <<")
    i = 1
    for restart in valide_restarts
        if !restart.test()
            continue
        end
        
        if restart.report isa Function
            report = restart.report()
        else
            report = eval(restart.report)
        end
        println(stderr, "   $i: [$(restart.token)] $(report)")
        i += 1
    end

    print(stderr, "options [1-$(length(valide_restarts))]: ")
    i = parse(Int, readline())

    while (i <= 0 || i > length(valide_restarts))
        println(stderr, "That option doesn't exists, try again!")
        print(stderr, "Options [1-$(length(valide_restarts))]: ")
        i = parse(Int, readline())
    end

    throw(RestartException(valide_restarts[i].token))
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