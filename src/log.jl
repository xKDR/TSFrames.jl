"""
# Log Function

```julia
log(ts::TS, complex::Bool = false)
```

This method computes the log value of non-index columns in the TS
object.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random
julia> random(x) = rand(MersenneTwister(123), x...);
julia> ts = TS(random(([1, 2, 3, 4, missing], 10)))
julia> show(ts)
(10 x 1) TS with Int64 Index

 Index  x1
 Int64  Int64?
────────────────
     1  missing
     2        2
     3        2
     4        3
     5        4
     6        3
     7        3
     8  missing
     9        2
    10        3

julia> log(ts)
(10 x 1) TS with Int64 Index

 Index  x1_log
 Int64  Float64?
───────────────────────
     1  missing
     2        0.693147
     3        0.693147
     4        1.09861
     5        1.38629
     6        1.09861
     7        1.09861
     8  missing
     9        0.693147
    10        1.09861

```
"""
function Base.log(ts::TS)
    df = select(ts.coredata, :Index,
        Not(:Index) .=> (x -> log.(x))
        =>
            colname -> string(colname, "_log"))
    TS(df)
end
