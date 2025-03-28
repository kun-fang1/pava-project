include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

reciprocal(value) = value == 0 ? error(DivisionByZero()) : 1/value

restartJump(s, value) = to_escape() do outer 
        with_restart(:return_zero => (c) -> 404,
                        :return_plus1 => (c) -> c+1,
                        :jump_inner => (c) -> 404,
                        :jump_outer => (c) -> outer(c)) do
            1 +
            to_escape() do inner
                with_restart(:return_zero => (c) -> 0,
                        :jump_inner => (c) -> inner(c),
                        :jump_outer => (c) -> outer(c)) do
                    (handling(DivisionByZero => (c) -> (invoke_restart(s, value))) do
                        reciprocal(value)
                    end) +
                    5
                end
            end
        end
    end

@assert restartJump(:jump_inner, 0) == 1
@assert restartJump(:jump_outer, 0) == 0
@assert restartJump(:return_plus1, 0) == 7
@assert restartJump(:return_zero, 0) == 6

#=
output:
=#

