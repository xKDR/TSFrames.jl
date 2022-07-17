function Base.axes(ts::TS)
    return (first(axes(ts.coredata)), Base.OneTo(last(collect(last(axes(ts.coredata)))) - 1))
end

