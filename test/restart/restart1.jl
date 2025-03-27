include("../../Exceptional.jl")

struct DivisionByZero <: Exception end

reciprocal(value) =
    with_restart(:return_zero => () -> 0,
                    :return_value => identity,
                    :retry_using => reciprocal) do
        value == 0 ? error(DivisionByZero()) : 1/value
    end
    
a1 = handling(DivisionByZero => (c) -> (invoke_restart(:return_zero))) do
        reciprocal(0)
    end
@assert a1 == 0

a2 = handling(DivisionByZero => (c)->invoke_restart(:return_value, 123)) do
        reciprocal(0)
    end
@assert a2 == 123


a3 = handling(DivisionByZero => (c)->invoke_restart(:retry_using, 10)) do
        reciprocal(0)
    end
@assert a3 == 0.1

a4 = handling(DivisionByZero => (c) -> 
            for restart in (:return_one, :return_zero, :die_horribly)
                if available_restart(restart)  
                    invoke_restart(restart) 
                end
            end) do
        reciprocal(0)
    end
@assert a4 == 0

#=
output:
=#