"""
# Differencing
```julia
diff(ts::TSFrame, periods::Int = 1)
```

Return the discrete difference of successive row elements.
Default is the element in the next row. `periods` defines the number
of rows to be shifted over. The skipped rows are rendered as `missing`.

`diff` returns an error if column type does not have the method `-`.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10));

julia> ts = TSFrame(random(length(dates)), dates);
julia> ts[1:10]
(10 x 1) TSFrame with Date Index

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

julia> diff(ts)[1:10]        # difference over successive rows
(10 x 1) TSFrame with Date Index

 Index       x1
 Date        Float64?
─────────────────────────────
 2017-01-01  missing
 2017-01-02        0.172067
 2017-01-03       -0.266556
 2017-01-04       -0.278506
 2017-01-05       -0.0822092
 2017-01-06        0.349311
 2017-01-07       -0.0765327
 2017-01-08       -0.533889
 2017-01-09        0.216506
 2017-01-10       -0.159769

julia> diff(ts, 3)[1:10]     # difference over the third row
(10 x 1) TSFrame with Date Index

 Index       x1
 Date        Float64?
─────────────────────────────
 2017-01-01  missing
 2017-01-02  missing
 2017-01-03  missing
 2017-01-04       -0.372995
 2017-01-05       -0.627271
 2017-01-06       -0.0114039
 2017-01-07        0.190569
 2017-01-08       -0.261111
 2017-01-09       -0.393915
 2017-01-10       -0.477151

```
"""

# Diff
function diff(ts::TSFrame, periods::Int = 1)
    if periods <= 0
        error("periods must be a postive int")
    end
    ddf = ts.coredata[:, Not(:Index)] .- TSFrames.lag(ts, periods).coredata[:, Not(:Index)]
    insertcols!(ddf, 1, "Index" => ts.coredata[:, :Index])
    TSFrame(ddf, :Index)
end
