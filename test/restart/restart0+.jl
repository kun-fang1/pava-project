include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

mystery(n) = if n % 2 == 0
                invoke_restart(:return_value, n)
            else
                invoke_restart(:skip)
                + 1
            end
    
veryMystery(n) = with_restart(:return_zero => () -> 0,
            :return_value => identity,
            :skip => () -> nothing) do
        mystery(n)
    end

@assert veryMystery(2) == 2
@assert veryMystery(4) == 4

@assert veryMystery(1) == 0
@assert veryMystery(3) == 0

#=
output:
=#