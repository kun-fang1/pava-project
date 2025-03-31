include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

mystery(n) = if n % 3 == 0
                9 + invoke_restart(:return_zero)
            elseif n % 3 == 1
                invoke_restart(:return_value, 9+n)
            else
                invoke_restart(:skip)
                + 1
            end
    
veryMystery(n) = with_restart(:return_zero => () -> 0,
            :return_value => identity,
            :skip => () -> nothing) do
        mystery(n)
    end

@assert veryMystery(0) == 0
@assert veryMystery(1) == 10
@assert veryMystery(2) === nothing
@assert veryMystery(3) == 0
@assert veryMystery(4) == 13
@assert veryMystery(5) === nothing

#=
output:
=#