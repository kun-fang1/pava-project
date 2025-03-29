include("Exceptional.jl")

macro handler_case(body, handlers...)
    return esc(quote
        handling(() -> $body, $(handlers...))
    end)
end

macro restart_case(body, restarts...)
    return esc(quote
        with_restart(() -> $body, $(restarts...))
    end)
end