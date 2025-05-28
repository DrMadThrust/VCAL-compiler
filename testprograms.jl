mempos = Dict()

lh = [
    Line(0, nothing, [1, 2, 3], nothing, nothing),
    Line("", "=", [4], [1], [3]),
    Line("dec", nothing, [3], [3], nothing),
    Line("", "=", [4], [2], [3]),
    Line(1, nothing, nothing, [1, 2, 3, 4], nothing)
]
h = Function("h", nothing, nothing, lh)
display(h.lines)

lg = [
    Line(0, nothing, [1, 2, 3], nothing, nothing),
    Line("+", nothing, [1], [1, 2], nothing),
    Line("", nothing, [4], [2], nothing),
    Line("", nothing, [2], [1], nothing),
    Line("", nothing, [1], [4], nothing),
    Line("dec", nothing, [3], [3], nothing),
    Line(Flabel("g"), ">=", nothing, [1, 2, 3], [3]),
    Line(1, nothing, nothing, [1], nothing)
]
g = Function("g", nothing, nothing, lg)
display(g.lines)

lmain = [
    Line(0, nothing, [], nothing, nothing),
    Line("", nothing, [1], [Const("read")], nothing),
    Line("", nothing, [2], [Const("read")], nothing),
    Line("", nothing, [3], [Const("read")], nothing),
    Line(Flabel("h"), nothing, [4, 5, 6, 7], [1, 2, 3], nothing),
    Line("", nothing, ["tempval"], [7], nothing),
    Line("", nothing, ["temp"], [6], nothing),
    Line(Flabel("g"), ">", [8], [4, 5, 6], [6]),
    Line("", "<=", [8], ["tempval"], ["temp"]),
    Line("write", nothing, nothing, [8], nothing),
    Line(1, nothing, nothing, [], nothing)
]
main = Function("main", [], [], lmain)
display(main.lines)

functions = Dict()
push!(functions, "g" => g)
push!(functions, "h" => h)



mempos = Dict()

lh = [
    Line(0, nothing, [1, 2, 3], nothing, nothing),
    Line("", "=", [1], [1], [3]),
    Line("dec", nothing, [3], [3], nothing),
    Line("", "=", [1], [2], [3]),
    Line(1, nothing, nothing, [1, 2, 3], nothing)
]
h = Function("h", nothing, nothing, lh)
display(h.lines)

lg = [
    Line(0, nothing, [1, 2, 3], nothing, nothing),
    Line("+", nothing, [1], [1, 2], nothing),
    Line("", nothing, [4], [2], nothing),
    Line("", nothing, [2], [1], nothing),
    Line("", nothing, [1], [4], nothing),
    Line("dec", nothing, [3], [3], nothing),
    Line(Flabel("g"), ">=", nothing, [1, 2, 3], [3]),
    Line(1, nothing, nothing, [1, 2, 3], nothing)
]
g = Function("g", nothing, nothing, lg)
display(g.lines)

lmain = [
    Line(0, nothing, [], nothing, nothing),
    Line("", nothing, [1], [Const("read")], nothing),
    Line("", nothing, [2], [Const("read")], nothing),
    Line("", nothing, [3], [Const("read")], nothing),
    Line(Flabel("h"), nothing, [1, 2, 3], [1, 2, 3], nothing),
    Line(Flabel("g"), ">", [1, 2, 3], [1, 2, 3], [3]),
    Line("write", nothing, nothing, [1], nothing),
    Line("write", nothing, nothing, [2], nothing),
    Line("write", nothing, nothing, [3], nothing),
    Line(1, nothing, nothing, [], nothing)
]
main = Function("main", [], [], lmain)
display(main.lines)

functions = Dict()
push!(functions, "g" => g)
push!(functions, "h" => h)



mempos = Dict()

lh = [
    Line(0, nothing, [1, 2], nothing, nothing),
    Line("inc", nothing, [1], [1], nothing),
    Line("dec", nothing, [2], [2], nothing),
    Line(1, nothing, nothing, [1, 2], nothing)
]
h = Function("h", nothing, nothing, lh)
display(h.lines)

lg = [
    Line(0, nothing, [1, 2, 3], nothing, nothing),
    Line(Flabel("h"), nothing, [1, 2], [1, 2], nothing),
    Line("dec", nothing, [3], [3], nothing),
    Line(Flabel("g"), ">", nothing, [1, 2, 3], [3]),
    Line(1, nothing, nothing, [1, 2, 3], nothing)
]
g = Function("g", nothing, nothing, lg)
display(g.lines)

lmain = [
    Line(0, nothing, [], nothing, nothing),
    Line("", nothing, [1], [Const("read")], nothing),
    Line("", nothing, [2], [Const("read")], nothing),
    Line("", nothing, [3], [Const("read")], nothing),
    Line(Flabel("g"), ">", [1, 2], [1, 2, 3], [3]),
    Line("write", nothing, nothing, [1], nothing),
    Line("write", nothing, nothing, [2], nothing),
    Line(1, nothing, nothing, [], nothing)
]
main = Function("main", [], [], lmain)
display(main.lines)

functions = Dict()
push!(functions, "g" => g)
push!(functions, "h" => h)



mempos = Dict()

lf = [
    Line(0, nothing, [1, 2], nothing, nothing),
    Line("+", nothing, [1], [1, Const(2)], nothing),
    Line("write", nothing, nothing, [1], nothing),
    Line("write", nothing, nothing, [2], nothing),
    Line("", nothing, [3], [Const(0)], nothing),
    Line(Flabel("f"), "=", nothing, [1, 2], [3]),
    Line(1, nothing, nothing, [], nothing)
]
f = Function("f", nothing, nothing, lf)
display(f.lines)

lmain = [
    Line(0, nothing, [], nothing, nothing),
    Line("", nothing, [1], [Const("read")], nothing),
    Line("", nothing, [2], [Const("read")], nothing),
    Line(Flabel("f"), nothing, nothing, [1, 2], nothing),
    Line(1, nothing, nothing, [], nothing)
]
main = Function("main", [], [], lmain)
display(main.lines)

functions = Dict()
push!(functions, "f" => f)
