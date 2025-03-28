include("../../Exceptional.jl")

mystery(n) =
    1 +
    to_escape() do outer 
        2 *
        to_escape() do middle
            1 /
            to_escape() do inner
                1 -
                if n == 0
                    inner(1)
                elseif n == 1
                    middle(2)
                elseif n == 2
                    outer(1)
                else
                    3
                end
            end
        end
    end

@assert mystery(0) == 3
@assert mystery(1) == 5
@assert mystery(2) == 2
@assert mystery(3) == 0

#=
output:
=#