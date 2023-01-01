"""
# Rolling Functions
```julia
rollapply(ts::TSFrame, fun::Function, windowsize::Int; bycolumn=true)
```
Apply function `fun` to rolling windows of `ts`. The output is a
`TSFrame` object with `(nrow(ts) - windowsize + 1)` rows indexed with
the last index value of each window.

The `bycolumn` argument should be set to `true` (default) if `fun` is
to be applied to each column separately, and to `false` if `fun` takes
a whole `TSFrame` as an input.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Statistics, StatsModels, StatsBase, GLM, Dates)
julia> rollapply(TSFrame([1:10 11:20]), mean, 5)
6×2 TSFrame with Int64 Index
 Index  rolling_x1_mean  rolling_x2_mean 
 Int64  Float64          Float64         
─────────────────────────────────────────
     5              3.0             13.0
     6              4.0             14.0
     7              5.0             15.0
     8              6.0             16.0
     9              7.0             17.0
    10              8.0             18.0

julia> dates = Date(2001, 1, 1):Day(1):Date(2001, 1, 10);
julia> df = DataFrame(Index=dates, inrchf=1:10, usdchf=1:10, eurchf=1:10, gbpchf=1:10, jpychf=1:10);
julia> ts = TSFrame(df)
10×5 TSFrame with Date Index
 Index       inrchf  usdchf  eurchf  gbpchf  jpychf 
 Date        Int64   Int64   Int64   Int64   Int64  
────────────────────────────────────────────────────
 2001-01-01       1       1       1       1       1
 2001-01-02       2       2       2       2       2
 2001-01-03       3       3       3       3       3
 2001-01-04       4       4       4       4       4
 2001-01-05       5       5       5       5       5
 2001-01-06       6       6       6       6       6
 2001-01-07       7       7       7       7       7
 2001-01-08       8       8       8       8       8
 2001-01-09       9       9       9       9       9
 2001-01-10      10      10      10      10      10

julia> function regress(ts)     # defining function for multiple regressions
            ll = lm(@formula(inrchf ~ usdchf + eurchf + gbpchf + jpychf), ts.coredata[:, Not(:Index)])
            co = coef(ll)[coefnames(ll) .== "usdchf"]
            sd = Statistics.std(residuals(ll))
            return (co, sd)
       end

julia> rollapply(ts, regress, 5; bycolumn=false)    # doing multiple regressions
6×1 TSFrame with Date Index
 Index       rolling_regress      
 Date        Tuple…               
──────────────────────────────────
 2001-01-05  ([1.0], 9.93014e-17)
 2001-01-06  ([1.0], 1.27168e-15)
 2001-01-07  ([1.0], 4.86475e-16)
 2001-01-08  ([1.0], 7.43103e-16)
 2001-01-09  ([1.0], 7.45753e-15)
 2001-01-10  ([1.0], 9.28561e-15)
```
"""
function rollapply(ts::TSFrame, fun::Function, windowsize::Int; bycolumn=true)
    if windowsize < 1
        throw(ArgumentError("windowsize must be greater than or equal to 1"))
    elseif windowsize > TSFrames.nrow(ts)
        windowsize = TSFrames.nrow(ts)
    end

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
