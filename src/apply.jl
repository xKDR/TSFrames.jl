"""
# Apply/Period conversion
```julia
apply(ts::TS,
      period::Union{T,Type{T}},
      fun::V,
      index_at::Function=first)
     where {T <: Union{DatePeriod,TimePeriod}, V <: Function}
```

Apply `fun` to `ts` object based on `period` and return correctly
indexed rows. This method is used for doing aggregation over a time
period or to convert `ts` into an object of lower frequency (ex. from
daily series to monthly).

`period` is any of `Periirstod` types in the `Dates` module. Conversion
from lower to a higher frequency will throw an error as interpolation
isn't currently handled by this method.

By default, the method uses the first value of the index within the
period to index the resulting aggregated object. This behaviour can be
controlled by `index_at` argument which can take `first` or `last` as
an input.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random, Statistics;
julia> random(x) = rand(MersenneTwister(123), x);
julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10));

julia> ts = TS(random(length(dates)), dates)
julia> show(ts[1:10])
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

julia> apply(ts, Month, first)
(15 x 1) TS with Date Index

 Index       x1_first
 Date        Float64
───────────────────────
 2017-01-01  0.768448
 2017-02-01  0.790201
 2017-03-01  0.467219
 2017-04-01  0.783473
 2017-05-01  0.651354
 2017-06-01  0.373346
 2017-07-01  0.83296
 2017-08-01  0.132716
 2017-09-01  0.27899
 2017-10-01  0.995414
 2017-11-01  0.214132
 2017-12-01  0.832917
 2018-01-01  0.0409471
 2018-02-01  0.720163
 2018-03-01  0.87459

# alternate months
julia> apply(ts, Month(2), first)
(8 x 1) TS with Date Index

 Index       x1_first
 Date        Float64
───────────────────────
 2017-01-01  0.768448
 2017-03-01  0.467219
 2017-05-01  0.651354
 2017-07-01  0.83296
 2017-09-01  0.27899
 2017-11-01  0.214132
 2018-01-01  0.0409471
 2018-03-01  0.87459


julia> ts_weekly = apply(ts, Week, Statistics.std) # weekly standard deviation
julia> show(ts_weekly[1:10])
(10 x 1) TS with Date Index

 Index       x1_std
 Date        Float64
────────────────────────
 2017-01-01  NaN
 2017-01-02    0.28935
 2017-01-09    0.270842
 2017-01-16    0.170197
 2017-01-23    0.269573
 2017-01-30    0.326687
 2017-02-06    0.279935
 2017-02-13    0.319216
 2017-02-20    0.272058
 2017-02-27    0.23651


julia> ts_weekly = apply(ts, Week, Statistics.std, last) # indexed by last date of the week
julia> show(ts_weekly[1:10])
(10 x 1) TS with Date Index

 Index       x1_std
 Date        Float64
────────────────────────
 2017-01-01  NaN
 2017-01-08    0.28935
 2017-01-15    0.270842
 2017-01-22    0.170197
 2017-01-29    0.269573
 2017-02-05    0.326687
 2017-02-12    0.279935
 2017-02-19    0.319216
 2017-02-26    0.272058
 2017-03-05    0.23651

```
"""
function apply(ts::TS, period::Union{T,Type{T}}, fun::V, index_at::Function=first) where {T<:Union{DatePeriod,TimePeriod}, V<:Function}
    sdf = transform(ts.coredata, :Index => i -> Dates.floor.(i, period))
    gd = groupby(sdf, :Index_function)
    df = combine(gd,
                 :Index => index_at => :Index,
                 Not(["Index", "Index_function"]) .=> fun,
                 keepkeys=false)
    TS(df, :Index)
end
