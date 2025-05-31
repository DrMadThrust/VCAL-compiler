struct Function
    name
    outputs
    inputs
    lines
end

struct Line
    operation
    condition
    outputs
    inputs
    conditionals
end

struct Var
    id
    lifetime
    scope
end

struct Const
    value
end

struct Flabel
    id
end

struct Memargs
    memzero
    regzero
    ramzero
    regsize
end

function getMemArgs(memargs)
    return [memargs.memzero, memargs.regzero, memargs.ramzero, memargs.regsize]
end
