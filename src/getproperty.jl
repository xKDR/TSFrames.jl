function Base.getproperty(ts::TimeFrame, f::Symbol)
    return (f == :coredata) ? getfield(ts, :coredata) : getproperty(ts.coredata, f)
end
