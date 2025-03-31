include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

mystery(n) =
    1 +
    to_escape() do outer
        1 +
        to_escape() do inner
            1 +
            if n == 0
                invoke_restart(:return_zero)
            elseif n == 1
                invoke_restart(:return_value, n)
            elseif n == 2
                invoke_restart(:retry_plusOne, n)
            else
                7
            end
        end
    end
    
veryMystery(n) = with_restart(:return_zero => () -> 0,
            :return_value => identity,
            :retry_plusOne => (x) -> x+1) do
        mystery(n)
    end

@assert veryMystery(0) == 0
@assert veryMystery(1) == 1
@assert veryMystery(2) == 3
@assert veryMystery(4) == 10

#=
output:
=#