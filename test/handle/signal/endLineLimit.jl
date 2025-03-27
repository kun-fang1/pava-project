include("../../../Exceptional.jl")

struct LineEndLimit <: Exception end

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
end

handling(LineEndLimit => (c) -> println()) do
    print_line("Hi, everybody! How are you feeling today?\n")
end

to_escape() do exit
    handling(LineEndLimit => (c) -> exit()) do
        print_line("Hi, everybody! How are you feeling today?\n")
    end
end

#=
output:
Hi, everybody! How a
re you feeling today
?
Hi, everybody! How a=#