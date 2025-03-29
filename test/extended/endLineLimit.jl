include("../../ExceptionalExtended.jl")

struct LineEndLimit <: Exception end
struct EndText <: Exception end

print_line(str, line_end=20) =
    let col = 0
    for c in str
        print(c)
        col += 1
        if col == line_end
            signal(LineEndLimit())
            col = 0
        end
    end
    signal(EndText())
end

@handler_case(print_line("Hi, everybody! How are you feeling today?\n"),
                LineEndLimit => (c) -> println(),
                EndText => (c) -> println("END!"))
    
to_escape() do exit
    @handler_case(print_line("Hi, everybody! How are you feeling today?\n"),
                    LineEndLimit => (c) -> exit(),
                    EndText => (c) -> println("END!"))
end

#=
output:
Hi, everybody! How a
re you feeling today
?
Hi, everybody! How a=#