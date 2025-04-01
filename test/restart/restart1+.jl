include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

reciprocal(value) =
    with_restart(:return_zero => () -> 0,
                    :return_value => identity,
                    :retry_using => reciprocal) do
        value == 0 ? error(DivisionByZero()) : 1/value
    end

a1 = to_escape() do leave
    handling(DivisionByZero => (c) -> invoke_restart(:return_value, 9)) do
        with_restart(:leave => leave) do
            reciprocal(0) + reciprocal(10)
        end
    end
end
@assert a1 == 9.1

a2 = to_escape() do leave
        handling(DivisionByZero => (c) -> invoke_restart(:leave, 9)) do
            with_restart(:leave => leave) do
                reciprocal(0) + reciprocal(10)
            end
        end
    end
@assert a2 == 9