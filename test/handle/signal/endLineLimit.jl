include("../../../Exceptional.jl")

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

handling(LineEndLimit => (c) -> println(),
            EndText => (c) -> println("END!")) do
    print_line("Hi, everybody! How are you feeling today?\n")
end

to_escape() do exit
    handling(LineEndLimit => (c) -> exit(1),
                EndText => (c) -> println("END!")) do
        print_line("Hi, everybody! How are you feeling today?\n")
    end
end

#=
output:
Hi, everybody! How a
re you feeling today
?
END!
Hi, everybody! How a=#