"""
# Upsampling
```julia
upsample(ts::TSFrame,
      period::T
    where {T<:Union{DatePeriod, TimePeriod}}
```
Converts `ts` into an object of higher frequency than the original (ex.
from monthly series to daily.) `period` is any of `Period` types in the
`Dates` module.

By default, the added rows contain `missing` data.

# Examples
```jldoctest; setup = :(using TimeFrames, DataFrames, Dates, Random, Statistics)
julia> using Random, Statistics;
julia> random(x) = rand(MersenneTwister(123), x);
julia> dates = collect(DateTime(2017,1,1):Day(1):DateTime(2018,3,10));

julia> ts = TSFrame(random(length(dates)), dates)
julia> show(ts[1:10])
(10 x 1) TSFrame with DateTime Index

 Index                x1        
 DateTime             Float64   
────────────────────────────────
 2017-01-01T00:00:00  0.768448
 2017-01-02T00:00:00  0.940515
 2017-01-03T00:00:00  0.673959
 2017-01-04T00:00:00  0.395453
 2017-01-05T00:00:00  0.313244
 2017-01-06T00:00:00  0.662555
 2017-01-07T00:00:00  0.586022
 2017-01-08T00:00:00  0.0521332
 2017-01-09T00:00:00  0.26864
 2017-01-10T00:00:00  0.108871

 julia> upsample(ts, Hour(1))
(10393 x 1) TSFrame with DateTime Index

 Index                x1              
 DateTime             Float64?        
──────────────────────────────────────
 2017-01-01T00:00:00        0.768448
 2017-01-01T01:00:00  missing         
 2017-01-01T02:00:00  missing         
 2017-01-01T03:00:00  missing         
          ⋮                  ⋮
 2018-03-09T21:00:00  missing         
 2018-03-09T22:00:00  missing         
 2018-03-09T23:00:00  missing         
 2018-03-10T00:00:00        0.0338698
                    10385 rows omitted

upsample(ts, Hour(12))
(867 x 1) TSFrame with DateTime Index

Index                x1              
DateTime             Float64?        
──────────────────────────────────────
2017-01-01T00:00:00        0.768448
2017-01-01T12:00:00  missing         
2017-01-02T00:00:00        0.940515
2017-01-02T12:00:00  missing         
        ⋮                  ⋮
2018-03-08T12:00:00  missing         
2018-03-09T00:00:00        0.375126
2018-03-09T12:00:00  missing         
2018-03-10T00:00:00        0.0338698
                    859 rows omitted
"""

function upsample(ts::TSFrame, period::T) where {T<:Union{DatePeriod, TimePeriod}}
    dex = collect(first(index(ts)):period:last(index(ts)))
    join(ts, TSFrame(DataFrame(index = dex), :index))
end