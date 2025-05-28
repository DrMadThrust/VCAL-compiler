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
