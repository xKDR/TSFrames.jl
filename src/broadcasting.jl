function Base.Broadcast.broadcasted(f, ts::TSFrame; renamecols=true)
    return TSFrame(
        select(
            ts.coredata,
            :Index,
            Not(:Index) .=> (x -> f.(x)) => colname -> string(colname, "_", Symbol(f)),
            renamecols = renamecols
        )
    )
end

function Base.Broadcast.broadcasted(f, arg, ts::TSFrame; renamecols=false)
    return TSFrame(
        select(
            ts.coredata,
            :Index,
            Not(:Index) .=> (x -> f(arg, x)),
            renamecols = renamecols
        )
    )
end
