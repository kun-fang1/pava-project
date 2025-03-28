include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

reciprocal(value) =
    with_restart(:return_zero => () -> 0,
                    :return_value => identity,
                    :retry_using => reciprocal) do
        value == 0 ? error(DivisionByZero()) : 1/value
    end

a1 = handling(DivisionByZero => (c) -> (println("I saw it too"))) do 
        handling(DivisionByZero => (c) -> (invoke_restart(:return_zero))) do
            handling(DivisionByZero => (c) -> (println("I saw a DivisionByZero"))) do
                reciprocal(0)
            end
        end
    end
@assert a1 == 0

#=
output:
I saw a DivisionByZero
=#

