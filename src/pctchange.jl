"""
# Percent Change

```julia
pctchange(ts::TSFrame, periods::Int = 1)
```

Return the percentage change between successive row elements.
Default is the element in the next row. `periods` defines the number
of rows to be shifted over. The skipped rows are rendered as `missing`.

`pctchange` returns an error if column type does not have the method `/`.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> ts = TSFrame(random(length(dates)), dates)
julia> show(ts)
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

# Pctchange over successive rows
julia> pctchange(ts)
(10 x 1) TSFrame with Date Index

 Index       x1
 Date        Float64?
────────────────────────────
 2017-01-01  missing
 2017-01-02        0.223915
 2017-01-03       -0.283415
 2017-01-04       -0.413238
 2017-01-05       -0.207886
 2017-01-06        1.11514
 2017-01-07       -0.115511
 2017-01-08       -0.911039
 2017-01-09        4.15295
 2017-01-10       -0.594733


# Pctchange over the third row
julia> pctchange(ts, 3)
(10 x 1) TSFrame with Date Index

 Index       x1
 Date        Float64?
─────────────────────────────
 2017-01-01  missing
 2017-01-02  missing
 2017-01-03  missing
 2017-01-04       -0.485387
 2017-01-05       -0.666944
 2017-01-06       -0.0169207
 2017-01-07        0.4819
 2017-01-08       -0.83357
 2017-01-09       -0.59454
 2017-01-10       -0.814221

```
"""

# Pctchange
function pctchange(ts::TSFrame, periods::Int = 1)
    if periods <= 0
        throw(ArgumentError("periods must be a positive int"))
    end
    ddf = (ts.coredata[:, Not(:Index)] .- TSFrames.lag(ts, periods).coredata[:, Not(:Index)]) ./ abs.(TSFrames.lag(ts, periods).coredata[:, Not(:Index)])
    insertcols!(ddf, 1, "Index" => ts.coredata[:, :Index])
    TSFrame(ddf, :Index)
end
