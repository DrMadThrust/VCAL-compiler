function load(filename, clean="y")
    file = open(filename, "r")
    vcal = readlines(file)
    close(file)
    if clean == "y"
        processed = []
        for line in vcal
            push!(processed, replace(line, r"\t" => ""))
        end
        return processed
    end
    return vcal
end

function separate(vcal)
    blocks = []
    block = []
    for line in vcal
        if line == ""
            push!(blocks, block)
            block = []
            continue
        end
        push!(block, line)
    end
    push!(blocks, block)
    return blocks
end

function getMetadata(block)
    memargs = (Int)[]
    keywords = (String)[]
    for line in block
        if occursin("Const", line)
            push!(keywords, replace(line, "Const " => ""))
        else
            line = replace(line, r"\s+" => "")
            for part in split(line, ",")
                push!(memargs, parse(Int, part))
            end
        end
    end
    return memargs, keywords
end

function getFunctionKeys(blocks)
    fkeywords = (String)[]
    for block in blocks
        push!(fkeywords, block[1][1:findfirst(" ", block[1])[1]-1])
    end
    return fkeywords
end

function parseLine(line, keywords=[], fkeywords=[], scope=nothing)
    line = replace(line, r"\s+" => " ")
    outputs = nothing
    inputs = nothing
    conditionals = nothing
    operation = nothing
    condition = nothing
    if occursin(" = ", line)
        s1, s2 = split(line, " = ")
        s1 = replace(s1, r"\s+" => "")
        s1 = replace(s1, "(" => "")
        s1 = replace(s1, ")" => "")
        outputs = [String(var) for var in split(s1, ",")]
        if occursin(" if ", s2)
            s2, s1 = split(s2, " if ")
            s = split(s1, " ")
            conditionals = [String(s[1])]
            condition = s[2]
        end
        if occursin("(", s2)
            s1, s2 = split(s2, "(")
            operation = String(s1) in fkeywords ? Flabel(String(s1)) : String(s1)
            s2 = replace(s2, r"\s+" => "")
            s2 = replace(s2, ")" => "")
            inputs = [String(var) for var in split(s2, ",")]
        else
            inputs = [String(replace(s2, r"\s+" => ""))]
            operation = ""
        end
    elseif replace(line, r"\s+" => "") == "break"
        return Line(9, nothing, nothing, nothing, nothing)
    elseif occursin("repeat ", line)
        s2 = line
        if occursin(" if ", line)
            s2, s1 = split(line, " if ")
            s = split(s1, " ")
            conditionals = [String(s[1])]
            condition = s[2]
        end
        operation = Flabel(scope)
        s2 = replace(s2, "repeat" => "")
        if occursin("(", s2)
            s1, s2 = split(s2, "(")
            s2 = replace(s2, r"\s+" => "")
            s2 = replace(s2, ")" => "")
            inputs = [String(var) for var in split(s2, ",")]
        else
            inputs = [String(replace(s2, r"\s+" => ""))]
        end
    else
        s2 = line
        if occursin(" if ", line)
            s2, s1 = split(line, " if ")
            s = split(s1, " ")
            conditionals = [String(s[1])]
            condition = s[2]
        end
        if occursin("(", s2)
            s1, s2 = split(s2, "(")
            operation = String(s1) in fkeywords ? Flabel(String(s1)) : String(s1)
            s2 = replace(s2, r"\s+" => "")
            s2 = replace(s2, ")" => "")
            inputs = [String(var) for var in split(s2, ",")]
        else
            inputs = [String(replace(s2, r"\s+" => ""))]
            operation = ""
        end
    end
    inputs = inputs == nothing ? nothing : [(var in keywords || var[1] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) ? Const(var) : var for var in inputs]
    inputs = inputs == [""] ? nothing : inputs
    outputs = typeof(operation) == Flabel && operation.id != scope && outputs == nothing ? outputs = [] : outputs
    
    #condition = condition == "==" ? "=" : condition # xdd
    
    return Line(operation, condition, outputs, inputs, conditionals)
end

function parseFunction(block, keywords=[], fkeywords=[])
    flines = (Line)[]
    
    line0 = replace(block[1], r"\s+" => "")
    scope, s2 = String.(split(line0, "("))
    if scope != "main"
        s2 = replace(s2, ")" => "")
        inputs = [String(var) for var in split(s2, ",")]
        inputs = inputs == [""] ? [] : inputs
        push!(flines, Line(0, nothing, inputs, nothing, nothing))
    else
        push!(flines, Line(0, nothing, [], nothing, nothing))
    end
    
    for line in block[2:end-1]
        push!(flines, parseLine(line, keywords, fkeywords, scope))
    end
    
    if scope != "main"
        line1 = replace(block[end], r"\s+" => "")
        unused, s2 = String.(split(line1, "("))
        s2 = replace(s2, ")" => "")
        outputs = [String(var) for var in split(s2, ",")]
        outputs = outputs == [""] ? [] : outputs
        push!(flines, Line(1, nothing, nothing, outputs, nothing))
    else
        push!(flines, Line(1, nothing, nothing, [], nothing))
        return Function("main", [], [], flines)
    end
    return Function(scope, nothing, nothing, flines)
end

function parseVcal(vcal)
    vcal = separate(vcal)
    memargs, keywords = getMetadata(vcal[1])
    fkeywords = getFunctionKeys(vcal[2:end])
    
    functions = Dict()
    for block in vcal[2:end]
        f = parseFunction(block, keywords, fkeywords)
        push!(functions, f.name => f)
    end
    return functions, Memargs(memargs...)
end
