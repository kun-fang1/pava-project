include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

reciprocal(value) =
    with_restart(:return_zero => () -> 0,
                    :return_value => identity,
                    :retry_using => reciprocal,
                    :leave => leave) do
        value == 0 ? error(DivisionByZero()) : 1/value
    end

a2 = to_escape() do leave
        handling(DivisionByZero => (c) -> invoke_restart(:leave, 9)) do
            reciprocal(0)
        end
    end

@assert a2 == 9