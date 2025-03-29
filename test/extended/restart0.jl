include("../../ExceptionalExtended.jl")

mystery(n) = if n % 2 == 0
                invoke_restart(:return_value, n)
            else
                invoke_restart(:skip)
                + 1
            end
    
veryMystery(n) = @restart_case(
                    mystery(n),
                    :return_zero => () -> 0,
                    :return_value => identity,
                    :skip => () -> nothing)

@assert veryMystery(2) == 2
@assert veryMystery(4) == 4

@assert veryMystery(1) == 1
@assert veryMystery(3) == 1

#=
output:
=#