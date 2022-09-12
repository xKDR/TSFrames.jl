"""
# Computing end points
```julia
endpoints(ts::TS, on::Function, k::Int=1)
endpoints(ts::TS, on::Type{Second}, k::Int=1)
endpoints(ts::TS, on::Type{Minute}, k::Int=1)
endpoints(ts::TS, on::Type{Hour}, k::Int=1)
endpoints(ts::TS, on::Type{Day}, k::Int=1)
endpoints(ts::TS, on::Type{Week}, k::Int=1)
endpoints(ts::TS, on::Type{Month}, k::Int=1)
endpoints(ts::TS, on::Type{Quarter}, k::Int=1)
endpoints(ts::TS, on::Type{Year}, k::Int=1)
endpoints(ts::TS, on::Symbol, k::Int=1)
endpoints(ts::TS, on::String, k::Int=1)
```

Return a vector of index values for last observation in `ts` for each
period given by `on`. The values are picked up every `k` instance of
the period (see examples).

Can be used to subset a `TS` object directly using this function's
return value.

`ts` is first converted into unique period-groups provided by `on`
then the last observation is picked up for every group. `k` decides
the number of groups to skip . For example, `k=2` picks every
alternate group starting from 2 out of the ones created by `on`. See
the examples below to see how the function works in the real world.

In the `endpoints(ts::TS, on::Function, k::Int=1)` method `on` takes a
`Function` which should return a `Vector` to be used as grouping
keys. For other methods the type of `on` determines the method that is
invoked (ex: `Week`, `Month`, etc.).
`endpoints(ts::TS, on::Symbol, k::Int=1)` and `endpoints(ts::TS, on::String, k::Int=1)`
are convenience methods where valid values for `on` are: `:years`,
`:quarters`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes`, and
`:seconds`. Note, that except for `on::Function` all other methods
expect Index type of `TS` to be a subtype of `TimeType`.

The method returns `Vector{Int}` corresponding to the matched values
in `Index`.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random
julia> random(x) = rand(MersenneTwister(123), x);
julia> dates = Date(2017):Day(1):Date(2019);
julia> ts = TS(random(length(dates)), dates)
(731 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2017-01-01  0.768448
 2017-01-02  0.940515
 2017-01-03  0.673959
 2017-01-04  0.395453
 2017-01-05  0.313244
 2017-01-06  0.662555
 2017-01-07  0.586022
 2017-01-08  0.0521332
 2017-01-09  0.26864
 2017-01-10  0.108871
     ⋮           ⋮
 2018-12-24  0.812797
 2018-12-25  0.158056
 2018-12-26  0.269285
 2018-12-27  0.15065
 2018-12-28  0.916177
 2018-12-29  0.278016
 2018-12-30  0.617211
 2018-12-31  0.67549
 2019-01-01  0.910285
       712 rows omitted

julia> ep = endpoints(ts, :months, 1)
25-element Vector{Int64}:
  31
  59
  90
 120
 151
 181
 212
 243
 273
 304
 334
 365
 396
 424
 455
 485
 516
 546
 577
 608
 638
 669
 699
 730
 731

julia> ts[ep]
(25 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2017-01-31  0.48
 2017-02-28  0.458476
 2017-03-31  0.274441
 2017-04-30  0.413966
 2017-05-31  0.734931
 2017-06-30  0.257159
 2017-07-31  0.415851
 2017-08-31  0.0377973
 2017-09-30  0.934059
 2017-10-31  0.413175
 2017-11-30  0.557009
 2017-12-31  0.346659
 2018-01-31  0.174777
 2018-02-28  0.432223
 2018-03-31  0.835142
 2018-04-30  0.945539
 2018-05-31  0.0635483
 2018-06-30  0.589922
 2018-07-31  0.285088
 2018-08-31  0.912558
 2018-09-30  0.238931
 2018-10-31  0.49775
 2018-11-30  0.830232
 2018-12-31  0.67549
 2019-01-01  0.910285

julia> diff(index(ts[ep]))
24-element Vector{Day}:
 28 days
 31 days
 30 days
 31 days
 30 days
 31 days
 31 days
 30 days
 31 days
 30 days
 31 days
 31 days
 28 days
 31 days
 30 days
 31 days
 30 days
 31 days
 31 days
 30 days
 31 days
 30 days
 31 days
 1 day

# with k=2
julia> ep = endpoints(ts, :months, 2);
julia> ts[ep]
(12 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2017-02-28  0.458476
 2017-04-30  0.413966
 2017-06-30  0.257159
 2017-08-31  0.0377973
 2017-10-31  0.413175
 2017-12-31  0.346659
 2018-02-28  0.432223
 2018-04-30  0.945539
 2018-06-30  0.589922
 2018-08-31  0.912558
 2018-10-31  0.49775
 2018-12-31  0.67549
 2019-01-01  0.910285

julia> diff(index(ts[ep]))
11-element Vector{Day}:
 61 days
 61 days
 62 days
 61 days
 61 days
 59 days
 61 days
 61 days
 62 days
 61 days
 61 days
 1 day

# Weekly points are implemented internally like this
julia> endpoints(ts, i -> lastdayofweek.(i), 1)
106-element Vector{Int64}:
   1
   8
  15
  22
  29
  36
  43
   ⋮
 694
 701
 708
 715
 722
 729
 731
```
"""
function endpoints(ts::TS, on::Function, k::Int=1)
    ii = index(ts)
    ex = Expr(:call, on, ii)
    keys = eval(ex)
    keys_unique = unique(keys) # for some `on` the keys become unsorted
    if (!issorted(keys_unique))
        keys_unique = sort(keys_unique)
    end
    points = keys_unique[k:k:length(keys_unique)]

    # include last observation if k^th period finishes before the end
    # value
    if (!isempty(points) && last(points) != last(keys_unique))
        push!(points, last(keys_unique))
    end
    [findlast([p] .== keys) for p in points]
end

function endpoints(ts::TS, on::Type{Second}, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end
    endpoints(ts, index -> [div(i.instant.periods.value, 1000) for i in index], k)
end

function endpoints(ts::TS, on::Type{Minute}, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end
    endpoints(ts, index -> [div(i.instant.periods.value, 60000) for i in index], k)
end

function endpoints(ts::TS, on::Type{Hour}, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end
    endpoints(ts, index -> [div(i.instant.periods.value, 3600000) for i in index], k)
end

function endpoints(ts::TS, on::Type{Day}, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end
    endpoints(ts, i -> Dates.yearmonthday.(i), k)
end

function endpoints(ts::TS, on::Type{Week}, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end
    endpoints(ts, i -> lastdayofweek.(i), k)
end

function endpoints(ts::TS, on::Type{Month}, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end
    endpoints(ts, i -> Dates.yearmonth.(i), k)
end

function endpoints(ts::TS, on::Type{Quarter}, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end
    endpoints(ts, i -> Dates.lastdayofquarter.(i), k)
end

function endpoints(ts::TS, on::Type{Year}, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end
    endpoints(ts, i -> Dates.year.(i), k)
end

function endpoints(ts::TS, on::Symbol, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end

    if (on == :days)
        endpoints(ts, Day, k)
    elseif (on == :weeks)
        endpoints(ts, Week, k)
    elseif (on == :months)
        endpoints(ts, Month, k)
    elseif (on == :quarters)
        endpoints(ts, Quarter, k)
    elseif (on == :years)
        endpoints(ts, Year, k)
    elseif (on == :hours)
        endpoints(ts, Hour, k)
    elseif (on == :minutes)
        endpoints(ts, Minute, k)
    elseif (on == :seconds)
        endpoints(ts, Second, k)
    elseif (on == :milliseconds)
        endpoints(ts, Millisecond, k)
    elseif (on == :microseconds)
        endpoints(ts, Microsecond, k)
    else
        throw(ArgumentError("unsupported value supplied to `on`"))
    end
end

function endpoints(ts::TS, on::String, k::Int=1)
    endpoints(ts, Symbol(on), k)
end
