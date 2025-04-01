include("../../../Exceptional.jl")

struct LineEndLimit <: Exception end
struct EndText <: Exception end

print_line(str, line_end=20) =
    let col = 0
    for c in str
        print(c)
        col += 1
        if col == line_end
            error(LineEndLimit())
            col = 0
        end
    end
    error(EndText())
end

try
    handling(LineEndLimit => (c) -> println(),
                EndText => (c) -> println("END!")) do
        print_line("Hi, everybody! How are you feeling today?\n")
    end
catch e
    if !isa(e, LineEndLimit)
        rethrow(e)
    end
end

try
    to_escape() do exit
        handling(LineEndLimit => (c) -> exit(1),
                    EndText => (c) -> println("END!")) do
            print_line("Hi, everybody! How are you feeling today?\n")
        end
    end
catch e
    if !isa(e, LineEndLimit)
        rethrow(e)
    end
end

#=
output:
Hi, everybody! How a
Hi, everybody! How a=#