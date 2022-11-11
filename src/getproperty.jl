function Base.getproperty(ts::TSFrame, f::Symbol)
    return (f == :coredata) ? getfield(ts, :coredata) : getproperty(ts.coredata, f)
end
