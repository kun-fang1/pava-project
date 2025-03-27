include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

reciprocal(x) = (x == 0) ? error(DivisionByZero()) : 1/x

msg = to_escape() do exit1
        to_escape() do exit2
            handling(DivisionByZero => (c) -> (exit2("escape with exit2"); println("DONT"))) do
                handling(DivisionByZero => (c) -> println("I saw a DivisionByZero")) do
                    reciprocal(0)
                end
            end
        end
    end

@assert msg == "escape with exit2"

#=
output:

I saw a DivisionByZero
=#