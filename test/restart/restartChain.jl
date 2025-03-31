include("../../Exceptional.jl")

struct ExcZero <: Exception end
struct ExcOne <: Exception end
struct ExcTwo <: Exception end

chain(n) = 1 +
        if n == 0
            error(ExcZero())
        elseif n == 1
            error(ExcOne())
        elseif n == 2
            error(ExcTwo())
        else
            1
        end
    
foo(n) = handling(ExcTwo => (c) -> invoke_restart(:try_again, 3)) do
            handling(ExcOne => (c) -> invoke_restart(:try_again, 2)) do
                handling(ExcZero => (c) -> invoke_restart(:try_again, 1)) do
                        with_restart(:return_zero => () -> 0,
                            :return_value => identity,
                            :try_again => chain,
                            :retry_plusOne => (x) -> x+1) do
                            chain(n)
                    end
                end
            end
        end

@assert foo(0) == 2

#=
output:
=#