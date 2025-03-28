include("../../Exceptional.jl")

hi(n) =
    "Hello" *
    to_escape() do inner
        "bar" *
        to_escape() do outer
            "foo" *
            to_escape() do inner
                " bar " *
                if "0" == n
                    inner("!")
                elseif n == "1"
                    outer("?")
                else
                    " foo "
                end
            end
        end
    end

@assert hi("0") == "Hellobarfoo!"
@assert hi("1") == "Hellobar?"
@assert hi("2") == "Hellobarfoo bar  foo "


#=
output:
=#