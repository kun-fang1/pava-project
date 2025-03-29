include("../../ExceptionalExtended.jl")

struct DivisionByZero <: Exception end

reciprocal(value) = value == 0 ? error(DivisionByZero()) : 1/value

restartJump(s, value) = 
        to_escape() do outer
            @restart_case(1 +
                to_escape() do inner
                    @restart_case(
                        @handler_case(
                            reciprocal(value), 
                            DivisionByZero => (c) -> invoke_restart(s, value)
                        ) + 5,
                        :return_zero => (c) -> 0,
                        :jump_inner => (c) -> inner(c),
                        :jump_outer => (c) -> outer(c)
                    )
                end,
                :return_zero => (c) -> 404,
                :return_plus1 => (c) -> c+1,
                :jump_inner => (c) -> 404,
                :jump_outer => (c) -> outer(c)
            )
        end
        
@assert restartJump(:jump_inner, 0) == 1
@assert restartJump(:jump_outer, 0) == 0
@assert restartJump(:return_plus1, 0) == 7
@assert restartJump(:return_zero, 0) == 6

#=
output:
=#

