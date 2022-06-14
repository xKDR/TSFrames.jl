"""
# Leading
```julia
lead(ts::TS, lead_value::Int = 1)
```

Similar to lag, this method leads the `ts` object by `lead_value`. The
lead rows are inserted with `missing`. Negative values of lead are
also accepted (see `TSx.lag`).

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10));

julia> ts = TS(DataFrame(Index = dates, x1 = random(length(dates))))
julia> show(ts)
(434 x 1) TS with Dates.Date Index

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
     ⋮           ⋮
 2018-03-03  0.127635
 2018-03-04  0.147813
 2018-03-05  0.873555
 2018-03-06  0.486486
 2018-03-07  0.495525
 2018-03-08  0.64075
 2018-03-09  0.375126
 2018-03-10  0.0338698
       418 rows omitted


julia> lead(ts)[1:10]        # leads once
(10 x 1) TS with Date Index

 Index       x1
 Date        Float64?
───────────────────────
 2017-01-01  0.940515
 2017-01-02  0.673959
 2017-01-03  0.395453
 2017-01-04  0.313244
 2017-01-05  0.662555
 2017-01-06  0.586022
 2017-01-07  0.0521332
 2017-01-08  0.26864
 2017-01-09  0.108871
 2017-01-10  0.163666

julia> lead(ts, 2)[1:10]     # leads by 2 values
(10 x 1) TS with Date Index

 Index       x1
 Date        Float64?
───────────────────────
 2017-01-01  0.673959
 2017-01-02  0.395453
 2017-01-03  0.313244
 2017-01-04  0.662555
 2017-01-05  0.586022
 2017-01-06  0.0521332
 2017-01-07  0.26864
 2017-01-08  0.108871
 2017-01-09  0.163666
 2017-01-10  0.473017

```
"""
function lead(ts::TS, lead_value::Int = 1)
    sdf = DataFrame(ShiftedArrays.lead.(eachcol(ts.coredata[!, Not(:Index)]), lead_value), TSx.names(ts))
    insertcols!(sdf, 1, :Index => ts.coredata[!, :Index])
    TS(sdf, :Index)
end
