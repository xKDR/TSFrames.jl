function upsample(ts::TS, period::Union{T, Type{T}}, fun::Function=first, renamecols::Bool=true) where {T<:Union{DatePeriod, TimePeriod}}
    dex = collect(first(index(ts)):period:last(index(ts)))
    join(ts, TS(DataFrame(index = dex), :index))
end