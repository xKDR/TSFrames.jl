function Base.getproperty(ts::TS, f::Symbol)
    return (f == :coredata) ? getfield(ts, :coredata) : getproperty(ts.coredata, f)
end
