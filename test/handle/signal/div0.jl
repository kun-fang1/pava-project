include("../../../Exceptional.jl")

struct DivisionByZero <: Exception end

# DivisionByZero test with signal. It doesn't stop when Exception ocurrs
function divZero_signal(x)
    if x == 0 
        signal(DivisionByZero())
        println("divZero_signal >> I saw a signal")
    else
        println(1/x)
    end
end

handling(DivisionByZero => (c)->println("I saw it too")) do
    handling(DivisionByZero => (c)->println("I saw a division by zero")) do
        divZero_signal(0)
        divZero_signal(1)
    end
end

#=
output:
I saw a division by zero
I saw it too
divZero_signal >> I saw a signal
1.0
=#