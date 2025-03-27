include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

reciprocal(value) =
    with_restart(:return_zero => () -> 0,
                    :return_value => identity,
                    :retry_using => reciprocal) do
        value == 0 ? error(DivisionByZero()) : 1/value
    end

infinity() =
    with_restart(:just_do_it => () -> 1/0) do
        reciprocal(0)
    end

a1 = handling(DivisionByZero => (c)->invoke_restart(:return_zero)) do
    infinity()
end
@assert a1 == 0

a2 = handling(DivisionByZero => (c)->invoke_restart(:return_value, 1)) do
    infinity()
end
@assert a2 == 1

a3 = handling(DivisionByZero => (c)->invoke_restart(:retry_using, 10)) do
    infinity()
end
@assert a3 == 0.1

a4 = handling(DivisionByZero => (c)->invoke_restart(:just_do_it)) do
    infinity()
end
@assert a4 == Inf

#=
output:
=#