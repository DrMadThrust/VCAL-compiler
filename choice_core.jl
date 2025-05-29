function choose(f, functions=Dict(), mempos=Dict())
    preasm = []
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
                for subline in reverse(choose(tempfn, functions, mempos))
                    push!(preasm, subline)
                end
                
                push!(preasm, Line(2, "{", nothing, nothing, nothing))
                if line.condition != nothing
                    
                    condvars = line.conditionals == nothing ? nothing : line.conditionals
                    for var in condvars
                        if typeof(var) != Const
                            if haskey(mempos, varmap[var]) == false
                                push!(mempos, varmap[var] => freePos(mempos))
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
                            push!(mempos, varmap[var] => freePos(mempos))
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
                            push!(mempos, varmap[var] => freePos(mempos))
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
