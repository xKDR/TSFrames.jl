"""
# Computing end points
```julia
endpoints(ts::TS, on::T, k::Int=1) where {T<:Union{Symbol, String}}
endpoints(ts::TS, on::Function, k::Int=1)
```

Return index values for last observation in `ts` for the period given
by `on` every `k` instance.
"""
function endpoints(ts::TS, on::T, k::Int=1) where {T<:Union{Symbol, String}}
    if (on == :days || on == "days")
        endpoints(ts, i -> Dates.yearmonthday.(i), k)
    elseif (on == :weeks || on == "weeks")
        endpoints(ts, i -> Dates.week.(i), k)
    elseif (on == :months || on == "months")
        endpoints(ts, i -> Dates.yearmonth.(i), k)
    elseif (on == :quarters || on == "quarters")
        endpoints(ts, i -> [(year(x), Dates.quarterofyear(x)) for x in i], k)
    elseif (on == :years || on == "years")
        endpoints(ts, i -> Dates.year.(i), k)
    else
        error("unsupported value supplied to `on`")
    end
end

function endpoints(ts::TS, on::Function, k::Int=1)
    ii = index(ts)
    ex = Expr(:call, on, ii)
    new_index = eval(ex)
    new_index_unique = unique(new_index)
    points = new_index_unique[k:k:length(new_index_unique)]
    [findlast([p] .== new_index) for p in points]
end
