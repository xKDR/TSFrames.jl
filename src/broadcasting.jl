function Base.Broadcast.broadcasted(f, ts::TimeFrame)
    return TimeFrame(
        select(
            ts.coredata,
            :Index,
            Not(:Index) .=> (x -> f.(x)) => colname -> string(colname, "_", Symbol(f))
        )
    )
end
