function raw_compile(source, outname=source)
    source = source*".vcal"
    outname = outname*".axm"
    display("loading source file: " * source)
    vcal = load(source)
    display("parsing source code")
    functions, memargs = parseVcal(vcal)
    display("mapping memory")
    preasm = choosemempos(functions["main"], functions, memargs.memzero)
    display("constructing target axm")
    create(preasm, outname, nothing, getMemArgs(memargs), "raw")
    display("compilation successful with output: " * outname)
end

function naive_compile(source, outname=source)
    source = source*".vcal"
    outname = outname*".axm"
    display("loading source file: " * source)
    vcal = load(source)
    display("parsing source code")
    functions, memargs = parseVcal(vcal)
    display("mapping memory")
    preasm = choosemempos(functions["main"], functions, memargs.memzero)
    display("mapping ram accesses")
    mapasm = naive_map(preasm, memargs.regzero)
    display("constructing target axm")
    create(mapasm, outname, nothing, getMemArgs(memargs), "naive")
    display("compilation successful with output: " * outname)
end

function naive_reduce(preasm, regzero=1)
    memfile = []
    reducedasm = (Line)[]
    for line in preasm
        regpos = regzero - 1
        seen = Dict()
        outvars = line.outputs == nothing ? nothing : [typeof(var) == Const ? var : (haskey(seen, var) ? seen[var] : push!(seen, var => begin regpos = regpos + 1 end)[var]) for var in line.outputs]
        invars = line.inputs == nothing ? nothing : [typeof(var) == Const ? var : (haskey(seen, var) ? seen[var] : push!(seen, var => begin regpos = regpos + 1 end)[var]) for var in line.inputs]
        condvars = line.conditionals == nothing ? nothing : [typeof(var) == Const ? var : (haskey(seen, var) ? seen[var] : push!(seen, var => begin regpos = regpos + 1 end)[var]) for var in line.conditionals]
        push!(reducedasm, Line(line.operation, line.condition, outvars, invars, condvars))
    end
    for line in preasm
        memactive = (Int)[]
        if line.outputs != nothing
            for var in line.outputs
                if typeof(var) != Const && (var in memactive) == false
                    push!(memactive, var)
                end
            end
        end
        if line.inputs != nothing
            for var in line.inputs
                if typeof(var) != Const && (var in memactive) == false
                    push!(memactive, var)
                end
            end
        end
        if line.conditionals != nothing
            for var in line.conditionals
                if typeof(var) != Const && (var in memactive) == false
                    push!(memactive, var)
                end
            end
        end
        push!(memfile, memactive)
    end
    return memfile, reducedasm
end

function naive_map(preasm, regzero=1)
    mapasm = []
    mappings, lines = naive_reduce(preasm, regzero)
    k = 1
    while k <= length(lines)
        regpos = regzero
        for rampos in mappings[k]
            push!(mapasm, Line("", nothing, [regpos], [Const("["*string(rampos)*"]")], nothing))
            regpos = regpos + 1
        end
        push!(mapasm, lines[k])
        if lines[k].operation == 3
            push!(mapasm, lines[k+1])
        end
        regpos = regzero
        for rampos in mappings[k]
            push!(mapasm, Line("", nothing, [Const("["*string(rampos)*"]")], [regpos], nothing))
            regpos = regpos + 1
        end
        if lines[k].operation == 3
            k = k + 1
        end
        k = k + 1
    end
    return mapasm
end

function choosemempos(f, functions=Dict(), memzero=1, mempos=Dict())
    preasm = (Line)[]
    varmap = assignVarmap(f)
    for (line, k) in reverse(f.lines) |> x -> zip(x, reverse(0:length(x)-1))
        if line.operation == 1
            for (var, output) in zip(line.inputs, f.outputs)
                push!(mempos, varmap[var] => mempos[output])
                delete!(mempos, output)
            end
        elseif line.operation == 0
            for (var, input) in zip(line.outputs, f.inputs)
                push!(mempos, input => mempos[varmap[var]])
                delete!(mempos, varmap[var])
            end 
        elseif typeof(line.operation) == Flabel
            if line.operation.id != f.name
                push!(preasm, Line(2, "}", nothing, nothing, nothing))
                
                templatefn = functions[line.operation.id]
                inputvars = line.inputs == nothing ? nothing : [varmap[var] for var in line.inputs]
                outputvars = line.outputs == nothing ? nothing : [varmap[var] for var in line.outputs]
                tempfn = Function(templatefn.name, outputvars, inputvars, templatefn.lines)
                for subline in reverse(choosemempos(tempfn, functions, memzero, mempos))
                    push!(preasm, subline)
                end
                
                push!(preasm, Line(2, "{", nothing, nothing, nothing))
                if line.condition != nothing
                    
                    condvars = line.conditionals == nothing ? nothing : line.conditionals
                    for var in condvars
                        if typeof(var) != Const
                            if haskey(mempos, varmap[var]) == false
                                push!(mempos, varmap[var] => freePos(mempos, memzero))
                            end
                        end
                    end
                    condpos = line.conditionals == nothing ? nothing : [typeof(var) == Const ? var : mempos[varmap[var]] for var in line.conditionals]
                    push!(preasm, Line(3, line.condition, nothing, nothing, condpos))
                end
                
            else #haram turbo mega logikbombe
                inputvars = line.inputs == nothing ? [] : line.inputs
                inputvars = line.conditionals == nothing ? inputvars : [inputvars; line.conditionals]
                for var in inputvars
                    if typeof(var) != Const
                        if haskey(mempos, varmap[var]) == false
                            push!(mempos, varmap[var] => freePos(mempos, memzero))
                        end
                    end
                end
                
                condpos = line.conditionals == nothing ? nothing : [typeof(var) == Const ? var : mempos[varmap[var]] for var in line.conditionals]
                push!(preasm, Line(4, line.condition, nothing, nothing, condpos))
            end #haram turbo mega logikbombe ende
            
        elseif typeof(line.operation) == String
            inputvars = line.inputs == nothing ? [] : line.inputs
            inputvars = line.conditionals == nothing ? inputvars : [inputvars; line.conditionals]
            outputvars = line.outputs == nothing ? [] : deepcopy(line.outputs)
            for var in inputvars
                if typeof(var) != Const
                    if haskey(mempos, varmap[var]) == false
                        
                        to_replace = true
                        for (outvar, s) in zip(outputvars, 1:length(outputvars))
                            if typeof(outvar) != Const && varmap[outvar].lifetime >= k
                                push!(mempos, varmap[var] => mempos[varmap[outvar]])
                                deleteat!(outputvars, s)
                                to_replace = false
                                break
                            end
                        end
                        
                        if to_replace == true
                            push!(mempos, varmap[var] => freePos(mempos, memzero))
                        end
                        
                    end
                end
            end
            
            outpos = line.outputs == nothing ? nothing : [typeof(var) == Const ? var : mempos[varmap[var]] for var in line.outputs]
            inpos = line.inputs == nothing ? nothing : [typeof(var) == Const ? var : mempos[varmap[var]] for var in line.inputs]
            condpos = line.conditionals == nothing ? nothing : [typeof(var) == Const ? var : mempos[varmap[var]] for var in line.conditionals]
            push!(preasm, Line(line.operation, line.condition, outpos, inpos, condpos))
            
            outputvars = line.outputs == nothing ? [] : line.outputs
            for var in outputvars
                if typeof(var) != Const && varmap[var].lifetime >= k #off by 1 farming
                     delete!(mempos, varmap[var])
                end
            end
        elseif line.operation == 9
            push!(preasm, Line(9, nothing, nothing, nothing, nothing))
        else
            println("invalid operation")
        end
    end
    return reverse(preasm)
end
