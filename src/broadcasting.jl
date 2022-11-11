function Base.Broadcast.broadcasted(f, ts::TSFrame)
    return TSFrame(
        select(
            ts.coredata,
            :Index,
            Not(:Index) .=> (x -> f.(x)) => colname -> string(colname, "_", Symbol(f))
        )
    )
end
