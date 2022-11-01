"""
# Computing end points
```julia
endpoints(timestamps::AbstractVector{T}, on::V) where {T<:Union{Date, DateTime, Time},
                                                       V<:Union{
                                                           Year,
                                                           Quarter,
                                                           Month,
                                                           Week,
                                                           Day,
                                                           Hour,
                                                           Minute,
                                                           Second,
                                                           Millisecond,
                                                           Microsecond,
                                                           Nanosecond
                                                       }}
endpoints(ts::TimeFrame, on::T) where {T<:Dates.Period}
endpoints(ts::TimeFrame, on::Symbol, k::Int=1)
endpoints(ts::TimeFrame, on::String, k::Int=1)
endpoints(ts::TimeFrame, on::Function, k::Int=1)
endpoints(values::AbstractVector, on::Function, k::Int=1)
```

Return an integer vector of values for last observation in
`timestamps` for each period given by `on`. The values are picked up
every `on.value` instance of the period.

Can be used to subset a `TimeFrame` object directly using this function's
return value. The methods work for regular time series of any
periodicity and irregular time series belonging to any of the
time-based types provided by the `Dates` module.

The primary method works for series of all time types including
`Date`, `DateTime`, and `Time`, and for `on` belonging to any of the
sub-types of `Dates.Period`. The `::TimeFrame` methods are provided for
convenience and call the primary method directly using the `Index`
column.

For the methods accepting `on` of `Function` type the `values` vector
will get converted into unique period-groups which act as unique keys.
The method uses these keys to create groups of values and uses the
period provided by `on` to pick up the last observation in each
group. `k` decides the number of groups to skip. For example, `k=2`
picks every alternate group starting from the 2ⁿᵈ element out of the
ones created by `on`. See the examples below to see how the function
works in the real world. The `on` function should return a `Vector` to
be used as grouping keys.

`endpoints(ts::TimeFrame, on::Symbol)` and `endpoints(ts::TimeFrame, on::String)`
are convenience methods where valid values for `on` are: `:years`,
`:quarters`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes`,
`:seconds`, `:milliseconds`, `:microseconds`, and `:nanoseconds`.

Note, that except for `on::Function` all other methods expect `Index`
type of `TimeFrame` to be a subtype of `TimeType`.

The method returns `Vector{Int}` corresponding to the matched values
in the first argument.

# Examples
```jldoctest; setup = :(using TimeFrames, DataFrames, Dates, Random, Statistics)
julia> using Random
julia> random(x) = rand(MersenneTwister(123), x);
julia> dates = Date(2017):Day(1):Date(2019);
julia> ts = TimeFrame(random(length(dates)), dates)
(731 x 1) TimeFrame with Date Index

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

julia> ep = endpoints(ts, Month(1))
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
(25 x 1) TimeFrame with Date Index

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

# every 2ⁿᵈ month
julia> ts[endpoints(ts, Month(2))]
(12 x 1) TimeFrame with Date Index

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

# Weekly points using a function
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

julia> endpoints(ts, i -> lastdayofweek.(i), 1) == endpoints(ts, Week(1))
true

# Time type series
julia> timestampsminutes = collect(Time(9, 1, 2):Minute(1):Time(11, 2, 3));
julia> timestampsminutes[endpoints(timestampsminutes, Minute(2))]
61-element Vector{Time}:
 09:02:02
 09:04:02
 09:06:02
 09:08:02
 09:10:02
 09:12:02
 09:14:02
 09:16:02
 09:18:02
 09:20:02
 09:22:02
 09:24:02
 ⋮
 10:40:02
 10:42:02
 10:44:02
 10:46:02
 10:48:02
 10:50:02
 10:52:02
 10:54:02
 10:56:02
 10:58:02
 11:00:02
 11:02:02

julia> timestampsminutes[endpoints(timestampsminutes, Hour(1))]
3-element Vector{Time}:
 09:59:02
 10:59:02
 11:02:02

## Irregular series
julia> datetimeseconds = collect(range(DateTime(2022, 10, 08) + Hour(9),
                                DateTime(2022, 10, 08) + Hour(15) + Minute(29),
                                step=Second(1)));
julia> datetimesecondsrandom = sample(MersenneTwister(123), datetimeseconds, 20, replace=false, ordered=true)
17-element Vector{DateTime}:
 2022-10-08T09:20:16
 2022-10-08T09:32:00
 2022-10-08T09:43:57
 2022-10-08T10:13:27
 2022-10-08T10:44:34
 2022-10-08T11:04:23
 2022-10-08T11:08:37
 2022-10-08T11:46:51
 2022-10-08T11:56:46
 2022-10-08T12:14:22
 2022-10-08T12:32:08
 2022-10-08T13:28:42
 2022-10-08T13:34:33
 2022-10-08T13:54:11
 2022-10-08T13:59:08
 2022-10-08T14:05:57
 2022-10-08T14:37:17

julia> datetimesecondsrandom[endpoints(datetimesecondsrandom, Hour(1))]
6-element Vector{DateTime}:
 2022-10-08T09:43:57
 2022-10-08T10:44:34
 2022-10-08T11:56:46
 2022-10-08T12:32:08
 2022-10-08T13:59:08
 2022-10-08T14:37:17
```
"""
function endpoints(values::AbstractVector, on::Function, k::Int=1)
    if (k <= 0)
        throw(DomainError("`k` needs to be greater than 0"))
    end

    ex = Expr(:call, on, values)
    keys = eval(ex)
    keys_unique = unique(keys) # for some `on` the keys become unsorted
    if (!issorted(keys_unique))
        keys_unique = sort(keys_unique)
    end
    points = keys_unique[k:k:length(keys_unique)]

    # include last observation if k^th period finishes before the end
    # value
    if (isempty(points) ||
        (!isempty(points) && last(points) != last(keys_unique)))
        push!(points, last(keys_unique))
    end
    [findlast([p] .== keys) for p in points]
end

function endpoints(ts::TimeFrame, on::Function, k::Int=1)
    endpoints(index(ts), on, k)
end

function endpoints(timestamps::AbstractVector{T}, on::V)::Vector{Int} where {T<:Union{Date, DateTime, Time},
                                                                V<:Union{
                                                                    Year,
                                                                    Quarter,
                                                                    Month,
                                                                    Week,
                                                                    Day,
                                                                    Hour,
                                                                    Minute,
                                                                    Second,
                                                                    Millisecond,
                                                                    Microsecond,
                                                                    Nanosecond
                                                                }}
    if (on.value <= 0)
        throw(DomainError("`on.value` needs to be greater than 0"))
    end
    if (typeof(first(timestamps)) == Date && typeof(on) <: TimePeriod)
        throw(ArgumentError("Cannot find `TimePeriod` type inside a `Date` vector"))
    end
    if (typeof(first(timestamps)) == DateTime &&
        (typeof(on) == Microsecond || typeof(on) == Nanosecond))
        throw(ArgumentError("`DateTime` type does not support resolution of Microsecond or Nanosecond"))
    end
    if (typeof(first(timestamps)) == Time && typeof(on) <: DatePeriod)
        throw(ArgumentError("Cannot find `DatePeriod` type inside a `Time` vector"))
    end

    ep = Int[]
    sizehint!(ep, length(timestamps))

    # store the next value of the period (on), use it for comparison
    # with values in the series (timestamps)
    nextval = eltype(timestamps)(1)
    if (typeof(on) == Week)
        nextval = floor(first(timestamps), typeof(on)) + on
    else
        nextval = trunc(first(timestamps), typeof(on)) + on
    end

    for i in eachindex(timestamps)
        if (timestamps[i] >= nextval)
            push!(ep, i-1)

            # handle gaps between values (irregular series)
            while (true)
                nextval += on
                if (nextval >= timestamps[i])
                    break
                end
            end
        end
    end

    if (isempty(ep) || last(ep) != lastindex(timestamps))
        push!(ep, lastindex(timestamps))
    end
    return ep
end

function endpoints(ts::TimeFrame, on::T) where {T<:Dates.Period}
    endpoints(index(ts), on)
end

function endpoints(ts::TimeFrame, on::Symbol, k::Int=1)
    if (on == :days)
        endpoints(ts, Day(k))
    elseif (on == :weeks)
        endpoints(ts, Week(k))
    elseif (on == :months)
        endpoints(ts, Month(k))
    elseif (on == :quarters)
        endpoints(ts, Quarter(k))
    elseif (on == :years)
        endpoints(ts, Year(k))
    elseif (on == :hours)
        endpoints(ts, Hour(k))
    elseif (on == :minutes)
        endpoints(ts, Minute(k))
    elseif (on == :seconds)
        endpoints(ts, Second(k))
    elseif (on == :milliseconds)
        endpoints(ts, Millisecond(k))
    elseif (on == :microseconds)
        endpoints(ts, Microsecond(k))
    elseif (on == :nanoseconds)
        endpoints(ts, Nanosecond(k))
    else
        throw(ArgumentError("unsupported value supplied to `on`"))
    end
end

function endpoints(ts::TimeFrame, on::String, k::Int=1)
    endpoints(ts, Symbol(on), k)
end
