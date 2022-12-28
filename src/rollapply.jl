"""
# Rolling Functions

```julia
rollapply(fun::Function, ts::TSFrame, column::Any, windowsize::Int)
```

Apply a function to a column of `ts` for each continuous set of rows
of size `windowsize`. `column` could be any of the `DataFrame` column
selectors.

The output is a TSFrame object with `(nrow(ts) - windowsize + 1)` rows
indexed with the last index value of each window.

This method uses `RollingFunctions` package to implement this
functionality.

# Examples

```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> ts = TSFrame(1:12, Date("2022-02-01"):Month(1):Date("2022-02-01")+Month(11))

julia> show(ts)
(12 x 1) TSFrame with Dates.Date Index

 Index       x1
 Date        Int64
───────────────────
 2022-02-01      1
 2022-03-01      2
 2022-04-01      3
 2022-05-01      4
 2022-06-01      5
 2022-07-01      6
 2022-08-01      7
 2022-09-01      8
 2022-10-01      9
 2022-11-01     10
 2022-12-01     11
 2023-01-01     12

julia> rollapply(sum, ts, :x1, 10)
(3 x 1) TSFrame with Dates.Date Index

 Index       x1_rolling_sum
 Date        Float64
────────────────────────────
 2022-11-01            55.0
 2022-12-01            65.0
 2023-01-01            75.0

julia> rollapply(Statistics.mean, ts, 1, 5)
(8 x 1) TSFrame with Dates.Date Index

 Index       x1_rolling_mean
 Date        Float64
─────────────────────────────
 2022-06-01              3.0
 2022-07-01              4.0
 2022-08-01              5.0
 2022-09-01              6.0
 2022-10-01              7.0
 2022-11-01              8.0
 2022-12-01              9.0
 2023-01-01             10.0

```
"""
function rollapply(fun::Function, ts::TSFrame, column::Any, windowsize::Int) # TODO: multiple columns
    if windowsize < 1
        throw(ArgumentError("windowsize must be greater than or equal to 1"))
    end
    col = Int(1)
    if typeof(column) <: Int
        col = copy(column)
        col = col+1             # index is always 1
    else
        col = column
    end
    res = RollingFunctions.rolling(fun, ts.coredata[!, col], windowsize)
    idx = TSFrames.index(ts)[windowsize:end]
    colname = names(ts.coredata[!, [col]])[1]
    res_df = DataFrame([idx, res], ["Index", "$(colname)_rolling_$(fun)"])
    return TSFrame(res_df)
end

"""
```julia
rollapply(ts::TSFrame, fun::Function, windowsize::Int; bycolumn=true)
```

Apply `fun` to rolling windows of `ts`. The output is a `TSFrame` object with `(nrow(ts) - windowsize + 1)` rows
indexed with the last index value of each window.

The `bycolumn` argument should be set to `true` if `fun` is to be applied to each column separately,
and should be set to  `false` if `fun` takes a whole `TSFrame` as an input.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Statistics, StatsModels, StatsBase, GLM, Dates)
julia> df = DataFrame(Index=Date(2001, 1, 1):Day(1):Date(2001, 1, 10), inrchf=1:10, usdchf=1:10, eurchf=1:10, gbpchf=1:10, jpychf=1:10);

julia ts = TSFrame(df);

julia> rollapply(ts, Statistics.mean, 5)    # apply Statistics.mean columnwise
6×5 TSFrame with Date Index
 Index       rolling_inrchf_mean  rolling_usdchf_mean  rolling_eurchf_mean  rolling_gbpchf_mean  rolling_jpychf_mean
 Date        Float64              Float64              Float64              Float64              Float64
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 2001-01-05                  3.0                  3.0                  3.0                  3.0                  3.0
 2001-01-06                  4.0                  4.0                  4.0                  4.0                  4.0
 2001-01-07                  5.0                  5.0                  5.0                  5.0                  5.0
 2001-01-08                  6.0                  6.0                  6.0                  6.0                  6.0
 2001-01-09                  7.0                  7.0                  7.0                  7.0                  7.0
 2001-01-10                  8.0                  8.0                  8.0                  8.0                  8.0

julia> function regress(ts)     # defining function for multiple regressions
            ll = lm(@formula(inrchf ~ usdchf + eurchf + gbpchf + jpychf), ts.coredata[:, Not(:Index)])
            co = coef(ll)[coefnames(ll) .== "usdchf"]
            sd = Statistics.std(residuals(ll))
            return Dict("coeff" => co, "sd" => sd)
       end

julia> rollapply(ts, regress, 5; bycolumn=false)    # doing multiple regressions
6×1 TSFrame with Date Index
 Index       rolling_regress
 Date        Dict…
───────────────────────────────────────────────
 2001-01-05  Dict{String, Any}("coeff"=>[1.0]…
 2001-01-06  Dict{String, Any}("coeff"=>[1.0]…
 2001-01-07  Dict{String, Any}("coeff"=>[1.0]…
 2001-01-08  Dict{String, Any}("coeff"=>[1.0]…
 2001-01-09  Dict{String, Any}("coeff"=>[1.0]…
 2001-01-10  Dict{String, Any}("coeff"=>[1.0]…

```
"""
function rollapply(ts::TSFrame, fun::Function, windowsize::Int; bycolumn=true)
    firstWindow = ts[1:windowsize]
    res = bycolumn ? mapcols(col -> fun(col), firstWindow.coredata[!, Not(:Index)]) : [fun(firstWindow)]

    for endindex in windowsize + 1:TSFrames.nrow(ts)
        currentWindow = ts[endindex - windowsize + 1:endindex]
        if bycolumn
            res = vcat(res, mapcols(col -> fun(col), currentWindow.coredata[!, Not(:Index)]), cols=:orderequal)
        else
            res = vcat(res, [fun(currentWindow)])
        end
    end

    if bycolumn
        DataFrames.rename!(res, [col => string("rolling_", col, "_", Symbol(fun)) for col in propertynames(res)])
        res[:, :Index] = TSFrames.index(ts)[windowsize:end]
        return TSFrame(res)
    else
        res_df = DataFrame(Index=TSFrames.index(ts)[windowsize:end], outputs=res)
        DataFrames.rename!(res_df, Dict(:outputs => string("rolling_", Symbol(fun))))
        return TSFrame(res_df)
    end
end
