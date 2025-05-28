function create(code, mode=nothing)
    output = nothing
    t = translate(code)
    output = mode == "t" ? deepcopy(t) : output
    w = wrap(t)
    output = mode == "w" ? deepcopy(w) : output
    save(w)
    return output
end

function translate(code)
    asm = []
    for line in code
        asmline = ""
        output = ""
        condition = ""
        action = ""
        
        if typeof(line.operation) == String
            output = line.outputs == nothing ? "" : "R" * string(line.outputs[1]) * " = "
            condition = line.condition == nothing ? "" : " if R" * string(line.conditionals[1]) * " " * line.condition * " 0"
            if line.inputs != nothing
                inputs = [typeof(var) == Const ? string(var.value) : "R" * string(var) for var in line.inputs]
                if length(line.inputs) == 1
                    action = (line.operation == "" ? "" : line.operation * " ") * inputs[1]
                elseif length(line.inputs) == 2
                    action = inputs[1] * " " * line.operation * " " * inputs[2]
                end
            end
        elseif line.operation == 2
            asmline = line.condition
        elseif line.operation == 3
            condition = line.condition == nothing ? "" : "if R" * string(line.conditionals[1]) * " " * line.condition * " 0"
        elseif line.operation == 4
            condition = line.condition == nothing ? "repeat" : "repeat if R" * string(line.conditionals[1]) * " " * line.condition * " 0"
        end
        
        asmline = asmline * output * action * condition
        push!(asm, asmline)
    end
    return asm
end

function wrap(asm)
    pushfirst!(asm, "@global:start {")
    push!(asm, "repeat")
    push!(asm, "}")
    return asm
end

function save(program)
    file = open("program.mcasm", "w")
    for asmline in program
        println(file, asmline)
    end
    close(file)
    print("saved \"program.mcasm\"")
end