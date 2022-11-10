"""
# Lagging
```julia
lag(ts::TSFrame, lag_value::Int = 1)
```

Lag the `ts` object by the specified `lag_value`. The rows corresponding
to lagged values will be rendered as `missing`. Negative values of lag are
also accepted (see `TSFrames.lead`).

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> ts = TSFrame(random(length(dates)), dates);
julia> show(ts)
(10 x 1) TSFrame with Dates.Date Index

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


julia> lag(ts)
(10 x 1) TSFrame with Date Index

 Index       x1
 Date        Float64?
─────────────────────────────
 2017-01-01  missing
 2017-01-02        0.768448
 2017-01-03        0.940515
 2017-01-04        0.673959
 2017-01-05        0.395453
 2017-01-06        0.313244
 2017-01-07        0.662555
 2017-01-08        0.586022
 2017-01-09        0.0521332
 2017-01-10        0.26864

julia> lag(ts, 2) # lags by 2 values
(10 x 1) TSFrame with Date Index

 Index       x1
 Date        Float64?
─────────────────────────────
 2017-01-01  missing
 2017-01-02  missing
 2017-01-03        0.768448
 2017-01-04        0.940515
 2017-01-05        0.673959
 2017-01-06        0.395453
 2017-01-07        0.313244
 2017-01-08        0.662555
 2017-01-09        0.586022
 2017-01-10        0.0521332

```
"""
function lag(ts::TSFrame, lag_value::Int = 1)
    sdf = DataFrame(ShiftedArrays.lag.(eachcol(ts.coredata[!, Not(:Index)]), lag_value), TSFrames.names(ts))
    insertcols!(sdf, 1, :Index => ts.coredata[!, :Index])
    TSFrame(sdf, :Index)
end
