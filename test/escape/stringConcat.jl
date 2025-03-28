include("../../Exceptional.jl")

hi(n) =
    "Hello" *
    to_escape() do inner
        (to_escape() do outer
            "foo" *
            to_escape() do inner
                (if "0" == n
                    inner("!")
                elseif n == "1"
                    outer("?")
                else
                    " foo "
                end) *
                " bar "
            end
        end) *
        "bar"
    end

@assert hi("0") == "Hellofoo!bar"
@assert hi("1") == "Hello?bar"
@assert hi("2") == "Hellofoo foo  bar bar"


#=
output:
=#