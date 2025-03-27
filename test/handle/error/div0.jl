include("../../../Exceptional.jl")

struct DivisionByZero <: Exception end

# DivisionByZero test with error. It must stop when Exception ocurrs
function divZero_error(x)
    if x == 0 
        error(DivisionByZero())
        println("divZero_error >> I saw an error")
    else
        println(1/x)
    end
end

handling(DivisionByZero => (c)->println("I saw it too")) do
    handling(DivisionByZero => (c)->println("I saw a division by zero")) do
        divZero_error(0)
        divZero_error(1)
    end
end

#=
output:
I saw a division by zero
I saw it too
=#