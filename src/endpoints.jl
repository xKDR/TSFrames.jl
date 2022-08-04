function endpoints(ts::TS, on::T, k::Int=1) where {T<:Union{Symbol, String}}
    if (on == :days)
        endpoints(ts, i -> Dates.yearmonthday.(i), k)
    elseif (on == :weeks)
        endpoints(ts, i -> Dates.week.(i), k)
    elseif (on == :months)
        endpoints(ts, i -> Dates.yearmonth.(i), k)
    elseif (on == :quarters)
        endpoints(ts, i -> [(year(x), Dates.quarterofyear(x)) for x in i], k)
    elseif (on == :years)
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
    points = new_index_unique[1:k:length(new_index_unique)]
    findall(x -> x in points, new_index)
end
