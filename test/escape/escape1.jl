include("../../Exceptional.jl")

mystery(n) =
    1 +
    to_escape() do outer
        1 +
        to_escape() do inner
            1 +
            to_escape() do inner
                1 +
                if n == 0
                    inner(1)
                elseif n == 1
                    outer(1)
                else
                    1
                end
            end
        end
    end

@assert mystery(0) == 4
@assert mystery(1) == 2
@assert mystery(2) == 5

#=
output:
=#