function freePos(mempos, memzero = 1)
    pos = memzero
    vals = collect(values(mempos))
    while true
        if (pos in vals) == false
            return pos
        end
        pos = pos+1
    end
end

function assignVarmap(f)
    varmap = Dict()
    for (line, k) in f.lines[1:end-1] |> x -> zip(x, 0:length(x))
        if line.outputs != nothing
            for var in line.outputs
                if typeof(var) != Const && haskey(varmap, var) == false
                    push!(varmap, var => Var(var, k, f.name))
                end
            end
        end
    end
    return varmap
end
