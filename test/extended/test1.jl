include("../../ExceptionalExtended.jl")

get_user_input = (n) -> begin
    ret = []
    println(stderr, "> User input < ")

    for _ in 1:n
        print(stderr, "Enter a value: ")
        push!(ret, parse(Int, readline()))
    end

    ret
end

mystery(n) = (n % 2 == 0) ? invoke_restart() : n
    
veryMystery(n) = @restart_case(
                    mystery(n),
                    Restart(:return_zero, () -> 0, report = "Return zero"),
                    Restart(:skip, () -> nothing, report = "SKIP", test = () -> false),
                    Restart(:retry_with_new_value, veryMystery, report = "RETRY", interactive = () -> get_user_input(1)),
                    Restart(:sum, (x, y) -> x+y, report = "Sum", interactive = () -> get_user_input(2)))
                    
println("Result: ", veryMystery(0))
println("Result: ", veryMystery(0))
println("Result: ", veryMystery(0))
#=
output:
=#