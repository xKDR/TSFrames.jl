"""
# Percent Change

```julia
pctchange(ts::TS; periods::Int = 1, log = false)
```

Return the percentage change between successive row elements.
Default is the element in the next row. `periods` defines the number
of rows to be shifted over, `1` being the default. The skipped rows are 
rendered as `missing`.

`log` is one of `false` (the default), `:log` and `:log10`. If `log == :log`, 
the percentage change is computed as the logarithm of the change. If 
`log == :log10`, the percentage change is computed as the logarithm of
the change in base 10. Other values are ignored with a warning message.

`pctchange` returns an error if: 
    - the column type does not have the method `/`; or,
    - the column type does not have the method `log` or `log10` when specified.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> ts = TS(random(length(dates)), dates)
julia> show(ts)
(10 x 1) TS with Date Index

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
(10 x 1) TS with Date Index

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
(10 x 1) TS with Date Index

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
function pctchange(ts::TS; periods::Int = 1, log::Any = false)
    if periods <= 0
        error("periods must be a positive int")
    end

    ddf = (ts.coredata[:, Not(:Index)] ./ TSx.lag(ts, periods).coredata[:, Not(:Index)])
    
    if log == false
        ddf = ddf .- 1
    elseif log == :log
        ddf = Base.log.(ddf)
    elseif log == :log10
        ddf = Base.log10.(ddf)
    else
        @warn "log must be one of false, :log or :log10"
    end

    insertcols!(ddf, 1, "Index" => ts.coredata[:, :Index])
    return TS(ddf, :Index)
end

# function pctchange(ts::TS, periods::Int = 1; log::Any = false) 
#     return pctchange(ts; periods = periods, log = log)
# end
